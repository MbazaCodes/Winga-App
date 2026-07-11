import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import AppBar from '../components/layout/AppBar'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { CATEGORIES } from '../lib/constants'

const NEARBY = [
  { name: 'Ahmed Juma', rating: 4.9, trips: 250, specialty: 'Elektroniki', dist: '0.2 km', badge: 'Verified', online: true },
  { name: 'Bakari Said', rating: 4.8, trips: 180, specialty: 'Mavazi', dist: '0.3 km', badge: 'Mid', online: true },
  { name: 'Hassan Ally', rating: 4.7, trips: 120, specialty: 'Hardware', dist: '0.5 km', badge: 'Starter', online: true },
]

export default function HomeScreen() {
  const nav = useNavigate()
  const [search, setSearch] = useState('')

  return (
    <div className="page">
      {/* Custom header */}
      <div style={{ background: '#fff', paddingTop: 'env(safe-area-inset-top)', paddingLeft: 20, paddingRight: 20, paddingBottom: 12, borderBottom: '1px solid #F3F4F6' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: 12 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span>📍</span>
            <span style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 600 }}>Kariakoo</span>
            <span style={{ color: '#9CA3AF' }}>▾</span>
          </div>
          <div style={{ position: 'relative' }}>
            <span style={{ fontSize: 22 }}>🔔</span>
            <div style={{ position: 'absolute', top: 0, right: 0, width: 8, height: 8, background: '#D32F2F', borderRadius: 4 }} />
          </div>
        </div>
      </div>

      <div className="scroll" style={{ padding: '0 0 0 0' }}>
        <div style={{ padding: '20px 20px 0' }}>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Karibu, John! 👋</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', marginBottom: 16 }}>Tuko hapa kukusaidia ununuzi wako</p>

          {/* Hero banner */}
          <div onClick={() => nav('/book')} style={{ background: '#1A5C2A', borderRadius: 20, padding: '20px', marginBottom: 20, cursor: 'pointer', position: 'relative', overflow: 'hidden' }}>
            <h3 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff', marginBottom: 6 }}>Pata Winga wako</h3>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.85)', marginBottom: 16 }}>Mwongozo wako wa kuaminika katika Kariakoo</p>
            <div style={{ background: '#fff', color: '#1A5C2A', display: 'inline-flex', alignItems: 'center', gap: 6, padding: '10px 16px', borderRadius: 10, fontFamily: 'Inter', fontSize: 14, fontWeight: 600 }}>
              Omba Winga →
            </div>
            <div style={{ position: 'absolute', top: 16, right: 16, background: 'rgba(255,255,255,0.15)', borderRadius: 10, padding: '8px 12px', fontSize: 12, color: '#fff', fontFamily: 'Inter' }}>
              ⭐ 4.8 · 2,340+ wateja
            </div>
          </div>

          {/* Search */}
          <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
            <div style={{ flex: 1, background: '#fff', border: '1px solid #E5E7EB', borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10, padding: '0 14px', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
              <span>🔍</span>
              <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Unatafuta nini leo?"
                style={{ flex: 1, border: 'none', outline: 'none', fontFamily: 'Inter', fontSize: 14, color: '#1A1A1A', padding: '14px 0', background: 'transparent' }} />
            </div>
            <div style={{ width: 50, height: 50, background: '#fff', border: '1px solid #E5E7EB', borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.04)', cursor: 'pointer', fontSize: 20 }}>
              ⚙️
            </div>
          </div>

          {/* Categories */}
          <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, marginBottom: 14 }}>Kategoria Maarufu</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '10px 8px', marginBottom: 24 }}>
            {CATEGORIES.map(cat => (
              <div key={cat.sw} onClick={() => nav('/book')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, cursor: 'pointer' }}>
                <div style={{ width: 54, height: 54, background: '#fff', borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.06)', border: '1px solid #F3F4F6' }}>
                  {cat.emoji}
                </div>
                <span style={{ fontFamily: 'Inter', fontSize: 9, color: '#6B7280', textAlign: 'center', lineHeight: 1.3 }}>{cat.sw}</span>
              </div>
            ))}
          </div>

          {/* Nearby Wingas */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
            <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600 }}>Wingas Waliopo Karibu</h3>
            <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#1A5C2A', cursor: 'pointer' }}>Tazama zote</span>
          </div>
        </div>

        {/* Wingas horizontal scroll */}
        <div style={{ display: 'flex', gap: 14, overflowX: 'auto', padding: '0 20px 20px', scrollbarWidth: 'none' }}>
          {NEARBY.map(w => (
            <div key={w.name} onClick={() => nav('/book')} style={{ minWidth: 155, background: '#fff', borderRadius: 16, boxShadow: '0 2px 12px rgba(0,0,0,0.06)', padding: 14, cursor: 'pointer', flexShrink: 0 }}>
              <div style={{ textAlign: 'center', marginBottom: 10 }}>
                <div style={{ width: 56, height: 56, borderRadius: 28, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, margin: '0 auto 6px', position: 'relative' }}>
                  👤
                  {w.online && <div style={{ position: 'absolute', bottom: 2, right: 2, width: 12, height: 12, background: '#4CAF50', borderRadius: 6, border: '2px solid white' }} />}
                </div>
                <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>{w.name}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>⭐ {w.rating} ({w.trips})</div>
              </div>
              <WingaBadge tier={w.badge} />
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF', marginTop: 6 }}>📍 {w.dist}</div>
              <button style={{ width: '100%', marginTop: 10, height: 32, background: '#1A5C2A', color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 12, fontWeight: 600, cursor: 'pointer' }}>
                Omba
              </button>
            </div>
          ))}
        </div>

        {/* Safety banner */}
        <div style={{ margin: '0 20px 20px', background: '#FFF8E1', borderRadius: 14, padding: 14, display: 'flex', alignItems: 'flex-start', gap: 12 }}>
          <div style={{ width: 36, height: 36, background: '#1A5C2A', borderRadius: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, color: '#F9A825', fontSize: 18 }}>🛡️</div>
          <div>
            <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>Usalama wako ni muhimu!</div>
            <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>Wingas wetu wote wameidhinishwa na kupitishwa ukaguzi.</div>
          </div>
        </div>
      </div>
      <BottomNav />
    </div>
  )
}
