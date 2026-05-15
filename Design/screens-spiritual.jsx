/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, TabBar, Icon */

// ─── 9. VERSET DU JOUR ─────────────────────────────────────────
const VerseScreen = () => (
  <Phone>
    <div className="phone-scroll" style={{ background: 'var(--bg)' }}>
      <ScreenHeader
        eyebrow="Spirituel"
        title="Verset & Annonces"
        right={<><RoundIcon><Icon.Search size={14}/></RoundIcon><RoundIcon><Icon.Bell size={14}/></RoundIcon></>}
      />

      <div style={{ padding: '0 16px 14px', display: 'flex', gap: 6 }}>
        {['Verset du jour', 'Annonces', 'Méditations', 'Archives'].map((c, i) => (
          <span key={i} className={`chip ${i === 0 ? 'active' : ''}`}>{c}</span>
        ))}
      </div>

      {/* Verse — editorial card */}
      <div style={{
        margin: '0 16px', padding: '32px 24px 28px',
        background: 'var(--ink)', color: '#fff', borderRadius: 22, position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', top: 18, right: 22, width: 16, height: 16, opacity: 0.5 }}>
          <Icon.Cross size={16} stroke={1}/>
        </div>
        <span className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'rgba(255,255,255,0.55)' }}>JEUDI 8 MAI · PSAUME 23.1–4</span>
        <p className="serif" style={{ fontSize: 26, fontWeight: 400, lineHeight: 1.3, margin: '18px 0 0', letterSpacing: '-0.005em' }}>
          « L'Éternel est mon berger : je ne manquerai de rien. Il me fait reposer dans de verts pâturages, il me dirige près des eaux paisibles. »
        </p>
        <div className="between" style={{ marginTop: 28, paddingTop: 16, borderTop: '1px solid rgba(255,255,255,0.12)' }}>
          <div className="row" style={{ gap: 16 }}>
            <span className="row" style={{ gap: 5, fontSize: 11, color: 'rgba(255,255,255,0.65)' }}><Icon.Heart size={13}/> 482</span>
            <span className="row" style={{ gap: 5, fontSize: 11, color: 'rgba(255,255,255,0.65)' }}><Icon.Send size={13}/> Partager</span>
          </div>
          <span className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'rgba(255,255,255,0.45)' }}>SEGOND 21</span>
        </div>
      </div>

      <div style={{ padding: '14px 20px 6px' }}>
        <span className="eyebrow">Méditation du jour</span>
      </div>
      <div style={{
        margin: '0 16px', padding: '20px 22px',
        background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 18,
      }}>
        <div className="row" style={{ gap: 10 }}>
          <Avatar size="sm" name="Pasteur Mwamba" color="#b89456"/>
          <div className="col" style={{ flex: 1 }}>
            <span style={{ fontSize: 13, fontWeight: 500 }}>Pasteur Joseph Mwamba</span>
            <span className="meta" style={{ fontSize: 11 }}>Direction nationale · 4 min de lecture</span>
          </div>
        </div>
        <h3 className="serif" style={{ fontSize: 21, fontWeight: 400, margin: '14px 0 8px', letterSpacing: '-0.01em', lineHeight: 1.2 }}>
          Reposer en celui qui pourvoit
        </h3>
        <p style={{ fontSize: 13, lineHeight: 1.55, color: 'var(--ink-2)', margin: 0 }}>
          David ne dit pas qu'il ne manque de rien parce qu'il est riche, mais parce que l'Éternel est son berger. Le repos est la posture du croyant qui a appris à se confier…
        </p>
        <div className="between" style={{ marginTop: 14 }}>
          <Tag>LECTURE</Tag>
          <span className="mono" style={{ fontSize: 10, color: 'var(--muted)' }}>LIRE LA SUITE →</span>
        </div>
      </div>

      <div className="section-h"><h3>Annonces de la semaine</h3><span className="more">3 nouvelles</span></div>
      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)', borderBottom: '1px solid var(--hair)' }}>
        {[
          { t: 'Camp national de jeunes — inscriptions', d: '15-22 août · Goma · 250 places', tag: 'CAMP', c: 'var(--accent)' },
          { t: 'Collecte spéciale — Édifice Gospel', d: 'Objectif 12 000 USD · 64% atteint', tag: 'FINANCE', c: 'var(--gold)' },
          { t: 'Nouveau cycle de discipulat L2', d: 'Démarrage 20 mai · 8 places', tag: 'FORMATION', c: 'var(--positive)' },
        ].map((a, i) => (
          <div key={i} className="list-row">
            <div style={{ width: 4, height: 36, borderRadius: 2, background: a.c }}/>
            <div className="col" style={{ flex: 1, gap: 2 }}>
              <span style={{ fontSize: 13, fontWeight: 500 }}>{a.t}</span>
              <span className="meta">{a.d}</span>
            </div>
            <Icon.Chevron size={14} stroke={1.5} style={{ color: 'var(--muted-2)' }}/>
          </div>
        ))}
      </div>
      <div style={{ height: 16 }}/>
    </div>
    <TabBar active="spirit" />
  </Phone>
);

// ─── 10. CHAÎNE DE PRIÈRE ──────────────────────────────────────
const PrayerChainScreen = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="Intercession · 24h"
        title="Chaîne de prière"
        right={<><RoundIcon><Icon.More size={14}/></RoundIcon></>}
      />

      {/* Chain hero */}
      <div style={{ margin: '0 16px', padding: '20px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 18 }}>
        <div className="between">
          <div className="col" style={{ gap: 4 }}>
            <span style={{ fontSize: 14, fontWeight: 500 }}>Réveil de Pentecôte 2026</span>
            <span className="meta" style={{ fontSize: 11 }}>BBC · UNIKIN · Démarrée il y a 14h</span>
          </div>
          <Tag kind="success">EN COURS</Tag>
        </div>
        <div style={{ marginTop: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ position: 'relative', width: 60, height: 60 }}>
            <svg width="60" height="60" style={{ transform: 'rotate(-90deg)' }}>
              <circle cx="30" cy="30" r="26" fill="none" stroke="var(--hair)" strokeWidth="3"/>
              <circle cx="30" cy="30" r="26" fill="none" stroke="var(--ink)" strokeWidth="3"
                strokeLinecap="round" strokeDasharray={`${2 * Math.PI * 26 * 0.58} ${2 * Math.PI * 26}`}/>
            </svg>
            <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span className="serif tabular" style={{ fontSize: 18 }}>14h</span>
            </div>
          </div>
          <div className="col" style={{ flex: 1, gap: 4 }}>
            <div className="between">
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.12em' }}>SLOTS COUVERTS</span>
              <span className="serif tabular" style={{ fontSize: 18 }}>14 / 24</span>
            </div>
            <Bar value={14/24}/>
            <span className="meta" style={{ fontSize: 10.5 }}>10 créneaux libres · prochaine relève à 11:00</span>
          </div>
        </div>
      </div>

      {/* Slot grid */}
      <div className="section-h"><h3>Créneaux 24h</h3><span className="more">Aujourd'hui</span></div>
      <div style={{ margin: '0 16px 14px', padding: '14px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 5 }}>
          {Array.from({ length: 24 }).map((_, i) => {
            const filled = [0,1,2,3,5,6,7,9,10,11,12,14,15,17,21,22].includes(i);
            const me = i === 10;
            const open = !filled;
            return (
              <div key={i} style={{
                aspectRatio: '1', borderRadius: 8,
                background: me ? 'var(--ink)' : filled ? 'var(--surface-2)' : 'transparent',
                border: '1px solid ' + (me ? 'var(--ink)' : 'var(--hair)'),
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: me ? '#fff' : open ? 'var(--muted-2)' : 'var(--ink)',
                fontSize: 10, fontWeight: 500,
                fontFamily: 'var(--mono)',
              }}>{String(i).padStart(2, '0')}h</div>
            );
          })}
        </div>
        <div className="between" style={{ marginTop: 12 }}>
          <div className="row" style={{ gap: 12 }}>
            <span className="row" style={{ gap: 5, fontSize: 10.5 }}>
              <span style={{ width: 9, height: 9, borderRadius: 3, background: 'var(--ink)' }}/>Vous
            </span>
            <span className="row" style={{ gap: 5, fontSize: 10.5 }}>
              <span style={{ width: 9, height: 9, borderRadius: 3, background: 'var(--surface-2)', border: '1px solid var(--hair)' }}/>Pris
            </span>
            <span className="row" style={{ gap: 5, fontSize: 10.5 }}>
              <span style={{ width: 9, height: 9, borderRadius: 3, border: '1px solid var(--hair)' }}/>Libre
            </span>
          </div>
        </div>
      </div>

      {/* Current intercessor */}
      <div className="section-h"><h3>Maintenant · 09h00 — 10h00</h3></div>
      <div style={{ margin: '0 16px 12px', padding: '16px', background: 'var(--ink)', color: '#fff', borderRadius: 16 }}>
        <div className="row" style={{ gap: 12 }}>
          <Avatar size="md" name="Marie Lumbu" color="#b89456"/>
          <div className="col" style={{ flex: 1, gap: 2 }}>
            <span style={{ fontSize: 14, fontWeight: 500 }}>Marie Lumbu</span>
            <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.6)' }}>Intercède maintenant · Sujet n°4</span>
          </div>
          <RoundIcon dark><Icon.Send size={14}/></RoundIcon>
        </div>
      </div>

      {/* Sujets de prière */}
      <div className="section-h"><h3>Sujets de prière</h3><span className="more">8 actifs</span></div>
      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)' }}>
        {[
          { n: '01', t: 'Réveil de la jeunesse universitaire', m: 24 },
          { n: '02', t: 'Famille du frère Mukendi (deuil)', m: 18 },
          { n: '03', t: 'Examens nationaux — étudiants L3', m: 12 },
          { n: '04', t: 'Église persécutée — Sahel', m: 9 },
        ].map((s, i) => (
          <div key={i} className="list-row" style={{ padding: '14px 20px' }}>
            <span className="mono" style={{ fontSize: 11, color: 'var(--muted-2)', width: 22 }}>{s.n}</span>
            <span style={{ flex: 1, fontSize: 13 }}>{s.t}</span>
            <span className="row" style={{ gap: 5, fontSize: 10.5, color: 'var(--muted)' }}>
              <Icon.Heart size={12}/>{s.m}
            </span>
          </div>
        ))}
      </div>
      <div style={{ padding: '14px 16px 18px' }}>
        <button className="btn btn-primary btn-block">Réserver un créneau <Icon.Plus size={13}/></button>
      </div>
    </div>
    <TabBar active="spirit" />
  </Phone>
);

Object.assign(window, { VerseScreen, PrayerChainScreen });
