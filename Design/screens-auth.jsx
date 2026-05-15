/* global React, Phone, ScreenHeader, RoundIcon, Tag, Avatar, Icon */

// ─── 1. LOGIN ──────────────────────────────────────────────────
const LoginScreen = () => (
  <Phone>
    <div className="phone-scroll" style={{ background: 'var(--ink)', color: '#fff', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, padding: '40px 28px 0', display: 'flex', flexDirection: 'column' }}>
        <div className="row" style={{ gap: 10 }}>
          <div style={{
            width: 28, height: 28, borderRadius: 6,
            background: '#fff', color: 'var(--ink)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'var(--serif)', fontSize: 18, fontWeight: 500,
          }}>B</div>
          <span className="mono" style={{ fontSize: 11, letterSpacing: '0.18em', color: 'rgba(255,255,255,0.6)' }}>BBCMS · CHF</span>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', paddingBottom: 36 }}>
          <span className="eyebrow" style={{ color: 'rgba(255,255,255,0.5)' }}>Connexion</span>
          <h1 className="serif" style={{ fontSize: 44, fontWeight: 400, margin: '8px 0 0', lineHeight: 1.05, letterSpacing: '-0.02em' }}>
            Bienvenue<br/>dans la maison.
          </h1>
          <p style={{ fontSize: 14, lineHeight: 1.5, color: 'rgba(255,255,255,0.65)', margin: '14px 0 0', maxWidth: 280 }}>
            Suivez votre fidélité, vos réunions et votre marche avec vos frères et sœurs.
          </p>
        </div>
      </div>

      <div style={{ background: 'var(--bg)', color: 'var(--ink)', padding: '28px 22px 20px', borderRadius: '24px 24px 0 0' }}>
        <div className="col" style={{ gap: 12 }}>
          <div className="field">
            <label>Adresse e-mail</label>
            <div className="field-inline-icon">
              <Icon.Mail size={16} stroke={1.4} />
              <input type="email" defaultValue="jean.kabongo@chf.org" />
            </div>
          </div>
          <div className="field">
            <label>Mot de passe</label>
            <div className="field-inline-icon">
              <Icon.Lock size={16} stroke={1.4} />
              <input type="password" defaultValue="••••••••••••" />
            </div>
          </div>
        </div>
        <div className="between" style={{ marginTop: 14 }}>
          <span className="mono" style={{ fontSize: 11, color: 'var(--muted)' }}>Mot de passe oublié ?</span>
          <span className="mono" style={{ fontSize: 11, color: 'var(--ink)', fontWeight: 600 }}>Réinitialiser</span>
        </div>
        <button className="btn btn-primary btn-block" style={{ marginTop: 18 }}>
          Se connecter <Icon.Arrow size={14} />
        </button>
        <div className="center" style={{ marginTop: 14, fontSize: 13, color: 'var(--muted)' }}>
          Pas encore membre ? <span style={{ color: 'var(--ink)', fontWeight: 500 }}>Demander l'adhésion</span>
        </div>
        <div className="center mono" style={{ marginTop: 18, fontSize: 9, color: 'var(--muted-2)', letterSpacing: '0.18em', textTransform: 'uppercase' }}>
          v3.2 · Sécurisé par JWT
        </div>
      </div>
    </div>
  </Phone>
);

// ─── 2. ONBOARDING — Demande d'adhésion ────────────────────────
const OnboardingScreen = () => (
  <Phone>
    <div className="phone-scroll" style={{ display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '20px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <RoundIcon><Icon.ArrowL size={16}/></RoundIcon>
        <div className="mono" style={{ fontSize: 10, letterSpacing: '0.16em', color: 'var(--muted)' }}>ÉTAPE 02 / 04</div>
        <RoundIcon><Icon.X size={14}/></RoundIcon>
      </div>

      <div style={{ padding: '8px 22px 14px', display: 'flex', gap: 4 }}>
        {[1, 1, 0, 0].map((v, i) => (
          <div key={i} style={{
            flex: 1, height: 3, borderRadius: 2,
            background: v ? 'var(--ink)' : 'var(--hair)',
          }}/>
        ))}
      </div>

      <div style={{ padding: '8px 22px 0' }}>
        <span className="eyebrow">Adhésion · Profil</span>
        <h1 className="serif" style={{ fontSize: 32, fontWeight: 400, margin: '8px 0 6px', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
          Quel est votre lien<br/>au Bible Club ?
        </h1>
        <p style={{ fontSize: 13, color: 'var(--muted)', margin: 0, lineHeight: 1.5 }}>
          Le responsable national valide chaque demande sous 48 h.
        </p>
      </div>

      <div style={{ padding: '24px 22px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {[
          { label: 'Étudiant', sub: 'Membre régulier d\'un club universitaire', sel: true, glyph: <Icon.Book size={20}/> },
          { label: 'Professionnel', sub: 'Anciens & responsables, marché du travail', sel: false, glyph: <Icon.Layers size={20}/> },
          { label: 'Visiteur', sub: 'Accompagnement temporaire, en discernement', sel: false, glyph: <Icon.Heart size={20}/> },
        ].map((opt, i) => (
          <div key={i} style={{
            border: `1px solid ${opt.sel ? 'var(--ink)' : 'var(--hair)'}`,
            background: opt.sel ? 'var(--ink)' : 'var(--surface)',
            color: opt.sel ? '#fff' : 'var(--ink)',
            borderRadius: 14, padding: '14px 16px',
            display: 'flex', alignItems: 'center', gap: 14,
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: 10,
              border: `1px solid ${opt.sel ? 'rgba(255,255,255,0.15)' : 'var(--hair)'}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: opt.sel ? '#fff' : 'var(--ink)',
            }}>{opt.glyph}</div>
            <div className="col" style={{ flex: 1, gap: 2 }}>
              <span style={{ fontSize: 15, fontWeight: 500 }}>{opt.label}</span>
              <span style={{ fontSize: 12, opacity: opt.sel ? 0.7 : 0.6 }}>{opt.sub}</span>
            </div>
            <div style={{
              width: 18, height: 18, borderRadius: 999,
              border: `1.5px solid ${opt.sel ? '#fff' : 'var(--hair)'}`,
              background: opt.sel ? '#fff' : 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{opt.sel && <div style={{ width: 8, height: 8, borderRadius: 999, background: 'var(--ink)' }}/>}</div>
          </div>
        ))}
      </div>

      <div style={{ padding: '20px 22px 12px' }}>
        <div className="field">
          <label>Bible Club souhaité</label>
          <div className="field-inline-icon">
            <Icon.Pin size={16} stroke={1.4}/>
            <input defaultValue="BBC · Université de Kinshasa" />
          </div>
        </div>
      </div>

      <div style={{ padding: '0 22px 22px', marginTop: 'auto' }}>
        <button className="btn btn-primary btn-block">Continuer <Icon.Arrow size={14}/></button>
      </div>
    </div>
  </Phone>
);

Object.assign(window, { LoginScreen, OnboardingScreen });
