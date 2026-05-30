# 오늘 한 절 — 프로젝트 문서

## 앱 개요

기독교 신앙생활을 돕는 모바일 앱. 매일 성경 구절과 해당 책 설명을 제공한다.

- 앱 이름: 오늘 한 절 (패키지명: today_verse, v1.0.1+4)
- 타겟 플랫폼: iOS / Android (Flutter 크로스플랫폼)
- 핵심 가치: 감성적인 UX 디자인

---

## 기술 스택

| 역할 | 기술 |
|------|------|
| 앱 프레임워크 | Flutter (Dart) |
| 백엔드 / DB | Firebase (Firestore, Cloud Functions, FCM, Storage) |
| AI 콘텐츠 생성 | Gemini API (`gemini-3-flash-preview`) |
| TTS | Gemini TTS (`gemini-3.1-flash-tts-preview`, voice: Gacrux) |
| 상태 관리 | Riverpod |
| 폰트 | Google Fonts (나눔명조, Noto Sans KR, Cormorant Garamond) |
| 구절 원문 | bolls.life API (개역개정판) |

---

## 핵심 기능

### 구절 생성 파이프라인 (Cloud Functions)
- **fillBuffer** (오전 2시 & 오후 2시, Asia/Seoul): 5일치 구절 버퍼 유지
  - 코드의 66권 목록 + CHAPTER_COUNTS에서 랜덤 책/장 선택 (족보·제사 장 제외)
  - bolls.life API로 개역개정 원문 조회 (최대 10회 재시도)
  - Gemini API 호출: verse_text_tts(구두점 보정) + book_description 생성
  - Gemini TTS → WAV 생성 → Firebase Storage `daily_voice/{YYYY-MM-DD}_{timestamp}.wav`
  - Firestore `/daily_verses/{YYYY-MM-DD}` 저장
- **sendDailyVerse** (오전 10시, Asia/Seoul): FCM `daily_verse` 토픽 전체 발송만 담당

### 앱 동작
- 앱 실행 시 랜딩 화면(대성당 일러스트 + 날짜) → 탭 네비게이션으로 구절/히스토리/설정 이동
- Firestore에서 오늘 날짜 문서 읽기 (오늘 없으면 어제 문서 fallback)
- 700ms fade-in 애니메이션으로 화면 표시
- 1초 후 TTS 자동 재생 (audio_url 기반 로컬 캐싱)
- PageView: 첫 페이지(책 설명) ↔ 두 번째 페이지(구절 본문)
- 히스토리 화면: 최근 30일 구절 월별 그룹화, 탭하면 해당 날짜 구절 진입
- 설정: TTS ON/OFF + 볼륨 슬라이더, 라이트/다크/시스템 테마 선택

---

## 아키텍처

### 데이터 흐름

```
[Cloud Scheduler 오전 2시 / 오후 2시]
    → fillBuffer 실행
    → 코드에서 랜덤 책/장/절 선택 (bolls.life API로 원문 조회, 10회 재시도)
    → Gemini API: verse_text_tts + book_description 생성
    → Gemini TTS (Gacrux): WAV 생성 (PCM 24kHz 16-bit mono, 1.5배 증폭)
    → Firebase Storage: daily_voice/{YYYY-MM-DD}_{timestamp}.wav
    → Firestore: /daily_verses/{YYYY-MM-DD}

[Cloud Scheduler 오전 10시]
    → sendDailyVerse 실행
    → FCM topic('daily_verse') 전체 발송

[사용자 앱 실행]
    → 랜딩 화면 (main_screen: 대성당 일러스트 + 날짜)
    → Firestore에서 오늘 문서 읽기 (fallback: 어제)
    → 700ms fade-in 애니메이션
    → 1초 후 audio_url WAV 자동 재생 (로컬 캐싱)
```

### Firestore 컬렉션 구조

```
/daily_verses/
  └── {YYYY-MM-DD}/
        ├── book: "열왕기하"
        ├── book_en: "2 Kings"
        ├── chapter: 5
        ├── verse: 14
        ├── verse_end: 15
        ├── verse_text: "14절 원문\n15절 원문"
        ├── verse_text_tts: "14절 구두점 보정본\n15절 구두점 보정본"
        ├── book_description: "열왕기하는...\n\n..."
        ├── audio_url: "https://storage.googleapis.com/.../daily_voice%2F{date}_{timestamp}.wav"
        └── generated_at: Timestamp
```

### Flutter 폴더 구조 (Clean Architecture)

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart           # AppColors, TVTheme extension, AppTheme
│   └── widgets/
│       ├── app_symbol.dart          # 아치+십자가 벡터 아이콘 (CustomPainter)
│       ├── cathedral_painter.dart   # 대성당 스티플 일러스트 (절차적 생성, Mulberry32 PRNG)
│       └── top_bar.dart             # TVTopBar, TVGhostButton, TTSPill, TVPageDots
├── features/
│   ├── daily_verse/
│   │   ├── data/
│   │   │   ├── models/verse_model.dart          # VerseModel, fromFirestore()
│   │   │   └── repositories/verse_repository.dart  # getTodayVerse, getRecentVerses(30)
│   │   ├── domain/
│   │   │   └── entities/verse.dart              # Verse 엔티티
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── verse_provider.dart          # todayVerseProvider, historyVersesProvider
│   │       │   └── verse_audio_provider.dart    # VerseAudioNotifier (just_audio 기반)
│   │       ├── screens/
│   │       │   ├── main_screen.dart             # 랜딩 화면 (대성당 + 탭 네비게이션)
│   │       │   ├── daily_verse_screen.dart      # 구절 경험 (2-page PageView)
│   │       │   └── history_screen.dart          # 히스토리 (월별 그룹화)
│   │       └── widgets/
│   │           ├── verse_card.dart              # 구절 본문 페이지
│   │           └── book_info_card.dart          # 책 설명 페이지
│   └── settings/
│       └── presentation/
│           ├── providers/settings_provider.dart # TTS ON/OFF, 볼륨, 테마
│           └── screens/settings_screen.dart
├── firebase_options.dart            # FlutterFire CLI 자동 생성
└── main.dart                        # Firebase 초기화, FCM 핸들러, ProviderScope
```

---

## Gemini 역할 분담

구절 선택은 코드(bolls.life API)가 담당. Gemini는 두 가지만 처리:

1. **verse_text_tts**: 원문에 구두점 보정 (TTS 낭독용)
2. **book_description**: 해당 책 소개 (쓰인 목적/저자 상황/핵심 메시지 중 1~3개, 3~4문장)

```
응답 스키마 (JSON):
{
  "verse_text_tts": "구두점이 보정된 구절 전문",
  "book_description": "책 소개 3~4문장"
}
```

---

## UX 디자인

- **배경**: 크림색 (#FAF6F0, 라이트) / 다크 (#1A1A1A)
- **포인트 컬러**: 골드 (#8B6914, 라이트) / (#D4A843, 다크)
- **타이포그래피**: 구절 → 나눔명조 serif / 책 설명 본문 → Noto Sans KR / 영문 → Cormorant Garamond
- **애니메이션**: 구절 등장 시 700ms fade-in
- **구절 표시**: 좌우 스와이프 PageView (책 설명 ↔ 구절 본문), 하단 골드 인디케이터 도트
- **구절 참조**: `책 장:시작절-끝절` 형식 (예: 로마서 8:28-29), 각 페이지에서 개별 절 번호 표시
- **책 설명 카드**: PageView 첫 번째 페이지 (나눔명조 42px 책명, Cormorant 20px 영문명, Noto Sans KR 16px 본문)
- **랜딩 화면**: 대성당 스티플 일러스트, 날짜/시간 헤더, 앱 제목 (오늘 한 절 / Today's Verse)
- **Fold 대응**: 600px 기준으로 normal/fold 레이아웃 자동 분기
- **다크모드**: 시스템 설정 자동 연동 (설정에서 강제 변경 가능)

---

## Firebase 설정

- 플랜: Blaze (예산 한도 설정)
- 리전: asia-northeast3 (서울)
- Firestore: 테스트 모드 (출시 전 프로덕션 모드로 전환 필요)
- Storage: us-central1, `daily_voice/` 경로에 WAV 저장
- FCM: 앱 최초 실행 시 `daily_verse` 토픽 자동 구독
- GEMINI_API_KEY: Firebase Secret Manager에 저장

## IAM 서비스 계정 역할 (201039526104-compute@developer.gserviceaccount.com)
- Cloud 빌드 서비스 계정
- Cloud Datastore 사용자
- Firebase 클라우드 메시징 관리자
- Firebase Admin

---

## 결정 사항 및 제외된 것들

- 구절 선택은 bolls.life API + 코드 제외 목록으로 완전 제어 (Gemini 편향 방지)
- EXCLUDED_CHAPTERS: 족보·제사 규례 등 낭독에 부적합한 장 제외
- EXCLUDED_VERSE_RANGES: 혼합 장에서 특정 절 범위만 제외
- 구절 버퍼 시스템: fillBuffer가 5일치 미리 생성 (당일 생성 실패 방지)
- 분위기별 테마 색상 시스템 제외 (과도한 복잡도)
- 즐겨찾기/공유 기능 미구현 (추후 추가 가능)
- 사용자별 알림 시간 설정 미구현
- 중복 구절 방지 로직 미구현 (추후 필요 시 Firestore에 이력 저장)
- chapter, verse는 verse_text와 분리 저장 → `"$book $chapter:$verse-$verseEnd"` 형태로 조합
- 구절은 연속 2절로 제공, verse_text는 `\n`으로 구분하여 한 필드에 저장
- TTS 대상: verse_text_tts (구두점 보정본) + book_description 낭독
- TTS 음성 파일명에 타임스탬프 포함 (`{date}_{timestamp}.wav`) → CDN 캐시 우회
- 앱 TTS 캐시 키: `Uri.decodeFull(audioUrl).split('/').last` (URL 기반)
- Google Cloud TTS Neural2-B → Gemini TTS (Gacrux)로 교체 (2026-05-06). Preview 기간 무료
- 오디오 포맷 MP3 → WAV (PCM 24kHz 16-bit mono에 WAV 헤더 직접 생성, 1.5배 증폭)
- TTS 스타일: "자연스럽고 따뜻하게, 일상 대화처럼" — 전통적 성경 낭독 투 지양
- TTS 수동 재생 버튼 없음 — 자동 재생 전용 (설정에서 ON/OFF + 볼륨 슬라이더, SharedPreferences key: `tts_volume`)
- FCM 백그라운드 핸들러에 `@pragma('vm:entry-point')` 필수 — 릴리즈 빌드 R8 난독화로 함수명 소실 방지
- 미사용 의존성 (firebase_auth, google_generative_ai, url_launcher): 정식 배포 후 정리 예정
