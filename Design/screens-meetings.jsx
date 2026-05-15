/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, TabBar, Icon */

// ─── 6. LISTE RÉUNIONS ─────────────────────────────────────────
const MeetingsList = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="BBC · UNIKIN"
        title="Réunions"
        right={<><RoundIcon><Icon.Search size={14}/></RoundIcon><RoundIcon><Icon.Plus size={14}/></RoundIcon></>}
      />
      <div style={{ padding: '4px 16px 14px', display: 'flex', gap: 6, overflow: 'auto' }}>
        {['Toutes', 'À venir', 'En cours', 'Tenues', 'Études', 'Prière'].map((c, i) => (
          <span key={i} className={`chip ${i === 1 ? 'active' : ''}`}>{c}</span>
        ))}
      </div>

      {[
        { date: ['VEN', '09', 'MAI'], title: 'Cellule de prière', time: '06h00 — 07h00', loc: 'Salle Goshen', type: 'PRIÈRE', n: 18, status: 'live' },
        { date: ['SAM', '10', 'MAI'], title: 'Étude — Romains 8', time: '16h00 — 18h00', loc: 'Salle B · Amphi', type: 'ÉTUDE', n: 42, status: 'soon' },
        { date: ['DIM', '11', 'MAI'], title: 'Culte mensuel BBC', time: '09h00 — 12h00', loc: 'Auditorium central', type: 'CULTE', n: 132, status: 'planned' },
        { date: ['MAR', '13', 'MAI'], title: 'Discipulat — L2', time: '17h00 — 18h30', loc: 'Salle 4', type: 'DISCIP.', n: 8, status: 'planned' },
        { date: ['JEU', '15', 'MAI'], title: 'Évangélisation campus', time: '14h00 — 17h00', loc: 'Faculté Sciences', type: 'ÉVANG.', n: 24, status: 'planned' },
      ].map((m, i) => (
        <div key={i} style={{
          margin: '0 16px 8px', padding: '14px 16px', background: 'var(--surface)',
          border: '1px solid var(--hair)', borderRadius: 14,
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div className="col center" style={{
            width: 50, padding: '6px 0', borderRadius: 10,
            background: m.status === 'live' ? 'var(--ink)' : 'var(--surface-2)',
            color: m.status === 'live' ? '#fff' : 'inherit',
            border: '1px solid ' + (m.status === 'live' ? 'var(--ink)' : 'var(--hair)'),
          }}>
            <span className="mono" style={{ fontSize: 9, opacity: 0.7, letterSpacing: '0.12em' }}>{m.date[0]}</span>
            <span className="serif" style={{ fontSize: 20, lineHeight: 1, marginTop: 1 }}>{m.date[1]}</span>
            <span className="mono" style={{ fontSize: 8, opacity: 0.6, letterSpacing: '0.12em', marginTop: 2 }}>{m.date[2]}</span>
          </div>
          <div className="col" style={{ flex: 1, gap: 4 }}>
            <div className="row" style={{ gap: 8 }}>
              <span style={{ fontSize: 13.5, fontWeight: 500 }}>{m.title}</span>
              {m.status === 'live' && (
                <span className="row" style={{ gap: 4 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 999, background: '#d23b3b' }}/>
                  <span className="mono" style={{ fontSize: 9, color: '#d23b3b', fontWeight: 600, letterSpacing: '0.12em' }}>EN COURS</span>
                </span>
              )}
            </div>
            <div className="row" style={{ gap: 10, fontSize: 11, color: 'var(--muted)' }}>
              <span className="row" style={{ gap: 3 }}><Icon.Clock size={11}/> {m.time}</span>
            </div>
            <div className="between" style={{ marginTop: 2 }}>
              <span className="row" style={{ gap: 3, fontSize: 11, color: 'var(--muted)' }}><Icon.Pin size={11}/> {m.loc}</span>
              <div className="row" style={{ gap: 6 }}>
                <span className="mono" style={{ fontSize: 9.5, color: 'var(--muted-2)', letterSpacing: '0.12em' }}>{m.type}</span>
                <span className="mono" style={{ fontSize: 10, color: 'var(--ink)', fontWeight: 600 }}>· {m.n}</span>
              </div>
            </div>
          </div>
        </div>
      ))}
      <div style={{ height: 16 }}/>
    </div>
    <TabBar active="meet" />
  </Phone>
);

// ─── 7. DÉTAIL RÉUNION + POINTAGE ──────────────────────────────
const MeetingAttendance = () => (
  <Phone>
    <div className="phone-scroll">
      {/* dark hero */}
      <div style={{ background: 'var(--ink)', color: '#fff', padding: '14px 20px 22px' }}>
        <div className="between">
          <RoundIcon dark><Icon.ArrowL size={15}/></RoundIcon>
          <div style={{ display: 'flex', gap: 6 }}>
            <RoundIcon dark><Icon.Edit size={14}/></RoundIcon>
            <RoundIcon dark><Icon.More size={14}/></RoundIcon>
          </div>
        </div>
        <div style={{ marginTop: 16 }}>
          <div className="row" style={{ gap: 8 }}>
            <span className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'rgba(255,255,255,0.55)' }}>SAMEDI 10 MAI · 16:00</span>
            <span style={{ width: 4, height: 4, borderRadius: 999, background: 'rgba(255,255,255,0.4)' }}/>
            <span className="mono" style={{ fontSize: 10, letterSpacing: '0.12em', color: '#b89456' }}>ÉTUDE</span>
          </div>
          <h1 className="serif" style={{ fontSize: 28, fontWeight: 400, margin: '8px 0 0', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
            Romains 8 — La vie<br/>par l'Esprit
          </h1>
          <div className="row" style={{ gap: 10, marginTop: 12, fontSize: 12, color: 'rgba(255,255,255,0.7)' }}>
            <span className="row" style={{ gap: 4 }}><Icon.Pin size={12}/> Salle B, Amphithéâtre</span>
            <span style={{ width: 3, height: 3, borderRadius: 999, background: 'rgba(255,255,255,0.3)' }}/>
            <span className="row" style={{ gap: 4 }}><Icon.Mic size={12}/> P. Mukendi</span>
          </div>
        </div>

        <div style={{ marginTop: 18, paddingTop: 16, borderTop: '1px solid rgba(255,255,255,0.12)', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {[
            { l: 'Présents', v: '38', t: 'sur 42' },
            { l: 'Excusés', v: '02', t: '' },
            { l: 'Visiteurs', v: '03', t: '' },
          ].map((s, i) => (
            <div key={i} className="col" style={{ gap: 2 }}>
              <span className="mono" style={{ fontSize: 9, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.14em' }}>{s.l.toUpperCase()}</span>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
                <span className="serif" style={{ fontSize: 22, lineHeight: 1, letterSpacing: '-0.02em' }}>{s.v}</span>
                <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)' }}>{s.t}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* attendance list */}
      <div style={{ padding: '14px 16px 8px', background: 'var(--bg)' }}>
        <div className="field-inline-icon">
          <Icon.Search size={15} stroke={1.4}/>
          <input style={{
            width: '100%', padding: '11px 14px 11px 40px',
            background: 'var(--surface)', border: '1px solid var(--hair)',
            borderRadius: 999, fontSize: 13.5, fontFamily: 'var(--sans)', outline: 'none',
          }} placeholder="Pointer un membre…" />
        </div>
      </div>

      <div style={{ padding: '0 20px 6px', display: 'flex', gap: 6 }}>
        {['Tous · 42', 'Présents · 38', 'À pointer · 4'].map((c, i) => (
          <span key={i} className={`chip ${i === 0 ? 'active' : ''}`}>{c}</span>
        ))}
      </div>

      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)' }}>
        {[
          { n: 'Marie Lukombo', l: 'L3', s: 'present', t: '16:02' },
          { n: 'Patrice Diur', l: 'L2', s: 'present', t: '16:00' },
          { n: 'Anne Mwenze', l: 'L1', s: 'present', t: '15:58' },
          { n: 'Joseph Tshiala', l: 'L4', s: 'late', t: '16:18' },
          { n: 'Esther Lumbu', l: 'L1', s: 'pending', t: '' },
          { n: 'Daniel Kayemba', l: 'L3', s: 'excused', t: 'Voyage' },
        ].map((p, i) => (
          <div key={i} className="list-row">
            <Avatar name={p.n} size="sm" color={['#0b1e4a','#2a5fff','#b89456','#0b1e4a','#6b7385','#6b7385'][i]}/>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span style={{ fontSize: 13, fontWeight: 500 }}>{p.n}</span>
              <span className="meta">Niveau {p.l}{p.t && ' · ' + p.t}</span>
            </div>
            {p.s === 'present' && (
              <div style={{ width: 28, height: 28, borderRadius: 999, background: 'var(--ink)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon.Check size={14}/>
              </div>
            )}
            {p.s === 'late' && <Tag kind="warn">RETARD</Tag>}
            {p.s === 'excused' && <Tag>EXCUSÉ</Tag>}
            {p.s === 'pending' && (
              <div style={{ width: 28, height: 28, borderRadius: 999, border: '1.5px dashed var(--hair)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}/>
            )}
          </div>
        ))}
      </div>

      <div style={{ padding: '14px 16px 22px', background: 'var(--bg)' }}>
        <button className="btn btn-primary btn-block">Clôturer le pointage <Icon.Check size={14}/></button>
      </div>
    </div>
  </Phone>
);

// ─── 8. CRÉATION RÉUNION ───────────────────────────────────────
const MeetingCreate = () => (
  <Phone>
    <div className="phone-scroll">
      <div style={{ padding: '14px 20px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <RoundIcon><Icon.X size={14}/></RoundIcon>
        <span className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'var(--muted)' }}>NOUVELLE RÉUNION</span>
        <RoundIcon><Icon.More size={14}/></RoundIcon>
      </div>

      <div style={{ padding: '14px 22px 4px' }}>
        <span className="eyebrow">Brouillon</span>
        <h1 className="serif" style={{ fontSize: 28, fontWeight: 400, margin: '6px 0 0', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
          Programmer une<br/>réunion
        </h1>
      </div>

      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div className="field">
          <label>Type</label>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6 }}>
            {[
              { l: 'Étude', sel: true },
              { l: 'Prière', sel: false },
              { l: 'Culte', sel: false },
              { l: 'Évang.', sel: false },
            ].map((t, i) => (
              <div key={i} style={{
                padding: '12px 6px', textAlign: 'center', borderRadius: 10,
                fontSize: 12, fontWeight: 500,
                background: t.sel ? 'var(--ink)' : 'var(--surface)',
                color: t.sel ? '#fff' : 'var(--ink)',
                border: '1px solid ' + (t.sel ? 'var(--ink)' : 'var(--hair)'),
              }}>{t.l}</div>
            ))}
          </div>
        </div>

        <div className="field">
          <label>Titre</label>
          <input defaultValue="Romains 8 — La vie par l'Esprit" />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <div className="field">
            <label>Date</label>
            <input defaultValue="Sam. 10 mai" />
          </div>
          <div className="field">
            <label>Horaire</label>
            <input defaultValue="16:00 → 18:00" />
          </div>
        </div>

        <div className="field">
          <label>Lieu</label>
          <div className="field-inline-icon">
            <Icon.Pin size={16} stroke={1.4}/>
            <input defaultValue="Salle B · Amphithéâtre" />
          </div>
        </div>

        <div className="field">
          <label>Orateur / animateur</label>
          <div style={{
            background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 10,
            padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <Avatar size="sm" name="Pierre Mukendi" color="#0b1e4a"/>
            <span style={{ flex: 1, fontSize: 13.5 }}>Pierre Mukendi · Ancien</span>
            <Icon.ChevronD size={14} stroke={1.5}/>
          </div>
        </div>

        <div className="field">
          <label>Notification</label>
          <div style={{
            background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 10,
            padding: '14px', display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 36, height: 22, borderRadius: 999, background: 'var(--ink)', position: 'relative' }}>
              <div style={{ position: 'absolute', top: 2, right: 2, width: 18, height: 18, borderRadius: 999, background: '#fff' }}/>
            </div>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span style={{ fontSize: 13, fontWeight: 500 }}>Push aux 142 membres</span>
              <span className="meta">24h avant + 1h avant</span>
            </div>
          </div>
        </div>
      </div>

      <div style={{ padding: '24px 20px 22px', display: 'flex', gap: 8 }}>
        <button className="btn btn-ghost" style={{ flex: 1 }}>Brouillon</button>
        <button className="btn btn-primary" style={{ flex: 2 }}>Publier <Icon.Send size={13}/></button>
      </div>
    </div>
  </Phone>
);

Object.assign(window, { MeetingsList, MeetingAttendance, MeetingCreate });
