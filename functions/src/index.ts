import { setGlobalOptions } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { TextToSpeechClient } from "@google-cloud/text-to-speech";
import { GoogleAuth } from "google-auth-library";

setGlobalOptions({ region: "asia-northeast3" });

admin.initializeApp();

const ttsClient = new TextToSpeechClient();

const BIBLE_BOOKS = [
  "창세기", "출애굽기", "레위기", "민수기", "신명기",
  "여호수아", "사사기", "룻기", "사무엘상", "사무엘하",
  "열왕기상", "열왕기하", "역대상", "역대하", "에스라",
  "느헤미야", "에스더", "욥기", "시편", "잠언",
  "전도서", "아가", "이사야", "예레미야", "예레미야애가",
  "에스겔", "다니엘", "호세아", "요엘", "아모스",
  "오바댜", "요나", "미가", "나훔", "하박국",
  "스바냐", "학개", "스가랴", "말라기",
  "마태복음", "마가복음", "누가복음", "요한복음", "사도행전",
  "로마서", "고린도전서", "고린도후서", "갈라디아서", "에베소서",
  "빌립보서", "골로새서", "데살로니가전서", "데살로니가후서",
  "디모데전서", "디모데후서", "디도서", "빌레몬서",
  "히브리서", "야고보서", "베드로전서", "베드로후서",
  "요한일서", "요한이서", "요한삼서", "유다서", "요한계시록",
];

// 각 책의 장 수 (BIBLE_BOOKS 순서와 동일)
const CHAPTER_COUNTS = [
  50, 40, 27, 36, 34,  // 창세기-신명기
  24, 21, 4, 31, 24,   // 여호수아-사무엘하
  22, 25, 29, 36, 10,  // 열왕기상-에스라
  13, 10, 42, 150, 31, // 느헤미야-잠언
  12, 8, 66, 52, 5,    // 전도서-예레미야애가
  48, 12, 14, 3, 9,    // 에스겔-아모스
  1, 4, 7, 3, 3,       // 오바댜-하박국
  3, 2, 14, 4,         // 스바냐-말라기
  28, 16, 24, 21, 28,  // 마태복음-사도행전
  16, 16, 13, 6, 6,    // 로마서-에베소서
  4, 4, 5, 3,          // 빌립보서-데살로니가후서
  6, 4, 3, 1,          // 디모데전서-빌레몬서
  13, 5, 5, 3,         // 히브리서-베드로후서
  5, 1, 1, 1, 22,      // 요한일서-요한계시록
];

interface BollsVerse {
  pk: number;
  verse: number;
  text: string;
}

async function fetchChapterVerses(bookNumber: number, chapter: number): Promise<BollsVerse[]> {
  const response = await fetch(`https://bolls.life/get-text/KRV/${bookNumber}/${chapter}/`);
  if (!response.ok) throw new Error(`bolls.life error: ${response.status}`);
  return response.json();
}

function buildGeminiPrompt(book: string, chapter: number, verse: number, verseEnd: number, verseText: string): string {
  return `
다음은 ${book} ${chapter}:${verse}-${verseEnd} 성경 구절이야 (개역한글):
"${verseText}"

두 가지를 작성해줘:
1. verse_text_tts: 위 구절을 TTS로 자연스럽게 읽도록 쉼표, 마침표, 줄바꿈 등을 적절히 추가해. 단어와 내용은 절대 변경하지 마.
2. book_description: ${book}에 대한 설명을 1. 쓰인 목적, 2. 저자의 상황, 3. 핵심 메시지 중 1~3개를 골라 한 글로 3~4문장으로 작성해. 줄바꿈을 활용해서 가독성을 좋게 해줘.

반드시 아래 JSON 형식으로만 응답해. 다른 텍스트는 포함하지 마.

{
  "verse_text_tts": "TTS용 구두점 추가본",
  "book_description": "설명..."
}
`.trim();
}

async function generateAudio(verseTts: string, bookDescription: string, today: string): Promise<string | undefined> {
  try {
    const escapeXml = (s: string) =>
      s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

    const formattedVerse = escapeXml(verseTts).replace(/\n/g, '<break time="700ms"/>');
    const ssml = `<speak>${formattedVerse}<break time="1500ms"/>${escapeXml(bookDescription)}</speak>`;

    const [ttsResponse] = await ttsClient.synthesizeSpeech({
      input: { ssml },
      voice: { languageCode: "ko-KR", name: "ko-KR-Neural2-B" },
      audioConfig: { audioEncoding: "MP3", volumeGainDb: 6.0 },
    });

    const audioContent = ttsResponse.audioContent as Buffer;
    const bucket = admin.storage().bucket();
    const audioFile = bucket.file(`daily_voice/${today}_${Date.now()}.mp3`);
    await audioFile.save(audioContent, {
      contentType: "audio/mpeg",
      metadata: { cacheControl: "no-cache, no-store" },
    });
    await audioFile.makePublic();
    return audioFile.publicUrl();
  } catch (e) {
    console.error("TTS generation failed:", e);
    return undefined;
  }
}

export const generateDailyVerse = onSchedule(
  {
    schedule: "0 10 * * *",
    timeZone: "Asia/Seoul",
    secrets: ["GEMINI_API_KEY"],
  },
  async () => {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("GEMINI_API_KEY is not set");

    // 1. 랜덤 책/장 선택
    const bookIndex = Math.floor(Math.random() * BIBLE_BOOKS.length);
    const book = BIBLE_BOOKS[bookIndex];
    const chapterCount = CHAPTER_COUNTS[bookIndex];
    const chapter = Math.floor(Math.random() * chapterCount) + 1;

    // 2. bolls.life에서 해당 장 전체 절 가져오기
    const verses = await fetchChapterVerses(bookIndex + 1, chapter);
    if (verses.length < 2) throw new Error(`Not enough verses: ${book} ${chapter}장`);

    // 3. 랜덤 연속 2절 선택
    const startIdx = Math.floor(Math.random() * (verses.length - 1));
    const v1 = verses[startIdx];
    const v2 = verses[startIdx + 1];
    const verse = v1.verse;
    const verseEnd = v2.verse;
    const verseText = `${v1.text}\n${v2.text}`;

    // 4. Gemini: TTS용 구두점 추가 + 책 설명 생성
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-3-flash-preview" });
    const result = await model.generateContent(buildGeminiPrompt(book, chapter, verse, verseEnd, verseText));
    const rawText = result.response.text().trim();
    const jsonText = rawText.replace(/^```json\n?/, "").replace(/\n?```$/, "");
    const geminiData = JSON.parse(jsonText);

    // 5. TTS 생성 (verse_text_tts 사용)
    const today = todayKey();
    const audioUrl = await generateAudio(geminiData.verse_text_tts, geminiData.book_description, today);

    // 6. Firestore 저장 (verse_text는 bolls.life 원문)
    await admin.firestore().collection("daily_verses").doc(today).set({
      book,
      chapter,
      verse,
      verse_end: verseEnd,
      verse_text: verseText,
      book_description: geminiData.book_description,
      ...(audioUrl ? { audio_url: audioUrl } : {}),
      generated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 7. FCM 발송
    await admin.messaging().send({
      topic: "daily_verse",
      notification: {
        title: `${book} ${chapter}:${verse}`,
        body: v1.text,
      },
    });
  }
);

function todayKey(): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Seoul" }).format(new Date());
}

export const stopBilling = onMessagePublished(
  { topic: "billing-alerts" },
  async (event) => {
    const data = JSON.parse(
      Buffer.from(event.data.message.data, "base64").toString()
    );

    if (data.costAmount <= data.budgetAmount) return;

    const auth = new GoogleAuth({
      scopes: ["https://www.googleapis.com/auth/cloud-billing"],
    });
    const client = await auth.getClient();
    await client.request({
      url: "https://cloudbilling.googleapis.com/v1/projects/today-verse/billingInfo",
      method: "PUT",
      data: { billingAccountName: "" },
    });

    console.log("Billing disabled — budget exceeded.");
  }
);
