# 오늘의 구절

매일 성경 구절과 해당 책 설명을 제공하는 기독교 신앙생활 앱.

## 기술 스택

| 역할 | 기술 |
|------|------|
| 앱 프레임워크 | Flutter (Dart) |
| 상태 관리 | Riverpod |
| 백엔드 / DB | Firebase (Firestore, Cloud Functions, FCM, Storage) |
| AI 콘텐츠 생성 | Gemini API (`gemini-3-flash-preview`) |
| TTS | Gemini TTS (`gemini-3.1-flash-tts-preview`, Zephyr) |
| 폰트 | Google Fonts (나눔명조, Noto Sans KR) |

## 핵심 기능

- 매일 오전 10시 (Asia/Seoul) 성경 66권 중 랜덤 구절 자동 생성
- Gemini AI가 구절 낭독용 구두점 보정 + 책 설명 작성
- Gemini TTS로 음성 파일 생성 → Firebase Storage 저장
- FCM으로 전체 사용자 푸시 알림 발송
- 구절 좌우 스와이프 (PageView), 앱 진입 1초 후 TTS 자동 재생
- 다크모드 자동 연동, TTS ON/OFF + 볼륨 설정

## 데이터 플로우

```
[Cloud Scheduler 오전 10시]
        ↓
[Cloud Function]
  1. 랜덤 책/장/절 선택 (제외 목록 적용, 최대 10회 재시도)
  2. Gemini API → verse_text_tts + book_description 생성
  3. Gemini TTS → WAV 생성 → Firebase Storage 저장
  4. Firestore /daily_verses/{YYYY-MM-DD} 저장
  5. FCM daily_verse 토픽 전체 발송

[사용자 앱 실행]
  → Firestore에서 오늘 문서 읽기
  → fade + slide 애니메이션 표시
  → 1초 후 audio_url WAV 자동 재생
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
