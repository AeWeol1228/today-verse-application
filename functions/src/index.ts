import { setGlobalOptions } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI, SchemaType } from "@google/generative-ai";
import { GoogleGenAI } from "@google/genai";
import { GoogleAuth } from "google-auth-library";

setGlobalOptions({ region: "asia-northeast3" });

admin.initializeApp();


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

const BIBLE_BOOKS_EN = [
  "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
  "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
  "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
  "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
  "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
  "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
  "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
  "Zephaniah", "Haggai", "Zechariah", "Malachi",
  "Matthew", "Mark", "Luke", "John", "Acts",
  "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
  "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
  "1 Timothy", "2 Timothy", "Titus", "Philemon",
  "Hebrews", "James", "1 Peter", "2 Peter",
  "1 John", "2 John", "3 John", "Jude", "Revelation",
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

// 통째로 제외할 장 목록 (족보, 제사 규례, 인구조사, 목록 등)
const EXCLUDED_CHAPTERS: Record<string, number[]> = {
  "창세기":    [5, 10, 36],
  "출애굽기":  [25, 26, 27, 28, 29, 30, 31, 36, 37, 38, 39],
  "레위기":    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
  "민수기":    [1, 2, 3, 4, 7, 26, 33],
  "에스라":    [2],
  "느헤미야":  [7, 10, 11],
  "역대상":    [1, 2, 3, 4, 5, 6, 7, 8, 9],
  "에스겔":    [40, 41, 42, 44, 45, 46, 48],
  "요한계시록": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
};

// 일부 절만 제외할 혼합 장 (제외 범위: [시작절, 끝절] 포함)
const EXCLUDED_VERSE_RANGES: Record<string, Record<number, [number, number]>> = {
  "창세기":   { 11: [10, 32] },           // 1-9 바벨탑, 10-32 셈의 족보
  "출애굽기": { 35: [4, 35], 40: [1, 33] }, // 35장: 1-3 안식일 명령만 유지 / 40장: 34-38 영광만 유지
  "마태복음": { 1: [1, 17] },             // 18-25 예수 탄생만 유지
  "누가복음": { 3: [23, 38] },            // 1-22 세례 요한·예수 세례만 유지
  "느헤미야": { 12: [1, 26] },            // 27-47 성벽 봉헌 서사만 유지
  "에스겔":   { 43: [13, 27], 47: [13, 23] }, // 43장: 1-12 영광 귀환만 유지 / 47장: 1-12 생명의 강만 유지
};

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

function getAvailableChapters(bookIndex: number): number[] {
  const book = BIBLE_BOOKS[bookIndex];
  const excluded = new Set(EXCLUDED_CHAPTERS[book] ?? []);
  const available: number[] = [];
  for (let c = 1; c <= CHAPTER_COUNTS[bookIndex]; c++) {
    if (!excluded.has(c)) available.push(c);
  }
  return available;
}

function filterExcludedVerses(book: string, chapter: number, verses: BollsVerse[]): BollsVerse[] {
  const range = EXCLUDED_VERSE_RANGES[book]?.[chapter];
  if (!range) return verses;
  const [start, end] = range;
  return verses.filter((v) => v.verse < start || v.verse > end);
}

async function selectVerses(): Promise<{ book: string; bookEn: string; chapter: number; verses: BollsVerse[] }> {
  for (let attempt = 0; attempt < 10; attempt++) {
    const bookIndex = Math.floor(Math.random() * BIBLE_BOOKS.length);
    const availableChapters = getAvailableChapters(bookIndex);
    if (availableChapters.length === 0) continue;

    const chapter = availableChapters[Math.floor(Math.random() * availableChapters.length)];
    const allVerses = await fetchChapterVerses(bookIndex + 1, chapter);
    const verses = filterExcludedVerses(BIBLE_BOOKS[bookIndex], chapter, allVerses);

    if (verses.length >= 3) return { book: BIBLE_BOOKS[bookIndex], bookEn: BIBLE_BOOKS_EN[bookIndex], chapter, verses };
  }
  throw new Error("유효한 구절 선택 실패 (10회 시도)");
}

function buildGeminiPrompt(book: string, chapter: number, verse: number, verseEnd: number, verseText: string): string {
  return `
다음은 ${book} ${chapter}:${verse}-${verseEnd} 성경 구절이야 (개역한글):
"${verseText}"

두 가지를 작성해줘:
1. verse_text_tts: 위 구절을 TTS로 자연스럽게 읽도록 쉼표, 마침표, 줄바꿈 등을 적절히 추가해. 단어와 내용은 절대 변경하지 마.
2. book_description: ${book}에 대한 설명을 1. 쓰인 목적, 2. 저자의 상황, 3. 핵심 메시지 중 1~3개를 골라 한 글로 3~4문장으로 작성해. 줄바꿈을 활용해서 가독성을 좋게 해줘.
`.trim();
}

function amplifyPcm(pcm: Buffer, gain: number): Buffer {
  const out = Buffer.alloc(pcm.length);
  for (let i = 0; i + 1 < pcm.length; i += 2) {
    const sample = pcm.readInt16LE(i);
    const amplified = Math.round(sample * gain);
    out.writeInt16LE(Math.max(-32768, Math.min(32767, amplified)), i);
  }
  return out;
}

function pcmToWav(pcm: Buffer, sampleRate = 24000, channels = 1, bitDepth = 16): Buffer {
  const byteRate = sampleRate * channels * (bitDepth / 8);
  const blockAlign = channels * (bitDepth / 8);
  const header = Buffer.alloc(44);
  header.write("RIFF", 0);
  header.writeUInt32LE(36 + pcm.length, 4);
  header.write("WAVE", 8);
  header.write("fmt ", 12);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(channels, 22);
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(byteRate, 28);
  header.writeUInt16LE(blockAlign, 32);
  header.writeUInt16LE(bitDepth, 34);
  header.write("data", 36);
  header.writeUInt32LE(pcm.length, 40);
  return Buffer.concat([header, pcm]);
}

async function generateSingleAudio(apiKey: string, text: string, filename: string, stylePrompt: string): Promise<string | undefined> {
  const ai = new GoogleGenAI({ apiKey });
  const prompt = `${stylePrompt}\n\n${text}`;

  const attemptTts = () => {
    const ttsCall = ai.models.generateContent({
      model: "gemini-3.1-flash-tts-preview",
      contents: [{ parts: [{ text: prompt }] }],
      config: {
        responseModalities: ["AUDIO"],
        speechConfig: {
          voiceConfig: {
            prebuiltVoiceConfig: { voiceName: "Gacrux" },
          },
        },
      },
    });
    const timeout = new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error(`TTS timeout (${filename})`)), 90_000)
    );
    return Promise.race([ttsCall, timeout]);
  };

  const retryDelays = [30_000]; // 2회 시도 (1차 + 재시도 1회)
  let lastError: unknown;
  for (let attempt = 0; attempt <= retryDelays.length; attempt++) {
    try {
      const response = await attemptTts();
      const audioData = response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
      if (!audioData) {
        const reason = response.candidates?.[0]?.finishReason;
        throw new Error(`No audio data (finishReason: ${reason})`);
      }
      const wavBuffer = pcmToWav(amplifyPcm(Buffer.from(audioData, "base64"), 1.5));
      const bucket = admin.storage().bucket();
      const audioFile = bucket.file(`daily_voice/${filename}.wav`);
      await audioFile.save(wavBuffer, {
        contentType: "audio/wav",
        metadata: { cacheControl: "no-cache, no-store" },
      });
      await audioFile.makePublic();
      return audioFile.publicUrl();
    } catch (e) {
      lastError = e;
      if (attempt < retryDelays.length) {
        const delay = retryDelays[attempt];
        console.warn(`TTS ${attempt + 1}차 실패, ${delay / 1000}초 후 재시도 (${filename}):`, e);
        await new Promise(r => setTimeout(r, delay));
      }
    }
  }
  console.error(`TTS 최종 실패 (${filename}):`, lastError);
  return undefined;
}

const STYLE_VERSE =
  '자연스럽고 따뜻하게, 일상 대화처럼 읽어주세요. 보통 속도로 읽어주세요.';

const STYLE_DESCRIPTION =
  '자연스럽고 따뜻하게 읽어주세요. 속도는 아주 빠르게 읽어주세요. 문장이 끝날 때마다 충분히 쉬어가며 읽어주세요.';

async function generateAudio(apiKey: string, verseTts: string, bookDescription: string, today: string): Promise<{ audioUrlVerse?: string; audioUrlDescription?: string }> {
  const ts = Date.now();
  const [audioUrlVerse, audioUrlDescription] = await Promise.all([
    generateSingleAudio(apiKey, verseTts, `${today}_${ts}_verse`, STYLE_VERSE),
    generateSingleAudio(apiKey, bookDescription, `${today}_${ts}_desc`, STYLE_DESCRIPTION),
  ]);
  return { audioUrlVerse, audioUrlDescription };
}

function dateKey(daysAhead = 0): string {
  const d = new Date(Date.now() + daysAhead * 24 * 60 * 60 * 1000);
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Seoul" }).format(d);
}

async function generateForDate(apiKey: string, date: string): Promise<void> {
  const { book, bookEn, chapter, verses } = await selectVerses();
  const startIdx = Math.floor(Math.random() * (verses.length - 2));
  const v1 = verses[startIdx];
  const v2 = verses[startIdx + 1];
  const v3 = verses[startIdx + 2];
  const verse = v1.verse;
  const verseEnd = v3.verse;
  const verseText = `${v1.text}\n${v2.text}\n${v3.text}`;

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: "gemini-3-flash-preview",
    generationConfig: {
      responseMimeType: "application/json",
      responseSchema: {
        type: SchemaType.OBJECT,
        properties: {
          verse_text_tts: { type: SchemaType.STRING },
          book_description: { type: SchemaType.STRING },
        },
        required: ["verse_text_tts", "book_description"],
      },
    },
  });
  const attemptGemini = () => Promise.race([
    model.generateContent(buildGeminiPrompt(book, chapter, verse, verseEnd, verseText)),
    new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error("Gemini content timeout")), 60_000)
    ),
  ]);
  let result;
  try {
    result = await attemptGemini();
  } catch (e1) {
    console.warn(`${date}: Gemini 1차 실패, 10초 후 재시도:`, e1);
    await new Promise(r => setTimeout(r, 10_000));
    result = await attemptGemini();
  }
  const geminiData = JSON.parse(result.response.text());

  const { audioUrlVerse, audioUrlDescription } = await generateAudio(
    apiKey, geminiData.verse_text_tts, geminiData.book_description, date
  );

  await admin.firestore().collection("daily_verses").doc(date).set({
    book,
    book_en: bookEn,
    chapter,
    verse,
    verse_end: verseEnd,
    verse_text: verseText,
    verse_text_tts: geminiData.verse_text_tts,
    book_description: geminiData.book_description.replace(/\\n/g, '\n'),
    ...(audioUrlVerse       ? { audio_url_verse: audioUrlVerse }             : {}),
    ...(audioUrlDescription ? { audio_url_description: audioUrlDescription } : {}),
    generated_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`${date}: 생성 완료 (TTS verse=${!!audioUrlVerse}, desc=${!!audioUrlDescription})`);
}

async function regenerateTTSForDate(apiKey: string, data: FirebaseFirestore.DocumentData, date: string): Promise<void> {
  const verseTts = data.verse_text_tts ?? data.verse_text;
  const { audioUrlVerse, audioUrlDescription } = await generateAudio(
    apiKey, verseTts, data.book_description, date
  );
  const updateData = {
    ...(audioUrlVerse       ? { audio_url_verse: audioUrlVerse }             : {}),
    ...(audioUrlDescription ? { audio_url_description: audioUrlDescription } : {}),
  };
  if (Object.keys(updateData).length === 0) {
    console.error(`${date}: TTS 재생성 실패 — Gemini TTS 서버 에러`);
    return;
  }
  await admin.firestore().collection("daily_verses").doc(date).update(updateData);
  console.log(`${date}: TTS 재생성 완료`);
}

// 오전 2시 / 오후 2시 — 5일치 버퍼 유지
export const fillBuffer = onSchedule(
  {
    schedule: "0 2,14 * * *",
    timeZone: "Asia/Seoul",
    secrets: ["GEMINI_API_KEY"],
    timeoutSeconds: 540,
  },
  async () => {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("GEMINI_API_KEY is not set");

    for (let i = 0; i < 5; i++) {
      const date = dateKey(i);
      try {
        const docSnap = await admin.firestore().collection("daily_verses").doc(date).get();
        const data = docSnap.data();

        if (docSnap.exists && data?.audio_url_verse && data?.audio_url_description) {
          console.log(`${date}: 완료, 스킵`);
          continue;
        }

        if (docSnap.exists && data?.verse_text) {
          console.log(`${date}: 구절 있음, TTS 재생성`);
          await regenerateTTSForDate(apiKey, data, date);
        } else {
          console.log(`${date}: 신규 생성`);
          await generateForDate(apiKey, date);
        }
      } catch (e) {
        console.error(`${date}: 생성 실패 — 다음 실행에서 재시도`, e);
      }

      if (i < 4) await new Promise(r => setTimeout(r, 30_000)); // 날짜 간 30초 대기
    }
  }
);

// 오전 10시 — FCM 발송만
export const sendDailyVerse = onSchedule(
  {
    schedule: "0 10 * * *",
    timeZone: "Asia/Seoul",
    timeoutSeconds: 60,
  },
  async () => {
    const today = dateKey(0);
    const doc = await admin.firestore().collection("daily_verses").doc(today).get();
    if (!doc.exists) {
      console.error(`오늘(${today}) 문서 없음 — 버퍼 소진`);
      return;
    }
    await admin.messaging().send({
      topic: "daily_verse",
      notification: {
        title: "오늘의 구절이 도착했습니다",
        body: "앱을 열어 오늘의 말씀을 확인하세요",
      },
      data: { type: "daily_verse", date: today },
    });
    console.log(`FCM 발송 완료: ${today}`);
  }
);

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
