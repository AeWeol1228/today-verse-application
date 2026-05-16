// screens.jsx — All 6 screens for "오늘의 구절"
// Each screen takes `dark` and renders inside an IOSDevice frame.
// Layouts assume 402 × 874 device, status bar ~50px top, home ~34px bottom.

const T = window.TV_CONTENT;

// ════════════════════════════════════════════════════════════
// Shared chrome — top bar (used inside verse experience, history, settings)
// ════════════════════════════════════════════════════════════
function TopBar({ leading, trailing, title, subtitle }) {
  return (
    <div style={{
      paddingTop: 58, paddingLeft: 20, paddingRight: 20, paddingBottom: 8,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      gap: 12,
    }}>
      <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 10 }}>
        {leading}
      </div>
      <div style={{ flex: 1, textAlign: 'center', minWidth: 0 }}>
        {subtitle && <div className="tv-display-it" style={{
          fontSize: 12, color: 'var(--tv-text-lo)', letterSpacing: '0.04em',
          marginBottom: 1,
        }}>{subtitle}</div>}
        {title && <div className="tv-body" style={{
          fontSize: 14, color: 'var(--tv-text-mid)', fontWeight: 500,
        }}>{title}</div>}
      </div>
      <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 6 }}>
        {trailing}
      </div>
    </div>
  );
}

function GhostButton({ children, onClick, ariaLabel, style = {} }) {
  return (
    <button
      onClick={onClick}
      aria-label={ariaLabel}
      style={{
        width: 40, height: 40, border: 'none', background: 'transparent',
        color: 'var(--tv-text-mid)', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        borderRadius: 'var(--tv-r-full)',
        transition: 'background 200ms var(--tv-ease)',
        ...style,
      }}
      onMouseEnter={(e) => e.currentTarget.style.background = 'var(--tv-gold-bg)'}
      onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
    >{children}</button>
  );
}

// ════════════════════════════════════════════════════════════
// 1. Main Page (Landing / Threshold)
// ════════════════════════════════════════════════════════════
function ScreenMain({ dark = false, onEnter = () => {}, onHistory = () => {}, onSettings = () => {} }) {
  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      paddingTop: 50,
      paddingBottom: 34,
      position: 'relative',
    }}>
      {/* Top: minimal date */}
      <div style={{
        paddingTop: 14, textAlign: 'center',
      }}>
        <div className="tv-display-it" style={{
          fontSize: 13, color: 'var(--tv-text-lo)',
          letterSpacing: '0.06em',
        }}>{T.today.weekday}</div>
        <div className="tv-display" style={{
          fontSize: 17, color: 'var(--tv-text-mid)',
          letterSpacing: '0.01em', marginTop: 2,
        }}>{T.today.dateLong}</div>
      </div>

      {/* Illustration — fills */}
      <div style={{
        flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '8px 24px',
        color: 'var(--tv-text-hi)',
      }}>
        <CathedralStipple width={320} color="var(--tv-text-hi)" />
      </div>

      {/* App name */}
      <div style={{ textAlign: 'center', paddingTop: 4 }}>
        <div className="tv-display-it" style={{
          fontSize: 13, color: 'var(--tv-text-lo)',
          letterSpacing: '0.18em', textTransform: 'uppercase',
        }}>Today's Verse</div>
        <h1 className="tv-verse" style={{
          fontSize: 26, fontWeight: 700,
          color: 'var(--tv-text-hi)',
          margin: '4px 0 0', letterSpacing: '0.04em',
        }}>오늘의 구절</h1>
      </div>

      {/* Three icon buttons */}
      <div style={{
        display: 'flex', justifyContent: 'center', alignItems: 'center',
        gap: 28, paddingTop: 38, paddingBottom: 8,
      }}>
        <ThresholdButton icon={<IconClock size={26}/>} onClick={onHistory}/>
        <ThresholdButton primary icon={<IconBook size={28}/>} onClick={onEnter}/>
        <ThresholdButton icon={<IconSettings size={26}/>} onClick={onSettings}/>
      </div>
    </div>
  );
}

function ThresholdButton({ icon, primary, onClick }) {
  if (primary) {
    return (
      <button
        onClick={onClick}
        style={{
          width: 76, height: 76, borderRadius: 'var(--tv-r-full)',
          border: '1px solid var(--tv-line-strong)',
          background: 'var(--tv-bg-2)',
          color: 'var(--tv-gold)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: 'var(--tv-shadow-card)',
          cursor: 'pointer',
          position: 'relative',
          transition: 'transform 200ms var(--tv-ease), box-shadow 200ms var(--tv-ease)',
        }}
        onMouseEnter={(e) => { e.currentTarget.style.transform = 'translateY(-1px)'; e.currentTarget.style.boxShadow = 'var(--tv-shadow-lift)'; }}
        onMouseLeave={(e) => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = 'var(--tv-shadow-card)'; }}
      >
        {icon}
        {/* subtle gold halo dot */}
        <span style={{
          position: 'absolute', bottom: -10, left: '50%',
          transform: 'translateX(-50%)',
          width: 5, height: 5, borderRadius: '50%',
          background: 'var(--tv-gold)', opacity: 0.85,
        }}/>
      </button>
    );
  }
  return (
    <button
      onClick={onClick}
      style={{
        width: 60, height: 60, borderRadius: 'var(--tv-r-full)',
        border: '1px solid var(--tv-line)',
        background: 'transparent',
        color: 'var(--tv-text-mid)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
        transition: 'background 200ms var(--tv-ease), color 200ms var(--tv-ease)',
      }}
      onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--tv-gold-bg)'; e.currentTarget.style.color = 'var(--tv-text-hi)'; }}
      onMouseLeave={(e) => { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.color = 'var(--tv-text-mid)'; }}
    >
      {icon}
    </button>
  );
}

// ════════════════════════════════════════════════════════════
// Shared: TTS pill (top right of verse experience)
// ════════════════════════════════════════════════════════════
function TtsPill({ playing, onToggle, length = T.today.ttsLength }) {
  return (
    <button
      onClick={onToggle}
      style={{
        height: 36, padding: '0 12px 0 10px',
        borderRadius: 'var(--tv-r-full)',
        border: '1px solid var(--tv-line)',
        background: 'var(--tv-bg-2)',
        color: 'var(--tv-text-mid)',
        display: 'flex', alignItems: 'center', gap: 6,
        cursor: 'pointer',
        fontFamily: 'var(--tv-font-display)',
        fontSize: 13, letterSpacing: '0.02em',
        fontVariantNumeric: 'tabular-nums',
      }}
    >
      <span style={{ display: 'flex', color: playing ? 'var(--tv-gold)' : 'var(--tv-text-mid)' }}>
        {playing ? <IconPause size={16}/> : <IconPlay size={16}/>}
      </span>
      <span>{length}</span>
      {playing && <Waveform />}
    </button>
  );
}

function Waveform() {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 2, marginLeft: 2 }}>
      {[6, 11, 8, 13, 7].map((h, i) => (
        <span key={i} style={{
          display: 'inline-block', width: 2, height: h,
          background: 'var(--tv-gold)', borderRadius: 1,
          animation: `tvBar 1.2s ${i * 0.12}s infinite ease-in-out`,
        }}/>
      ))}
    </span>
  );
}

// ════════════════════════════════════════════════════════════
// 2. Verse Experience — Book Description (Page 1)
// ════════════════════════════════════════════════════════════
function ScreenBookDescription({ dark = false, playing = true, onHome = () => {}, onSwipeToVerse = () => {} }) {
  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      paddingBottom: 34,
    }}>
      <TopBar
        leading={<GhostButton ariaLabel="홈" onClick={onHome}><AppSymbol size={26} style={{ color: 'var(--tv-text-mid)' }}/></GhostButton>}
        subtitle="Context"
        title="책 설명"
        trailing={<TtsPill playing={playing}/>}
      />

      {/* Body — scrollable */}
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 28px 32px' }}>
        {/* Book title block */}
        <div style={{ paddingTop: 8, marginBottom: 28 }}>
          <div className="tv-display-it" style={{
            fontSize: 14, color: 'var(--tv-gold)',
            letterSpacing: '0.12em', textTransform: 'uppercase',
          }}>{T.today.book.kind}</div>
          <h1 className="tv-verse" style={{
            fontSize: 44, fontWeight: 800, lineHeight: 1.1,
            margin: '4px 0 6px',
            color: 'var(--tv-text-hi)',
            letterSpacing: '0.02em',
          }}>{T.today.book.ko}</h1>
          <div className="tv-display" style={{
            fontSize: 22, fontStyle: 'italic',
            color: 'var(--tv-text-mid)',
            letterSpacing: '0.01em',
          }}>{T.today.book.en}</div>
          <div className="tv-mono-ref" style={{
            fontSize: 12, color: 'var(--tv-text-lo)',
            marginTop: 8, letterSpacing: '0.08em',
          }}>· {T.today.book.period} ·</div>
        </div>

        {/* Description paragraphs */}
        <div className="tv-body" style={{
          fontSize: 16, lineHeight: 1.85,
          color: 'var(--tv-text-hi)',
        }}>
          {T.today.bookDescription.map((p, i) => (
            <p key={i} style={{
              margin: '0 0 18px',
              textIndent: i === 0 ? 0 : '0',
              textWrap: 'pretty',
            }}>{p}</p>
          ))}
        </div>

        {/* Ornament */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          gap: 10, margin: '16px 0 8px', color: 'var(--tv-gold-soft)',
        }}>
          <span style={{ width: 32, height: 1, background: 'currentColor', opacity: 0.5 }}/>
          <span className="tv-display-it" style={{ fontSize: 14 }}>✣</span>
          <span style={{ width: 32, height: 1, background: 'currentColor', opacity: 0.5 }}/>
        </div>

        {/* Swipe hint */}
        <div onClick={onSwipeToVerse}
          style={{
            marginTop: 16, padding: '14px 16px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            color: 'var(--tv-text-lo)',
            cursor: 'pointer',
          }}>
          <span className="tv-display-it" style={{ fontSize: 14, letterSpacing: '0.04em' }}>
            오늘의 구절로 넘어가기
          </span>
          <span style={{ display: 'flex', gap: 2, color: 'var(--tv-gold)' }}>
            <IconChevronRight size={20}/>
          </span>
        </div>
      </div>

      {/* Page indicator */}
      <PageDots count={2} active={0} />
    </div>
  );
}

function PageDots({ count, active }) {
  return (
    <div style={{
      display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 8,
      paddingBottom: 12, paddingTop: 6,
    }}>
      {Array.from({ length: count }).map((_, i) => (
        <span key={i} style={{
          width: i === active ? 18 : 6, height: 6,
          borderRadius: 999,
          background: i === active ? 'var(--tv-gold)' : 'var(--tv-line-strong)',
          transition: 'all 300ms var(--tv-ease)',
        }}/>
      ))}
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// 3. Verse Experience — Verse (Page 2)
// ════════════════════════════════════════════════════════════
function ScreenVerse({ dark = false, playing = true, onHome = () => {}, onBack = () => {} }) {
  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      paddingBottom: 34,
      background: 'var(--tv-paper)',
    }}>
      <TopBar
        leading={<GhostButton ariaLabel="홈" onClick={onHome}><AppSymbol size={26} style={{ color: 'var(--tv-text-mid)' }}/></GhostButton>}
        subtitle="Verse"
        title="오늘의 구절"
        trailing={<TtsPill playing={playing}/>}
      />

      <div style={{ flex: 1, overflow: 'auto', padding: '20px 28px 24px' }}>
        {/* Opening ornament */}
        <div style={{
          color: 'var(--tv-gold)', textAlign: 'center',
          fontFamily: 'var(--tv-font-display)',
          fontSize: 64, lineHeight: 0.8, marginBottom: 12,
          fontStyle: 'italic',
        }}>“</div>

        {/* Reference */}
        <div className="tv-mono-ref" style={{
          textAlign: 'center',
          fontSize: 14, color: 'var(--tv-gold)',
          letterSpacing: '0.12em', marginBottom: 26,
        }}>
          {T.today.reference}
        </div>

        {/* Verses */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          {T.today.verses.map((v) => (
            <div key={v.n} style={{ display: 'flex', gap: 14 }}>
              <span className="tv-mono-ref" style={{
                flex: '0 0 auto', fontSize: 13, color: 'var(--tv-gold-soft)',
                paddingTop: 7, lineHeight: 1,
                fontVariantNumeric: 'lining-nums',
                fontWeight: 600,
                width: 18, textAlign: 'right',
              }}>{v.n}</span>
              <p className="tv-verse" style={{
                margin: 0, flex: 1,
                fontSize: 21, lineHeight: 1.9, fontWeight: 400,
                color: 'var(--tv-text-hi)',
                letterSpacing: '0.005em',
                textWrap: 'pretty',
              }}>{v.text}</p>
            </div>
          ))}
        </div>

        {/* Closing ornament */}
        <div style={{
          color: 'var(--tv-gold)', textAlign: 'center',
          fontFamily: 'var(--tv-font-display)',
          fontSize: 64, lineHeight: 0.8, marginTop: 24,
          fontStyle: 'italic',
        }}>”</div>

        {/* Footer attribution */}
        <div style={{ textAlign: 'center', marginTop: 24 }}>
          <div className="tv-display-it" style={{
            fontSize: 13, color: 'var(--tv-text-lo)', letterSpacing: '0.04em',
          }}>{T.today.book.en} {T.today.reference.split(' ')[1]}</div>
          <div className="tv-display" style={{
            fontSize: 12, color: 'var(--tv-text-lo)', marginTop: 4,
            letterSpacing: '0.18em', textTransform: 'uppercase',
          }}>개역개정 · KRV</div>
        </div>
      </div>

      <PageDots count={2} active={1}/>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// 4. History
// ════════════════════════════════════════════════════════════
function ScreenHistory({ dark = false, onHome = () => {}, onItem = () => {} }) {
  // Group by month
  const items = T.history;
  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      paddingBottom: 34,
    }}>
      <TopBar
        leading={<GhostButton ariaLabel="홈" onClick={onHome}><AppSymbol size={26} style={{ color: 'var(--tv-text-mid)' }}/></GhostButton>}
        subtitle="Archive"
        title="지난 구절"
        trailing={<div style={{ width: 40, height: 40 }}/>}
      />

      {/* Header */}
      <div style={{ padding: '12px 28px 16px' }}>
        <h1 className="tv-verse" style={{
          fontSize: 32, fontWeight: 800, margin: 0,
          color: 'var(--tv-text-hi)', letterSpacing: '0.02em',
        }}>지난 구절</h1>
        <div className="tv-display-it" style={{
          fontSize: 14, color: 'var(--tv-text-lo)', marginTop: 4,
          letterSpacing: '0.04em',
        }}>{items.length} 일 · since May 2026</div>
      </div>

      {/* Month section */}
      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 24px' }}>
        <MonthLabel>2026 · May</MonthLabel>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map((it, i) => (
            <HistoryCard key={i} item={it} onClick={() => onItem(it)} />
          ))}
        </div>

        <div style={{ paddingTop: 18, textAlign: 'center', color: 'var(--tv-text-lo)' }}>
          <span className="tv-display-it" style={{ fontSize: 13, letterSpacing: '0.06em' }}>· 처음으로 ·</span>
        </div>
      </div>
    </div>
  );
}

function MonthLabel({ children }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '8px 8px 14px',
    }}>
      <span style={{ flex: 1, height: 1, background: 'var(--tv-line)' }}/>
      <span className="tv-display" style={{
        fontSize: 12, color: 'var(--tv-text-lo)',
        letterSpacing: '0.22em', textTransform: 'uppercase',
        fontStyle: 'italic',
      }}>{children}</span>
      <span style={{ flex: 1, height: 1, background: 'var(--tv-line)' }}/>
    </div>
  );
}

function HistoryCard({ item, onClick }) {
  // Parse "5월 15일 (금)"
  const m = item.dateKR.match(/(\d+)월 (\d+)일 \((\S+)\)/);
  const day = m ? m[2] : '–';
  const weekday = m ? m[3] : '';
  return (
    <button onClick={onClick} style={{
      width: '100%', textAlign: 'left',
      padding: '14px 16px',
      border: '1px solid var(--tv-line)',
      borderRadius: 'var(--tv-r-lg)',
      background: 'var(--tv-bg-2)',
      display: 'flex', alignItems: 'stretch', gap: 14,
      cursor: 'pointer',
      transition: 'background 200ms var(--tv-ease), transform 200ms var(--tv-ease)',
      fontFamily: 'inherit',
    }}
    onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--tv-bg-3)'; }}
    onMouseLeave={(e) => { e.currentTarget.style.background = 'var(--tv-bg-2)'; }}
    >
      {/* Date column */}
      <div style={{
        flex: '0 0 auto', width: 50,
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        justifyContent: 'center',
        borderRight: '1px solid var(--tv-line)',
        paddingRight: 12, marginRight: 2,
      }}>
        <div className="tv-display" style={{
          fontSize: 26, color: 'var(--tv-text-hi)', fontWeight: 500,
          lineHeight: 1, fontVariantNumeric: 'lining-nums',
        }}>{day}</div>
        <div className="tv-display-it" style={{
          fontSize: 11, color: 'var(--tv-text-lo)', marginTop: 3,
          letterSpacing: '0.05em',
        }}>{weekday}요일</div>
      </div>

      {/* Content column */}
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 4 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
          <span className="tv-verse" style={{
            fontSize: 17, fontWeight: 700, color: 'var(--tv-text-hi)',
            letterSpacing: '0.01em',
          }}>{item.book}</span>
          <span className="tv-mono-ref" style={{
            fontSize: 12, color: 'var(--tv-gold)',
            letterSpacing: '0.06em',
          }}>{item.ref.replace(item.book + ' ', '')}</span>
        </div>
        <p className="tv-body" style={{
          margin: 0, fontSize: 13, lineHeight: 1.5,
          color: 'var(--tv-text-mid)',
          overflow: 'hidden', textOverflow: 'ellipsis',
          display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical',
        }}>{item.preview}</p>
      </div>
    </button>
  );
}

// ════════════════════════════════════════════════════════════
// 5. Settings
// ════════════════════════════════════════════════════════════
function ScreenSettings({ dark = false, ttsOn: ttsOnProp, theme: themeProp, onHome = () => {}, onToggleTheme = () => {} }) {
  const [ttsOn, setTtsOn] = React.useState(ttsOnProp ?? true);
  const [vol, setVol] = React.useState(0.72);
  const [theme, setTheme] = React.useState(themeProp ?? (dark ? 'dark' : 'light'));

  React.useEffect(() => { if (themeProp !== undefined) setTheme(themeProp); }, [themeProp]);

  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      paddingBottom: 34,
    }}>
      <TopBar
        leading={<GhostButton ariaLabel="홈" onClick={onHome}><AppSymbol size={26} style={{ color: 'var(--tv-text-mid)' }}/></GhostButton>}
        subtitle="Settings"
        title="설정"
        trailing={<div style={{ width: 40, height: 40 }}/>}
      />

      <div style={{ padding: '12px 28px 12px' }}>
        <h1 className="tv-verse" style={{
          fontSize: 32, fontWeight: 800, margin: 0,
          color: 'var(--tv-text-hi)', letterSpacing: '0.02em',
        }}>설정</h1>
        <div className="tv-display-it" style={{
          fontSize: 14, color: 'var(--tv-text-lo)', marginTop: 4,
          letterSpacing: '0.04em',
        }}>Preferences</div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 24px' }}>
        {/* — 음성 — */}
        <SectionHeader>음성 · Voice</SectionHeader>
        <SettingsGroup>
          <SettingsRow
            title="자동 낭독"
            sub="페이지 진입 시 책 설명과 구절을 읽어줍니다"
          >
            <Toggle on={ttsOn} onToggle={() => setTtsOn(v => !v)} />
          </SettingsRow>
          <Divider/>
          <SettingsRow
            title="음량"
            sub={null}
            tight
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, flex: 1 }}>
              <span style={{ color: 'var(--tv-text-lo)', display: 'flex' }}><IconVolume size={18}/></span>
              <VolumeSlider value={vol} onChange={setVol} disabled={!ttsOn} />
              <span className="tv-mono-ref" style={{
                color: 'var(--tv-text-mid)', fontSize: 12,
                width: 30, textAlign: 'right', fontVariantNumeric: 'tabular-nums',
              }}>{Math.round(vol * 100)}</span>
            </div>
          </SettingsRow>
        </SettingsGroup>

        {/* — 화면 — */}
        <SectionHeader>화면 · Theme</SectionHeader>
        <SettingsGroup>
          <ThemePicker theme={theme} onChange={(t) => { setTheme(t); onToggleTheme(t); }} />
        </SettingsGroup>

        {/* — 후원 — */}
        <SectionHeader>후원 · Support</SectionHeader>
        <SettingsGroup>
          <LinkRow
            icon={<IconHeart size={20}/>}
            title="개발자에게 커피 한 잔"
            sub="이 앱을 만든 사람을 응원합니다"
          />
          <Divider/>
          <LinkRow
            icon={<IconChevronUpRight size={20}/>}
            title="피드백 보내기"
            sub="조용히 듣고 있어요"
          />
        </SettingsGroup>

        {/* footer */}
        <div style={{ textAlign: 'center', paddingTop: 28, color: 'var(--tv-text-lo)' }}>
          <div className="tv-display-it" style={{ fontSize: 14, letterSpacing: '0.04em' }}>
            오늘의 구절 · v1.2.0
          </div>
          <div className="tv-display" style={{
            fontSize: 11, letterSpacing: '0.18em', textTransform: 'uppercase',
            marginTop: 6, opacity: 0.7,
          }}>made quietly</div>
        </div>
      </div>
    </div>
  );
}

function SectionHeader({ children }) {
  return (
    <div className="tv-display-it" style={{
      padding: '20px 8px 10px',
      fontSize: 12, color: 'var(--tv-text-lo)',
      letterSpacing: '0.16em', textTransform: 'uppercase',
    }}>{children}</div>
  );
}

function SettingsGroup({ children }) {
  return (
    <div style={{
      background: 'var(--tv-bg-2)',
      border: '1px solid var(--tv-line)',
      borderRadius: 'var(--tv-r-lg)',
      overflow: 'hidden',
    }}>{children}</div>
  );
}

function SettingsRow({ title, sub, children, tight = false }) {
  return (
    <div style={{
      padding: tight ? '14px 16px' : '14px 16px',
      display: 'flex', alignItems: 'center', gap: 12,
      minHeight: tight ? 0 : 56,
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="tv-body" style={{
          fontSize: 15, fontWeight: 500, color: 'var(--tv-text-hi)',
        }}>{title}</div>
        {sub && <div className="tv-body" style={{
          fontSize: 12, color: 'var(--tv-text-mid)', marginTop: 2,
          lineHeight: 1.4,
        }}>{sub}</div>}
      </div>
      <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', minWidth: tight ? '60%' : 'auto' }}>
        {children}
      </div>
    </div>
  );
}

function Divider() {
  return <div style={{ height: 1, background: 'var(--tv-line)', margin: '0 16px' }}/>;
}

function Toggle({ on, onToggle }) {
  return (
    <button onClick={onToggle} style={{
      width: 46, height: 28, borderRadius: 999,
      border: '1px solid ' + (on ? 'transparent' : 'var(--tv-line-strong)'),
      background: on ? 'var(--tv-gold)' : 'transparent',
      position: 'relative',
      cursor: 'pointer',
      transition: 'all 200ms var(--tv-ease)',
      padding: 0,
    }}>
      <span style={{
        position: 'absolute', top: 2, left: on ? 20 : 2,
        width: 22, height: 22, borderRadius: '50%',
        background: on ? 'var(--tv-text-on-gold)' : 'var(--tv-text-lo)',
        transition: 'left 200ms var(--tv-ease), background 200ms var(--tv-ease)',
        boxShadow: '0 1px 2px rgba(70, 45, 15, 0.2)',
      }}/>
    </button>
  );
}

function VolumeSlider({ value, onChange, disabled }) {
  const trackRef = React.useRef(null);
  const handlePointer = (e) => {
    if (disabled) return;
    const rect = trackRef.current.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    onChange(Math.max(0, Math.min(1, x)));
  };
  return (
    <div ref={trackRef} onPointerDown={(e) => { e.target.setPointerCapture?.(e.pointerId); handlePointer(e); }}
      onPointerMove={(e) => { if (e.buttons === 1) handlePointer(e); }}
      style={{
        flex: 1, height: 24, position: 'relative', cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.45 : 1,
        touchAction: 'none',
        display: 'flex', alignItems: 'center',
      }}>
      <div style={{
        width: '100%', height: 3, background: 'var(--tv-line-strong)', borderRadius: 999,
        position: 'relative',
      }}>
        <div style={{
          position: 'absolute', left: 0, top: 0, height: '100%', width: (value * 100) + '%',
          background: 'var(--tv-gold)', borderRadius: 999,
        }}/>
        <div style={{
          position: 'absolute', left: `calc(${value * 100}% - 8px)`, top: -6.5,
          width: 16, height: 16, borderRadius: '50%',
          background: 'var(--tv-paper)',
          border: '1.5px solid var(--tv-gold)',
          boxShadow: 'var(--tv-shadow-soft)',
        }}/>
      </div>
    </div>
  );
}

function ThemePicker({ theme, onChange }) {
  const options = [
    { id: 'light',  label: '라이트', icon: <IconSun size={20}/> },
    { id: 'dark',   label: '다크',   icon: <IconMoon size={20}/> },
    { id: 'system', label: '시스템', icon: <IconSystem size={20}/> },
  ];
  return (
    <div style={{ padding: 8, display: 'flex', gap: 8 }}>
      {options.map((o) => {
        const active = theme === o.id;
        return (
          <button key={o.id} onClick={() => onChange(o.id)} style={{
            flex: 1, padding: '14px 8px', borderRadius: 'var(--tv-r-md)',
            border: active ? '1.5px solid var(--tv-gold)' : '1px solid var(--tv-line)',
            background: active ? 'var(--tv-gold-bg)' : 'transparent',
            color: active ? 'var(--tv-gold)' : 'var(--tv-text-mid)',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
            cursor: 'pointer',
            transition: 'all 200ms var(--tv-ease)',
            fontFamily: 'inherit',
          }}>
            {o.icon}
            <span className="tv-body" style={{ fontSize: 12, fontWeight: 500, letterSpacing: '0.02em' }}>{o.label}</span>
          </button>
        );
      })}
    </div>
  );
}

function LinkRow({ icon, title, sub }) {
  return (
    <div style={{
      padding: '14px 16px',
      display: 'flex', alignItems: 'center', gap: 14,
      cursor: 'pointer',
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 'var(--tv-r-md)',
        background: 'var(--tv-gold-bg)', color: 'var(--tv-gold)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="tv-body" style={{ fontSize: 15, fontWeight: 500, color: 'var(--tv-text-hi)' }}>{title}</div>
        {sub && <div className="tv-body" style={{ fontSize: 12, color: 'var(--tv-text-mid)', marginTop: 2 }}>{sub}</div>}
      </div>
      <span style={{ color: 'var(--tv-text-lo)', display: 'flex' }}>
        <IconChevronRight size={18}/>
      </span>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// 6. Loading state
// ════════════════════════════════════════════════════════════
function ScreenLoading({ dark = false }) {
  return (
    <div className="tv-root" style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center',
      paddingTop: 50, paddingBottom: 34,
      gap: 28,
    }}>
      <div style={{ color: 'var(--tv-text-hi)', opacity: 0.45, position: 'relative' }}>
        <CathedralStipple width={220} color="var(--tv-text-hi)"/>
        {/* shimmer overlay */}
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(110deg, transparent 30%, var(--tv-bg-2) 50%, transparent 70%)',
          opacity: 0.6,
          mixBlendMode: 'screen',
          animation: 'tvShimmer 2.2s infinite linear',
        }}/>
      </div>

      <div style={{ textAlign: 'center' }}>
        <div className="tv-display-it" style={{
          fontSize: 13, color: 'var(--tv-text-lo)',
          letterSpacing: '0.18em', textTransform: 'uppercase',
        }}>Loading today</div>
        <div className="tv-verse" style={{
          fontSize: 18, color: 'var(--tv-text-mid)', marginTop: 6,
          letterSpacing: '0.02em',
        }}>오늘의 구절을 가져오는 중…</div>
      </div>

      {/* breathing dot */}
      <div style={{
        width: 7, height: 7, borderRadius: '50%',
        background: 'var(--tv-gold)',
        animation: 'tvBreathe 1.6s infinite ease-in-out',
      }}/>
    </div>
  );
}

Object.assign(window, {
  ScreenMain, ScreenBookDescription, ScreenVerse,
  ScreenHistory, ScreenSettings, ScreenLoading,
  TopBar, GhostButton, PageDots, TtsPill,
});
