import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { CATEGORIES } from '../lib/constants'

interface WingaCard {
  id: string
  name: string
  specialty: string
  badge: string
  winga_score: number
  rated_trips: number
  total_trips: number
  is_online: boolean
  current_city: string
  current_area: string | null
  is_top_rated: boolean
}

export default function HomeScreen() {
  const nav = useNavigate()
  const [search, setSearch] = useState('')
  const [userName, setUserName] = useState('Rafiki')
  const [city, setCity] = useState('Kariakoo')
  const [wingas, setWingas] = useState<WingaCard[]>([])
  const [topWingas, setTopWingas] = useState<WingaCard[]>([])
  const [loading, setLoading] = useState(true)
  const [notifCount] = useState(0)

  const greeting = () => {
    const h = new Date().getHours()
    if (h < 12) return 'Habari za Asubuhi'
    if (h < 17) return 'Habari za Mchana'
    return 'Habari za Jioni'
  }

  useEffect(() => {
    loadData()
  }, [])

  async function loadData() {
    try {
      const uid = Session.uid()
      if (uid) {
        const { data: user } = await supabase
          .from('users')
          .select('name')
          .eq('id', uid)
          .maybeSingle()
        if (user?.name && user.name !== 'Mteja Mpya') {
          setUserName(user.name.split(' ')[0])
        }
      }

      // Load online verified wingas
      const { data: nearby } = await supabase
        .from('wingas')
        .select('id, name, specialty, badge, winga_score, rated_trips, total_trips, is_online, current_city, current_area, is_top_rated')
        .eq('status', 'active')
        .eq('verification_status', 'verified')
        .order('is_online', { ascending: false })
        .order('winga_score', { ascending: false })
        .limit(10)

      if (nearby) setWingas(nearby)

      // Load top rated
      const { data: top } = await supabase
        .from('wingas')
        .select('id, name, specialty, badge, winga_score, rated_trips, total_trips, is_online, current_city, current_area, is_top_rated')
        .eq('status', 'active')
        .eq('verification_status', 'verified')
        .eq('is_top_rated', true)
        .order('winga_score', { ascending: false })
        .limit(5)

      if (top) setTopWingas(top)
    } catch (e) {
      console.error('HomeScreen load error:', e)
    } finally {
      setLoading(false)
    }
  }

  const filtered = wingas.filter(w =>
    !search ||
    w.name.toLowerCase().includes(search.toLowerCase()) ||
    w.specialty.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: '#fff', paddingTop: 'env(safe-area-inset-top, 0px)', paddingLeft: 20, paddingRight: 20, paddingBottom: 12, borderBottom: '1px solid #F3F4F6', position: 'sticky', top: 0, zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: 12 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 16 }}>📍</span>
            <span style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 600 }}>{city}</span>
            <span style={{ color: '#9CA3AF', fontSize: 12 }}>▾</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ position: 'relative', cursor: 'pointer' }} onClick={() => nav('/requests')}>
              <span style={{ fontSize: 22 }}>🔔</span>
              {notifCount > 0 && (
                <div style={{ position: 'absolute', top: 0, right: 0, width: 8, height: 8, background: '#D32F2F', borderRadius: 4 }} />
              )}
            </div>
            <div onClick={() => nav('/profile')} style={{
              width: 36, height: 36, borderRadius: 18,
              background: '#E8F5E9', display: 'flex', alignItems: 'center',
              justifyContent: 'center', cursor: 'pointer', fontSize: 18,
            }}>👤</div>
          </div>
        </div>
      </div>

      <div className="scroll">
        <div style={{ padding: '20px 20px 0' }}>
          {/* Greeting */}
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', marginBottom: 2 }}>{greeting()} 👋</p>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 16, color: '#1A1A1A' }}>
            Karibu, {userName}!
          </h2>

          {/* Hero */}
          <div onClick={() => nav('/book')} style={{
            background: 'linear-gradient(135deg, #1A5C2A 0%, #0F3D1A 100%)',
            borderRadius: 20, padding: '20px', marginBottom: 20, cursor: 'pointer',
            position: 'relative', overflow: 'hidden',
          }}>
            <div style={{ position: 'absolute', top: -20, right: -20, width: 120, height: 120, borderRadius: 60, background: 'rgba(255,255,255,0.05)' }} />
            <h3 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff', marginBottom: 6 }}>
              Pata Winga Wako
            </h3>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.85)', marginBottom: 16 }}>
              Mwongozo wa kuaminika katika masoko ya Tanzania
            </p>
            <div style={{
              background: '#F9A825', color: '#1A1A1A',
              display: 'inline-flex', alignItems: 'center', gap: 6,
              padding: '10px 18px', borderRadius: 10,
              fontFamily: 'Inter', fontSize: 14, fontWeight: 700,
            }}>
              Omba Winga →
            </div>
            {wingas.filter(w => w.is_online).length > 0 && (
              <div style={{
                position: 'absolute', top: 16, right: 16,
                background: 'rgba(255,255,255,0.15)', borderRadius: 10,
                padding: '6px 12px', fontSize: 12, color: '#fff', fontFamily: 'Inter',
              }}>
                🟢 {wingas.filter(w => w.is_online).length} mtandaoni
              </div>
            )}
          </div>

          {/* Search */}
          <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
            <div style={{
              flex: 1, background: '#fff', border: '1px solid #E5E7EB',
              borderRadius: 12, display: 'flex', alignItems: 'center',
              gap: 10, padding: '0 14px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
            }}>
              <span>🔍</span>
              <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Tafuta Winga au bidhaa..."
                style={{
                  flex: 1, border: 'none', outline: 'none',
                  fontFamily: 'Inter', fontSize: 14, padding: '14px 0',
                  background: 'transparent',
                }}
              />
              {search && (
                <button onClick={() => setSearch('')}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9CA3AF', fontSize: 18 }}>✕</button>
              )}
            </div>
          </div>

          {/* Categories */}
          {!search && (
            <>
              <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>Kategoria</h3>
              <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4, marginBottom: 24, scrollbarWidth: 'none' }}>
                {CATEGORIES.map(cat => (
                  <div key={cat.id} onClick={() => nav(`/book?category=${cat.id}`)}
                    style={{
                      flexShrink: 0, background: '#fff', border: '1px solid #E5E7EB',
                      borderRadius: 14, padding: '10px 14px', cursor: 'pointer',
                      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 72,
                    }}>
                    <span style={{ fontSize: 24 }}>{cat.icon}</span>
                    <span style={{ fontFamily: 'Inter', fontSize: 10, fontWeight: 500, color: '#374151', textAlign: 'center' }}>{cat.name}</span>
                  </div>
                ))}
              </div>
            </>
          )}

          {/* Top Rated row */}
          {!search && topWingas.length > 0 && (
            <>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700 }}>⭐ Wingas Bora</h3>
                <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#1A5C2A', fontWeight: 600 }}>Wanaopendekezwa</span>
              </div>
              <div style={{ display: 'flex', gap: 12, overflowX: 'auto', paddingBottom: 4, marginBottom: 24, scrollbarWidth: 'none' }}>
                {topWingas.map(w => (
                  <div key={w.id} onClick={() => nav(`/book?winga=${w.id}`)}
                    style={{
                      flexShrink: 0, width: 140, background: '#fff',
                      border: '1.5px solid rgba(249,168,37,0.3)', borderRadius: 16,
                      padding: 12, cursor: 'pointer',
                      boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
                    }}>
                    <div style={{ width: 48, height: 48, borderRadius: 24, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, marginBottom: 8 }}>👤</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, marginBottom: 2 }}>{w.name.split(' ')[0]}</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280', marginBottom: 6 }}>{w.specialty}</div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <span style={{ fontSize: 9, background: '#F9A825', color: '#fff', fontWeight: 700, padding: '2px 6px', borderRadius: 20, fontFamily: 'Inter' }}>⭐ TOP</span>
                    </div>
                    {w.is_online && (
                      <div style={{ marginTop: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
                        <div style={{ width: 6, height: 6, borderRadius: 3, background: '#22C55E' }} />
                        <span style={{ fontFamily: 'Inter', fontSize: 10, color: '#22C55E' }}>Mtandaoni</span>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Wingas list */}
        <div style={{ padding: '0 20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700 }}>
              {search ? `Matokeo ya "${search}"` : 'Wingas Waliopo'}
            </h3>
            {!search && (
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>
                {wingas.filter(w => w.is_online).length} mtandaoni
              </span>
            )}
          </div>

          {loading ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {[1, 2, 3].map(i => (
                <div key={i} style={{ height: 96, background: '#F3F4F6', borderRadius: 16, animation: 'pulse 1.5s ease-in-out infinite' }} />
              ))}
            </div>
          ) : filtered.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>🔍</div>
              <p style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280' }}>
                {search ? `Hakuna Winga anayepatikana kwa "${search}"` : 'Hakuna Winga mtandaoni sasa hivi'}
              </p>
              {search && (
                <button onClick={() => setSearch('')}
                  style={{ marginTop: 12, background: 'none', border: 'none', color: '#1A5C2A', fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter' }}>
                  Tazama wote
                </button>
              )}
            </div>
          ) : (
            filtered.map(w => (
              <div key={w.id} onClick={() => nav(`/book?winga=${w.id}`)}
                style={{
                  background: '#fff', borderRadius: 16, padding: '14px 16px',
                  marginBottom: 10, cursor: 'pointer', display: 'flex', gap: 14,
                  border: '1px solid #F3F4F6',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
                }}>
                {/* Avatar */}
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  <div style={{ width: 52, height: 52, borderRadius: 26, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26 }}>👤</div>
                  {w.is_online && (
                    <div style={{ position: 'absolute', bottom: 1, right: 1, width: 12, height: 12, borderRadius: 6, background: '#22C55E', border: '2px solid #fff' }} />
                  )}
                </div>
                {/* Info */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 3 }}>
                    <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#1A1A1A' }}>{w.name}</span>
                    <WingaBadge badge={w.badge} />
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 6 }}>
                    {w.specialty}{w.current_area ? ` · ${w.current_area}` : ''}
                  </div>
                  <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                    {w.rated_trips > 0 && (
                      <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#1A5C2A', fontWeight: 600 }}>
                        👍 {Math.round((w.winga_score || 0) * 100)}%
                      </span>
                    )}
                    <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>
                      {w.total_trips ?? 0} safari
                    </span>
                    {w.is_top_rated && (
                      <span style={{ fontFamily: 'Inter', fontSize: 9, background: '#FFF8E1', color: '#F57F17', fontWeight: 700, padding: '2px 6px', borderRadius: 20 }}>⭐ TOP</span>
                    )}
                  </div>
                </div>
                {/* Book arrow */}
                <div style={{ display: 'flex', alignItems: 'center', color: '#D1D5DB', fontSize: 18, flexShrink: 0 }}>›</div>
              </div>
            ))
          )}

          {!loading && !search && wingas.length === 0 && (
            <div style={{ background: '#E8F5E9', borderRadius: 14, padding: 16, textAlign: 'center' }}>
              <div style={{ fontSize: 32, marginBottom: 8 }}>🛍️</div>
              <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#1A5C2A', fontWeight: 600, marginBottom: 4 }}>Winga App inaanza!</p>
              <p style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>Wingas wataonekana hapa baada ya kujisajili.</p>
            </div>
          )}

          <div style={{ height: 100 }} />
        </div>
      </div>

      <BottomNav active="home" />
      <style>{`@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.5} }`}</style>
    </div>
  )
}
