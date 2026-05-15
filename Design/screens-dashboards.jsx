/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Bar, Donut, Sparkline, TabBar, Icon */

// ─── 3. DASHBOARD MEMBRE ───────────────────────────────────────
const MemberDashboard = () => {
  const series = [62, 64, 70, 68, 73, 78, 82, 80, 84, 87, 91, 88];
  return (
    <Phone>
      <div className="phone-scroll">
        <div style={{ padding: '14px 20px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div className="row" style={{ gap: 10 }}>
            <Avatar name="Jean Kabongo" />
            <div className="col" style={{ gap: 1 }}>
              <span className="eyebrow">Jeudi 8 mai · 09:41</span>
              <span style={{ fontSize: 15, fontWeight: 500 }}>Bonjour, Jean</span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6 }}>
            <RoundIcon><Icon.Search size={15}/></RoundIcon>
            <RoundIcon>
              <div style={{ position: 'relative' }}>
                <Icon.Bell size={15}/>
                <div style={{ position: 'absolute', top: -3, right: -3, width: 7, height: 7, borderRadius: 999, background: 'var(--accent)' }}/>
              </div>
            </RoundIcon>
          </div>
        </div>

        {/* Hero — fidelity */}
        <div style={{ margin: '8px 16px 0', borderRadius: 22, padding: '24px 22px', background: 'var(--ink)', color: '#fff', position: 'relative', overflow: 'hidden' }}>
          <div className="between" style={{ alignItems: 'flex-start' }}>
            <div className="col" style={{ gap: 4 }}>
              <span className="eyebrow" style={{ color: 'rgba(255,255,255,0.55)' }}>Score de fidélité · Année 2025/26</span>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 6 }}>
                <span className="serif" style={{ fontSize: 72, fontWeight: 400, lineHeight: 0.9, letterSpacing: '-0.03em' }}>87</span>
                <span className="mono" style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)' }}>/100</span>
              </div>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginTop: 8 }}>
                <Tag kind="accent" style={{ background: 'rgba(255,255,255,0.08)', color: '#fff', borderColor: 'rgba(255,255,255,0.15)' }}>
                  <Icon.TrendUp size={10}/> +4 ce mois
                </Tag>
                <span className="mono" style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.12em' }}>FIDÈLE</span>
              </div>
            </div>
            <Donut value={0.87} size={82} stroke={4} color="#fff" track="rgba(255,255,255,0.14)">
              <span className="mono" style={{ fontSize: 11, color: 'rgba(255,255,255,0.7)' }}>87%</span>
            </Donut>
          </div>
          <div style={{ marginTop: 20, paddingTop: 18, borderTop: '1px solid rgba(255,255,255,0.1)', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12 }}>
            {[
              { l: 'Présences', v: '24', s: '/26' },
              { l: 'Rétractations', v: '02', s: 'sur 4 max' },
              { l: 'Service', v: '18h', s: 'ce trim.' },
            ].map((s, i) => (
              <div key={i} className="col" style={{ gap: 2 }}>
                <span className="mono" style={{ fontSize: 9, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.12em' }}>{s.l.toUpperCase()}</span>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
                  <span className="serif" style={{ fontSize: 24, lineHeight: 1, letterSpacing: '-0.02em' }}>{s.v}</span>
                  <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)' }}>{s.s}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Verse of day */}
        <div style={{ margin: '14px 16px 0', padding: '20px 22px', background: 'var(--surface-2)', border: '1px solid var(--hair)', borderRadius: 18 }}>
          <div className="between">
            <span className="eyebrow">Verset du jour</span>
            <span className="mono" style={{ fontSize: 10, color: 'var(--muted)' }}>Ps. 23.1</span>
          </div>
          <p className="serif" style={{ fontSize: 19, lineHeight: 1.35, margin: '12px 0 0', color: 'var(--ink)', letterSpacing: '-0.005em' }}>
            « L'Éternel est mon berger : je ne manquerai de rien. »
          </p>
        </div>

        {/* Next meeting */}
        <div className="section-h"><h3>Prochaine réunion</h3><span className="more">Voir tout</span></div>
        <div style={{ margin: '0 16px', padding: '16px 18px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
          <div className="row" style={{ gap: 14 }}>
            <div className="col center" style={{
              width: 52, padding: '8px 0', borderRadius: 10,
              background: 'var(--surface-2)', border: '1px solid var(--hair)',
            }}>
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.14em' }}>SAM</span>
              <span className="serif" style={{ fontSize: 24, lineHeight: 1, marginTop: 2 }}>10</span>
              <span className="mono" style={{ fontSize: 8, color: 'var(--muted-2)', letterSpacing: '0.14em', marginTop: 4 }}>MAI</span>
            </div>
            <div className="col" style={{ flex: 1, gap: 4 }}>
              <span style={{ fontSize: 14, fontWeight: 500 }}>Étude biblique — Romains 8</span>
              <div className="row" style={{ gap: 10, fontSize: 11.5, color: 'var(--muted)' }}>
                <span className="row" style={{ gap: 4 }}><Icon.Clock size={12}/> 16h00</span>
                <span className="row" style={{ gap: 4 }}><Icon.Pin size={12}/> Salle B · Amphi</span>
              </div>
              <div style={{ marginTop: 6, display: 'flex', gap: -6, alignItems: 'center' }}>
                {['ML', 'PD', 'AM'].map((n, i) => <Avatar key={i} size="sm" name={n} color={['#0b1e4a','#2a5fff','#b89456'][i]} />)}
                <span className="mono" style={{ fontSize: 10, color: 'var(--muted)', marginLeft: 8 }}>+12 confirmés</span>
              </div>
            </div>
            <RoundIcon size={28}><Icon.Chevron size={12}/></RoundIcon>
          </div>
        </div>

        {/* Quick actions */}
        <div className="section-h"><h3>Actions rapides</h3></div>
        <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
          {[
            { icon: <Icon.Check size={16}/>, l: 'Pointer', s: 'présence' },
            { icon: <Icon.Coin size={16}/>, l: 'Donner', s: 'contribuer' },
            { icon: <Icon.Heart size={16}/>, l: 'Prier', s: 'chaîne' },
            { icon: <Icon.Send size={16}/>, l: 'Évang.', s: 'rapport' },
          ].map((a, i) => (
            <div key={i} className="col" style={{
              gap: 6, padding: '12px 6px', alignItems: 'center',
              background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 12,
            }}>
              <div style={{ width: 28, height: 28, borderRadius: 8, background: 'var(--ink)', color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{a.icon}</div>
              <span style={{ fontSize: 11, fontWeight: 500 }}>{a.l}</span>
              <span className="mono" style={{ fontSize: 8.5, color: 'var(--muted-2)', letterSpacing: '0.1em' }}>{a.s.toUpperCase()}</span>
            </div>
          ))}
        </div>

        {/* Trend chart */}
        <div className="section-h"><h3>Présence — 12 dernières semaines</h3><span className="more">Détail</span></div>
        <div style={{ margin: '0 16px 16px', padding: '16px 16px 8px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
          <div className="between">
            <div className="col" style={{ gap: 2 }}>
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted-2)', letterSpacing: '0.12em' }}>MOY. 12 SEM.</span>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
                <span className="serif" style={{ fontSize: 28, lineHeight: 1, letterSpacing: '-0.02em' }}>87%</span>
                <span style={{ fontSize: 11, color: 'var(--positive)' }}>+12 pts</span>
              </div>
            </div>
            <Tag>HEBDO</Tag>
          </div>
          <div style={{ marginTop: 10 }}>
            <Sparkline data={series} width={314} height={64} color="var(--ink)" fill="rgba(11,14,26,0.05)" />
          </div>
          <div className="between" style={{ marginTop: 4 }}>
            <span className="mono" style={{ fontSize: 9, color: 'var(--muted-2)' }}>S07</span>
            <span className="mono" style={{ fontSize: 9, color: 'var(--muted-2)' }}>S18</span>
          </div>
        </div>
      </div>
      <TabBar active="home" />
    </Phone>
  );
};

// ─── 4. DASHBOARD LEADER BBC ───────────────────────────────────
const LeaderDashboard = () => (
  <Phone>
    <div className="phone-scroll">
      <ScreenHeader
        eyebrow="BBC · UNIKIN · 2025/26"
        title="Tableau de bord"
        sub="Vue responsable"
        right={<><RoundIcon><Icon.Filter size={14}/></RoundIcon><RoundIcon><Icon.More size={14}/></RoundIcon></>}
      />

      {/* KPI grid */}
      <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        {[
          { l: 'Membres actifs', v: '142', s: '+6 ce mois', acc: 'var(--positive)', icon: <Icon.Users size={14}/> },
          { l: 'Fidélité moy.', v: '78%', s: 'Cible 80', acc: 'var(--warn)', icon: <Icon.TrendUp size={14}/> },
          { l: 'Réunions tenues', v: '42', s: 'sur 48 prévues', acc: 'var(--muted)', icon: <Icon.Calendar size={14}/> },
          { l: 'Inactifs (>4 sem.)', v: '11', s: 'Suivi requis', acc: 'var(--danger)', icon: <Icon.Clock size={14}/> },
        ].map((k, i) => (
          <div key={i} style={{ padding: '14px 14px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14 }}>
            <div className="between">
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.14em', textTransform: 'uppercase' }}>{k.l}</span>
              <div style={{ color: k.acc }}>{k.icon}</div>
            </div>
            <div className="serif" style={{ fontSize: 32, lineHeight: 1, marginTop: 8, letterSpacing: '-0.02em' }}>{k.v}</div>
            <div style={{ fontSize: 10.5, color: k.acc, marginTop: 4 }}>{k.s}</div>
          </div>
        ))}
      </div>

      {/* Distribution by level */}
      <div className="section-h"><h3>Répartition par niveau</h3></div>
      <div style={{ margin: '0 16px', padding: '18px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
        {[
          { l: 'L1 · Initiation', v: 32, p: 0.85, c: 'var(--ink)' },
          { l: 'L2 · Affermissement', v: 41, p: 0.72, c: 'var(--accent)' },
          { l: 'L3 · Engagement', v: 38, p: 0.81, c: 'var(--gold)' },
          { l: 'L4 · Service', v: 18, p: 0.92, c: 'var(--positive)' },
          { l: 'Anciens', v: 13, p: 0.95, c: 'var(--muted)' },
        ].map((row, i) => (
          <div key={i} style={{ marginBottom: i === 4 ? 0 : 14 }}>
            <div className="between" style={{ marginBottom: 6 }}>
              <span style={{ fontSize: 12.5, fontWeight: 500 }}>{row.l}</span>
              <div className="row" style={{ gap: 10 }}>
                <span className="mono" style={{ fontSize: 10.5, color: 'var(--muted)' }}>{Math.round(row.p * 100)}%</span>
                <span className="serif tabular" style={{ fontSize: 16, minWidth: 28, textAlign: 'right' }}>{row.v}</span>
              </div>
            </div>
            <Bar value={row.p} color={row.c} />
          </div>
        ))}
      </div>

      {/* Inactivity watchlist */}
      <div className="section-h"><h3>Veille d'inactivité</h3><span className="more">11 personnes</span></div>
      <div style={{ background: 'var(--surface)', borderTop: '1px solid var(--hair)', borderBottom: '1px solid var(--hair)' }}>
        {[
          { n: 'Patricia Mukendi', a: '5 semaines', l: 'L2' },
          { n: 'Daniel Tshisekedi', a: '6 semaines', l: 'L3' },
          { n: 'Esther Lumbu', a: '4 semaines', l: 'L1' },
        ].map((p, i) => (
          <div key={i} className="list-row">
            <Avatar name={p.n} size="sm" color={['#0b1e4a','#b89456','#2a5fff'][i]} />
            <div className="col" style={{ flex: 1, gap: 1 }}>
              <span style={{ fontSize: 13.5, fontWeight: 500 }}>{p.n}</span>
              <span className="meta">Absent depuis {p.a} · Niveau {p.l}</span>
            </div>
            <Tag kind="warn">À CONTACTER</Tag>
          </div>
        ))}
      </div>

      <div style={{ height: 16 }}/>
    </div>
    <TabBar active="home" />
  </Phone>
);

// ─── 5. DASHBOARD NATIONAL ─────────────────────────────────────
const NationalDashboard = () => (
  <Phone>
    <div className="phone-scroll">
      <div style={{ padding: '14px 20px 8px' }}>
        <div className="between">
          <RoundIcon><Icon.ArrowL size={15}/></RoundIcon>
          <div className="col center" style={{ gap: 0 }}>
            <span className="eyebrow">Direction nationale</span>
            <span style={{ fontSize: 13, fontWeight: 600 }}>RDC · 2025/26</span>
          </div>
          <RoundIcon><Icon.Filter size={14}/></RoundIcon>
        </div>
      </div>

      {/* National hero */}
      <div style={{ margin: '12px 16px 0', padding: '22px', borderRadius: 20, background: 'var(--surface)', border: '1px solid var(--hair)' }}>
        <span className="eyebrow">Total membres actifs</span>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 6 }}>
          <span className="serif" style={{ fontSize: 56, fontWeight: 400, letterSpacing: '-0.03em', lineHeight: 0.95 }}>4&nbsp;128</span>
          <span style={{ fontSize: 12, color: 'var(--positive)' }}>+247 (6,4%)</span>
        </div>
        <div style={{ marginTop: 16 }}>
          <Sparkline data={[3500,3620,3700,3640,3780,3820,3910,3980,4050,4080,4128]} width={302} height={56}
            color="var(--ink)" fill="rgba(11,14,26,0.06)" />
        </div>
        <div className="between" style={{ marginTop: 10, paddingTop: 14, borderTop: '1px solid var(--hair)' }}>
          {[
            { l: 'BBC', v: '38' },
            { l: 'Provinces', v: '12' },
            { l: 'Réunions/sem.', v: '186' },
          ].map((s, i) => (
            <div key={i} className="col">
              <span className="serif" style={{ fontSize: 22, letterSpacing: '-0.02em' }}>{s.v}</span>
              <span className="mono" style={{ fontSize: 9, color: 'var(--muted)', letterSpacing: '0.12em' }}>{s.l.toUpperCase()}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Top BBC ranking */}
      <div className="section-h"><h3>Classement Bible Clubs</h3><span className="more">Fidélité</span></div>
      <div style={{ margin: '0 16px', padding: '4px 0', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 14 }}>
        {[
          { r: '01', n: 'BBC · UNIKIN', m: 142, f: 87 },
          { r: '02', n: 'BBC · UPC', m: 118, f: 84 },
          { r: '03', n: 'BBC · ULUB', m: 96, f: 81 },
          { r: '04', n: 'BBC · UNILU', m: 87, f: 78 },
        ].map((row, i, arr) => (
          <div key={i} className="row" style={{
            padding: '12px 16px',
            borderBottom: i < arr.length - 1 ? '1px solid var(--hair-2)' : 'none',
            gap: 14,
          }}>
            <span className="mono" style={{ fontSize: 11, color: 'var(--muted-2)', width: 22 }}>{row.r}</span>
            <span style={{ flex: 1, fontSize: 13, fontWeight: 500 }}>{row.n}</span>
            <span className="mono" style={{ fontSize: 11, color: 'var(--muted)', width: 36, textAlign: 'right' }}>{row.m}M</span>
            <div style={{ width: 60 }}><Bar value={row.f / 100} height={3}/></div>
            <span className="serif tabular" style={{ fontSize: 16, width: 30, textAlign: 'right' }}>{row.f}</span>
          </div>
        ))}
      </div>

      {/* Map of provinces */}
      <div className="section-h"><h3>Carte des provinces</h3></div>
      <div style={{ margin: '0 16px 16px', padding: '18px', background: 'var(--surface)', border: '1px solid var(--hair)', borderRadius: 16 }}>
        <svg viewBox="0 0 200 140" style={{ width: '100%', height: 160 }}>
          {/* abstract province grid */}
          {[
            [20,20,3], [50,15,4], [80,22,5], [120,18,2], [150,25,3],
            [25,55,2], [60,50,5], [95,58,4], [135,55,3], [165,62,2],
            [30,90,3], [70,95,4], [110,92,3], [150,98,2],
          ].map(([x, y, n], i) => (
            <g key={i}>
              <circle cx={x} cy={y} r={3 + n} fill="var(--ink)" opacity={0.08}/>
              <circle cx={x} cy={y} r={n * 0.7} fill="var(--ink)"/>
            </g>
          ))}
          <text x="60" y="48" fontSize="6" fill="var(--ink)" fontFamily="var(--mono)">KIN · 1 184</text>
        </svg>
        <div className="between" style={{ marginTop: 10 }}>
          <div className="row" style={{ gap: 6 }}>
            <div style={{ width: 8, height: 8, borderRadius: 999, background: 'var(--ink)' }}/>
            <span className="mono" style={{ fontSize: 10, color: 'var(--muted)' }}>Membres actifs</span>
          </div>
          <span className="mono" style={{ fontSize: 10, color: 'var(--muted-2)' }}>14 PROVINCES</span>
        </div>
      </div>
    </div>
    <TabBar active="home" />
  </Phone>
);

Object.assign(window, { MemberDashboard, LeaderDashboard, NationalDashboard });
