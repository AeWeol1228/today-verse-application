// TTS 보이스 × 억양 조합 테스트
// 실행: GEMINI_API_KEY=your_key node functions/test-tts/run.js
// 또는:  node functions/test-tts/run.js (GEMINI_API_KEY 환경변수 설정된 경우)

const { GoogleGenAI } = require("../node_modules/@google/genai");
const fs = require("fs");
const path = require("path");

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY) {
  console.error("GEMINI_API_KEY 환경변수를 설정해주세요.");
  process.exit(1);
}

const VOICES = ["Gacrux", "Aoede", "Sulafat"];
const ACCENTS = ["서울", "경상도", "충청도", "전라도", "강원도"];

// dadada.txt에서 book_description 랜덤 추출
function loadSampleFromDadada() {
  const filePath = path.join(__dirname, "../../dadada.txt");
  const raw = fs.readFileSync(filePath, "utf8");
  const descriptions = [...raw.matchAll(/"([^"]+)"/g)].map(m => m[1].trim()).filter(d => d.length > 30);
  if (descriptions.length === 0) throw new Error("dadada.txt에서 텍스트를 찾을 수 없습니다.");
  return descriptions[Math.floor(Math.random() * descriptions.length)];
}

const SAMPLE_VERSE = loadSampleFromDadada();
const SAMPLE_BIBLE = "여호와는 나의 목자시니 내게 부족함이 없으리로다.\n그가 나를 푸른 풀밭에 누이시며 쉴 만한 물 가로 인도하시는도다.";
console.log(`샘플 텍스트:\n"${SAMPLE_VERSE}"\n`);

const OUT_DIR = path.join(__dirname, "output");
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR);

function pcmToWav(pcm, sampleRate = 24000, channels = 1, bitDepth = 16) {
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

async function generate(voice, accent, style = "desc") {
  const ai = new GoogleGenAI({ apiKey: API_KEY });
  const stylePrompt = style === "verse"
    ? `자연스럽고 따뜻하게, 일상 대화처럼 읽어주세요. 보통 속도로 읽어주세요. ${accent} 억양으로 읽어주세요.`
    : `자연스럽고 따뜻하게 읽어주세요. 글의 리듬감을 살려서 읽어주세요. 문장이 끝날 때마다 충분히 쉬어가며 읽어주세요. ${accent} 억양으로 읽어주세요.`;
  const text = style === "verse" ? SAMPLE_BIBLE : SAMPLE_VERSE;
  const prompt = `${stylePrompt}\n\n${text}`;

  const response = await ai.models.generateContent({
    model: "gemini-3.1-flash-tts-preview",
    contents: [{ parts: [{ text: prompt }] }],
    config: {
      responseModalities: ["AUDIO"],
      speechConfig: {
        voiceConfig: {
          prebuiltVoiceConfig: { voiceName: voice },
        },
      },
    },
  });

  const audioData = response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
  if (!audioData) throw new Error(`No audio data (voice: ${voice}, accent: ${accent})`);

  const wav = pcmToWav(Buffer.from(audioData, "base64"));
  const filename = `${voice}_${accent}_${style}.wav`;
  fs.writeFileSync(path.join(OUT_DIR, filename), wav);
  return filename;
}

async function main() {
  // 전체 15개 조합 중 각 보이스당 서울 억양 먼저 테스트 (3개)
  // 전체를 원하면 아래 combinations를 교체
  const combinations = ["경상도", "충청도", "전라도"].map(a => ({ voice: "Aoede", accent: a, style: "verse" }));
  // 억양 5개 (설명): const combinations = ACCENTS.map(a => ({ voice: "Aoede", accent: a }));
  // 전체 테스트: const combinations = VOICES.flatMap(v => ACCENTS.map(a => ({ voice: v, accent: a })));
  // 보이스 비교: const combinations = VOICES.map(v => ({ voice: v, accent: "서울" }));

  console.log(`총 ${combinations.length}개 생성 시작...\n`);

  for (const { voice, accent, style = "desc" } of combinations) {
    process.stdout.write(`  ${voice} × ${accent} × ${style} ... `);
    try {
      const filename = await generate(voice, accent, style);
      console.log(`완료 → output/${filename}`);
    } catch (e) {
      console.log(`실패: ${e.message}`);
    }
  }

  console.log(`\n완료. output/ 폴더에서 파일을 확인하세요.`);
  console.log(`전체 15개 테스트는 스크립트 내 combinations 주석을 교체하세요.`);
}

main().catch(console.error);
