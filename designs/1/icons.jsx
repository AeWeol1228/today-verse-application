// icons.jsx — Hand-tuned line icons for 오늘의 구절
// stroke="currentColor", 24x24 viewBox, 1.6 px effective stroke.

function Icon({ size = 24, stroke = 1.6, children, style = {} }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth={stroke}
      strokeLinecap="round" strokeLinejoin="round"
      style={{ display: 'block', ...style }}>
      {children}
    </svg>
  );
}

// Book — closed book, verse entry
const IconBook = (p) => (
  <Icon {...p}>
    <path d="M4 5.5C4 4.67 4.67 4 5.5 4H11v15H5.5C4.67 19 4 18.33 4 17.5V5.5z"/>
    <path d="M20 5.5C20 4.67 19.33 4 18.5 4H13v15h5.5c.83 0 1.5-.67 1.5-1.5V5.5z"/>
    <path d="M11 4v15M13 4v15"/>
    <path d="M6 19v2M18 19v2"/>
  </Icon>
);

// Clock — history (with subtle hands)
const IconClock = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="8.5"/>
    <path d="M12 7.5V12l3 2"/>
  </Icon>
);

// Settings — minimal sliders
const IconSettings = (p) => (
  <Icon {...p}>
    <path d="M5 7h7M16 7h3"/>
    <path d="M5 17h3M12 17h7"/>
    <circle cx="14" cy="7" r="2"/>
    <circle cx="10" cy="17" r="2"/>
  </Icon>
);

// Play
const IconPlay = (p) => (
  <Icon {...p}>
    <path d="M8 5.5v13l11-6.5L8 5.5z" fill="currentColor" stroke="none"/>
  </Icon>
);

// Pause
const IconPause = (p) => (
  <Icon {...p}>
    <rect x="7" y="5" width="3.5" height="14" rx="1" fill="currentColor" stroke="none"/>
    <rect x="13.5" y="5" width="3.5" height="14" rx="1" fill="currentColor" stroke="none"/>
  </Icon>
);

// Chevron left
const IconChevronLeft = (p) => (
  <Icon {...p}>
    <path d="M14.5 6L9 12l5.5 6"/>
  </Icon>
);

// Chevron right
const IconChevronRight = (p) => (
  <Icon {...p}>
    <path d="M9.5 6L15 12l-5.5 6"/>
  </Icon>
);

// App symbol — small cross-on-book-spine glyph for the app icon
const AppSymbol = ({ size = 28, style = {} }) => (
  <svg width={size} height={size} viewBox="0 0 32 32" fill="none"
    style={{ display: 'block', ...style }}>
    {/* Stylized arch with a thin cross at the top — quiet, editorial */}
    <path d="M16 4 C 11 4 8 7 8 12 V 26 C 8 27.1 8.9 28 10 28 H 22 C 23.1 28 24 27.1 24 26 V 12 C 24 7 21 4 16 4 Z"
      stroke="currentColor" strokeWidth="1.4" fill="none"/>
    <path d="M16 9 V 16 M 13 12.5 H 19" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
    <circle cx="16" cy="22" r="1" fill="currentColor"/>
  </svg>
);

// Sun / moon for theme switcher
const IconSun = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="3.5"/>
    <path d="M12 3.5v2M12 18.5v2M3.5 12h2M18.5 12h2M5.5 5.5l1.5 1.5M17 17l1.5 1.5M5.5 18.5l1.5-1.5M17 7l1.5-1.5"/>
  </Icon>
);
const IconMoon = (p) => (
  <Icon {...p}>
    <path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>
  </Icon>
);
const IconSystem = (p) => (
  <Icon {...p}>
    <rect x="3.5" y="5" width="17" height="12" rx="2"/>
    <path d="M8 21h8M12 17v4"/>
  </Icon>
);

// Volume
const IconVolume = (p) => (
  <Icon {...p}>
    <path d="M4 9.5v5h3l4 3.5V6L7 9.5H4z"/>
    <path d="M14.5 8.5a5 5 0 0 1 0 7M17.5 6a8 8 0 0 1 0 12"/>
  </Icon>
);

// Heart for support
const IconHeart = (p) => (
  <Icon {...p}>
    <path d="M12 19.5s-6.5-3.7-8.5-8C2 8 4.5 4.5 8 5c1.7.3 3 1.4 4 3 1-1.6 2.3-2.7 4-3 3.5-.5 6 3 4.5 6.5-2 4.3-8.5 8-8.5 8z"/>
  </Icon>
);

const IconChevronUpRight = (p) => (
  <Icon {...p}>
    <path d="M7 17 L 17 7 M 10 7 H 17 V 14"/>
  </Icon>
);

const IconCross = (p) => (
  <Icon {...p}>
    <path d="M6 6l12 12M18 6L6 18"/>
  </Icon>
);

Object.assign(window, {
  Icon, IconBook, IconClock, IconSettings, IconPlay, IconPause,
  IconChevronLeft, IconChevronRight, AppSymbol,
  IconSun, IconMoon, IconSystem, IconVolume, IconHeart,
  IconChevronUpRight, IconCross,
});
