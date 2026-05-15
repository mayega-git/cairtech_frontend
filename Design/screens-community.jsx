/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, TabBar, Icon */

// ─── 11. CONTRIBUTION FINANCIÈRE ──────────────────────────────
const FinanceScreen = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="Finance · Mon compte"
        title="Contribuer"
        right={<><RoundIcon><Icon.Clock size={14}/></RoundIcon><RoundIcon><Icon.More size={14}/></RoundIcon></>}
      />

      {/* Hero — total contributed */}
      <div style={{ margin: '0 16px', padding: '22px', background: 'var(--ink)', color: '#fff', borderRadius: 20 }}>
        <span className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'rgba(255,255,255,0.55)' }}>TOTAL CONTRIBUÉ · 2025/26</span>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 6 }}>
          <span className="serif" style={{ fontSize: 48, fontWeight: 400, lineHeight: 0.95, letterSpacing: '-0.03em' }}>284</span>
          <span className="mono" style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)' }}>USD</span>
          <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginLeft: 'auto' }}>· 12 dons</span>
        </div>
        <div style={{ marginTop: 16, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.1)' }}>
          <div className="between">
            <span className="mono" style={{ fontSize: 9.5, color: 'rgba(255,255,255,0.55)', letterSpacing: '0.12em' }}>OBJECTIF ANNUEL · 480 USD</span>
            <span className="mono" style={{ fontSize: 10.5, color: '#fff' }}>59%</span>
          </div>
          <div style={{ marginTop: 8 }}>
            <Bar value={0.59} color="#fff" track="rgba(255,255,255,0.14)" height={3}/>
          </div>
        </div>
      </div>

      {/* Quick amounts */}
      <div className="section-h"><h3>Faire un don</h3><span className="more">USD · CDF</span></div>
      <div style={{ padding: '0 16px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6 }}>
          {[5, 10, 25, 50].map((v, i) => (
            <div key={i} style={{
              padding: '14px 0', textAlign: 'center', borderRadius: 12,
              background: i === 1 ? 'var(--ink)' : 'var(--surface)',
              color: i === 1 ? '#fff' : 'var(--ink)',
              border: '1px solid ' + (i === 1 ? 'var(--ink)' : 'var(--hair)'),
            }}>
              <div className="serif" style={{ fontSize: 22, lineHeight: 1, letterSpacing: '-0.01em' }}>{v}</div>
              <div className="mono" style={{ fontSize: 9, opacity: 0.65, marginTop: 4, letterSpacing: '0.1em' }}>USD</div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 14 }}>
          <div className="field">
            <label>Affectation</label>
            <div style={{
              background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 12,
              overflow: 'hidden',
            }}>
              {[
                { l: 'Dîme régulière', s: 'Fonctionnement du club', sel: true },
                { l: 'Édifice Gospel', s: 'Collecte spéciale · 64% atteint', sel: false },
                { l: 'Mission camp Goma', s: 'Frais de transport · 8 jeunes', sel: false },
              ].map((d, i, arr) => (
                <div key={i} style={{
                  padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
                  borderBottom: i < arr.length - 1 ? '1px solid var(--hair-2)' : 'none',
                }}>
                  <div style={{
                    width: 18, height: 18, borderRadius: 999,
                    border: `1.5px solid ${d.sel ? 'var(--ink)' : 'var(--hair)'}`,
                    background: d.sel ? 'var(--ink)' : 'transparent',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>{d.sel && <div style={{ width: 7, height: 7, borderRadius: 999, background: '#fff' }}/>}</div>
                  <div className="col" style={{ flex: 1, gap: 1 }}>
                    <span style={{ fontSize: 13, fontWeight: 500 }}>{d.l}</span>
                    <span className="meta">{d.s}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div style={{ marginTop: 14 }}>
          <div className="field">
            <label>Mode de paiement</label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6 }}>
              {[
                { l: 'M-Pesa', sel: true },
                { l: 'Orange', sel: false },
                { l: 'Carte', sel: false },
              ].map((p, i) => (
                <div key={i} style={{
                  padding: '14px 0', textAlign: 'center', borderRadius: 12,
                  fontSize: 12.5, fontWeight: 500,
                  background: p.sel ? 'var(--ink)' : 'var(--surface)',
                  color: p.sel ? '#fff' : 'var(--ink)',
                  border: '1px solid ' + (p.sel ? 'var(--ink)' : 'var(--hair)'),
                }}>{p.l}</div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Recent */}
      <div className="section-h"><h3>Mes dernières contributions</h3></div>
      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)', borderBottom: '1px solid var(--hair)' }}>
        {[
          { d: '02 mai', t: 'Dîme régulière', m: '25,00', s: 'CONFIRMÉ' },
          { d: '15 avr.', t: 'Édifice Gospel', m: '50,00', s: 'CONFIRMÉ' },
          { d: '04 avr.', t: 'Dîme régulière', m: '25,00', s: 'CONFIRMÉ' },
        ].map((r, i) => (
          <div key={i} className="list-row">
            <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon.Coin size={16} stroke={1.4}/>
            </div>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span style={{ fontSize: 13, fontWeight: 500 }}>{r.t}</span>
              <span className="meta">{r.d} · M-Pesa</span>
            </div>
            <div className="col" style={{ alignItems: 'flex-end', gap: 2 }}>
              <span className="serif tabular" style={{ fontSize: 16 }}>{r.m}</span>
              <span className="mono" style={{ fontSize: 9, color: 'var(--positive)', letterSpacing: '0.1em' }}>{r.s}</span>
            </div>
          </div>
        ))}
      </div>

      <div style={{ padding: '14px 16px 22px' }}>
        <button className="btn btn-primary btn-block">Confirmer 10,00 USD <Icon.Arrow size={13}/></button>
      </div>
    </div>
  </Phone>
);

// ─── 12. LISTE MEMBRES ─────────────────────────────────────────
const MembersList = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="BBC · UNIKIN · 142 membres"
        title="Annuaire"
        right={<><RoundIcon><Icon.Filter size={14}/></RoundIcon><RoundIcon><Icon.Plus size={14}/></RoundIcon></>}
      />

      <div style={{ padding: '0 16px 12px' }}>
        <div className="field-inline-icon">
          <Icon.Search size={15} stroke={1.4}/>
          <input style={{
            width: '100%', padding: '12px 14px 12px 40px',
            background: 'var(--surface)', border: '1px solid var(--hair)',
            borderRadius: 999, fontSize: 13.5, fontFamily: 'var(--sans)', outline: 'none',
          }} placeholder="Rechercher un membre, une faculté…" />
        </div>
      </div>

      <div style={{ padding: '0 16px 14px', display: 'flex', gap: 6, overflow: 'auto' }}>
        {['Tous · 142', 'Actifs', 'Étudiants · 124', 'Pros · 18', 'Inactifs · 11', 'Visiteurs · 6'].map((c, i) => (
          <span key={i} className={`chip ${i === 0 ? 'active' : ''}`}>{c}</span>
        ))}
      </div>

      {[
        { letter: 'A', items: [
          { n: 'Anne Mwenze', r: 'Étudiante L1 · Médecine', s: 'fid', tag: '92', av: '#0b1e4a' },
          { n: 'Aimé Bokondji', r: 'Étudiant L3 · Droit', s: 'fid', tag: '88', av: '#2a5fff' },
        ]},
        { letter: 'D', items: [
          { n: 'Daniel Tshisekedi', r: 'Étudiant L3 · Polytech', s: 'inactive', tag: '54', av: '#6b7385' },
          { n: 'Daniella Kabamba', r: 'Étudiante L2 · Lettres', s: 'fid', tag: '85', av: '#b89456' },
        ]},
        { letter: 'E', items: [
          { n: 'Esther Lumbu', r: 'Étudiante L1 · Sciences', s: 'inactive', tag: '61', av: '#6b7385' },
        ]},
        { letter: 'M', items: [
          { n: 'Marie Lukombo', r: 'Étudiante L3 · Méd.', s: 'fid', tag: '94', av: '#0b1e4a' },
          { n: 'Mireille Diur', r: 'Pro · Comptable BCC', s: 'fid', tag: '79', av: '#b89456' },
        ]},
      ].map((g, i) => (
        <div key={i}>
          <div style={{
            padding: '8px 20px', background: 'var(--bg)',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <span className="mono" style={{ fontSize: 11, fontWeight: 600, letterSpacing: '0.1em' }}>{g.letter}</span>
            <div style={{ flex: 1, height: 1, background: 'var(--hair)' }}/>
          </div>
          {g.items.map((m, j) => (
            <div key={j} className="list-row">
              <Avatar name={m.n} size="sm" color={m.av}/>
              <div className="col" style={{ flex: 1, gap: 1 }}>
                <span style={{ fontSize: 13.5, fontWeight: 500 }}>{m.n}</span>
                <span className="meta">{m.r}</span>
              </div>
              <div className="col" style={{ alignItems: 'flex-end', gap: 3 }}>
                <span className="serif tabular" style={{ fontSize: 16, color: m.s === 'inactive' ? 'var(--danger)' : 'var(--ink)' }}>{m.tag}</span>
                <span className="mono" style={{ fontSize: 8.5, color: 'var(--muted-2)', letterSpacing: '0.1em' }}>FIDÉLITÉ</span>
              </div>
            </div>
          ))}
        </div>
      ))}
      <div style={{ height: 16 }}/>
    </div>
    <TabBar active="people" />
  </Phone>
);

// ─── 13. DÉTAIL MEMBRE ─────────────────────────────────────────
const MemberDetail = () => (
  <Phone>
    <div className="phone-scroll">
      <div style={{ background: 'var(--ink)', color: '#fff', padding: '14px 20px 26px' }}>
        <div className="between">
          <RoundIcon dark><Icon.ArrowL size={15}/></RoundIcon>
          <div style={{ display: 'flex', gap: 6 }}>
            <RoundIcon dark><Icon.Phone size={14}/></RoundIcon>
            <RoundIcon dark><Icon.Mail size={14}/></RoundIcon>
            <RoundIcon dark><Icon.More size={14}/></RoundIcon>
          </div>
        </div>
        <div style={{ marginTop: 22, display: 'flex', alignItems: 'center', gap: 16 }}>
          <Avatar size="lg" name="Marie Lukombo" color="#b89456"/>
          <div className="col" style={{ flex: 1, gap: 4 }}>
            <span className="mono" style={{ fontSize: 10, letterSpacing: '0.14em', color: 'rgba(255,255,255,0.55)' }}>L3 · ENGAGEMENT</span>
            <h1 className="serif" style={{ fontSize: 26, fontWeight: 400, margin: 0, letterSpacing: '-0.02em', lineHeight: 1.05 }}>Marie Lukombo</h1>
            <span style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.7)' }}>Étudiante · Faculté de Médecine</span>
          </div>
        </div>

        <div style={{ marginTop: 20, paddingTop: 16, borderTop: '1px solid rgba(255,255,255,0.12)', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
          {[
            { l: 'Fidélité', v: '94' },
            { l: 'Présences', v: '24/26' },
            { l: 'Service', v: '32h' },
            { l: 'Anc.', v: '3 ans' },
          ].map((s, i) => (
            <div key={i} className="col">
              <span className="serif" style={{ fontSize: 18, letterSpacing: '-0.02em', lineHeight: 1 }}>{s.v}</span>
              <span className="mono" style={{ fontSize: 8.5, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.12em', marginTop: 3 }}>{s.l.toUpperCase()}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: '1px solid var(--hair)', background: 'var(--bg)' }}>
        {['Profil', 'Parcours', 'Discipulat', 'Historique'].map((t, i) => (
          <div key={i} style={{
            flex: 1, padding: '14px 0', textAlign: 'center', fontSize: 12, fontWeight: 500,
            color: i === 0 ? 'var(--ink)' : 'var(--muted)',
            borderBottom: '2px solid ' + (i === 0 ? 'var(--ink)' : 'transparent'),
          }}>{t}</div>
        ))}
      </div>

      <div style={{ padding: '18px 20px 8px' }}>
        <span className="eyebrow">Coordonnées</span>
      </div>
      <div style={{ margin: '0 16px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14 }}>
        {[
          { l: 'Email', v: 'marie.lukombo@chf.org', icon: <Icon.Mail size={14}/> },
          { l: 'Téléphone', v: '+243 815 432 109', icon: <Icon.Phone size={14}/> },
          { l: 'Promesse de baptême', v: '2023 · BBC UNIKIN', icon: <Icon.Cross size={14}/> },
          { l: 'Mentor', v: 'Pasteur Mwamba', icon: <Icon.Heart size={14}/> },
        ].map((row, i, arr) => (
          <div key={i} style={{
            padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
            borderBottom: i < arr.length - 1 ? '1px solid var(--hair-2)' : 'none',
          }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--muted)' }}>
              {row.icon}
            </div>
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span className="meta" style={{ fontSize: 10.5 }}>{row.l}</span>
              <span style={{ fontSize: 13, fontWeight: 500 }}>{row.v}</span>
            </div>
          </div>
        ))}
      </div>

      <div className="section-h"><h3>Engagements</h3></div>
      <div style={{ margin: '0 16px 16px', display: 'flex', flexWrap: 'wrap', gap: 6 }}>
        {[
          { l: 'Cellule de prière', k: 'default' },
          { l: 'Évangélisation campus', k: 'default' },
          { l: 'Mentore L1', k: 'accent' },
          { l: 'Comité formation', k: 'default' },
          { l: 'Trésorerie cellule', k: 'success' },
        ].map((t, i) => <Tag key={i} kind={t.k}>{t.l}</Tag>)}
      </div>
    </div>
  </Phone>
);

Object.assign(window, { FinanceScreen, MembersList, MemberDetail });
