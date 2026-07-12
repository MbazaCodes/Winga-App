import { useState, useEffect, useRef } from 'react'
import { useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { WingaBadge } from '../components/ui/Badge'
import { CATEGORIES } from '../lib/constants'
import BottomNav from '../components/layout/BottomNav'

interface WingaCard {
  id: string; name: string; specialty: string; badge: string
  winga_score: number; rated_trips: number; total_trips: number
  is_online: boolean; current_city: string; current_area: string | null
  is_top_rated: boolean; winga_id: string; bio: string | null
  profile_photo: string | null; profile_complete: boolean
}

export default function CategorySafariScreen() {
  const nav = useNavigate()
  const [searchParams] = useSearchParams()
  const categoryId = searchParams.get('category') || 'all'

  const [wingas, setWingas] = useState<WingaCard[]>([])
  const [loading, setLoading] = useState(true)
  const [sortBy, setSortBy] = useState<'online' | 'rating' | 'trips'>('online')
  const [selectedWinga, setSelectedWinga] = useState<WingaCard | null>(null)
  const [appointing, setAppointing] = useState<string | null>(null)
  const mounted = useRef(true)

  const category = CATEGORIES.find(c => c.id === categoryId)

  useEffect(() => {
    mounted.current = true
    loadWingas()
    return () => { mounted.current = false }
  }, [categoryId, sortBy])

  async function loadWingas() {
    setLoading(true)
    try {
      let query = supabase
        .from('wingas')
        .select('id,name,specialty,badge,winga_score,rated_trips,total_trips,is_online,current_city,current_area,is_top_rated,winga_id,bio,profile_photo,profile_complete')
        .eq('status', 'active')
        .eq('profile_complete', true)

      // Filter by category if specific
      if (category) {
        query = query.ilike('specialty', `%${category.name}%`)
      }

      // Sort
      if (sortBy === 'online') query = query.order('is_online', { ascending: false }).order('winga_score', { ascending: false })
      else if (sortBy === 'rating') query = query.order('winga_score', { ascending: false })
      else query = query.order('total_trips', { ascending: false })

      const { data } = await query.limit(100)
      if (mounted.current) setWingas((data as WingaCard[]) || [])
    } catch {} finally {
      if (mounted.current) setLoading(false)
    }
  }

  const appointWinga = async (w: WingaCard) => {
    setAppointing(w.id)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const authUid = user?.id
      if (!authUid) { nav('/login'); return }

      const { error } = await supabase.from('requests').insert({
        customer_id: authUid,
        winga_id: w.id,
        category: w.specialty,
        meeting_point: '',
        shopping_area: '',
        service_type: 'hourly',
        delivery_method: 'with_client',
        estimated_price: 15000,
        total_price: 15000,
        note: `Ombi la moja kwa moja kwa ${w.name} (${w.winga_id})`,
        status: 'accepted',
        accepted_at: new Date().toISOString(),
      })
      if (!error) {
        setSelectedWinga(null)
        nav('/requests', { state: { justBooked: true } })
      }
    } catch {} finally {
      setAppointing(null)
    }
  }

  const onlineCount = wingas.filter(w => w.is_online).length

  // If a winga profile is selected, show it
  if (selectedWinga) {
    return (
      <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: '#F8F9FA' }}>
        <div style={{
          background: selectedWinga.is_online ? 'linear-gradient(135deg, #1A5C2A, #2E7D40)' : 'linear-gradient(135deg, #6B7280, #9CA3AF)',
          paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0, paddingBottom: 20,
        }}>
          <div style={{ padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 12 }}>
            <button onClick={() => setSelectedWinga(null)} style={{
              width: 36, height: 36, borderRadius: 18, background: 'rgba(255,255,255,0.2)',
              border: 'none', color: '#fff', fontSize: 20, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>←</button>
            <span style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: '#fff' }}>Wasifu wa Winga</span>
          </div>
          <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 10 }}>
            <div style={{ position: 'relative', marginBottom: 12 }}>
              {selectedWinga.profile_photo ? (
                <img src={selectedWinga.profile_photo} alt={selectedWinga.name} style={{ width: 80, height: 80, borderRadius: 40, objectFit: 'cover', border: '3px solid rgba(255,255,255,0.3)' }} />
              ) : (
                <div style={{ width: 80, height: 80, borderRadius: 40, background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 38 }}>👤</div>
              )}
              {selectedWinga.is_online && <div style={{ position: 'absolute', bottom: 2, right: 2, width: 14, height: 14, borderRadius: 7, background: '#22C55E', border: '3px solid #1A5C2A' }} />}
            </div>
            <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff' }}>{selectedWinga.name}</div>
            <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#F9A825', fontWeight: 600, marginTop: 2 }}>{selectedWinga.winga_id}</div>
            <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
              <WingaBadge badge={selectedWinga.badge} />
              {selectedWinga.is_top_rated && <span style={{ background: '#F9A825', color: '#fff', padding: '3px 10px', borderRadius: 20, fontFamily: 'Inter', fontSize: 10, fontWeight: 700 }}>⭐ TOP</span>}
            </div>
          </div>
        </div>
        <div style={{ flex: 1, overflowY: 'auto', padding: '20px 20px 120px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginBottom: 20 }}>
            {[
              { l: 'Ukadiriaji', v: selectedWinga.rated_trips > 0 ? `${Math.round((selectedWinga.winga_score||0)*100)}%` : '—', i: '⭐' },
              { l: 'Safari', v: String(selectedWinga.total_trips), i: '🛍️' },
              { l: 'Makadirio', v: String(selectedWinga.rated_trips), i: '👍' },
            ].map(s => (
              <div key={s.l} style={{ background: '#fff', borderRadius: 14, padding: '12px', textAlign: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
                <div style={{ fontSize: 18, marginBottom: 2 }}>{s.i}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: '#1A1A1A' }}>{s.v}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF', marginTop: 2 }}>{s.l}</div>
              </div>
            ))}
          </div>
          <div style={{ background: '#fff', borderRadius: 16, padding: 16, boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
            {[
              { l: 'Specialty', v: selectedWinga.specialty, i: '🏷️' },
              { l: 'Jiji', v: selectedWinga.current_city || '—', i: '🏙️' },
              { l: 'Eneo', v: selectedWinga.current_area || '—', i: '📍' },
            ].map(item => (
              <div key={item.l} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0', borderBottom: '1px solid #F3F4F6' }}>
                <span style={{ fontSize: 16 }}>{item.i}</span>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>{item.l}</div>
                  <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 500, color: '#1A1A1A' }}>{item.v}</div>
                </div>
              </div>
            ))}
          </div>
          {selectedWinga.bio && (
            <div style={{ background: '#fff', borderRadius: 16, padding: 16, marginTop: 16, boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A1A1A', marginBottom: 8 }}>Kuhusu</div>
              <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', lineHeight: 1.6 }}>{selectedWinga.bio}</p>
            </div>
          )}
        </div>
        <div style={{ position: 'fixed', bottom: 0, left: 0, right: 0, padding: '16px 20px calc(env(safe-area-inset-bottom,0px) + 16px)', background: '#fff', borderTop: '1px solid #F3F4F6', boxShadow: '0 -4px 16px rgba(0,0,0,0.06)', zIndex: 50 }}>
          <button onClick={() => appointWinga(selectedWinga)} disabled={!!appointing || !selectedWinga.is_online}
            style={{ width: '100%', height: 54, background: appointing || !selectedWinga.is_online ? '#9CA3AF' : '#1A5C2A', color: '#fff', border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 700, cursor: appointing || !selectedWinga.is_online ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, boxShadow: '0 4px 16px rgba(26,92,42,0.3)' }}>
            {appointing === selectedWinga.id ? '⏳ Inatuma...' : selectedWinga.is_online ? '🤝 Teua Winga Huu' : '⛔ Nje ya Mtandao'}
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="page">
      {/* Header */}
      <div style={{
        background: category ? 'linear-gradient(135deg, #1A5C2A, #2E7D40)' : '#1A5C2A',
        paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0, paddingBottom: 16,
      }}>
        <div style={{ padding: '12px 20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <button onClick={() => nav(-1)} style={{
              width: 36, height: 36, borderRadius: 18, background: 'rgba(255,255,255,0.2)',
              border: 'none', color: '#fff', fontSize: 20, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>←</button>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff', display: 'flex', alignItems: 'center', gap: 8 }}>
                {category ? `${category.icon} ${category.name}` : '🌍 Wote'} Safari
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.7)', marginTop: 2 }}>
                {wingas.length} Wingas {onlineCount > 0 && `· 🟢 ${onlineCount} mtandaoni`}
              </div>
            </div>
          </div>

          {/* Sort options */}
          <div style={{ display: 'flex', gap: 8 }}>
            {[
              { key: 'online' as const, label: '🟢 Mtandaoni' },
              { key: 'rating' as const, label: '⭐ Bora' },
              { key: 'trips' as const, label: '🛍️ Safari Nyingi' },
            ].map(s => (
              <button key={s.key} onClick={() => setSortBy(s.key)}
                style={{
                  padding: '6px 14px', borderRadius: 20, border: 'none',
                  fontFamily: 'Inter', fontSize: 11, fontWeight: 600, cursor: 'pointer',
                  background: sortBy === s.key ? 'rgba(255,255,255,0.25)' : 'rgba(255,255,255,0.08)',
                  color: '#fff', transition: 'all 0.2s',
                }}>
                {s.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="scroll">
        {loading ? (
          <div style={{ padding: '20px' }}>
            {[1,2,3,4].map(i => (
              <div key={i} style={{ height: 88, background: '#F3F4F6', borderRadius: 16, marginBottom: 10, animation: 'pulse 1.5s infinite' }} />
            ))}
          </div>
        ) : wingas.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px' }}>
            <div style={{ fontSize: 52, marginBottom: 12 }}>{category ? category.icon : '🔍'}</div>
            <p style={{ fontFamily: 'Inter', fontSize: 15, color: '#6B7280' }}>
              Hakuna Winga wa {category?.name || 'hii kategoria'} bado
            </p>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#9CA3AF', marginTop: 4 }}>
              Angalia tena baadaye
            </p>
          </div>
        ) : (
          <div style={{ padding: '16px 20px' }}>
            {wingas.map((w, idx) => (
              <div key={w.id} onClick={() => setSelectedWinga(w)}
                style={{
                  background: '#fff', borderRadius: 16, padding: '14px 16px', marginBottom: 10,
                  cursor: 'pointer', display: 'flex', gap: 14,
                  border: `1.5px solid ${w.is_online ? 'rgba(34,197,94,0.25)' : '#F3F4F6'}`,
                  boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
                  WebkitTapHighlightColor: 'transparent',
                  animation: idx < 5 ? `slideUp 0.3s ease ${idx * 0.05}s both` : 'none',
                }}>
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  {w.profile_photo ? (
                    <img src={w.profile_photo} alt={w.name} style={{ width: 56, height: 56, borderRadius: 28, objectFit: 'cover' }} />
                  ) : (
                    <div style={{ width: 56, height: 56, borderRadius: 28, background: '#E8F5E9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28 }}>👤</div>
                  )}
                  {w.is_online && <div style={{ position: 'absolute', bottom: 1, right: 1, width: 14, height: 14, borderRadius: 7, background: '#22C55E', border: '2.5px solid #fff' }} />}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 3 }}>
                    <div>
                      <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#1A1A1A' }}>{w.name}</span>
                      <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF', marginLeft: 8 }}>{w.winga_id}</span>
                    </div>
                    <WingaBadge badge={w.badge} />
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 4 }}>
                    {w.specialty}{w.current_area ? ` · ${w.current_area}` : ''}{w.current_city !== w.current_area ? ` · ${w.current_city}` : ''}
                  </div>
                  <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                    {w.rated_trips > 0 && <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#1A5C2A', fontWeight: 600 }}>👍 {Math.round((w.winga_score||0)*100)}%</span>}
                    <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>{w.total_trips} safari</span>
                    {w.is_top_rated && <span style={{ background: '#FFF8E1', color: '#F57F17', fontSize: 9, fontWeight: 700, padding: '2px 6px', borderRadius: 20, fontFamily: 'Inter' }}>⭐ TOP</span>}
                    {w.is_online && <span style={{ background: '#E8F5E9', color: '#22C55E', fontSize: 9, fontWeight: 600, padding: '2px 8px', borderRadius: 20, fontFamily: 'Inter' }}>🟢 Mtandaoni</span>}
                  </div>
                </div>
                <div style={{ color: '#D1D5DB', fontSize: 20, display: 'flex', alignItems: 'center' }}>›</div>
              </div>
            ))}
            <div style={{ height: 20 }} />
          </div>
        )}
      </div>

      <BottomNav />
      <style>{`
        @keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}
        @keyframes slideUp{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
      `}</style>
    </div>
  )
}