import { setGlobalOptions } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";

setGlobalOptions({ region: "asia-northeast3" }); // 서울 리전

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

function buildPrompt(book: string): string {
  return `
"${book}"에서 구절 1개를 가져와. (개역개정판 기준)
해당 성경이 어떤 책인지, 1. 쓰인 목적, 2. 저자의 상황, 3. 핵심 메시지 중 1~3개를 골라 한 글로 3~4문장으로 작성해. 줄바꿈을 활용해서 최대한 가독성을 좋게 해줘.
반드시 아래 JSON 형식으로만 응답해. 다른 텍스트는 포함하지 마.

{
  "book": "${book}",
  "chapter": 5,
  "verse": 14,
  "verse_text": "구절 원문",
  "book_description": "설명..."
}
`.trim();
}

export const generateDailyVerse = onSchedule(
  {
    schedule: "0 0 * * *",
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
    await admin.firestore().collection("daily_verses").doc(today).set({
      ...data,
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
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}
