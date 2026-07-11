import { useNavigate } from 'react-router-dom'

const C = { primary: '#1A5C2A', gold: '#F9A825', white: '#fff', textSec: '#6B7280', border: '#E5E7EB', primarySurface: '#E8F5E9' }

export default function WingaRegisterScreen() {
  const nav = useNavigate()
  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white }}>
      <div style={{ background: C.primary, padding: 'calc(env(safe-area-inset-top,0px) + 28px) 24px 28px' }}>
        <button onClick={() => nav('/login')} style={{ background: 'none', border: 'none', color: C.white, fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
        <h1 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: C.white, marginTop: 12 }}>Jiunge kama Winga</h1>
        <p style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.8)' }}>Winga Shopping Guide · Tanzania</p>
      </div>
      <div style={{ flex: 1, padding: 24, display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ background: C.primarySurface, borderRadius: 16, padding: 20, textAlign: 'center' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>🛍️</div>
          <h2 style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: C.primary, marginBottom: 8 }}>Jiunge leo — Chapisha Fedha</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, lineHeight: 1.6 }}>
            Kama Winga utasaidia wateja kununua na kupata TZS 12,000–32,000 kwa saa.
          </p>
        </div>

        {[
          { icon: '🥉', title: 'Starter', price: 'TZS 5,000/mwezi', desc: 'Orodha ya msingi' },
          { icon: '🥈', title: 'Mid', price: 'TZS 15,000/mwezi', desc: 'Kipaumbele + uchambuzi' },
          { icon: '🥇', title: 'Verified', price: 'TZS 30,000/mwezi', desc: 'Nafasi ya kwanza + utangazaji' },
        ].map(t => (
          <div key={t.title} style={{ border: `1px solid ${C.border}`, borderRadius: 14, padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 14 }}>
            <span style={{ fontSize: 28 }}>{t.icon}</span>
            <div>
              <div style={{ fontFamily: 'Inter', fontWeight: 700, fontSize: 15, color: C.primary }}>{t.title}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec }}>{t.price} · {t.desc}</div>
            </div>
          </div>
        ))}

        <div style={{ marginTop: 8 }}>
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec, textAlign: 'center', marginBottom: 14 }}>
            Usajili kamili unapatikana kwenye App ya Android
          </p>
          <button
            onClick={() => window.open('https://play.google.com/store/apps/details?id=com.winga.app', '_blank')}
            style={{ width: '100%', height: 54, background: C.primary, color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: 'pointer', marginBottom: 10 }}>
            📱 Pakua App ya Android
          </button>
          <button onClick={() => nav('/login')}
            style={{ width: '100%', height: 46, background: 'transparent', color: C.primary, border: `1.5px solid ${C.primary}`, borderRadius: 14, fontFamily: 'Inter', fontSize: 14, fontWeight: 600, cursor: 'pointer' }}>
            Rudi Login
          </button>
        </div>
      </div>
    </div>
  )
}
