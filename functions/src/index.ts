import { setGlobalOptions } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { TextToSpeechClient } from "@google-cloud/text-to-speech";

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

function buildPrompt(book: string): string {
  return `
"${book}"에서 연속된 2절을 가져와. (개역개정판 기준)
시작 절과 바로 다음 절(시작절+1)을 선택해.
해당 성경이 어떤 책인지, 1. 쓰인 목적, 2. 저자의 상황, 3. 핵심 메시지 중 1~3개를 골라 한 글로 3~4문장으로 작성해. 줄바꿈을 활용해서 최대한 가독성을 좋게 해줘.
반드시 아래 JSON 형식으로만 응답해. 다른 텍스트는 포함하지 마.

{
  "book": "${book}",
  "chapter": 5,
  "verse": 14,
  "verse_end": 15,
  "verse_text": "14절 원문\n15절 원문",
  "book_description": "설명..."
}
`.trim();
}

async function generateAudio(verseText: string, today: string): Promise<string | undefined> {
  try {
    const [ttsResponse] = await ttsClient.synthesizeSpeech({
      input: { text: verseText },
      voice: { languageCode: "ko-KR", name: "ko-KR-Neural2-B" },
      audioConfig: { audioEncoding: "MP3" },
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

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-3-flash-preview" });

    const randomBook = BIBLE_BOOKS[Math.floor(Math.random() * BIBLE_BOOKS.length)];
    const result = await model.generateContent(buildPrompt(randomBook));
    const text = result.response.text().trim();

    const jsonText = text.replace(/^```json\n?/, "").replace(/\n?```$/, "");
    const data = JSON.parse(jsonText);

    const today = todayKey();
    const audioUrl = await generateAudio(data.book_description, today);

    await admin.firestore().collection("daily_verses").doc(today).set({
      ...data,
      ...(audioUrl ? { audio_url: audioUrl } : {}),
      generated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.messaging().send({
      topic: "daily_verse",
      notification: {
        title: `${data.book} ${data.chapter}:${data.verse}`,
        body: data.verse_text,
      },
    });
  }
);

function todayKey(): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Seoul" }).format(new Date());
}
