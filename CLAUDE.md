# 오늘의 구절 — 프로젝트 문서

## 앱 개요

기독교 신앙생활을 돕는 모바일 앱. 매일 정해진 시간에 성경 구절과 해당 성경 책 설명을 제공한다.

- 앱 이름 (가칭): 오늘의 구절
- 타겟 플랫폼: iOS / Android (Flutter 크로스플랫폼)
- 핵심 가치: 감성적인 UX 디자인

---

## 기술 스택

| 역할 | 기술 |
|------|------|
| UI 디자인 | Figma (미적용), Flutter |
| 앱 프레임워크 | Flutter (Dart) |
| 백엔드 / DB | Firebase (Firestore, Cloud Functions, FCM, Storage) |
| AI 콘텐츠 생성 | Gemini API (gemini-3-flash-preview) |
| TTS | Google Cloud Text-to-Speech (ko-KR-Neural2-B) |
| 상태 관리 | Riverpod |
| 폰트 | Google Fonts (나눔명조, Noto Sans KR) |

---

## 핵심 기능

### 오늘의 구절
- 매일 오전 10시 Cloud Function이 자동 실행 (Cloud Scheduler, Asia/Seoul)
- 코드에서 66권 중 랜덤으로 책을 선택 → Gemini API 호출 (1회)
- Gemini가 해당 책에서 연속된 2절 선택 + 책 설명 생성
- book_description을 Google Cloud TTS로 변환 → Firebase Storage에 `daily_voice/{YYYY-MM-DD}_{timestamp}.mp3` 저장
- Firestore `/daily_verses/{YYYY-MM-DD}` 에 저장 (audio_url 포함)
- FCM `daily_verse` 토픽으로 전체 사용자에게 푸시 알림 발송
- 앱 실행 시 Firestore에서 오늘 날짜 문서 읽어 화면 표시
- 구절 영역은 좌우 스와이프로 1절씩 전환 (PageView + 페이지 인디케이터)
- 앱 진입 1초 후 TTS 자동 재생, "이 책에 대하여" 카드 열릴 때 재재생 / 닫으면 정지
- 설정 화면에서 TTS ON/OFF 가능 (shared_preferences 저장)

---

## 아키텍처

### 데이터 흐름

```
[Cloud Scheduler 오전 10시]
    → Cloud Function 실행
    → 코드에서 66권 중 랜덤 책 선택
    → Gemini API 호출 (1회)
    → Google Cloud TTS로 book_description 음성 변환 (ko-KR-Neural2-B)
    → Firebase Storage에 daily_voice/{YYYY-MM-DD}_{timestamp}.mp3 저장
    → Firestore /daily_verses/{YYYY-MM-DD} 저장 (audio_url 포함)
    → FCM topic('daily_verse') 전체 발송

[사용자 앱 실행]
    → Firestore에서 오늘 날짜 문서 읽기
    → fade + slide 애니메이션으로 화면 표시
    → 1초 후 TTS 자동 재생 (URL 기반 로컬 캐싱)
```

### Firestore 컬렉션 구조

```
/daily_verses/
  └── {YYYY-MM-DD}/
        ├── book: "열왕기하"
        ├── chapter: 5
        ├── verse: 14
        ├── verse_end: 15
        ├── verse_text: "14절 원문\n15절 원문"
        ├── book_description: "열왕기하는...\n\n..."
        ├── audio_url: "https://storage.googleapis.com/.../daily_voice%2F{YYYY-MM-DD}_{timestamp}.mp3"
        └── generated_at: Timestamp
```

### Flutter 폴더 구조 (Clean Architecture)

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── daily_verse/
│   │   ├── data/
│   │   │   ├── models/verse_model.dart
│   │   │   └── repositories/verse_repository.dart
│   │   ├── domain/
│   │   │   └── entities/verse.dart
│   │   └── presentation/
│   │       ├── screens/daily_verse_screen.dart
│   │       ├── widgets/verse_card.dart
│   │       ├── widgets/book_info_card.dart
│   │       ├── providers/verse_provider.dart
│   │       └── providers/verse_audio_provider.dart
│   └── settings/
│       └── presentation/
│           ├── screens/settings_screen.dart
│           └── providers/settings_provider.dart
├── firebase_options.dart
└── main.dart
```

---

## Gemini 프롬프트 전략

- Cloud Function 코드에서 66권 목록 중 랜덤으로 책 선택
- 선택된 책을 프롬프트에 명시하여 Gemini에 전달
- Gemini는 해당 책 안에서 연속 2절 선택 + 설명 작성

```
"{book}"에서 연속된 2절을 가져와. (개역개정판 기준)
시작 절과 바로 다음 절(시작절+1)을 선택해.
해당 성경이 어떤 책인지, 1. 쓰인 목적, 2. 저자의 상황, 3. 핵심 메시지 중
1~3개를 골라 한 글로 3~4문장으로 작성해. 줄바꿈을 활용해서 가독성을 좋게 해줘.
반드시 JSON 형식으로만 응답해.
```

---

## UX 디자인

- **배경**: 크림색 (#FAF6F0, 라이트) / 다크 (#1A1A1A)
- **포인트 컬러**: 골드 (#8B6914, 라이트) / (#D4A843, 다크)
- **타이포그래피**: 구절 → 나눔명조 serif / 본문 → Noto Sans KR
- **애니메이션**: 구절 등장 시 900ms fade + slide
- **구절 표시**: 좌우 스와이프 PageView, 1절씩 표시, 하단 골드 인디케이터 도트
- **구절 참조**: `책 장:시작절-끝절` 형식 (예: 로마서 8:28-29), 각 페이지에서 개별 절 번호 표시
- **책 설명 카드**: 탭하면 펼쳐지는 accordion 방식
- **다크모드**: 시스템 설정 자동 연동

---

## Firebase 설정

- 플랜: Blaze (예산 1KRW 한도 설정)
- 리전: asia-northeast3 (서울)
- Firestore: 테스트 모드 (출시 전 프로덕션 모드로 전환 필요)
- Storage: us-central1, 테스트 모드 / `daily_voice/` 경로에 MP3 저장
- FCM: 앱 최초 실행 시 `daily_verse` 토픽 자동 구독
- GEMINI_API_KEY: Firebase Secret Manager에 저장
- Cloud Text-to-Speech API: 활성화됨 (Neural2 무료 한도 월 100만자)

## IAM 서비스 계정 역할 (201039526104-compute@developer.gserviceaccount.com)
- Cloud 빌드 서비스 계정
- Cloud Datastore 사용자
- Firebase 클라우드 메시징 관리자
- Firebase Admin

---

## 결정 사항 및 제외된 것들

- 성경 책 목록은 Cloud Function 코드에서 관리 (Gemini 편향 방지)
- 분위기별 테마 색상 시스템 제외 (과도한 복잡도)
- 즐겨찾기/공유 기능 미구현 (추후 추가 가능)
- 사용자별 알림 시간 설정 미구현
- 중복 구절 방지 로직 미구현 (추후 필요 시 Firestore에 이력 저장)
- chapter, verse는 verse_text와 분리 저장 → `"$book $chapter:$verse-$verseEnd"` 형태로 조합
- 구절은 연속 2절로 제공, verse_text는 `\n`으로 구분하여 한 필드에 저장
- TTS 대상은 verse_text가 아닌 book_description (책 설명 낭독)
- TTS 음성 파일명에 타임스탬프 포함 (`{date}_{timestamp}.mp3`) → CDN 캐시 우회
- 앱 TTS 캐시 키: `Uri.decodeFull(audioUrl).split('/').last` (URL 기반)
- Chirp3-HD / Gemini TTS는 무료 한도 없어 제외, Neural2-B 선택
- TTS 수동 재생 버튼 없음 — 자동 재생 전용 (설정에서 ON/OFF)
