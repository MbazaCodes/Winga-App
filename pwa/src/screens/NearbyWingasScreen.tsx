import { useState, useEffect, useRef, useCallback } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
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

export default function NearbyWingasScreen() {
  const nav = useNavigate()
  const [searchParams] = useSearchParams()
  const preselectedCategory = searchParams.get('category') || ''

  const [wingas, setWingas] = useState<WingaCard[]>([])
  const [filteredWingas, setFilteredWingas] = useState<WingaCard[]>([])
  const [loading, setLoading] = useState(true)
  const [activeCategory, setActiveCategory] = useState(preselectedCategory)
  const [viewMode, setViewMode] = useState<'discover' | 'list'>('discover')
  const [currentIndex, setCurrentIndex] = useState(0)
  const [search, setSearch] = useState('')
  const [showProfile, setShowProfile] = useState<WingaCard | null>(null)
  const [appointing, setAppointing] = useState(false)
  const touchStartX = useRef(0)
  const touchStartY = useRef(0)
  const [swipeDir, setSwipeDir] = useState<'left' | 'right' | null>(null)
  const mounted = useRef(true)

  useEffect(() => {
    mounted.current = true
    loadWingas()
    return () => { mounted.current = false }
  }, [])

  useEffect(() => {
    if (wingas.length === 0) { setFilteredWingas([]); return }

    let result = [...wingas]

    // Filter by category
    if (activeCategory) {
      result = result.filter(w =>
        w.specialty.toLowerCase().includes(
          CATEGORIES.find(c => c.id === activeCategory)?.name.toLowerCase() || ''
        )
      )
    }

    // Filter by search
    if (search.trim()) {
      const q = search.toLowerCase()
      result = result.filter(w =>
        w.name.toLowerCase().includes(q) ||
        w.specialty.toLowerCase().includes(q) ||
        (w.current_area || '').toLowerCase().includes(q) ||
        (w.current_city || '').toLowerCase().includes(q)
      )
    }

    setFilteredWingas(result)
    setCurrentIndex(0)
  }, [activeCategory, search, wingas])

  async function loadWingas() {
    try {
      const { data } = await supabase
        .from('wingas')
        .select('id,name,specialty,badge,winga_score,rated_trips,total_trips,is_online,current_city,current_area,is_top_rated,winga_id,bio,profile_photo,profile_complete')
        .eq('status', 'active')
        .eq('profile_complete', true)
        .order('is_online', { ascending: false })
        .order('winga_score', { ascending: false })
        .limit(50)
      if (mounted.current) {
        setWingas((data as WingaCard[]) || [])
      }
    } catch {} finally {
      if (mounted.current) setLoading(false)
    }
  }

  // Swipe handling
  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX
    touchStartY.current = e.touches[0].clientY
  }

  const handleTouchEnd = (e: React.TouchEvent) => {
    const dx = e.changedTouches[0].clientX - touchStartX.current
    const dy = e.changedTouches[0].clientY - touchStartY.current
    if (Math.abs(dx) < 60 || Math.abs(dy) > Math.abs(dx)) return

    if (dx < 0 && currentIndex < filteredWingas.length - 1) {
      setSwipeDir('left')
      setTimeout(() => { setCurrentIndex(i => i + 1); setSwipeDir(null) }, 250)
    } else if (dx > 0 && currentIndex > 0) {
      setSwipeDir('right')
      setTimeout(() => { setCurrentIndex(i => i - 1); setSwipeDir(null) }, 250)
    }
  }

  const goNext = () => {
    if (currentIndex < filteredWingas.length - 1) {
      setSwipeDir('left')
      setTimeout(() => { setCurrentIndex(i => i + 1); setSwipeDir(null) }, 250)
    }
  }

  const goPrev = () => {
    if (currentIndex > 0) {
      setSwipeDir('right')
      setTimeout(() => { setCurrentIndex(i => i - 1); setSwipeDir(null) }, 250)
    }
  }

  const appointWinga = async (w: WingaCard) => {
    setAppointing(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const authUid = user?.id || Session.uid()
      if (!authUid) { nav('/login'); return }

      // Create request appointed to this specific Winga
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
        setShowProfile(null)
        nav('/requests', { state: { justBooked: true } })
      }
    } catch {} finally {
      setAppointing(false)
    }
  }

  const currentWinga = filteredWingas[currentIndex]

  if (showProfile) {
    return <WingaProfileModal winga={showProfile} onBack={() => setShowProfile(null)} onAppoint={() => appointWinga(showProfile)} appointing={appointing} />
  }

  return (
    <div className="page">
      {/* Header */}
      <div style={{
        background: '#fff', flexShrink: 0,
        paddingTop: 'env(safe-area-inset-top,0px)',
        borderBottom: '1px solid #F3F4F6',
        position: 'sticky', top: 0, zIndex: 10,
      }}>
        <div style={{ padding: '12px 20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h2 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#1A1A1A' }}>
              🔍 Gundua Wingas
            </h2>
            <div style={{ display: 'flex', gap: 4, background: '#F3F4F6', borderRadius: 10, padding: 3 }}>
              <button onClick={() => setViewMode('discover')}
                style={{ padding: '6px 12px', border: 'none', borderRadius: 8, fontFamily: 'Inter', fontSize: 11, fontWeight: 600, cursor: 'pointer',
                  background: viewMode === 'discover' ? '#1A5C2A' : 'transparent', color: viewMode === 'discover' ? '#fff' : '#6B7280', transition: 'all 0.2s' }}>
                🃏 Kadi
              </button>
              <button onClick={() => setViewMode('list')}
                style={{ padding: '6px 12px', border: 'none', borderRadius: 8, fontFamily: 'Inter', fontSize: 11, fontWeight: 600, cursor: 'pointer',
                  background: viewMode === 'list' ? '#1A5C2A' : 'transparent', color: viewMode === 'list' ? '#fff' : '#6B7280', transition: 'all 0.2s' }}>
                📋 Orodha
              </button>
            </div>
          </div>

          {/* Search */}
          <div style={{ display: 'flex', alignItems: 'center', background: '#F8F9FA', border: '1px solid #E5E7EB', borderRadius: 12, padding: '0 14px' }}>
            <span style={{ fontSize: 16, marginRight: 8 }}>🔍</span>
            <input
              value={search} onChange={e => setSearch(e.target.value)}
              placeholder="Tafuta jina, eneo, au specialty..."
              style={{ flex: 1, border: 'none', outline: 'none', fontFamily: 'Inter', fontSize: 13, padding: '12px 0', background: 'transparent' }}
            />
            {search && (
              <button onClick={() => setSearch('')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9CA3AF', fontSize: 18, padding: '4px' }}>✕</button>
            )}
          </div>
        </div>

        {/* Category filters */}
        <div style={{ padding: '0 20px 12px', display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none' }}>
          <button onClick={() => setActiveCategory('')}
            style={{ flexShrink: 0, padding: '6px 14px', borderRadius: 20, border: 'none', fontFamily: 'Inter', fontSize: 11, fontWeight: 600, cursor: 'pointer',
              background: !activeCategory ? '#1A5C2A' : '#F3F4F6', color: !activeCategory ? '#fff' : '#6B7280', transition: 'all 0.2s' }}>
            Wote
          </button>
          {CATEGORIES.map(cat => (
            <button key={cat.id} onClick={() => setActiveCategory(activeCategory === cat.id ? '' : cat.id)}
              style={{ flexShrink: 0, padding: '6px 14px', borderRadius: 20, border: 'none', fontFamily: 'Inter', fontSize: 11, fontWeight: 500, cursor: 'pointer',
                background: activeCategory === cat.id ? '#1A5C2A' : '#F3F4F6', color: activeCategory === cat.id ? '#fff' : '#6B7280', transition: 'all 0.2s',
                display: 'flex', alignItems: 'center', gap: 4 }}>
              <span style={{ fontSize: 13 }}>{cat.icon}</span>
              {cat.name}
            </button>
          ))}
        </div>
      </div>

      <div className="scroll">
        {loading ? (
          <div style={{ padding: '40px 20px', textAlign: 'center' }}>
            {[1,2,3].map(i => (
              <div key={i} style={{ height: 100, background: '#F3F4F6', borderRadius: 16, marginBottom: 12, animation: 'pulse 1.5s infinite' }} />
            ))}
          </div>
        ) : filteredWingas.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px' }}>
            <div style={{ fontSize: 52, marginBottom: 12 }}>🔍</div>
            <p style={{ fontFamily: 'Inter', fontSize: 15, color: '#6B7280', marginBottom: 6 }}>
              {activeCategory ? 'Hakuna Winga kwa kategoria hii bado' : 'Hakuna Winga waliopo sasa hivi'}
            </p>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#9CA3AF' }}>
              Jaribu tena baadaye au badilisha chujio
            </p>
          </div>
        ) : viewMode === 'discover' ? (
          /* ═══════ CARD DISCOVERY MODE (Badoo-style) ═══════ */
          <div style={{ padding: '16px 20px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            {/* Card counter */}
            <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#9CA3AF', marginBottom: 12 }}>
              {currentIndex + 1} / {filteredWingas.length} Wingas
            </div>

            {/* Card stack */}
            <div style={{ width: '100%', maxWidth: 360, height: 440, position: 'relative', perspective: 800 }}
              onTouchStart={handleTouchStart} onTouchEnd={handleTouchEnd}>

              {/* Background card (next) */}
              {currentIndex + 1 < filteredWingas.length && (
                <div style={{
                  position: 'absolute', inset: 0, borderRadius: 24,
                  background: '#E5E7EB', transform: 'scale(0.93)', zIndex: 1,
                }}>
                  <div style={{ width: '100%', height: '100%', borderRadius: 24, background: '#fff', border: '1px solid #E5E7EB', padding: 20, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, opacity: 0.5 }}>
                    <div style={{ fontSize: 36 }}>👤</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#9CA3AF' }}>
                      {filteredWingas[currentIndex + 1].name}
                    </div>
                  </div>
                </div>
              )}

              {/* Active card */}
              {currentWinga && (
                <div style={{
                  position: 'relative', zIndex: 2, width: '100%', height: '100%',
                  borderRadius: 24, background: '#fff',
                  border: '2px solid #E5E7EB',
                  boxShadow: '0 8px 32px rgba(0,0,0,0.12)',
                  overflow: 'hidden',
                  transition: swipeDir === 'left' ? 'transform 0.25s ease-in, opacity 0.25s ease-in' :
                    swipeDir === 'right' ? 'transform 0.25s ease-in, opacity 0.25s ease-in' : 'none',
                  transform: swipeDir === 'left' ? 'translateX(-120%) rotate(-10deg)' :
                    swipeDir === 'right' ? 'translateX(120%) rotate(10deg)' : 'translateX(0) rotate(0)',
                  opacity: swipeDir ? 0.5 : 1,
                  cursor: 'pointer',
                }} onClick={() => setShowProfile(currentWinga)}>
                  {/* Top gradient with photo area */}
                  <div style={{
                    height: 220, position: 'relative',
                    background: currentWinga.is_online
                      ? 'linear-gradient(135deg, #1A5C2A, #2E7D40)'
                      : 'linear-gradient(135deg, #6B7280, #9CA3AF)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    {/* Online badge */}
                    <div style={{
                      position: 'absolute', top: 16, right: 16,
                      background: currentWinga.is_online ? '#22C55E' : '#9CA3AF',
                      color: '#fff', padding: '4px 12px', borderRadius: 20,
                      fontFamily: 'Inter', fontSize: 11, fontWeight: 600,
                      display: 'flex', alignItems: 'center', gap: 4,
                    }}>
                      <div style={{ width: 6, height: 6, borderRadius: 3, background: '#fff' }} />
                      {currentWinga.is_online ? 'Mtandaoni' : 'Nje'}
                    </div>

                    {/* Top Rated badge */}
                    {currentWinga.is_top_rated && (
                      <div style={{
                        position: 'absolute', top: 16, left: 16,
                        background: '#F9A825', color: '#fff', padding: '4px 12px', borderRadius: 20,
                        fontFamily: 'Inter', fontSize: 11, fontWeight: 700,
                      }}>
                        ⭐ TOP RATED
                      </div>
                    )}

                    {/* Avatar */}
                    {currentWinga.profile_photo ? (
                      <img src={currentWinga.profile_photo} alt={currentWinga.name}
                        style={{ width: 90, height: 90, borderRadius: 45, objectFit: 'cover', border: '4px solid rgba(255,255,255,0.3)' }} />
                    ) : (
                      <div style={{
                        width: 90, height: 90, borderRadius: 45,
                        background: 'rgba(255,255,255,0.15)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: 42, border: '3px solid rgba(255,255,255,0.2)',
                      }}>👤</div>
                    )}

                    {/* Tap to view */}
                    <div style={{
                      position: 'absolute', bottom: 12, left: 0, right: 0,
                      textAlign: 'center', fontFamily: 'Inter', fontSize: 11, color: 'rgba(255,255,255,0.7)',
                    }}>
                      Bonyeza kuona wasifu kamili
                    </div>
                  </div>

                  {/* Card info */}
                  <div style={{ padding: '16px 20px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                      <div>
                        <div style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: '#1A1A1A' }}>
                          {currentWinga.name}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginTop: 2 }}>
                          {currentWinga.winga_id}
                        </div>
                      </div>
                      <WingaBadge badge={currentWinga.badge} />
                    </div>

                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 10 }}>
                      <span style={{ background: '#E8F5E9', color: '#1A5C2A', padding: '4px 10px', borderRadius: 8, fontFamily: 'Inter', fontSize: 11, fontWeight: 500 }}>
                        🏷️ {currentWinga.specialty}
                      </span>
                      {currentWinga.current_area && (
                        <span style={{ background: '#F3F4F6', color: '#6B7280', padding: '4px 10px', borderRadius: 8, fontFamily: 'Inter', fontSize: 11, fontWeight: 500 }}>
                          📍 {currentWinga.current_area}
                        </span>
                      )}
                    </div>

                    {currentWinga.bio && (
                      <p style={{
                        fontFamily: 'Inter', fontSize: 12, color: '#6B7280', lineHeight: 1.5,
                        overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical',
                      }}>
                        {currentWinga.bio}
                      </p>
                    )}

                    {/* Stats */}
                    <div style={{ display: 'flex', gap: 16, marginTop: 12, paddingTop: 12, borderTop: '1px solid #F3F4F6' }}>
                      <div style={{ textAlign: 'center', flex: 1 }}>
                        <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: '#1A5C2A' }}>
                          {currentWinga.rated_trips > 0 ? `${Math.round((currentWinga.winga_score || 0) * 100)}%` : '—'}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF' }}>Ukadiriaji</div>
                      </div>
                      <div style={{ textAlign: 'center', flex: 1 }}>
                        <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: '#1A1A1A' }}>
                          {currentWinga.total_trips}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF' }}>Safari</div>
                      </div>
                      <div style={{ textAlign: 'center', flex: 1 }}>
                        <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: '#1A5C2A' }}>
                          {currentWinga.rated_trips}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF' }}>Makadirio</div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Navigation buttons */}
            <div style={{ display: 'flex', gap: 20, marginTop: 20, alignItems: 'center' }}>
              <button onClick={goPrev} disabled={currentIndex === 0}
                style={{
                  width: 50, height: 50, borderRadius: 25,
                  background: currentIndex === 0 ? '#F3F4F6' : '#fff',
                  border: '2px solid #E5E7EB', cursor: currentIndex === 0 ? 'not-allowed' : 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 22, color: '#6B7280', transition: 'all 0.2s',
                }}>‹</button>

              <button onClick={() => currentWinga && appointWinga(currentWinga)}
                disabled={appointing || !currentWinga?.is_online}
                style={{
                  height: 50, padding: '0 28px', borderRadius: 25,
                  background: appointing || !currentWinga?.is_online ? '#9CA3AF' : '#1A5C2A',
                  color: '#fff', border: 'none', cursor: appointing ? 'not-allowed' : 'pointer',
                  fontFamily: 'Inter', fontSize: 14, fontWeight: 600,
                  display: 'flex', alignItems: 'center', gap: 8,
                  boxShadow: '0 4px 12px rgba(26,92,42,0.3)',
                  transition: 'all 0.2s',
                }}>
                {appointing ? '⏳ Inatuma...' : '🤝 Teua Winga Huu'}
              </button>

              <button onClick={goNext} disabled={currentIndex >= filteredWingas.length - 1}
                style={{
                  width: 50, height: 50, borderRadius: 25,
                  background: currentIndex >= filteredWingas.length - 1 ? '#F3F4F6' : '#fff',
                  border: '2px solid #E5E7EB', cursor: currentIndex >= filteredWingas.length - 1 ? 'not-allowed' : 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 22, color: '#6B7280', transition: 'all 0.2s',
                }}>›</button>
            </div>

            <p style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF', marginTop: 12, textAlign: 'center' }}>
              Teleka kadi kulia/kushoto au bonyeza kitufe
            </p>
          </div>
        ) : (
          /* ═══════ LIST MODE ═══════ */
          <div style={{ padding: '0 20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <span style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280' }}>
                {filteredWingas.length} Wingas waliopatikana
              </span>
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#22C55E', fontWeight: 600 }}>
                🟢 {filteredWingas.filter(w => w.is_online).length} mtandaoni
              </span>
            </div>

            {filteredWingas.map(w => (
              <div key={w.id} onClick={() => setShowProfile(w)}
                style={{
                  background: '#fff', borderRadius: 16, padding: '14px 16px', marginBottom: 10,
                  cursor: 'pointer', display: 'flex', gap: 14,
                  border: `1.5px solid ${w.is_online ? 'rgba(34,197,94,0.3)' : '#F3F4F6'}`,
                  boxShadow: '0 2px 6px rgba(0,0,0,0.04)',
                  WebkitTapHighlightColor: 'transparent',
                  transition: 'transform 0.15s',
                }}>
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  {w.profile_photo ? (
                    <img src={w.profile_photo} alt={w.name}
                      style={{ width: 54, height: 54, borderRadius: 27, objectFit: 'cover' }} />
                  ) : (
                    <div style={{
                      width: 54, height: 54, borderRadius: 27, background: '#E8F5E9',
                      display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26,
                    }}>👤</div>
                  )}
                  {w.is_online && (
                    <div style={{ position: 'absolute', bottom: 1, right: 1, width: 14, height: 14, borderRadius: 7, background: '#22C55E', border: '2.5px solid #fff' }} />
                  )}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 3 }}>
                    <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#1A1A1A' }}>{w.name}</span>
                    <WingaBadge badge={w.badge} />
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 4 }}>
                    {w.specialty}{w.current_area ? ` · ${w.current_area}` : ''}
                  </div>
                  <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                    {w.rated_trips > 0 && (
                      <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#1A5C2A', fontWeight: 600 }}>
                        👍 {Math.round((w.winga_score || 0) * 100)}%
                      </span>
                    )}
                    <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>
                      {w.total_trips} safari
                    </span>
                    {w.is_top_rated && (
                      <span style={{ background: '#FFF8E1', color: '#F57F17', fontSize: 9, fontWeight: 700, padding: '2px 6px', borderRadius: 20, fontFamily: 'Inter' }}>⭐ TOP</span>
                    )}
                  </div>
                </div>
                <div style={{ color: '#D1D5DB', fontSize: 20, display: 'flex', alignItems: 'center' }}>›</div>
              </div>
            ))}
          </div>
        )}

        <div style={{ height: 20 }} />
      </div>

      <BottomNav />
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}`}</style>
    </div>
  )
}

/* ═══════ WINGA PROFILE MODAL ═══════ */
function WingaProfileModal({ winga, onBack, onAppoint, appointing }: {
  winga: WingaCard; onBack: () => void; onAppoint: () => void; appointing: boolean
}) {
  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: '#F8F9FA' }}>
      {/* Header */}
      <div style={{
        background: winga.is_online ? 'linear-gradient(135deg, #1A5C2A, #2E7D40)' : 'linear-gradient(135deg, #6B7280, #9CA3AF)',
        paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0,
        paddingBottom: 20, position: 'relative',
      }}>
        <div style={{ padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={onBack} style={{
            width: 36, height: 36, borderRadius: 18, background: 'rgba(255,255,255,0.2)',
            border: 'none', color: '#fff', fontSize: 20, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>←</button>
          <span style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: '#fff' }}>Wasifu wa Winga</span>
        </div>

        {/* Profile section */}
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 10 }}>
          <div style={{ position: 'relative', marginBottom: 12 }}>
            {winga.profile_photo ? (
              <img src={winga.profile_photo} alt={winga.name}
                style={{ width: 88, height: 88, borderRadius: 44, objectFit: 'cover', border: '4px solid rgba(255,255,255,0.3)' }} />
            ) : (
              <div style={{
                width: 88, height: 88, borderRadius: 44, background: 'rgba(255,255,255,0.15)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 42, border: '3px solid rgba(255,255,255,0.2)',
              }}>👤</div>
            )}
            {winga.is_online && (
              <div style={{ position: 'absolute', bottom: 4, right: 4, width: 16, height: 16, borderRadius: 8, background: '#22C55E', border: '3px solid #1A5C2A' }} />
            )}
          </div>

          <div style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: '#fff' }}>{winga.name}</div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#F9A825', fontWeight: 600, marginTop: 2, letterSpacing: 1 }}>{winga.winga_id}</div>

          <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
            <WingaBadge badge={winga.badge} />
            {winga.is_top_rated && (
              <span style={{ background: '#F9A825', color: '#fff', padding: '4px 12px', borderRadius: 20, fontFamily: 'Inter', fontSize: 11, fontWeight: 700 }}>⭐ TOP RATED</span>
            )}
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: auto, padding: '20px 20px 120px' }}>
        {/* Info cards */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginBottom: 20 }}>
          {[
            { label: 'Ukadiriaji', value: winga.rated_trips > 0 ? `${Math.round((winga.winga_score || 0) * 100)}%` : '—', icon: '⭐' },
            { label: 'Safari', value: String(winga.total_trips), icon: '🛍️' },
            { label: 'Makadirio', value: String(winga.rated_trips), icon: '👍' },
          ].map(s => (
            <div key={s.label} style={{ background: '#fff', borderRadius: 14, padding: '14px 12px', textAlign: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
              <div style={{ fontSize: 20, marginBottom: 4 }}>{s.icon}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: '#1A1A1A' }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF', marginTop: 2 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Details */}
        <div style={{ background: '#fff', borderRadius: 16, padding: 16, marginBottom: 16, boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A1A1A', marginBottom: 12 }}>Taarifa</div>

          {[
            { label: 'Specialty', value: winga.specialty, icon: '🏷️' },
            { label: 'Jiji', value: winga.current_city || '—', icon: '🏙️' },
            { label: 'Eneo', value: winga.current_area || '—', icon: '📍' },
            { label: 'Hali', value: winga.is_online ? 'Mtandaoni' : 'Nje', icon: winga.is_online ? '🟢' : '⚪' },
          ].map(item => (
            <div key={item.label} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0', borderBottom: '1px solid #F3F4F6' }}>
              <span style={{ fontSize: 18 }}>{item.icon}</span>
              <div>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>{item.label}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 500, color: '#1A1A1A' }}>{item.value}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Bio */}
        {winga.bio && (
          <div style={{ background: '#fff', borderRadius: 16, padding: 16, marginBottom: 16, boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
            <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A1A1A', marginBottom: 8 }}>Kuhusu</div>
            <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', lineHeight: 1.6 }}>{winga.bio}</p>
          </div>
        )}
      </div>

      {/* Bottom CTA */}
      <div style={{
        position: 'fixed', bottom: 0, left: 0, right: 0,
        padding: '16px 20px calc(env(safe-area-inset-bottom,0px) + 16px)',
        background: '#fff', borderTop: '1px solid #F3F4F6',
        boxShadow: '0 -4px 16px rgba(0,0,0,0.06)', zIndex: 50,
      }}>
        <button
          onClick={onAppoint}
          disabled={appointing || !winga.is_online}
          style={{
            width: '100%', height: 54,
            background: appointing || !winga.is_online ? '#9CA3AF' : '#1A5C2A',
            color: '#fff', border: 'none', borderRadius: 14,
            fontFamily: 'Inter', fontSize: 16, fontWeight: 700,
            cursor: appointing || !winga.is_online ? 'not-allowed' : 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: '0 4px 16px rgba(26,92,42,0.3)',
          }}>
          {appointing ? '⏳ Inatuma ombi...' : winga.is_online ? '🤝 Teua Winga Huu Sasa' : '⛔ Winga Huyu Hayuko Mtandaoni'}
        </button>
        {!winga.is_online && (
          <p style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF', textAlign: 'center', marginTop: 8 }}>
            Winga huyu hayuko mtandaoni. Unaweza kutuma ombi la jumla litakalofikishwa apo atakapoingia.
          </p>
        )}
      </div>
    </div>
  )
}