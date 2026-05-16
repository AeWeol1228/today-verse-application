// app.jsx — Top-level mount + design canvas composition.
// Each artboard mounts an IOSDevice with one screen.
// Light/dark is set by `data-theme` attribute on the device root.

const { useState, useEffect } = React;

// ─── A self-contained phone holding its own little router ────
//  so each artboard is interactive: tap icons on Main to navigate,
//  swipe / tap the page indicator to flip between book + verse, etc.
function Phone({ initial = 'main', theme = 'light', height = 874, width = 402 }) {
  const [route, setRoute] = useState(initial);
  const [playing, setPlaying] = useState(true);
  const [t, setT] = useState(theme);

  // re-sync theme if prop changes (used by Tweaks)
  useEffect(() => setT(theme), [theme]);

  const dark = t === 'dark';

  let body;
  if (route === 'main')      body = <ScreenMain dark={dark} onEnter={() => setRoute('book')} onHistory={() => setRoute('history')} onSettings={() => setRoute('settings')} />;
  else if (route === 'book') body = <ScreenBookDescription dark={dark} playing={playing} onHome={() => setRoute('main')} onSwipeToVerse={() => setRoute('verse')} />;
  else if (route === 'verse')body = <ScreenVerse dark={dark} playing={playing} onHome={() => setRoute('main')} onBack={() => setRoute('book')} />;
  else if (route === 'history') body = <ScreenHistory dark={dark} onHome={() => setRoute('main')} onItem={() => setRoute('book')} />;
  else if (route === 'settings') body = <ScreenSettings dark={dark} theme={t} onHome={() => setRoute('main')} onToggleTheme={setT} />;
  else if (route === 'loading') body = <ScreenLoading dark={dark} />;

  return (
    <div data-theme={dark ? 'dark' : 'light'} style={{ width, height, borderRadius: 48, overflow: 'hidden' }}>
      <IOSDevice width={width} height={height} dark={dark}>
        {body}
      </IOSDevice>
    </div>
  );
}

// ─── Static phone (won't navigate) — useful for variants ──────
function StaticPhone({ screen = 'main', theme = 'light', width = 402, height = 874 }) {
  const dark = theme === 'dark';
  const map = {
    main:     <ScreenMain dark={dark} />,
    book:     <ScreenBookDescription dark={dark} playing={true} />,
    verse:    <ScreenVerse dark={dark} playing={true} />,
    history:  <ScreenHistory dark={dark} />,
    settings: <ScreenSettings dark={dark} theme={theme} />,
    loading:  <ScreenLoading dark={dark} />,
  };
  return (
    <div data-theme={theme} style={{ width, height, borderRadius: 48, overflow: 'hidden' }}>
      <IOSDevice width={width} height={height} dark={dark}>
        {map[screen]}
      </IOSDevice>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// Design System artboards
// ════════════════════════════════════════════════════════════
function PaletteCard({ theme = 'light' }) {
  const W = 460, H = 700;
  const tokens = [
    { name: 'bg',         var: '--tv-bg',         desc: 'background' },
    { name: 'bg-2',       var: '--tv-bg-2',       desc: 'surface · card' },
    { name: 'bg-3',       var: '--tv-bg-3',       desc: 'surface · pressed' },
    { name: 'paper',      var: '--tv-paper',      desc: 'verse paper' },
    { name: 'text-hi',    var: '--tv-text-hi',    desc: 'high · headings, verse' },
    { name: 'text-mid',   var: '--tv-text-mid',   desc: 'mid · body' },
    { name: 'text-lo',    var: '--tv-text-lo',    desc: 'low · meta' },
    { name: 'gold',       var: '--tv-gold',       desc: 'point · primary' },
    { name: 'gold-soft',  var: '--tv-gold-soft',  desc: 'point · hover/accent' },
    { name: 'line',       var: '--tv-line',       desc: 'hairline borders' },
  ];
  return (
    <div data-theme={theme} style={{
      width: W, height: H, padding: 28,
      background: 'var(--tv-bg)', color: 'var(--tv-text-hi)',
      fontFamily: 'var(--tv-font-sans-ko)',
    }}>
      <div className="tv-display-it" style={{ fontSize: 14, color: 'var(--tv-text-lo)', letterSpacing: '0.12em', textTransform: 'uppercase' }}>Color · {theme}</div>
      <h2 className="tv-verse" style={{ fontSize: 30, margin: '4px 0 4px', fontWeight: 800, letterSpacing: '0.02em' }}>세피아 + 골드</h2>
      <p className="tv-body" style={{ fontSize: 13, color: 'var(--tv-text-mid)', margin: '0 0 22px', maxWidth: 380 }}>
        차갑지 않은 색. 모든 중립색은 노랑·갈색 편향. 골드는 점 단위로 — 결코 면으로 깔지 않습니다.
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {tokens.map((t) => (
          <div key={t.name} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            padding: '8px 12px',
            border: '1px solid var(--tv-line)',
            borderRadius: 12,
            background: 'var(--tv-bg-2)',
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: 10,
              background: `var(${t.var})`,
              border: '1px solid var(--tv-line)',
              flex: '0 0 auto',
            }}/>
            <div style={{ flex: 1 }}>
              <div className="tv-body" style={{ fontSize: 14, fontWeight: 600 }}>{t.name}</div>
              <div className="tv-body" style={{ fontSize: 12, color: 'var(--tv-text-mid)' }}>{t.desc}</div>
            </div>
            <div className="tv-mono-ref" style={{ fontSize: 11, color: 'var(--tv-text-lo)', letterSpacing: '0.04em' }}>
              {t.var}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function TypeCard({ theme = 'light' }) {
  return (
    <div data-theme={theme} style={{
      width: 720, height: 700, padding: 36,
      background: 'var(--tv-bg)', color: 'var(--tv-text-hi)',
      fontFamily: 'var(--tv-font-sans-ko)',
    }}>
      <div className="tv-display-it" style={{ fontSize: 14, color: 'var(--tv-text-lo)', letterSpacing: '0.12em', textTransform: 'uppercase' }}>Typography</div>
      <h2 className="tv-verse" style={{ fontSize: 30, margin: '4px 0 22px', fontWeight: 800, letterSpacing: '0.02em' }}>나눔명조 + Cormorant + Noto Sans</h2>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
        {/* Verse — Nanum Myeongjo */}
        <TypeSpec
          tag="Verse / 본문"
          family="Nanum Myeongjo · Regular"
          spec="21px / 1.9 · -0.005em"
          sample={
            <p className="tv-verse" style={{ fontSize: 21, lineHeight: 1.9, color: 'var(--tv-text-hi)', margin: 0 }}>
              우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라
            </p>
          }/>
        {/* Display — Cormorant italic */}
        <TypeSpec
          tag="Display · 영문/숫자"
          family="Cormorant Garamond · Italic"
          spec="display sizes · letter-spacing +0.01em"
          sample={
            <div>
              <div className="tv-display" style={{ fontSize: 36, fontStyle: 'italic', letterSpacing: '0.005em' }}>Romans 8:28–29</div>
              <div className="tv-display-it" style={{ fontSize: 14, color: 'var(--tv-text-lo)', letterSpacing: '0.18em', textTransform: 'uppercase', marginTop: 4 }}>Today's Verse</div>
            </div>
          }/>
        {/* Body — Noto Sans KR */}
        <TypeSpec
          tag="Body · UI 설명"
          family="Noto Sans KR · Regular"
          spec="16px / 1.7 · -0.005em"
          sample={
            <p className="tv-body" style={{ fontSize: 16, lineHeight: 1.7, margin: 0, maxWidth: 520, color: 'var(--tv-text-hi)' }}>
              로마서는 사도 바울이 로마에 있는 신자들에게 보낸 가장 정교한 신학 서신입니다. 그는 로마를 직접 방문하기 전 자신의 복음 이해를 서면으로 미리 전했습니다.
            </p>
          }/>
        {/* Heading — Nanum Myeongjo Bold */}
        <TypeSpec
          tag="Heading · 책 제목"
          family="Nanum Myeongjo · ExtraBold"
          spec="44 / 1.1 · +0.02em"
          sample={
            <h3 className="tv-verse" style={{ fontSize: 44, fontWeight: 800, margin: 0, letterSpacing: '0.02em' }}>로마서</h3>
          }/>
      </div>
    </div>
  );
}

function TypeSpec({ tag, family, spec, sample }) {
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '180px 1fr',
      gap: 24, alignItems: 'baseline',
      paddingBottom: 22, borderBottom: '1px solid var(--tv-line)',
    }}>
      <div>
        <div className="tv-display-it" style={{ fontSize: 13, color: 'var(--tv-gold)', letterSpacing: '0.08em', textTransform: 'uppercase' }}>{tag}</div>
        <div className="tv-body" style={{ fontSize: 12, color: 'var(--tv-text-mid)', marginTop: 4, fontWeight: 500 }}>{family}</div>
        <div className="tv-mono-ref" style={{ fontSize: 11, color: 'var(--tv-text-lo)', marginTop: 2, letterSpacing: '0.04em' }}>{spec}</div>
      </div>
      <div>{sample}</div>
    </div>
  );
}

function BrandCard({ theme = 'light' }) {
  return (
    <div data-theme={theme} style={{
      width: 460, height: 700, padding: 36,
      background: 'var(--tv-bg)', color: 'var(--tv-text-hi)',
      display: 'flex', flexDirection: 'column', gap: 24,
      fontFamily: 'var(--tv-font-sans-ko)',
    }}>
      <div>
        <div className="tv-display-it" style={{ fontSize: 14, color: 'var(--tv-text-lo)', letterSpacing: '0.12em', textTransform: 'uppercase' }}>Brand · 일러스트</div>
        <h2 className="tv-verse" style={{ fontSize: 30, margin: '4px 0', fontWeight: 800, letterSpacing: '0.02em' }}>스티플링 성당</h2>
        <p className="tv-body" style={{ fontSize: 13, color: 'var(--tv-text-mid)', margin: 0 }}>
          점의 밀도로 빛과 돌의 질감을 표현한 절제된 일러스트.
        </p>
      </div>

      {/* main illustration */}
      <div style={{
        flex: 1,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'var(--tv-bg-2)', borderRadius: 'var(--tv-r-lg)',
        border: '1px solid var(--tv-line)',
        color: 'var(--tv-text-hi)',
      }}>
        <CathedralStipple width={320} color="var(--tv-text-hi)"/>
      </div>

      {/* spec details */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <SpecRow label="기법" value="Stippling · 점묘"/>
        <SpecRow label="색상" value="단일 색 · currentColor"/>
        <SpecRow label="모티프" value="고딕 성당 · 첨탑 · 장미창"/>
        <SpecRow label="Phase 1" value="고정 이미지"/>
        <SpecRow label="Phase 2" value="날짜별 변주"/>
      </div>
    </div>
  );
}

function SpecRow({ label, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 16, fontSize: 13 }}>
      <span className="tv-display-it" style={{ flex: '0 0 80px', color: 'var(--tv-text-lo)', letterSpacing: '0.08em', textTransform: 'uppercase', fontSize: 11 }}>{label}</span>
      <span className="tv-body" style={{ color: 'var(--tv-text-hi)' }}>{value}</span>
    </div>
  );
}

function AppSymbolCard({ theme = 'light' }) {
  return (
    <div data-theme={theme} style={{
      width: 460, height: 700, padding: 36,
      background: 'var(--tv-bg)', color: 'var(--tv-text-hi)',
      display: 'flex', flexDirection: 'column', gap: 28,
      fontFamily: 'var(--tv-font-sans-ko)',
    }}>
      <div>
        <div className="tv-display-it" style={{ fontSize: 14, color: 'var(--tv-text-lo)', letterSpacing: '0.12em', textTransform: 'uppercase' }}>App symbol</div>
        <h2 className="tv-verse" style={{ fontSize: 30, margin: '4px 0', fontWeight: 800, letterSpacing: '0.02em' }}>심볼 · 아이콘</h2>
      </div>

      {/* large mark */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'var(--tv-bg-2)', borderRadius: 'var(--tv-r-xl)',
        border: '1px solid var(--tv-line)',
        height: 220,
      }}>
        <div style={{ color: 'var(--tv-text-hi)' }}>
          <AppSymbol size={128}/>
        </div>
      </div>

      {/* sizes */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 20, padding: '0 8px' }}>
        {[64, 40, 28, 20].map((s) => (
          <div key={s} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
            <div style={{ color: 'var(--tv-text-hi)' }}><AppSymbol size={s}/></div>
            <span className="tv-mono-ref" style={{ fontSize: 11, color: 'var(--tv-text-lo)' }}>{s}px</span>
          </div>
        ))}
      </div>

      {/* nav icons */}
      <div>
        <div className="tv-display-it" style={{ fontSize: 12, color: 'var(--tv-text-lo)', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 10 }}>System icons</div>
        <div style={{ display: 'flex', gap: 14 }}>
          {[
            { i: <IconBook size={24}/>, n: 'verse' },
            { i: <IconClock size={24}/>, n: 'history' },
            { i: <IconSettings size={24}/>, n: 'settings' },
            { i: <IconPlay size={24}/>, n: 'play' },
            { i: <IconPause size={24}/>, n: 'pause' },
            { i: <IconVolume size={24}/>, n: 'volume' },
          ].map((g, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
              <div style={{
                width: 48, height: 48, borderRadius: 12,
                border: '1px solid var(--tv-line)', background: 'var(--tv-bg-2)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: 'var(--tv-text-mid)',
              }}>{g.i}</div>
              <span className="tv-mono-ref" style={{ fontSize: 10, color: 'var(--tv-text-lo)', letterSpacing: '0.04em' }}>{g.n}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// Canvas composition
// ════════════════════════════════════════════════════════════
function App() {
  const phoneW = 402, phoneH = 874;
  // Artboard sizes (canvas frame) — give padding around the device
  const aw = 440, ah = 900;

  return (
    <DesignCanvas>
      <DCSection id="prototype" title="Interactive prototype"
        subtitle="라이트 / 다크 — 아이콘과 카드를 탭하면 화면 사이를 이동합니다 (Focus 모드 권장).">
        <DCArtboard id="proto-light" label="Light · 라이트 모드" width={aw} height={ah}>
          <ArtboardCenter><Phone initial="main" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="proto-dark" label="Dark · 다크 모드" width={aw} height={ah}>
          <ArtboardCenter dark><Phone initial="main" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="main" title="① 메인 페이지 · Threshold"
        subtitle="일상과 구절 사이의 전이 공간. 아이콘 3개만, 텍스트 레이블 없음.">
        <DCArtboard id="main-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="main" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="main-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="main" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="book" title="② 구절 경험 · 책 설명"
        subtitle="Page 1 / 2 — 책의 배경을 먼저. 진입 시 TTS 자동 재생.">
        <DCArtboard id="book-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="book" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="book-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="book" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="verse" title="③ 구절 경험 · 구절"
        subtitle="Page 2 / 2 — 두 절을 한 페이지에. 종이 톤(--tv-paper)으로 미세하게 분리.">
        <DCArtboard id="verse-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="verse" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="verse-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="verse" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="history" title="④ 히스토리"
        subtitle="지난 구절 아카이브 — 날짜·책·참조·미리보기.">
        <DCArtboard id="history-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="history" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="history-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="history" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="settings" title="⑤ 설정"
        subtitle="TTS · 음량 · 테마 · 후원. Editorial 톤 유지.">
        <DCArtboard id="settings-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="settings" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="settings-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="settings" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="loading" title="⑥ 로딩 상태"
        subtitle="Firestore 호출 동안 — 일러스트 페이드 + 작은 호흡 도트.">
        <DCArtboard id="loading-light" label="Light" width={aw} height={ah}>
          <ArtboardCenter><StaticPhone screen="loading" theme="light" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="loading-dark" label="Dark" width={aw} height={ah}>
          <ArtboardCenter dark><StaticPhone screen="loading" theme="dark" width={phoneW} height={phoneH}/></ArtboardCenter>
        </DCArtboard>
      </DCSection>

      <DCSection id="system" title="⑦ 디자인 시스템"
        subtitle="컬러 토큰 · 타이포 스케일 · 일러스트 · 심볼.">
        <DCArtboard id="palette-light" label="Color · Light" width={500} height={740}>
          <ArtboardCenter><PaletteCard theme="light"/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="palette-dark" label="Color · Dark" width={500} height={740}>
          <ArtboardCenter dark><PaletteCard theme="dark"/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="type" label="Typography" width={760} height={740}>
          <ArtboardCenter><TypeCard theme="light"/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="illust" label="Illustration" width={500} height={740}>
          <ArtboardCenter><BrandCard theme="light"/></ArtboardCenter>
        </DCArtboard>
        <DCArtboard id="symbol" label="App symbol + icons" width={500} height={740}>
          <ArtboardCenter><AppSymbolCard theme="light"/></ArtboardCenter>
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

// Padding wrapper inside artboards — keeps consistent gutter and contextual background.
function ArtboardCenter({ children, dark = false }) {
  return (
    <div style={{
      width: '100%', height: '100%',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      // Soft outer background hint that picks up sepia/dark — not loud
      background: dark
        ? 'radial-gradient(140% 90% at 50% 30%, #2A261F 0%, #1A1813 100%)'
        : 'radial-gradient(140% 90% at 50% 30%, #F6F0DF 0%, #E8DBC2 100%)',
    }}>{children}</div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
