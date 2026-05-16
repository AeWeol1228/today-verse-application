// stipple.jsx — Procedural stippling cathedral illustration
// Generates thousands of ink dots arranged in cathedral silhouette.
// Single-color (currentColor) so it inherits from parent.

function mulberry32(seed) {
  let s = seed >>> 0;
  return function () {
    s |= 0; s = (s + 0x6D2B79F5) | 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Generates a dot list inside `inside(x,y)`-defined region.
// density = dots per 1000 sq-px. Sizes are tone-weighted by `tone(x,y)`.
function fillRegion(rng, bounds, inside, opts) {
  const { density = 6, tone = () => 1, maxR = 1.0, minR = 0.35, jitter = 0 } = opts;
  const { x0, y0, x1, y1 } = bounds;
  const area = (x1 - x0) * (y1 - y0);
  const n = Math.floor((area / 1000) * density);
  const dots = [];
  let tries = 0;
  while (dots.length < n && tries < n * 12) {
    tries++;
    const x = x0 + rng() * (x1 - x0);
    const y = y0 + rng() * (y1 - y0);
    if (!inside(x, y)) continue;
    const t = tone(x, y);          // 0 = sparse highlight, 1 = dense shadow
    if (rng() > t) continue;       // probabilistic skip for highlights
    const jx = (rng() - 0.5) * jitter;
    const jy = (rng() - 0.5) * jitter;
    const r = minR + rng() * (maxR - minR) * (0.6 + 0.4 * t);
    dots.push([x + jx, y + jy, r]);
  }
  return dots;
}

// Sharper edge strokes (architectural outlines) — denser dots along a line.
function strokeLine(rng, x1, y1, x2, y2, opts = {}) {
  const { width = 1.2, density = 1.6, jitter = 0.6, r = 0.45 } = opts;
  const len = Math.hypot(x2 - x1, y2 - y1);
  const n = Math.floor(len * density);
  const dx = (x2 - x1) / n;
  const dy = (y2 - y1) / n;
  const nx = -(y2 - y1) / len;
  const ny = (x2 - x1) / len;
  const out = [];
  for (let i = 0; i <= n; i++) {
    for (let k = 0; k < 2; k++) {
      const off = (rng() - 0.5) * width;
      const jx = (rng() - 0.5) * jitter;
      const jy = (rng() - 0.5) * jitter;
      out.push([x1 + dx * i + nx * off + jx, y1 + dy * i + ny * off + jy, r + rng() * 0.2]);
    }
  }
  return out;
}

function buildCathedralDots(seed = 7) {
  const rng = mulberry32(seed);
  const W = 400, H = 560;
  const all = [];

  // ── Geometry definitions ────────────────────────────────
  // Center bay (nave + facade), 130 wide, runs from y=120 to y=470
  const bayX0 = 135, bayX1 = 265, bayTop = 150, bayBottom = 470;
  // Twin spires
  const lSpireX0 = 95,  lSpireX1 = 138, lSpireBaseY = 470, lSpireApexY = 60;
  const rSpireX0 = 262, rSpireX1 = 305, rSpireBaseY = 470, rSpireApexY = 60;
  // Central tower (pointed gable above facade)
  const gableApex = [200, 95];
  const gableLeft = [bayX0, bayTop];
  const gableRight = [bayX1, bayTop];
  // Rose window center
  const rose = { cx: 200, cy: 235, r: 38 };
  // Arched door
  const door = { x0: 178, x1: 222, top: 360, bottom: 460, archTop: 340 };
  // Side aisles (lower)
  const lAisleX0 = 60, lAisleX1 = 95, lAisleTop = 280, lAisleBottom = 470;
  const rAisleX0 = 305, rAisleX1 = 340, rAisleTop = 280, rAisleBottom = 470;

  // ── Helpers ─────────────────────────────────────────────
  const inPolygon = (px, py, pts) => {
    let inside = false;
    for (let i = 0, j = pts.length - 1; i < pts.length; j = i++) {
      const [xi, yi] = pts[i], [xj, yj] = pts[j];
      if (((yi > py) !== (yj > py)) &&
          (px < (xj - xi) * (py - yi) / (yj - yi) + xi)) inside = !inside;
    }
    return inside;
  };

  // Spire: trapezoid tapering to apex
  const inSpire = (x, y, x0, x1, baseY, apexY) => {
    if (y < apexY || y > baseY) return false;
    const t = (y - apexY) / (baseY - apexY);
    const halfW = (x1 - x0) * 0.5;
    const cx = (x0 + x1) * 0.5;
    // taper: top is 0.2 of base width, bottom is full
    const w = halfW * (0.18 + 0.82 * t);
    return Math.abs(x - cx) <= w;
  };

  // Vertical lighting: stone has gradient — top lighter, bottom darker; left edges slightly lit.
  const stoneTone = (x, y, baseTone = 0.6) => {
    const vert = 0.4 + (y - 80) / 500;             // darker lower
    const lit = 1 - Math.exp(-Math.abs(x - 110) / 70) * 0.25; // left-lit highlight
    return Math.min(1, baseTone * vert * lit);
  };

  // ── 1. Sky atmospheric stipple ──────────────────────────
  all.push(...fillRegion(rng, { x0: 0, y0: 0, x1: W, y1: 120 }, () => true, {
    density: 0.7, tone: (x, y) => 0.05 + (y / 200) * 0.15, minR: 0.25, maxR: 0.55,
  }));

  // ── 2. Twin spires ──────────────────────────────────────
  for (const [x0, x1, baseY, apexY] of [
    [lSpireX0, lSpireX1, lSpireBaseY, lSpireApexY],
    [rSpireX0, rSpireX1, rSpireBaseY, rSpireApexY],
  ]) {
    all.push(...fillRegion(rng, { x0: x0 - 2, y0: apexY, x1: x1 + 2, y1: baseY },
      (x, y) => inSpire(x, y, x0, x1, baseY, apexY),
      {
        density: 12,
        tone: (x, y) => {
          // strong vertical gradient on stone, slight edge-darken
          const cx = (x0 + x1) / 2;
          const edge = Math.abs(x - cx) / ((x1 - x0) / 2);
          return Math.min(1, 0.35 + (y - apexY) / (baseY - apexY) * 0.55 + edge * 0.15);
        },
        minR: 0.3, maxR: 0.95,
      }));

    // spire silhouette stroke
    const cx = (x0 + x1) / 2;
    all.push(...strokeLine(rng, cx, apexY, x0, baseY, { width: 0.8, density: 1.4, r: 0.5 }));
    all.push(...strokeLine(rng, cx, apexY, x1, baseY, { width: 0.8, density: 1.4, r: 0.5 }));

    // Small pinnacle balls
    for (let i = 0; i < 16; i++) {
      const a = (i / 16) * Math.PI * 2;
      all.push([cx + Math.cos(a) * 4, apexY + 6 + Math.sin(a) * 4, 0.6]);
    }

    // Cross at apex
    all.push(...strokeLine(rng, cx, apexY - 8, cx, apexY + 4, { width: 0.5, density: 2, r: 0.55 }));
    all.push(...strokeLine(rng, cx - 4, apexY - 4, cx + 4, apexY - 4, { width: 0.5, density: 2, r: 0.55 }));
  }

  // ── 3. Side aisles (lower flanking buildings) ───────────
  for (const [x0, x1, top, bottom] of [
    [lAisleX0, lAisleX1, lAisleTop, lAisleBottom],
    [rAisleX0, rAisleX1, rAisleTop, rAisleBottom],
  ]) {
    all.push(...fillRegion(rng, { x0, y0: top, x1, y1: bottom },
      () => true,
      {
        density: 10,
        tone: (x, y) => stoneTone(x, y, 0.55),
        minR: 0.28, maxR: 0.85,
      }));

    // narrow vertical windows (sparse interior)
    for (const winX of [(x0 + x1) / 2]) {
      all.push(...fillRegion(rng, { x0: winX - 5, y0: top + 20, x1: winX + 5, y1: bottom - 30 },
        () => true,
        { density: 18, tone: () => 0.9, minR: 0.4, maxR: 1.0 }));
    }
  }

  // ── 4. Central bay (facade) ─────────────────────────────
  // Gable polygon (the pointed top)
  const gablePts = [gableLeft, gableApex, gableRight];
  all.push(...fillRegion(rng, { x0: bayX0 - 2, y0: 90, x1: bayX1 + 2, y1: bayTop + 2 },
    (x, y) => inPolygon(x, y, gablePts),
    { density: 14, tone: (x, y) => stoneTone(x, y, 0.7), minR: 0.3, maxR: 0.95 }));

  // Gable cross
  const gcx = 200;
  all.push(...strokeLine(rng, gcx, 78, gcx, 100, { width: 0.5, density: 2.5, r: 0.55 }));
  all.push(...strokeLine(rng, gcx - 6, 86, gcx + 6, 86, { width: 0.5, density: 2.5, r: 0.55 }));

  // Main facade rectangle
  all.push(...fillRegion(rng, { x0: bayX0, y0: bayTop, x1: bayX1, y1: bayBottom },
    (x, y) => {
      // exclude rose window (dense ring + light center)
      const dr = Math.hypot(x - rose.cx, y - rose.cy);
      if (dr < rose.r - 4) return false;
      // exclude door interior
      if (x > door.x0 && x < door.x1 && y > door.archTop && y < door.bottom) {
        const dcx = (door.x0 + door.x1) / 2;
        const drad = (door.x1 - door.x0) / 2;
        if (y < door.top) {
          if (Math.hypot(x - dcx, y - door.top) < drad) return false;
        } else return false;
      }
      return true;
    },
    { density: 14, tone: (x, y) => stoneTone(x, y, 0.7), minR: 0.3, maxR: 0.95 }));

  // ── 5. Rose window: dense ring + radiating tracery ──────
  // outer ring (very dense)
  for (let a = 0; a < 360; a += 1.4) {
    const rad = a * Math.PI / 180;
    const r1 = rose.r;
    const r2 = rose.r - 5;
    for (let r = r2; r <= r1; r += 0.5) {
      const jr = r + (rng() - 0.5) * 0.6;
      all.push([rose.cx + Math.cos(rad) * jr, rose.cy + Math.sin(rad) * jr, 0.4 + rng() * 0.3]);
    }
  }
  // inner hub
  for (let i = 0; i < 90; i++) {
    const a = rng() * Math.PI * 2;
    const r = rng() * 6;
    all.push([rose.cx + Math.cos(a) * r, rose.cy + Math.sin(a) * r, 0.4 + rng() * 0.3]);
  }
  // 8 radiating spokes (tracery)
  for (let k = 0; k < 8; k++) {
    const a = (k / 8) * Math.PI * 2;
    const x1 = rose.cx + Math.cos(a) * 7;
    const y1 = rose.cy + Math.sin(a) * 7;
    const x2 = rose.cx + Math.cos(a) * (rose.r - 4);
    const y2 = rose.cy + Math.sin(a) * (rose.r - 4);
    all.push(...strokeLine(rng, x1, y1, x2, y2, { width: 0.5, density: 2.6, r: 0.42 }));
    // small foil at spoke end
    for (let i = 0; i < 18; i++) {
      const aa = (i / 18) * Math.PI * 2;
      const r = 2.6 + rng() * 0.5;
      all.push([x2 + Math.cos(aa) * r, y2 + Math.sin(aa) * r, 0.38]);
    }
  }

  // ── 6. Arched door (dense, dark interior) ───────────────
  // arched shape: rectangle + semicircular top
  const dcx = (door.x0 + door.x1) / 2;
  const drad = (door.x1 - door.x0) / 2;
  all.push(...fillRegion(rng,
    { x0: door.x0, y0: door.top, x1: door.x1, y1: door.bottom },
    (x, y) => {
      if (y >= door.archTop) return true;
      return Math.hypot(x - dcx, y - door.top) <= drad;
    },
    { density: 36, tone: () => 0.95, minR: 0.45, maxR: 1.1 }));
  // door arch outline (lighter, sharp)
  for (let a = Math.PI; a <= 2 * Math.PI; a += 0.05) {
    all.push([dcx + Math.cos(a) * drad, door.top + Math.sin(a) * drad, 0.7]);
  }
  // central door divider
  all.push(...strokeLine(rng, dcx, door.archTop - 2, dcx, door.bottom, { width: 0.6, density: 2, r: 0.5 }));

  // ── 7. Tall lancet windows on facade either side of rose
  for (const wx of [157, 243]) {
    all.push(...fillRegion(rng, { x0: wx - 5, y0: 220, x1: wx + 5, y1: 310 },
      (x, y) => {
        if (y < 230) {
          return Math.hypot(x - wx, y - 230) <= 5;
        }
        return true;
      },
      { density: 30, tone: () => 0.92, minR: 0.4, maxR: 1.0 }));
  }

  // ── 8. Stone joint horizontal lines (architectural courses)
  for (const y of [195, 320, 410]) {
    all.push(...strokeLine(rng, bayX0 + 4, y, bayX1 - 4, y, { width: 0.4, density: 1.4, r: 0.35 }));
  }

  // ── 9. Foreground stairs (3 steps) ──────────────────────
  for (let i = 0; i < 3; i++) {
    const y0 = 458 + i * 8;
    const x0 = 165 - i * 12;
    const x1 = 235 + i * 12;
    all.push(...fillRegion(rng, { x0, y0, x1, y1: y0 + 8 }, () => true,
      { density: 14, tone: (x, y) => 0.55 + i * 0.1, minR: 0.32, maxR: 0.85 }));
    all.push(...strokeLine(rng, x0, y0, x1, y0, { width: 0.4, density: 1.2, r: 0.4 }));
  }

  // ── 10. Ground line + scattered foreground ─────────────
  all.push(...strokeLine(rng, 0, 485, W, 485, { width: 0.6, density: 1.2, r: 0.4 }));
  all.push(...fillRegion(rng, { x0: 0, y0: 485, x1: W, y1: H }, () => true,
    { density: 3, tone: (x, y) => 0.1 + ((y - 485) / 80) * 0.4, minR: 0.3, maxR: 0.75 }));

  return all;
}

// Cache so we generate once
let _stippleCache = null;
function getStippleDots() {
  if (_stippleCache) return _stippleCache;
  _stippleCache = buildCathedralDots(11);
  return _stippleCache;
}

function CathedralStipple({ width = 320, color = 'currentColor', style = {} }) {
  const dots = React.useMemo(() => getStippleDots(), []);
  const W = 400, H = 560;
  return (
    <svg
      viewBox={`0 0 ${W} ${H}`}
      style={{ width, height: 'auto', display: 'block', color, ...style }}
      shapeRendering="geometricPrecision"
    >
      <g fill={color}>
        {dots.map(([x, y, r], i) => (
          <circle key={i} cx={x.toFixed(1)} cy={y.toFixed(1)} r={r.toFixed(2)} />
        ))}
      </g>
    </svg>
  );
}

Object.assign(window, { CathedralStipple });
