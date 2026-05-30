# 오늘 한 절

매일 성경 구절과 해당 책 설명을 제공하는 기독교 신앙생활 앱.

## 기술 스택

| 역할 | 기술 |
|------|------|
| 앱 프레임워크 | Flutter (Dart) |
| 상태 관리 | Riverpod |
| 백엔드 / DB | Firebase (Firestore, Cloud Functions, FCM, Storage) |
| 구절 원문 | bolls.life API (개역개정판) |
| AI 콘텐츠 생성 | Gemini API (`gemini-3-flash-preview`) |
| TTS | Gemini TTS (`gemini-3.1-flash-tts-preview`, Gacrux) |
| 폰트 | Google Fonts (나눔명조, Noto Sans KR, Cormorant Garamond) |

## 핵심 기능

- 매일 오전 10시 (Asia/Seoul) 푸시 알림 발송
- bolls.life API로 개역개정 원문 직접 조회 (족보·제사 장 제외, 최대 10회 재시도)
- Gemini AI가 TTS용 구두점 보정 + 책 설명 작성
- Gemini TTS(Gacrux)로 WAV 음성 생성 → Firebase Storage 저장
- 5일치 구절 버퍼 사전 생성 (당일 생성 실패 방지)
- 랜딩 화면: 대성당 일러스트 + 날짜, 탭 네비게이션
- PageView: 책 설명 ↔ 구절 본문 스와이프
- 히스토리: 최근 30일 구절 월별 그룹화
- 앱 진입 1초 후 TTS 자동 재생 (로컬 캐싱)
- 다크모드 자동 연동, TTS ON/OFF + 볼륨 설정, Fold 기기 대응

## 데이터 플로우

```
[Cloud Scheduler 오전 2시 / 오후 2시]
        ↓
[fillBuffer — Cloud Function]
  1. 코드에서 랜덤 책/장/절 선택
  2. bolls.life API → 개역개정 원문 조회
  3. Gemini API → verse_text_tts + book_description 생성
  4. Gemini TTS → WAV 생성 → Firebase Storage 저장
  5. Firestore /daily_verses/{YYYY-MM-DD} 저장

[Cloud Scheduler 오전 10시]
        ↓
[sendDailyVerse — Cloud Function]
  → FCM daily_verse 토픽 전체 발송

[사용자 앱 실행]
  → 랜딩 화면 (대성당 일러스트)
  → Firestore에서 오늘 문서 읽기
  → 700ms fade-in 애니메이션
  → 1초 후 WAV 자동 재생
```

## Firebase 설정

- 플랜: Blaze (예산 한도 설정)
- 리전: `asia-northeast3` (서울)
- Storage: `daily_voice/{YYYY-MM-DD}_{timestamp}.wav`
- FCM: 앱 최초 실행 시 `daily_verse` 토픽 자동 구독
- `GEMINI_API_KEY`: Firebase Secret Manager에 저장

## 로컬 개발

```bash
# 의존성 설치
flutter pub get

# Cloud Functions 빌드
cd functions && npm install && npm run build

# Functions 배포
firebase deploy --only functions
```
