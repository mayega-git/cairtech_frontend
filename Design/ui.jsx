/* global React */
// Phone shell + shared UI atoms

const Phone = ({ children, statusDark = false, homeDark = false, time = "9:41" }) => (
  <div className="phone">
    <div className={`phone-statusbar ${statusDark ? 'dark' : ''}`}>
      <span>{time}</span>
      <div className="right">
        <Icon.Signal />
        <Icon.Wifi />
        <Icon.Battery />
      </div>
    </div>
    <div className="phone-notch" />
    <div className="phone-content">{children}</div>
    <div className={`phone-home ${homeDark ? 'dark' : ''}`} />
  </div>
);

const ScreenHeader = ({ eyebrow, title, right, sub, dense = false, dark = false }) => (
  <div style={{
    padding: dense ? '14px 20px 10px' : '18px 20px 14px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    background: dark ? 'var(--ink)' : 'transparent',
    color: dark ? '#fff' : 'inherit',
  }}>
    <div className="col" style={{ gap: 2 }}>
      {eyebrow && <span className="eyebrow" style={{ color: dark ? 'rgba(255,255,255,0.55)' : undefined }}>{eyebrow}</span>}
      <span style={{
        fontSize: dense ? 17 : 22,
        fontWeight: dense ? 600 : 500,
        letterSpacing: '-0.015em',
        lineHeight: 1.15,
      }}>{title}</span>
      {sub && <span className="muted" style={{ fontSize: 12, marginTop: 2, color: dark ? 'rgba(255,255,255,0.55)' : undefined }}>{sub}</span>}
    </div>
    <div style={{ display: 'flex', gap: 6 }}>{right}</div>
  </div>
);

const RoundIcon = ({ children, dark = false, size = 36 }) => (
  <div style={{
    width: size, height: size, borderRadius: 999,
    border: `1px solid ${dark ? 'rgba(255,255,255,0.16)' : 'var(--hair)'}`,
    background: dark ? 'rgba(255,255,255,0.04)' : 'var(--surface)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    color: dark ? 'rgba(255,255,255,0.85)' : 'var(--ink)',
  }}>{children}</div>
);

const Tag = ({ children, kind = 'default', style }) => (
  <span className={`tag ${kind === 'default' ? '' : 'tag-' + kind}`} style={style}>{children}</span>
);

const Avatar = ({ name, color, size = 'md', src }) => {
  const init = (name || '?').split(' ').filter(Boolean).slice(0, 2).map(s => s[0]).join('').toUpperCase();
  const cls = `avatar ${size === 'sm' ? 'sm' : size === 'lg' ? 'lg' : ''}`;
  return (
    <div className={cls} style={color ? { background: color } : {}}>
      {src ? <img src={src} style={{ width: '100%', height: '100%', borderRadius: 999, objectFit: 'cover' }} /> : init}
    </div>
  );
};

const Bar = ({ value = 0.5, color = 'var(--ink)', track = 'var(--hair)', height = 4 }) => (
  <div className="bar" style={{ background: track, height }}>
    <div style={{ width: `${Math.max(0, Math.min(1, value)) * 100}%`, background: color }} />
  </div>
);

const Donut = ({ value = 0.78, size = 120, stroke = 8, color = 'var(--ink)', track = 'var(--hair)', children }) => {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} className="donut">
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={track} strokeWidth={stroke} />
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeLinecap="round" strokeDasharray={`${c * value} ${c}`} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {children}
      </div>
    </div>
  );
};

const Sparkline = ({ data, width = 320, height = 80, color = 'var(--ink)', fill = 'rgba(11,14,26,0.06)' }) => {
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const step = width / (data.length - 1);
  const pts = data.map((v, i) => `${i * step},${height - ((v - min) / range) * (height - 8) - 4}`);
  const d = `M${pts.join(' L')}`;
  const fillD = `${d} L${width},${height} L0,${height} Z`;
  return (
    <svg width={width} height={height} style={{ display: 'block' }}>
      <path d={fillD} fill={fill} />
      <path d={d} fill="none" stroke={color} strokeWidth={1.5} strokeLinejoin="round" />
      {data.map((v, i) => i === data.length - 1 && (
        <circle key={i} cx={i * step} cy={height - ((v - min) / range) * (height - 8) - 4} r={3} fill={color} />
      ))}
    </svg>
  );
};

const TabBar = ({ active = 'home' }) => (
  <div className="tabbar">
    {[
      { id: 'home', label: 'Accueil', icon: <Icon.Home /> },
      { id: 'meet', label: 'Réunions', icon: <Icon.Calendar /> },
      { id: 'people', label: 'Membres', icon: <Icon.Users /> },
      { id: 'spirit', label: 'Spirituel', icon: <Icon.Dove /> },
      { id: 'me', label: 'Profil', icon: <Icon.User /> },
    ].map(t => (
      <a key={t.id} className={active === t.id ? 'active' : ''}>
        {t.icon}
        <span>{t.label}</span>
      </a>
    ))}
  </div>
);

// --- Icons (1.25–1.5px stroke, 24px frame) ---
const ic = (path, viewBox = "0 0 24 24") => ({ size = 18, stroke = 1.5, ...p } = {}) => (
  <svg width={size} height={size} viewBox={viewBox} fill="none" stroke="currentColor"
    strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round" {...p}>
    {path}
  </svg>
);

const Icon = {
  Signal: ic(<><path d="M2 18h2v2H2zM6 14h2v6H6zM10 10h2v10h-2zM14 6h2v14h-2z" fill="currentColor" stroke="none"/></>, "0 0 18 22"),
  Wifi: ic(<><path d="M5 12.55a11 11 0 0 1 14 0"/><path d="M8.5 16.05a6 6 0 0 1 7 0"/><path d="M12 19.5h.01"/></>),
  Battery: () => (
    <svg width="22" height="12" viewBox="0 0 22 12" fill="none">
      <rect x="0.5" y="0.5" width="18" height="11" rx="2.5" stroke="currentColor" />
      <rect x="2" y="2" width="14" height="8" rx="1" fill="currentColor" />
      <rect x="20" y="4" width="2" height="4" rx="1" fill="currentColor" />
    </svg>
  ),
  Home: ic(<><path d="M3 11l9-8 9 8"/><path d="M5 9.5V21h14V9.5"/></>),
  Calendar: ic(<><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></>),
  Users: ic(<><path d="M16 7a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/><path d="M3 21v-1a6 6 0 0 1 6-6h2"/><path d="M16.5 14h.5a4 4 0 0 1 4 4v3"/><circle cx="18.5" cy="9.5" r="2.5"/></>),
  Dove: ic(<><path d="M3 14c2 0 4-1 5-3 1 4 4 5 7 5 3 0 6-2 6-5l-3 1c0-3-3-5-6-4-2 1-3 2-3 4l-2-1c-2 0-4 1-4 3z"/></>),
  User: ic(<><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>),
  Search: ic(<><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></>),
  Plus: ic(<><path d="M12 5v14M5 12h14"/></>),
  Arrow: ic(<><path d="M5 12h14M13 6l6 6-6 6"/></>),
  ArrowL: ic(<><path d="M19 12H5M11 6l-6 6 6 6"/></>),
  Check: ic(<><path d="M5 12l5 5L20 7"/></>),
  X: ic(<><path d="M6 6l12 12M18 6L6 18"/></>),
  Bell: ic(<><path d="M6 8a6 6 0 1 1 12 0c0 6 2 7 2 7H4s2-1 2-7"/><path d="M10 19a2 2 0 0 0 4 0"/></>),
  Filter: ic(<><path d="M3 6h18M6 12h12M10 18h4"/></>),
  Mail: ic(<><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></>),
  Lock: ic(<><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></>),
  Eye: ic(<><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></>),
  Pin: ic(<><path d="M12 22s7-7.5 7-13a7 7 0 1 0-14 0c0 5.5 7 13 7 13z"/><circle cx="12" cy="9" r="2.5"/></>),
  Clock: ic(<><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>),
  Coin: ic(<><circle cx="12" cy="12" r="9"/><path d="M9 9c0-1 1-2 3-2s3 1 3 2-1 2-3 2-3 1-3 2 1 2 3 2 3-1 3-2"/><path d="M12 5v2M12 17v2"/></>),
  TrendUp: ic(<><path d="M3 17l6-6 4 4 8-8"/><path d="M14 7h7v7"/></>),
  Sparkle: ic(<><path d="M12 3v6M12 15v6M3 12h6M15 12h6"/></>),
  Cross: ic(<><path d="M12 3v18M6 9h12"/></>),
  Chevron: ic(<><path d="m9 6 6 6-6 6"/></>),
  ChevronD: ic(<><path d="m6 9 6 6 6-6"/></>),
  Camera: ic(<><path d="M3 8h3l2-3h8l2 3h3v11H3z"/><circle cx="12" cy="13" r="4"/></>),
  More: ic(<><circle cx="5" cy="12" r="1.5" fill="currentColor"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/><circle cx="19" cy="12" r="1.5" fill="currentColor"/></>),
  Edit: ic(<><path d="M4 20h4l10-10-4-4L4 16v4z"/></>),
  Heart: ic(<><path d="M12 21s-7-4.5-9-9C1.5 8 4 4 8 5c2 .5 3 2 4 3 1-1 2-2.5 4-3 4-1 6.5 3 5 7-2 4.5-9 9-9 9z"/></>),
  Phone: ic(<><path d="M5 4h4l2 5-3 2a11 11 0 0 0 5 5l2-3 5 2v4a2 2 0 0 1-2 2A18 18 0 0 1 3 6a2 2 0 0 1 2-2z"/></>),
  Map: ic(<><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2z"/><path d="M9 4v14M15 6v14"/></>),
  Book: ic(<><path d="M4 4h7a3 3 0 0 1 3 3v14"/><path d="M20 4h-7a3 3 0 0 0-3 3v14"/><path d="M4 4v15a2 2 0 0 0 2 2h14"/></>),
  Mic: ic(<><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></>),
  Layers: ic(<><path d="M12 3 3 8l9 5 9-5-9-5z"/><path d="m3 13 9 5 9-5M3 18l9 5 9-5"/></>),
  Send: ic(<><path d="M22 2 11 13M22 2 15 22l-4-9-9-4 20-7z"/></>),
  Settings: ic(<><circle cx="12" cy="12" r="3"/><path d="M19 12c0 .7-.1 1.3-.2 2l2 1.5-2 3.5-2.3-1c-1 .8-2.1 1.4-3.3 1.7L13 22h-4l-.2-2.3a8 8 0 0 1-3.3-1.7l-2.3 1-2-3.5 2-1.5c-.1-.7-.2-1.3-.2-2s.1-1.3.2-2l-2-1.5 2-3.5 2.3 1c1-.8 2.1-1.4 3.3-1.7L9 2h4l.2 2.3a8 8 0 0 1 3.3 1.7l2.3-1 2 3.5-2 1.5c.1.7.2 1.3.2 2z"/></>),
  Shield: ic(<><path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6l-8-3z"/></>),
  Logout: ic(<><path d="M9 4H5v16h4M16 8l4 4-4 4M9 12h11"/></>),
};

Object.assign(window, { Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, Donut, Sparkline, TabBar, Icon });
