/* global React, I */
// 오늘의 구절 — Screens
// Each screen is a self-contained component that fills its parent (the iOS frame's content slot).
// Data is hard-coded to a realistic example day.

const { useState } = React;

// ─── Today's data ─────────────────────────────────────────────
const TODAY = {
  date: '2026년 5월 16일 토요일',
  dateShort: 'SAT · MAY 16',
  book: '로마서',
  bookEn: 'Romans',
  chapter: 8,
  verses: [28, 29],
  ref: '8:28–29',
  background: [
    '로마서는 사도 바울이 아직 가본 적 없는 로마 교회에 보낸 편지입니다. 유대인과 이방인이 함께 모인 이 공동체에 그는 복음의 뿌리를 차근차근 설명하려 했습니다.',
    '8장은 편지의 정점입니다. 율법 아래 신음하던 사람들에게 성령 안에서 누리는 자유를 선포하고, 고난 가운데서도 흔들리지 않는 소망의 근거를 보여 줍니다.',
    '오늘 읽는 28–29절은 그 흐름의 한가운데에 놓여 있습니다. 모든 일이 합력하여 선을 이룬다는 약속과, 그 선의 모습이 다름 아닌 아들의 형상을 닮아가는 것임을 밝혀 줍니다.',
  ],
  verseLines: [
    { n: 28, text: '우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라.' },
    { n: 29, text: '하나님이 미리 아신 자들을 또한 그 아들의 형상을 본받게 하기 위하여 미리 정하셨으니 이는 그로 많은 형제 중에서 맏아들이 되게 하려 하심이니라.' },
  ],
};

const HISTORY = [
  { month: '5월', monthEn: 'May 2026', items: [
    { day: 16, dow: 'SAT', book: '로마서', ref: '8:28–29', today: true },
    { day: 15, dow: 'FRI', book: '로마서', ref: '8:18–25' },
    { day: 14, dow: 'THU', book: '로마서', ref: '8:1–11' },
    { day: 13, dow: 'WED', book: '시편', ref: '23:1–6' },
    { day: 12, dow: 'TUE', book: '시편', ref: '139:1–10' },
    { day: 11, dow: 'MON', book: '잠언', ref: '3:5–8' },
    { day: 10, dow: 'SUN', book: '마태복음', ref: '6:25–34' },
  ]},
  { month: '4월', monthEn: 'April 2026', items: [
    { day: 30, dow: 'WED', book: '마태복음', ref: '5:1–12' },
    { day: 29, dow: 'TUE', book: '이사야', ref: '40:28–31' },
    { day: 28, dow: 'MON', book: '이사야', ref: '53:3–6' },
  ]},
];

// ─── Reusable atoms ───────────────────────────────────────────
function Waveform({ progress = 0.34, n = 36 }) {
  // deterministic pseudo-random bars
  const bars = [];
  for (let i = 0; i < n; i++) {
    const a = Math.sin(i * 1.7) * 0.5 + 0.5;
    const b = Math.sin(i * 0.7 + 1.3) * 0.5 + 0.5;
    const h = 6 + (a * 0.6 + b * 0.4) * 18;
    const played = i / n < progress;
    bars.push(<i key={i} className={played ? 'played' : ''} style={{ height: h }} />);
  }
  return <div className="player-wave">{bars}</div>;
}

function Player({ label = 'TTS · 구절 읽기', current = '0:42', total = '1:58', playing = true, progress = 0.34 }) {
  return (
    <div className="player">
      <button className="player-btn">
        {playing ? <I.Pause /> : <I.Play />}
      </button>
      <Waveform progress={progress} />
      <div className="player-meta" style={{ alignItems: 'flex-end' }}>
        <div className="player-label">{label}</div>
        <div className="player-time">{current} / {total}</div>
      </div>
    </div>
  );
}

// ─── Screen: Main ─────────────────────────────────────────────
function MainScreen() {
  return (
    <div className="app">
      <div className="topbar">
        <div className="topbar-brand">
          <span className="topbar-brand-dot" />
          오늘의 구절
        </div>
        <button className="topbar-iconbtn" aria-label="설정">
          <I.Settings />
        </button>
      </div>

      <div className="app-scroll">
        <div className="hero">
          <div className="hero-date">{TODAY.dateShort}</div>
          <div className="hero-greet">조용한 아침,<br/>한 구절을 마주합니다.</div>
        </div>

        <div className="today-card">
          <div className="today-card-head">
            <span className="today-tag">
              <span className="today-tag-dot" />
              오늘의 구절
            </span>
            <span className="today-ref">{TODAY.book} {TODAY.ref}</span>
          </div>
          <div className="today-book">{TODAY.book} {TODAY.chapter}장</div>
          <div className="today-preview">"{TODAY.verseLines[0].text}"</div>
          <div className="today-cta">
            지금 묵상하기
            <I.ChevronRight />
          </div>
        </div>

        <div className="quicknav">
          <div className="quicknav-tile">
            <div className="quicknav-tile-icon"><I.History /></div>
            <div className="quicknav-tile-label">히스토리</div>
            <div className="quicknav-tile-hint">지난 구절 다시 보기</div>
          </div>
          <div className="quicknav-tile">
            <div className="quicknav-tile-icon"><I.Settings /></div>
            <div className="quicknav-tile-label">설정</div>
            <div className="quicknav-tile-hint">음성 · 화면 · 후원</div>
          </div>
        </div>

        <div className="streak">
          <div>
            <div className="streak-num">23<span style={{ color: 'var(--color-label-alternative)', fontSize: 18, fontWeight: 500 }}> 일</span></div>
            <div className="streak-label">CONNECTED · 5월</div>
          </div>
          <div className="streak-dots" aria-label="이번 주 묵상">
            <span className="streak-dot on" />
            <span className="streak-dot on" />
            <span className="streak-dot on" />
            <span className="streak-dot on" />
            <span className="streak-dot on" />
            <span className="streak-dot today" />
            <span className="streak-dot" />
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Screen: Verse experience (Book background sub-page) ─────
function VerseBookScreen() {
  return (
    <div className="app">
      <div className="topbar">
        <button className="topbar-iconbtn" aria-label="뒤로"><I.Back /></button>
        <div className="subhead-title">{TODAY.book} {TODAY.chapter}장</div>
        <button className="topbar-iconbtn" aria-label="설정"><I.Settings /></button>
      </div>

      <div className="verse-pageindicator" aria-label="페이지">
        <span className="on" style={{ width: 24 }} />
        <span style={{ width: 12 }} />
      </div>

      <div className="verse-body">
        <div className="verse-eyebrow">BOOK BACKGROUND · 책 배경</div>
        <div className="verse-book-title">{TODAY.book}</div>
        <div className="verse-book-meta">{TODAY.bookEn} · 사도 바울 · 신약 6번째 책</div>
        <div className="verse-book-rule" />
        <div className="verse-book-body">
          {TODAY.background.map((p, i) => <p key={i}>{p}</p>)}
          <p style={{ color: 'var(--color-label-alternative)', fontSize: 15, lineHeight: '24px' }}>
            오른쪽으로 넘기면 오늘의 구절이 이어집니다.
          </p>
        </div>
      </div>

      <Player label="TTS · 책 배경" current="0:38" total="1:24" playing={true} progress={0.45} />
    </div>
  );
}

// ─── Screen: Verse experience (Verse text sub-page) ──────────
function VerseTextScreen() {
  return (
    <div className="app">
      <div className="topbar">
        <button className="topbar-iconbtn" aria-label="뒤로"><I.Back /></button>
        <div className="subhead-title">{TODAY.book} {TODAY.ref}</div>
        <button className="topbar-iconbtn" aria-label="설정"><I.Settings /></button>
      </div>

      <div className="verse-pageindicator" aria-label="페이지">
        <span style={{ width: 12 }} />
        <span className="on" style={{ width: 24 }} />
      </div>

      <div className="verse-body">
        <div className="verse-eyebrow">TODAY'S VERSE · 오늘의 구절</div>
        <div className="verse-ref-line">
          <span className="verse-ref-pill">{TODAY.book.toUpperCase()} {TODAY.ref}</span>
          <span style={{ fontSize: 12, color: 'var(--color-label-assistive)', letterSpacing: '0.04em' }}>개역개정</span>
        </div>

        <div className="verse-text">
          {TODAY.verseLines.map((line) => (
            <span key={line.n}>
              <span className="vnum">{line.n}</span>
              {line.text}
              {' '}
            </span>
          ))}
        </div>

        <div style={{
          paddingTop: 20,
          borderTop: '1px solid var(--color-line-neutral)',
          color: 'var(--color-label-alternative)',
          font: 'var(--weight-regular) 13px/22px var(--font-sans)',
          letterSpacing: 0.01,
          paddingBottom: 8,
        }}>
          잠시 멈춰서, 한 절을 천천히 다시 읽어 봅니다.<br/>
          오늘 이 말씀이 나에게 어떤 모양으로 다가오는지.
        </div>
      </div>

      <Player label="TTS · 구절" current="0:14" total="0:52" playing={true} progress={0.27} />
    </div>
  );
}

// ─── Screen: History ─────────────────────────────────────────
function HistoryScreen() {
  return (
    <div className="app">
      <div className="topbar">
        <button className="topbar-iconbtn" aria-label="뒤로"><I.Back /></button>
        <div className="subhead-title">히스토리</div>
        <button className="topbar-iconbtn" aria-label="설정"><I.Settings /></button>
      </div>

      <div className="bigtitle">
        <h1>지난 구절들</h1>
        <p>마주했던 말씀을 언제든 다시 펼쳐보세요.</p>
      </div>

      <div className="app-scroll" style={{ paddingBottom: 24 }}>
        {HISTORY.map((group) => (
          <section key={group.month} className="history-section">
            <div className="history-month">
              <div className="history-month-num">{group.month}</div>
              <div className="history-month-eng">{group.monthEn}</div>
            </div>
            <div className="history-list">
              {group.items.map((it) => (
                <div key={it.day} className={'history-row' + (it.today ? ' today' : '')}>
                  <div className="history-date">
                    <div className="history-day">{it.day}</div>
                    <div className="history-dow">{it.today ? '오늘' : it.dow}</div>
                  </div>
                  <div className="history-main">
                    <div className="history-book">{it.book}</div>
                    <div className="history-ref">{it.book.toUpperCase()} {it.ref}</div>
                  </div>
                  <div className="history-arrow"><I.ChevronRight /></div>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

// ─── Screen: Settings ────────────────────────────────────────
function SettingsScreen({ themeChoice = 'light' }) {
  return (
    <div className="app">
      <div className="topbar">
        <button className="topbar-iconbtn" aria-label="뒤로"><I.Back /></button>
        <div className="subhead-title">설정</div>
        <span style={{ width: 36 }} />
      </div>

      <div className="bigtitle">
        <h1>설정</h1>
        <p>나의 묵상 환경을 다듬어 보세요.</p>
      </div>

      <div className="app-scroll" style={{ paddingBottom: 24 }}>
        {/* Audio */}
        <div className="settings-section">
          <div className="settings-section-head">음성 · TTS</div>
          <div className="settings-card">
            <div className="settings-row">
              <div className="settings-row-main">
                <div className="settings-row-label">TTS 자동 재생</div>
                <div className="settings-row-sub">페이지에 들어가면 자동으로 읽기 시작</div>
              </div>
              <div className="switch on" />
            </div>
            <div className="settings-row" style={{ flexDirection: 'column', alignItems: 'stretch', gap: 0, padding: '14px 18px 6px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                <div className="settings-row-label">볼륨</div>
                <div className="player-time" style={{ fontSize: 12 }}>72%</div>
              </div>
            </div>
            <div className="slider">
              <span className="slider-icon"><I.VolumeOff /></span>
              <div className="slider-track">
                <div className="slider-fill" style={{ width: '72%' }} />
                <div className="slider-knob" style={{ left: '72%' }} />
              </div>
              <span className="slider-icon" style={{ color: 'var(--color-label-neutral)' }}><I.Volume /></span>
            </div>
          </div>
        </div>

        {/* Display */}
        <div className="settings-section">
          <div className="settings-section-head">화면</div>
          <div className="settings-card">
            <div className="settings-row" style={{ borderBottom: '1px solid var(--color-line-neutral)' }}>
              <div className="settings-row-main">
                <div className="settings-row-label">테마</div>
                <div className="settings-row-sub">눈에 편한 분위기를 골라 보세요.</div>
              </div>
            </div>
            <div className="theme-picker">
              {[
                { id: 'light', label: '라이트', cls: 'light' },
                { id: 'dark',  label: '다크',   cls: 'dark' },
                { id: 'auto',  label: '시스템', cls: 'auto' },
              ].map((t) => (
                <div key={t.id} className={'theme-opt' + (themeChoice === t.id ? ' on' : '')}>
                  <div className={'theme-swatch ' + t.cls} />
                  <div className="theme-opt-label">{t.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* About */}
        <div className="settings-section">
          <div className="settings-section-head">정보</div>
          <div className="settings-card">
            <div className="settings-link">
              <div className="settings-link-text">
                <div className="settings-link-title" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  개발자 후원하기 <I.Heart style={{ color: 'var(--ink-accent)' }} />
                </div>
                <div className="settings-link-sub">매일의 구절은 한 사람이 만들고 있어요.</div>
              </div>
              <div style={{ color: 'var(--color-label-assistive)' }}>
                <I.External />
              </div>
            </div>
            <div className="settings-link" style={{ borderTop: '1px solid var(--color-line-neutral)' }}>
              <div className="settings-link-text">
                <div className="settings-link-title">피드백 보내기</div>
                <div className="settings-link-sub">언제든 한 마디 남겨 주세요.</div>
              </div>
              <div style={{ color: 'var(--color-label-assistive)' }}><I.ChevronRight /></div>
            </div>
            <div className="settings-link" style={{ borderTop: '1px solid var(--color-line-neutral)' }}>
              <div className="settings-link-text">
                <div className="settings-link-title">이용 약관</div>
              </div>
              <div style={{ color: 'var(--color-label-assistive)' }}><I.ChevronRight /></div>
            </div>
          </div>
        </div>

        <div className="settings-meta">
          <div className="settings-meta-mark">오늘의 구절</div>
          <div className="settings-meta-ver">v 1.4.0 · build 240</div>
        </div>
      </div>
    </div>
  );
}

window.MainScreen = MainScreen;
window.VerseBookScreen = VerseBookScreen;
window.VerseTextScreen = VerseTextScreen;
window.HistoryScreen = HistoryScreen;
window.SettingsScreen = SettingsScreen;
