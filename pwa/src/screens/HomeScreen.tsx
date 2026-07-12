import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { CATEGORIES } from '../lib/constants'

interface WingaCard {
  id: string; name: string; specialty: string; badge: string
  winga_score: number; rated_trips: number; total_trips: number
  is_online: boolean; current_city: string; current_area: string | null
  is_top_rated: boolean
}

export default function HomeScreen() {
  const nav = useNavigate()
  const [search, setSearch] = useState('')
  const [userName, setUserName] = useState('')
  const [wingas, setWingas] = useState<WingaCard[]>([])
  const [topWingas, setTopWingas] = useState<WingaCard[]>([])
  const [loading, setLoading] = useState(true)
  const mounted = useRef(true)

  const hour = new Date().getHours()
  const greeting = hour < 12 ? 'Habari za Asubuhi' : hour < 17 ? 'Habari za Mchana' : 'Habari za Jioni'

  useEffect(() => {
    mounted.current = true
    loadData()
    return () => { mounted.current = false }
  }, [])

  async function loadData() {
    const uid = Session.uid()
    if (uid) {
      try {
        const { data: user } = await supabase
          .from('users').select('name').eq('id', uid).maybeSingle()
        if (mounted.current && user?.name) {
          const n = user.name
          // Show real name; if still default placeholder, show empty (will show generic greeting)
          setUserName(n === 'Mteja Mpya' ? '' : n.split(' ')[0])
        }
      } catch {}
    }

    try {
      const { data: nearby } = await supabase
        .from('wingas')
        .select('id,name,specialty,badge,winga_score,rated_trips,total_trips,is_online,current_city,current_area,is_top_rated')
        .eq('status', 'active')
        .eq('verification_status', 'verified')
        .order('is_online', { ascending: false })
        .order('winga_score', { ascending: false })
        .limit(20)
      if (mounted.current) setWingas(nearby || [])
    } catch {}

    try {
      const { data: top } = await supabase
        .from('wingas')
        .select('id,name,specialty,badge,winga_score,rated_trips,total_trips,is_online,current_city,current_area,is_top_rated')
        .eq('status', 'active')
        .eq('is_top_rated', true)
        .order('winga_score', { ascending: false })
        .limit(5)
      if (mounted.current) setTopWingas(top || [])
    } catch {}

    if (mounted.current) setLoading(false)
  }

  const filtered = search.trim()
    ? wingas.filter(w =>
        w.name.toLowerCase().includes(search.toLowerCase()) ||
        w.specialty.toLowerCase().includes(search.toLowerCase()) ||
        (w.current_area || '').toLowerCase().includes(search.toLowerCase()))
    : wingas

  const onlineCount = wingas.filter(w => w.is_online).length

  return (
    <div className="page">
      {/* Sticky header */}
      <div style={{
        background: '#fff', flexShrink: 0,
        paddingTop: 'env(safe-area-inset-top,0px)',
        borderBottom: '1px solid #F3F4F6',
        position: 'sticky', top: 0, zIndex: 10,
      }}>
        <div style={{ padding: '12px 20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, cursor: 'pointer' }}>
              <span style={{ fontSize: 16 }}>📍</span>
              <span style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 600 }}>Tanzania</span>
              <span style={{ color: '#9CA3AF', fontSize: 12 }}>▾</span>
            </div>
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <div style={{ position: 'relative', cursor: 'pointer' }} onClick={() => nav('/requests')}>
                <span style={{ fontSize: 22 }}>🔔</span>
              </div>
              <div onClick={() => nav('/profile')} style={{ width: 34, height: 34, borderRadius: 17, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', fontSize: 18 }}>👤</div>
            </div>
          </div>
        </div>
      </div>

      <div className="scroll">
        <div style={{ padding: '20px 20px 0' }}>
          {/* Greeting */}
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', marginBottom: 2 }}>{greeting} 👋</p>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: '#1A1A1A', marginBottom: 20 }}>
            {userName ? `Karibu, ${userName}! 👋` : 'Karibu Winga App! 👋'}
          </h2>

          {/* Hero */}
          <div onClick={() => nav('/book')} style={{
            background: 'linear-gradient(135deg,#1A5C2A,#0F3D1A)',
            borderRadius: 20, padding: '20px', marginBottom: 20, cursor: 'pointer',
            position: 'relative', overflow: 'hidden',
            WebkitTapHighlightColor: 'transparent',
          }}>
            <div style={{ position: 'absolute', top: -20, right: -20, width: 100, height: 100, borderRadius: 50, background: 'rgba(255,255,255,0.05)' }} />
            <h3 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff', marginBottom: 6 }}>Pata Winga Wako</h3>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.85)', marginBottom: 16 }}>
              Mwongozo wa kuaminika katika masoko ya Tanzania
            </p>
            <div style={{ background: '#F9A825', color: '#1A1A1A', display: 'inline-flex', alignItems: 'center', gap: 6, padding: '10px 18px', borderRadius: 10, fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>
              Omba Winga →
            </div>
            {onlineCount > 0 && (
              <div style={{ position: 'absolute', top: 16, right: 16, background: 'rgba(255,255,255,0.15)', borderRadius: 10, padding: '6px 12px', fontSize: 12, color: '#fff', fontFamily: 'Inter' }}>
                🟢 {onlineCount} mtandaoni
              </div>
            )}
          </div>

          {/* Search */}
          <div style={{ display: 'flex', alignItems: 'center', background: '#fff', border: '1px solid #E5E7EB', borderRadius: 14, padding: '0 16px', marginBottom: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
            <span style={{ fontSize: 18, marginRight: 10 }}>🔍</span>
            <input
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Tafuta Winga au bidhaa..."
              style={{ flex: 1, border: 'none', outline: 'none', fontFamily: 'Inter', fontSize: 14, padding: '14px 0', background: 'transparent' }}
            />
            {search && (
              <button onClick={() => setSearch('')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9CA3AF', fontSize: 20, padding: '4px' }}>✕</button>
            )}
          </div>

          {/* Categories */}
          {!search && (
            <>
              <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>Kategoria</h3>
              <div style={{ display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 4, marginBottom: 24, scrollbarWidth: 'none' }}>
                {CATEGORIES.map(cat => (
                  <div key={cat.id} onClick={() => nav(`/book?category=${cat.id}`)}
                    style={{ flexShrink: 0, background: '#fff', border: '1px solid #E5E7EB', borderRadius: 14, padding: '12px 14px', cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, minWidth: 76, WebkitTapHighlightColor: 'transparent' }}>
                    <span style={{ fontSize: 26 }}>{cat.icon}</span>
                    <span style={{ fontFamily: 'Inter', fontSize: 10, fontWeight: 500, color: '#374151', textAlign: 'center', lineHeight: 1.3 }}>{cat.name}</span>
                  </div>
                ))}
              </div>
            </>
          )}

          {/* Top rated */}
          {!search && topWingas.length > 0 && (
            <>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                <h3 style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700 }}>⭐ Wingas Bora</h3>
                <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#1A5C2A', fontWeight: 600 }}>Wanaopendekezwa</span>
              </div>
              <div style={{ display: 'flex', gap: 12, overflowX: 'auto', paddingBottom: 4, marginBottom: 24, scrollbarWidth: 'none' }}>
                {topWingas.map(w => (
                  <div key={w.id} onClick={() => nav(`/book?winga=${w.id}`)}
                    style={{ flexShrink: 0, width: 140, background: '#fff', border: '1.5px solid rgba(249,168,37,0.35)', borderRadius: 16, padding: 12, cursor: 'pointer', boxShadow: '0 2px 8px rgba(0,0,0,0.05)', WebkitTapHighlightColor: 'transparent' }}>
                    <div style={{ width: 48, height: 48, borderRadius: 24, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, marginBottom: 8 }}>👤</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, marginBottom: 2, overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>{w.name.split(' ')[0]}</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280', marginBottom: 6, overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>{w.specialty}</div>
                    <span style={{ background: '#F9A825', color: '#fff', fontSize: 9, fontWeight: 700, padding: '2px 8px', borderRadius: 20, fontFamily: 'Inter' }}>⭐ TOP</span>
                    {w.is_online && <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', gap: 4 }}><div style={{ width: 6, height: 6, borderRadius: 3, background: '#22C55E' }} /><span style={{ fontFamily: 'Inter', fontSize: 10, color: '#22C55E' }}>Mtandaoni</span></div>}
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
              {search ? `Matokeo: "${search}"` : 'Wingas Waliopo'}
            </h3>
            {!search && onlineCount > 0 && (
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>{onlineCount} mtandaoni</span>
            )}
          </div>

          {loading ? (
            [1,2,3].map(i => (
              <div key={i} style={{ height: 90, background: '#F3F4F6', borderRadius: 16, marginBottom: 10, animation: 'pulse 1.5s infinite' }} />
            ))
          ) : filtered.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>{search ? '🔍' : '🛍️'}</div>
              <p style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280', marginBottom: 16 }}>
                {search ? `Hakuna Winga kwa "${search}"` : 'Hakuna Winga mtandaoni sasa hivi'}
              </p>
              {search
                ? <button onClick={() => setSearch('')} style={{ background: 'none', border: 'none', color: '#1A5C2A', fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer', fontSize: 14 }}>Tazama wote →</button>
                : <button onClick={() => nav('/book')} style={{ background: '#1A5C2A', color: '#fff', border: 'none', borderRadius: 12, padding: '12px 24px', fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer', fontSize: 14 }}>Omba Winga</button>
              }
            </div>
          ) : (
            filtered.map(w => (
              <div key={w.id} onClick={() => nav(`/book?winga=${w.id}`)}
                style={{ background: '#fff', borderRadius: 16, padding: '14px 16px', marginBottom: 10, cursor: 'pointer', display: 'flex', gap: 14, border: '1px solid #F3F4F6', boxShadow: '0 2px 6px rgba(0,0,0,0.04)', WebkitTapHighlightColor: 'transparent' }}>
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  <div style={{ width: 52, height: 52, borderRadius: 26, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26 }}>👤</div>
                  {w.is_online && <div style={{ position: 'absolute', bottom: 1, right: 1, width: 12, height: 12, borderRadius: 6, background: '#22C55E', border: '2px solid #fff' }} />}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 3 }}>
                    <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#1A1A1A' }}>{w.name}</span>
                    <WingaBadge badge={w.badge} />
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 6 }}>
                    {w.specialty}{w.current_area ? ` · ${w.current_area}` : ''}
                  </div>
                  <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                    {w.rated_trips > 0 && <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#1A5C2A', fontWeight: 600 }}>👍 {Math.round((w.winga_score||0)*100)}%</span>}
                    <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>{w.total_trips||0} safari</span>
                    {w.is_top_rated && <span style={{ background: '#FFF8E1', color: '#F57F17', fontSize: 9, fontWeight: 700, padding: '2px 6px', borderRadius: 20, fontFamily: 'Inter' }}>⭐ TOP</span>}
                  </div>
                </div>
                <div style={{ color: '#D1D5DB', fontSize: 20, display: 'flex', alignItems: 'center' }}>›</div>
              </div>
            ))
          )}
          <div style={{ height: 20 }} />
        </div>
      </div>

      <BottomNav />
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}`}</style>
    </div>
  )
}
