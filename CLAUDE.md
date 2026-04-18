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
| 백엔드 / DB | Firebase (Firestore, Cloud Functions, FCM) |
| AI 콘텐츠 생성 | Gemini API (gemini-3-flash-preview) |
| 상태 관리 | Riverpod |
| 폰트 | Google Fonts (나눔명조, Noto Sans KR) |

---

## 핵심 기능

### 오늘의 구절
- 매일 자정 Cloud Function이 자동 실행 (Cloud Scheduler, Asia/Seoul)
- 코드에서 66권 중 랜덤으로 책을 선택 → Gemini API 호출 (1회)
- Gemini가 해당 책에서 구절 선택 + 책 설명 생성
- Firestore `/daily_verses/{YYYY-MM-DD}` 에 저장
- FCM `daily_verse` 토픽으로 전체 사용자에게 푸시 알림 발송
- 앱 실행 시 Firestore에서 오늘 날짜 문서 읽어 화면 표시

---

## 아키텍처

### 데이터 흐름

```
[Cloud Scheduler 자정]
    → Cloud Function 실행
    → 코드에서 66권 중 랜덤 책 선택
    → Gemini API 호출 (1회)
    → Firestore /daily_verses/{YYYY-MM-DD} 저장
    → FCM topic('daily_verse') 전체 발송

[사용자 앱 실행]
    → Firestore에서 오늘 날짜 문서 읽기
    → fade + slide 애니메이션으로 화면 표시
```

### Firestore 컬렉션 구조

```
/daily_verses/
  └── {YYYY-MM-DD}/
        ├── book: "열왕기하"
        ├── chapter: 5
        ├── verse: 14
        ├── verse_text: "나아만이 이에 내려가서..."
        ├── book_description: "열왕기하는...\n\n..."
        └── generated_at: Timestamp
```

### Flutter 폴더 구조 (Clean Architecture)

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart      # 라이트/다크 테마, 나눔명조 폰트
├── features/
│   └── daily_verse/
│       ├── data/
│       │   ├── models/verse_model.dart
│       │   └── repositories/verse_repository.dart
│       ├── domain/
│       │   └── entities/verse.dart
│       └── presentation/
│           ├── screens/daily_verse_screen.dart
│           ├── widgets/verse_card.dart
│           ├── widgets/book_info_card.dart
│           └── providers/verse_provider.dart
├── firebase_options.dart
└── main.dart
```

---

## Gemini 프롬프트 전략

- Cloud Function 코드에서 66권 목록 중 랜덤으로 책 선택
- 선택된 책을 프롬프트에 명시하여 Gemini에 전달
- Gemini는 해당 책 안에서 구절 선택 + 설명 작성

```
"{book}"에서 구절 1개를 가져와. (개역개정판 기준)
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
- **책 설명 카드**: 탭하면 펼쳐지는 accordion 방식
- **다크모드**: 시스템 설정 자동 연동

---

## Firebase 설정

- 플랜: Blaze (예산 1KRW 한도 설정)
- 리전: asia-northeast3 (서울)
- Firestore: 테스트 모드 (출시 전 프로덕션 모드로 전환 필요)
- FCM: 앱 최초 실행 시 `daily_verse` 토픽 자동 구독
- GEMINI_API_KEY: Firebase Secret Manager에 저장

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
- chapter, verse는 verse_text와 분리 저장 → `"$book $chapter:$verse"` 형태로 조합
