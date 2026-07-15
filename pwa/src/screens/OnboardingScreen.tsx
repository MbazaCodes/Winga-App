import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Session } from '../lib/session'

const slides = [
  { title: 'Karibu Winga App!', sub: 'Mwongozo wako wa kuaminika katika masoko ya Tanzania', emoji: '🛍️', bg: '#1A5C2A' },
  { title: 'Pata Winga Wako', sub: 'Wingas wetu ni wabobezi walioidhinishwa — watakusaidia kupata bidhaa bora kwa bei nzuri', emoji: '🤝', bg: '#0F3D1A' },
  { title: 'Salama na Rahisi', sub: 'Lipa baada ya huduma. Fuatilia Winga wako wakati wote. Hakuna wasiwasi!', emoji: '🔒', bg: '#1A5C2A' },
]

export default function OnboardingScreen() {
  const [idx, setIdx] = useState(0)
  const nav = useNavigate()

  const next = () => {
    if (idx < slides.length - 1) { setIdx(idx + 1) }
    else { Session.setOnboarded(); nav('/login') }
  }

  const s = slides[idx]

  return (
    <div style={{ height: '100dvh', background: s.bg, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'space-between', padding: '60px 28px 48px', transition: 'background 0.3s' }}>
      <button onClick={() => { Session.setOnboarded(); nav('/login') }}
        style={{ alignSelf: 'flex-end', background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white', padding: '8px 16px', borderRadius: 20, fontFamily: 'Inter', fontSize: 13, cursor: 'pointer' }}>
        Ruka
      </button>

      <div style={{ textAlign: 'center', flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24 }}>
        <div style={{ fontSize: 80 }}>{s.emoji}</div>
        <h1 style={{ fontFamily: 'Inter', fontSize: 26, fontWeight: 800, color: '#fff', lineHeight: 1.2 }}>{s.title}</h1>
        <p style={{ fontFamily: 'Inter', fontSize: 15, color: 'rgba(255,255,255,0.8)', lineHeight: 1.6, maxWidth: 300 }}>{s.sub}</p>
      </div>

      <div style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20 }}>
        {/* Dots */}
        <div style={{ display: 'flex', gap: 8 }}>
          {slides.map((_, i) => (
            <div key={i} style={{ height: 8, borderRadius: 4, background: i === idx ? '#F9A825' : 'rgba(255,255,255,0.3)', width: i === idx ? 24 : 8, transition: 'all 0.3s' }} />
          ))}
        </div>
        <button onClick={next} style={{ width: '100%', height: 54, background: '#fff', color: '#1A5C2A', border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 700, cursor: 'pointer' }}>
          {idx < slides.length - 1 ? 'Endelea →' : 'Anza Sasa →'}
        </button>
      </div>
    </div>
  )
}
