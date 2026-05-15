/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, TabBar, Icon */

// ─── 14. ÉVANGÉLISATION ───────────────────────────────────────
const EvangelismScreen = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="Mission · Avril → Mai"
        title="Évangélisation"
        right={<><RoundIcon><Icon.Map size={14}/></RoundIcon><RoundIcon><Icon.Plus size={14}/></RoundIcon></>}
      />

      {/* Active program */}
      <div style={{ margin: '0 16px', padding: '20px 22px', background: 'var(--ink)', color: '#fff', borderRadius: 20, position: 'relative', overflow: 'hidden' }}>
        <div className="between">
          <Tag style={{ background: 'rgba(255,255,255,0.08)', color: '#fff', borderColor: 'rgba(255,255,255,0.16)' }}>EN COURS</Tag>
          <span className="mono" style={{ fontSize: 10, color: 'rgba(255,255,255,0.55)', letterSpacing: '0.12em' }}>J+12 / 30</span>
        </div>
        <h2 className="serif" style={{ fontSize: 24, fontWeight: 400, margin: '14px 0 4px', letterSpacing: '-0.02em', lineHeight: 1.15 }}>
          Campus en feu — Mai 2026
        </h2>
        <p style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.7)', margin: 0, lineHeight: 1.5 }}>
          Sortie quotidienne · 3 facultés ciblées · porte-à-porte cellules
        </p>

        <div style={{ marginTop: 18, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.12)', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {[
            { l: 'Évangélisés', v: '247' },
            { l: 'Décisions', v: '38' },
            { l: 'À suivre', v: '94' },
          ].map((s, i) => (
            <div key={i} className="col">
              <span className="serif" style={{ fontSize: 24, lineHeight: 1, letterSpacing: '-0.02em' }}>{s.v}</span>
              <span className="mono" style={{ fontSize: 9, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.12em', marginTop: 4 }}>{s.l.toUpperCase()}</span>
            </div>
          ))}
        </div>
      </div>

      {/* New record form preview */}
      <div className="section-h"><h3>Nouvel enregistrement</h3><span className="more">Anonyme OK</span></div>
      <div style={{ margin: '0 16px', padding: '18px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
        <div className="field">
          <label>Type de rencontre</label>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6 }}>
            {[
              { l: 'Personne', sel: true, ic: <Icon.User size={14}/> },
              { l: 'Groupe', sel: false, ic: <Icon.Users size={14}/> },
              { l: 'Famille', sel: false, ic: <Icon.Heart size={14}/> },
            ].map((t, i) => (
              <div key={i} style={{
                padding: '12px 0', textAlign: 'center', borderRadius: 10,
                fontSize: 12, fontWeight: 500,
                background: t.sel ? 'var(--ink)' : 'var(--surface-2)',
                color: t.sel ? '#fff' : 'var(--ink)',
                border: '1px solid ' + (t.sel ? 'var(--ink)' : 'var(--hair)'),
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              }}>{t.ic}<span>{t.l}</span></div>
            ))}
          </div>
        </div>

        <div className="field" style={{ marginTop: 12 }}>
          <label>Réponse</label>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {[
              { l: 'A reçu Christ', s: 'Décision claire — accompagnement immédiat', sel: true, c: 'var(--positive)' },
              { l: 'Intéressé', s: 'Désir de revoir, lecture de tract' },
              { l: 'Indifférent', s: 'Conversation respectueuse, pas de suite' },
              { l: 'Refus', s: 'Reste en prière' },
            ].map((r, i) => (
              <div key={i} style={{
                padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
                background: r.sel ? 'rgba(47,107,74,0.05)' : 'var(--surface-2)',
                border: '1px solid ' + (r.sel ? 'var(--positive)' : 'var(--hair)'),
                borderRadius: 10,
              }}>
                <div style={{
                  width: 18, height: 18, borderRadius: 999,
                  border: `1.5px solid ${r.sel ? 'var(--positive)' : 'var(--hair)'}`,
                  background: r.sel ? 'var(--positive)' : 'transparent',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>{r.sel && <div style={{ width: 7, height: 7, borderRadius: 999, background: '#fff' }}/>}</div>
                <div className="col" style={{ flex: 1, gap: 1 }}>
                  <span style={{ fontSize: 13, fontWeight: 500 }}>{r.l}</span>
                  <span className="meta" style={{ fontSize: 11 }}>{r.s}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="field" style={{ marginTop: 12 }}>
          <label>Lieu</label>
          <div className="field-inline-icon">
            <Icon.Pin size={15} stroke={1.4}/>
            <input defaultValue="Faculté Sciences · Hall central" />
          </div>
        </div>
      </div>

      <div style={{ padding: '14px 16px 8px', display: 'flex', gap: 8 }}>
        <button className="btn btn-ghost" style={{ flex: 1 }}>Anonyme</button>
        <button className="btn btn-primary" style={{ flex: 2 }}>Enregistrer <Icon.Check size={13}/></button>
      </div>

      <div className="section-h"><h3>Mes enregistrements</h3><span className="more">Aujourd'hui</span></div>
      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)', borderBottom: '1px solid var(--hair)' }}>
        {[
          { t: '14:32', l: 'Faculté Droit · Auditoire 3', s: 'Décision', c: 'var(--positive)' },
          { t: '13:08', l: 'Resto-U · Table 4', s: 'Intéressé', c: 'var(--ink)' },
          { t: '11:50', l: 'Bibliothèque centrale', s: 'À suivre', c: 'var(--accent)' },
        ].map((e, i) => (
          <div key={i} className="list-row">
            <span className="mono tabular" style={{ fontSize: 11, color: 'var(--muted)', width: 36 }}>{e.t}</span>
            <div className="col" style={{ flex: 1 }}>
              <span style={{ fontSize: 13 }}>{e.l}</span>
            </div>
            <span style={{ fontSize: 11, color: e.c, fontWeight: 500 }}>{e.s}</span>
          </div>
        ))}
      </div>
      <div style={{ height: 16 }}/>
    </div>
  </Phone>
);

// ─── 15. DISCIPULAT ───────────────────────────────────────────
const DiscipleshipScreen = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="Mentor · Marie Lukombo"
        title="Discipulat"
        right={<><RoundIcon><Icon.Calendar size={14}/></RoundIcon><RoundIcon><Icon.More size={14}/></RoundIcon></>}
      />

      {/* Mentor relation viz */}
      <div style={{ margin: '0 16px', padding: '18px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 18 }}>
        <div className="row" style={{ gap: 12, justifyContent: 'center', alignItems: 'center', padding: '8px 0' }}>
          <div className="col" style={{ alignItems: 'center', gap: 6 }}>
            <Avatar size="md" name="Marie Lukombo" color="#b89456"/>
            <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.12em' }}>MENTORE</span>
            <span style={{ fontSize: 11, fontWeight: 500 }}>Marie L.</span>
          </div>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
            <svg width="100%" height="40" style={{ overflow: 'visible' }}>
              <line x1="0" y1="20" x2="100%" y2="20" stroke="var(--hair)" strokeWidth="1" strokeDasharray="3 3"/>
              <circle cx="50%" cy="20" r="14" fill="var(--ink)"/>
              <text x="50%" y="24" textAnchor="middle" fontSize="10" fill="#fff" fontFamily="var(--mono)" letterSpacing="0.1em">14M</text>
            </svg>
          </div>
          <div className="col" style={{ alignItems: 'center', gap: 6 }}>
            <Avatar size="md" name="Esther Kalala" color="#0b1e4a"/>
            <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.12em' }}>DISCIPLE</span>
            <span style={{ fontSize: 11, fontWeight: 500 }}>Esther K.</span>
          </div>
        </div>
        <div style={{ marginTop: 6, paddingTop: 12, borderTop: '1px solid var(--hair)', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {[
            { l: 'Sessions', v: '14' },
            { l: 'Modules', v: '7/12' },
            { l: 'Régularité', v: '92%' },
          ].map((s, i) => (
            <div key={i} className="col center" style={{ alignItems: 'center' }}>
              <span className="serif" style={{ fontSize: 18, letterSpacing: '-0.02em' }}>{s.v}</span>
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.1em' }}>{s.l.toUpperCase()}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Curriculum */}
      <div className="section-h"><h3>Parcours · L1 → L2</h3><span className="more">Module 8</span></div>
      <div style={{ margin: '0 16px', padding: '4px 0', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14 }}>
        {[
          { n: 'M01', t: 'Assurance du salut', s: 'done', d: 'Janv.' },
          { n: 'M02', t: 'Lecture quotidienne de la Bible', s: 'done', d: 'Janv.' },
          { n: 'M03', t: 'La prière', s: 'done', d: 'Févr.' },
          { n: 'M04', t: 'Vie d\'adoration', s: 'done', d: 'Févr.' },
          { n: 'M05', t: 'L\'Esprit Saint', s: 'done', d: 'Mars' },
          { n: 'M06', t: 'Le combat spirituel', s: 'done', d: 'Mars' },
          { n: 'M07', t: 'Communion fraternelle', s: 'done', d: 'Avr.' },
          { n: 'M08', t: 'Témoigner du Christ', s: 'active', d: 'En cours' },
          { n: 'M09', t: 'Disciples & multiplication', s: 'todo', d: '—' },
          { n: 'M10', t: 'Servir l\'Église', s: 'todo', d: '—' },
        ].map((m, i, arr) => (
          <div key={i} style={{
            padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12,
            borderBottom: i < arr.length - 1 ? '1px solid var(--hair-2)' : 'none',
          }}>
            <div style={{
              width: 26, height: 26, borderRadius: 999,
              background: m.s === 'done' ? 'var(--ink)' : m.s === 'active' ? 'var(--accent)' : 'transparent',
              border: '1.5px solid ' + (m.s === 'done' ? 'var(--ink)' : m.s === 'active' ? 'var(--accent)' : 'var(--hair)'),
              color: m.s === 'todo' ? 'var(--muted-2)' : '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 9, fontFamily: 'var(--mono)', fontWeight: 600,
            }}>{m.s === 'done' ? <Icon.Check size={12}/> : m.s === 'active' ? <span style={{ width: 8, height: 8, borderRadius: 999, background: '#fff' }}/> : ''}</div>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <div className="row" style={{ gap: 8 }}>
                <span className="mono" style={{ fontSize: 9.5, color: 'var(--muted-2)', letterSpacing: '0.1em' }}>{m.n}</span>
                <span style={{ fontSize: 13, fontWeight: m.s === 'active' ? 600 : 500, color: m.s === 'todo' ? 'var(--muted)' : 'var(--ink)' }}>{m.t}</span>
              </div>
            </div>
            <span className="mono" style={{ fontSize: 10, color: 'var(--muted-2)', letterSpacing: '0.1em' }}>{m.d.toUpperCase()}</span>
          </div>
        ))}
      </div>

      {/* Next session */}
      <div className="section-h"><h3>Prochaine session</h3></div>
      <div style={{ margin: '0 16px 16px', padding: '16px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14, display: 'flex', alignItems: 'center', gap: 14 }}>
        <div className="col center" style={{
          width: 50, padding: '8px 0', borderRadius: 10,
          background: 'var(--surface-2)', border: '1px solid var(--hair)',
        }}>
          <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.12em' }}>MAR</span>
          <span className="serif" style={{ fontSize: 22, lineHeight: 1, marginTop: 2 }}>13</span>
        </div>
        <div className="col" style={{ flex: 1, gap: 3 }}>
          <span style={{ fontSize: 13.5, fontWeight: 500 }}>Module 8 — Témoigner</span>
          <div className="row" style={{ gap: 10, fontSize: 11, color: 'var(--muted)' }}>
            <span className="row" style={{ gap: 4 }}><Icon.Clock size={11}/> 17h00 — 18h30</span>
            <span className="row" style={{ gap: 4 }}><Icon.Pin size={11}/> Salle 4</span>
          </div>
        </div>
        <RoundIcon size={28}><Icon.Chevron size={12}/></RoundIcon>
      </div>
    </div>
  </Phone>
);

// ─── 16. PROFIL & PARAMÈTRES ──────────────────────────────────
const ProfileScreen = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="Mon compte"
        title="Profil"
        right={<><RoundIcon><Icon.Edit size={14}/></RoundIcon></>}
      />

      <div style={{ padding: '0 16px' }}>
        <div style={{ padding: '20px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 18, display: 'flex', alignItems: 'center', gap: 14 }}>
          <Avatar size="lg" name="Jean Kabongo" color="#0b1e4a"/>
          <div className="col" style={{ flex: 1, gap: 3 }}>
            <span className="mono" style={{ fontSize: 9.5, color: 'var(--muted)', letterSpacing: '0.14em' }}>L3 · ENGAGEMENT</span>
            <h2 style={{ fontSize: 18, fontWeight: 500, margin: 0, letterSpacing: '-0.01em' }}>Jean Kabongo</h2>
            <span style={{ fontSize: 12, color: 'var(--muted)' }}>BBC UNIKIN · Membre depuis 2022</span>
          </div>
        </div>
      </div>

      {/* QR membership card */}
      <div style={{ margin: '12px 16px', padding: '20px', background: 'var(--ink)', color: '#fff', borderRadius: 18 }}>
        <div className="between">
          <span className="mono" style={{ fontSize: 9.5, letterSpacing: '0.16em', color: 'rgba(255,255,255,0.5)' }}>CARTE DE MEMBRE</span>
          <span className="mono" style={{ fontSize: 9.5, letterSpacing: '0.14em', color: 'rgba(255,255,255,0.5)' }}>2025/26</span>
        </div>
        <div className="row" style={{ marginTop: 18, gap: 18, alignItems: 'center' }}>
          <div style={{
            width: 72, height: 72, background: '#fff', borderRadius: 8,
            display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 1, padding: 4,
          }}>
            {Array.from({ length: 64 }).map((_, i) => (
              <div key={i} style={{
                background: [0,1,2,5,6,7,8,15,16,21,23,24,29,30,33,38,40,42,45,46,48,55,56,57,58,61,62,63].includes(i) ? '#0b0e1a' : 'transparent',
              }}/>
            ))}
          </div>
          <div className="col" style={{ flex: 1, gap: 4 }}>
            <span className="serif" style={{ fontSize: 18, letterSpacing: '-0.01em' }}>Jean Kabongo</span>
            <span className="mono" style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', letterSpacing: '0.12em' }}>BBCMS-UNK-0427</span>
            <span className="mono" style={{ fontSize: 9, color: 'rgba(255,255,255,0.45)', letterSpacing: '0.1em' }}>VALIDE JUSQU'AU 30/09/26</span>
          </div>
        </div>
      </div>

      {/* settings groups */}
      <div className="section-h"><h3>Paramètres</h3></div>
      <div style={{ margin: '0 16px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14 }}>
        {[
          { l: 'Notifications', s: 'Push, e-mail, SMS', icon: <Icon.Bell size={14}/> },
          { l: 'Confidentialité', s: 'Données & permissions', icon: <Icon.Shield size={14}/> },
          { l: 'Synchronisation', s: 'Hors-ligne · 2 modifs', icon: <Icon.Layers size={14}/> },
          { l: 'Langue', s: 'Français', icon: <Icon.Book size={14}/> },
        ].map((row, i, arr) => (
          <div key={i} style={{
            padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
            borderBottom: i < arr.length - 1 ? '1px solid var(--hair-2)' : 'none',
          }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--muted)' }}>{row.icon}</div>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span style={{ fontSize: 13.5, fontWeight: 500 }}>{row.l}</span>
              <span className="meta">{row.s}</span>
            </div>
            <Icon.Chevron size={14} stroke={1.4} style={{ color: 'var(--muted-2)' }}/>
          </div>
        ))}
      </div>

      <div style={{ padding: '14px 16px 22px' }}>
        <button className="btn btn-ghost btn-block" style={{ color: 'var(--danger)' }}>
          <Icon.Logout size={14}/> Se déconnecter
        </button>
        <div className="center mono" style={{ marginTop: 16, fontSize: 9, color: 'var(--muted-2)', letterSpacing: '0.16em' }}>
          BBCMS · v3.2 · CHF · KINSHASA
        </div>
      </div>
    </div>
    <TabBar active="me" />
  </Phone>
);

Object.assign(window, { EvangelismScreen, DiscipleshipScreen, ProfileScreen });
