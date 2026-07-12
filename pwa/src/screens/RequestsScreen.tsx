import { useState, useEffect, useCallback, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import AppBar from '../components/layout/AppBar'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import { fmt } from '../lib/constants'

/* ------------------------------------------------------------------ */
/*  Types                                                              */
/* ------------------------------------------------------------------ */

interface WingaRow {
  id: string
  name: string
  winga_id: string
  badge: string
  rating: number
  phone: string
  profile_photo_url: string | null
  specialty: string
  current_area: string | null
  is_online: boolean
}

interface WingaPointRow {
  request_id: string
  point: number
}

interface RequestRow {
  id: string
  category: string
  meeting_point: string
  shopping_area: string
  service_type: string
  estimated_price: number
  total_price: number
  final_price: number | null
  status: string
  created_at: string
  completed_at: string | null
  accepted_at: string | null
  note: string | null
  delivery_method: string
  winga_id: string | null
  winga: WingaRow | null
  winga_points: WingaPointRow | null
}

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

const STATUS_MAP: Record<string, { label: string; bg: string; color: string; emoji: string }> = {
  searching:  { label: 'Inatafuta Winga...', bg: '#F3F4F6', color: '#6B7280', emoji: '🔍' },
  accepted:   { label: 'Imekubaliwa',       bg: '#E3F2FD', color: '#1565C0', emoji: '✅' },
  shopping:   { label: 'Winga Ananunua...',  bg: '#E8F5E9', color: '#2E7D32', emoji: '🛒' },
  completed:  { label: 'Imekamilika',       bg: '#E8F5E9', color: '#1A5C2A', emoji: '✅' },
  cancelled:  { label: 'Imehairishwa',      bg: '#FFEBEE', color: '#D32F2F', emoji: '❌' },
}

const SERVICE_TYPE_LABELS: Record<string, string> = {
  hourly: 'Saa 1',
  half_day: 'Nusu Siku',
  full_day: 'Siku Nzima',
}

function timeAgo(dateStr: string): string {
  const now = Date.now()
  const then = new Date(dateStr).getTime()
  const diffMs = now - then
  const mins = Math.floor(diffMs / 60000)
  if (mins < 1) return 'Dakika 0 iliyopita'
  if (mins < 60) return `${mins}m iliyopita`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `${hrs}h iliyopita`
  const days = Math.floor(hrs / 24)
  if (days < 30) return `${days}d iliyopita`
  const months = Math.floor(days / 30)
  return `${months}mo iliyopita`
}

/* ------------------------------------------------------------------ */
/*  Tabs                                                               */
/* ------------------------------------------------------------------ */

type TabKey = 'all' | 'active' | 'completed' | 'cancelled'

const TABS = [
  { key: 'all' as TabKey, label: 'Zote', statuses: [] as string[] },
  { key: 'active' as TabKey, label: 'Inaendelea', statuses: ['searching', 'accepted', 'shopping'] },
  { key: 'completed' as TabKey, label: 'Zilizokamilika', statuses: ['completed'] },
  { key: 'cancelled' as TabKey, label: 'Zilizohairishwa', statuses: ['cancelled'] },
]

/* ------------------------------------------------------------------ */
/*  Screen                                                             */
/* ------------------------------------------------------------------ */

export default function RequestsScreen() {
  const nav = useNavigate()

  /* state */
  const [activeTab, setActiveTab] = useState<TabKey>('all')
  const [requests, setRequests] = useState<RequestRow[]>([])
  const [loading, setLoading] = useState(true)
  const mounted = useRef(true)
  const [error, setError] = useState<string | null>(null)

  /* rating modal */
  const [ratingRequest, setRatingRequest] = useState<RequestRow | null>(null)
  const [goodService, setGoodService] = useState<boolean | null>(null)
  const [remark, setRemark] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [ratingSuccess, setRatingSuccess] = useState(false)

  /* Refresh interval ref */
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null)

  /* ---------------------------------------------------------------- */
  /*  Fetch requests                                                   */
  /* ---------------------------------------------------------------- */

  const fetchRequests = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const uid = user?.id || Session.uid() || ''
      if (!uid) return

      const { data, error: err } = await supabase
        .from('requests')
        .select(
          `id, category, meeting_point, shopping_area, service_type, estimated_price, total_price, final_price, status, created_at, completed_at, accepted_at, note, delivery_method, winga_id,
            winga:winga_id(id, name, winga_id, badge, rating, phone, profile_photo_url, specialty, current_area, is_online)`
        )
        .eq('customer_id', uid)
        .order('created_at', { ascending: false })

      if (err) throw err
      // Supabase joins return arrays — flatten to single objects
      const rows = ((data as any[]) ?? []).map((r: any) => ({
        ...r,
        winga: Array.isArray(r.winga) ? r.winga[0] || null : r.winga || null,
        winga_points: Array.isArray(r.winga_points) ? r.winga_points[0] || null : r.winga_points || null,
      })) as RequestRow[]

      if (mounted.current) {
        setRequests(rows)
      }
    } catch (e: any) {
      if (mounted.current) setError(e?.message || 'Imeshindwa kupakia safari')
    } finally {
      if (mounted.current) setLoading(false)
    }
  }, [])

  useEffect(() => {
    mounted.current = true
    fetchRequests()
    // Poll every 8s as fallback to catch realtime misses
    pollRef.current = setInterval(fetchRequests, 8000)
    return () => {
      mounted.current = false
      if (pollRef.current) clearInterval(pollRef.current)
    }
  }, [fetchRequests])



  /* ---------------------------------------------------------------- */
  /*  Filtered list                                                    */
  /* ---------------------------------------------------------------- */

  const filtered = requests.filter(r => {
    const tab = TABS.find(t => t.key === activeTab)
    if (!tab || tab.statuses.length === 0) return true
    return tab.statuses.includes(r.status)
  })

  /* ---------------------------------------------------------------- */
  /*  Submit rating                                                    */
  /* ---------------------------------------------------------------- */

  async function submitRating() {
    if (!ratingRequest || goodService === null) return
    setSubmitting(true)
    try {
      const { error: err } = await supabase.rpc('rate_winga', {
        p_request_id: ratingRequest.id,
        p_point: goodService ? 1 : 0,
        p_reason: remark.trim() || null,
      })
      if (err) throw err
      setRatingSuccess(true)
      setTimeout(() => {
        setRatingRequest(null)
        setGoodService(null)
        setRemark('')
        setRatingSuccess(false)
        fetchRequests()
      }, 1200)
    } catch (e: any) {
      alert(e?.message || 'Imeshindwa kuwasilisha pima')
      setSubmitting(false)
    }
  }

  function closeRatingModal() {
    if (submitting) return
    setRatingRequest(null)
    setGoodService(null)
    setRemark('')
    setRatingSuccess(false)
  }

  /* ---------------------------------------------------------------- */
  /*  Render helpers                                                   */
  /* ---------------------------------------------------------------- */

  function renderSkeleton() {
    return Array.from({ length: 3 }).map((_, i) => (
      <div key={i} style={{ background: '#fff', borderRadius: 16, padding: 16, marginBottom: 12, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
          <div style={{ width: 120, height: 14, borderRadius: 7, background: '#E5E7EB' }} />
          <div style={{ width: 80, height: 22, borderRadius: 100, background: '#E5E7EB' }} />
        </div>
        <div style={{ width: '70%', height: 12, borderRadius: 6, background: '#F3F4F6', marginBottom: 8 }} />
        <div style={{ width: '50%', height: 12, borderRadius: 6, background: '#F3F4F6', marginBottom: 8 }} />
        <div style={{ width: 80, height: 20, borderRadius: 6, background: '#E5E7EB' }} />
      </div>
    ))
  }

  function renderEmpty() {
    return (
      <div style={{ textAlign: 'center', paddingTop: 60, padding: '60px 24px' }}>
        <div style={{ fontSize: 56, marginBottom: 16 }}>📋</div>
        <p style={{ fontFamily: 'Inter', fontSize: 17, fontWeight: 600, color: '#1A1A1A', marginBottom: 6 }}>Huna safari bado</p>
        <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', marginBottom: 24 }}>
          Omba Winga sasa na upate huduma bora
        </p>
        <button
          onClick={() => nav('/book')}
          style={{
            background: '#1A5C2A', color: '#fff', border: 'none', borderRadius: 12,
            fontFamily: 'Inter', fontSize: 14, fontWeight: 600, padding: '12px 28px',
            cursor: 'pointer',
          }}
        >
          Omba Winga Sasa
        </button>
      </div>
    )
  }

  function renderCard(r: RequestRow) {
    const st = STATUS_MAP[r.status] || STATUS_MAP.searching
    const price = r.status === 'completed' && r.final_price != null ? fmt(r.final_price) : fmt(r.total_price || r.estimated_price)
    const serviceLabel = SERVICE_TYPE_LABELS[r.service_type] || r.service_type
    const isRated = !!r.winga_points
    const needsRating = r.status === 'completed' && !isRated
    const isActive = ['accepted', 'shopping'].includes(r.status)

    return (
      <div key={r.id} style={{
        background: '#fff', borderRadius: 16, padding: 16, marginBottom: 12,
        boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
        border: isActive ? '2px solid #1A5C2A' : '1px solid #F3F4F6',
        transition: 'border-color 0.3s',
      }}>
        {/* Top row: category + status */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
          <span style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 600, color: '#1A1A1A' }}>{r.category}</span>
          <span style={{
            background: st.bg, color: st.color, padding: '3px 10px', borderRadius: 100,
            fontSize: 11, fontWeight: 600, fontFamily: 'Inter', display: 'inline-flex', alignItems: 'center',
            whiteSpace: 'nowrap', flexShrink: 0, gap: 4,
          }}>
            <span style={{ fontSize: 11 }}>{st.emoji}</span>
            {st.label}
          </span>
        </div>

        {/* Meeting point */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginBottom: 4 }}>
          <span style={{ fontSize: 13 }}>📍</span>
          <span style={{ fontFamily: 'Inter', fontSize: 13, color: '#4B5563' }}>{r.meeting_point}</span>
        </div>

        {/* Shopping area */}
        {r.shopping_area && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginBottom: 4 }}>
            <span style={{ fontSize: 13 }}>🛒</span>
            <span style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>{r.shopping_area}</span>
          </div>
        )}

        {/* Note */}
        {r.note && (
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 6, fontStyle: 'italic' }}>
            📝 {r.note}
          </div>
        )}

        {/* Service type badge + price + time */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', marginBottom: 8 }}>
          <span style={{
            background: '#F3F4F6', color: '#374151', padding: '3px 10px', borderRadius: 100,
            fontSize: 11, fontWeight: 600, fontFamily: 'Inter',
          }}>
            {serviceLabel}
          </span>
          <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A1A1A' }}>{price}</span>
          <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF', marginLeft: 'auto' }}>{timeAgo(r.created_at)}</span>
        </div>

        {/* ═══ WINGA INFO — shown for ALL active + completed states ═══ */}
        {r.winga && isActive && (
          <div style={{
            background: '#E8F5E9', borderRadius: 14, padding: '12px 14px',
            marginTop: 8, marginBottom: 8,
            display: 'flex', gap: 12, alignItems: 'center',
          }}>
            {/* Avatar */}
            <div style={{ position: 'relative', flexShrink: 0 }}>
              {r.winga.profile_photo_url ? (
                <img src={r.winga.profile_photo_url} alt={r.winga.name} style={{ width: 44, height: 44, borderRadius: 22, objectFit: 'cover' }} />
              ) : (
                <div style={{
                  width: 44, height: 44, borderRadius: 22, background: '#1A5C2A',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 20, fontWeight: 700,
                }}>
                  {r.winga.name?.charAt(0) || 'W'}
                </div>
              )}
              {r.winga.is_online && (
                <div style={{ position: 'absolute', bottom: 0, right: 0, width: 12, height: 12, borderRadius: 6, background: '#22C55E', border: '2px solid #E8F5E9' }} />
              )}
            </div>

            {/* Info */}
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
                <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A1A1A' }}>
                  {r.winga.name}
                </span>
                <WingaBadge badge={r.winga.badge} />
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280', marginBottom: 2 }}>
                {r.winga.specialty}{r.winga.current_area ? ` · ${r.winga.current_area}` : ''}
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                {r.winga.winga_id} {r.winga.rating != null ? `· ⭐ ${r.winga.rating.toFixed(1)}` : ''}
              </div>
            </div>

            {/* Call button */}
            {r.winga.phone && (
              <a href={`tel:${r.winga.phone}`}
                style={{
                  width: 42, height: 42, borderRadius: 21, background: '#1A5C2A',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: '#fff', fontSize: 18, textDecoration: 'none', flexShrink: 0,
                  boxShadow: '0 2px 8px rgba(26,92,42,0.3)',
                }}
                onClick={(e) => e.stopPropagation()}>
                📞
              </a>
            )}
          </div>
        )}

        {/* Progress tracker for active requests */}
        {isActive && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 4, marginBottom: 4 }}>
            {[
              { label: 'Ombi', done: true },
              { label: 'Imekubaliwa', done: r.status !== 'searching' },
              { label: 'Inanunua', done: r.status === 'shopping' },
              { label: 'Imekamilika', done: false },
            ].map((step, i, arr) => (
              <div key={step.label} style={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flex: 1 }}>
                  <div style={{
                    width: step.done ? 20 : 16, height: step.done ? 20 : 16,
                    borderRadius: step.done ? 10 : 8,
                    background: step.done ? '#1A5C2A' : '#E5E7EB',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: step.done ? 10 : 8, color: '#fff',
                    transition: 'all 0.3s',
                  }}>
                    {step.done ? '✓' : (i + 1)}
                  </div>
                  <span style={{
                    fontFamily: 'Inter', fontSize: 9, marginTop: 4, fontWeight: step.done ? 600 : 400,
                    color: step.done ? '#1A5C2A' : '#9CA3AF', textAlign: 'center',
                  }}>
                    {step.label}
                  </span>
                </div>
                {i < arr.length - 1 && (
                  <div style={{
                    height: 2, flex: 1, maxWidth: 24,
                    background: step.done && arr[i + 1].done ? '#1A5C2A' : '#E5E7EB',
                    transition: 'background 0.3s',
                  }} />
                )}
              </div>
            ))}
          </div>
        )}

        {/* Winga info for completed */}
        {r.status === 'completed' && r.winga && (
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8, marginTop: 8,
            paddingTop: 8, borderTop: '1px solid #F3F4F6',
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 16, background: '#E8F5E9',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, flexShrink: 0,
            }}>
              {r.winga.profile_photo_url
                ? <img src={r.winga.profile_photo_url} alt="" style={{ width: 32, height: 32, borderRadius: 16, objectFit: 'cover' }} />
                : '👤'}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#1A1A1A' }}>{r.winga.name}</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 2 }}>
                <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>⭐ {r.winga.rating?.toFixed(1) || '—'}</span>
                <WingaBadge badge={r.winga.badge} />
              </div>
            </div>
          </div>
        )}

        {/* Rate button */}
        {needsRating && (
          <button
            onClick={() => setRatingRequest(r)}
            style={{
              width: '100%', height: 44, marginTop: 12, background: '#1A5C2A', color: '#fff',
              border: 'none', borderRadius: 12, fontFamily: 'Inter', fontSize: 14, fontWeight: 600,
              cursor: 'pointer', WebkitTapHighlightColor: 'transparent',
            }}
          >
            ⭐ Pima Huduma
          </button>
        )}

        {/* Already rated indicator */}
        {r.status === 'completed' && isRated && (
          <div style={{
            marginTop: 10, padding: '8px 0', textAlign: 'center',
            fontFamily: 'Inter', fontSize: 12, color: '#9CA3AF',
          }}>
            {r.winga_points!.point === 1 ? '👍 Umepima huduma: Nzuri' : '👎 Umepima huduma: Mbaya'}
          </div>
        )}
      </div>
    )
  }

  /* ---------------------------------------------------------------- */
  /*  Rating modal                                                     */
  /* ---------------------------------------------------------------- */

  function renderRatingModal() {
    if (!ratingRequest) return null

    return (
      <div
        onClick={closeRatingModal}
        style={{
          position: 'fixed', inset: 0, zIndex: 200,
          background: 'rgba(0,0,0,0.4)', display: 'flex', alignItems: 'flex-end',
          justifyContent: 'center',
        }}
      >
        <div
          onClick={e => e.stopPropagation()}
          style={{
            width: '100%', maxWidth: 480,
            background: '#fff', borderRadius: '24px 24px 0 0',
            padding: '24px 20px calc(24px + env(safe-area-inset-bottom))',
            animation: 'slideUp 0.25s ease-out',
          }}
        >
          {/* Success state */}
          {ratingSuccess ? (
            <div style={{ textAlign: 'center', padding: '20px 0' }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>✅</div>
              <p style={{ fontFamily: 'Inter', fontSize: 17, fontWeight: 600, color: '#1A1A1A', marginBottom: 4 }}>
                Asante kwa pima yako!
              </p>
              <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280' }}>
                Pima yako imewasilishwa
              </p>
            </div>
          ) : (
            <>
              {/* Handle bar */}
              <div style={{ width: 36, height: 4, borderRadius: 2, background: '#E5E7EB', margin: '0 auto 20px' }} />

              {/* Title */}
              <h2 style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: '#1A1A1A', marginBottom: 4, textAlign: 'center' }}>
                Jinsi gani ulipata huduma?
              </h2>
              {ratingRequest.winga && (
                <p style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280', textAlign: 'center', marginBottom: 20 }}>
                  Safari na {ratingRequest.winga.name}
                </p>
              )}

              {/* Good / Bad buttons */}
              <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
                <button
                  onClick={() => setGoodService(true)}
                  style={{
                    flex: 1, height: 64, borderRadius: 14, border: goodService === true ? '2px solid #1A5C2A' : '2px solid #E5E7EB',
                    background: goodService === true ? '#E8F5E9' : '#fff', cursor: 'pointer',
                    display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4,
                  }}
                >
                  <span style={{ fontSize: 28 }}>👍</span>
                  <span style={{
                    fontFamily: 'Inter', fontSize: 13, fontWeight: 600,
                    color: goodService === true ? '#1A5C2A' : '#6B7280',
                  }}>
                    Huduma Nzuri
                  </span>
                </button>
                <button
                  onClick={() => setGoodService(false)}
                  style={{
                    flex: 1, height: 64, borderRadius: 14, border: goodService === false ? '2px solid #D32F2F' : '2px solid #E5E7EB',
                    background: goodService === false ? '#FFEBEE' : '#fff', cursor: 'pointer',
                    display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4,
                  }}
                >
                  <span style={{ fontSize: 28 }}>👎</span>
                  <span style={{
                    fontFamily: 'Inter', fontSize: 13, fontWeight: 600,
                    color: goodService === false ? '#D32F2F' : '#6B7280',
                  }}>
                    Huduma Mbaya
                  </span>
                </button>
              </div>

              {/* Remark */}
              <textarea
                value={remark}
                onChange={e => setRemark(e.target.value)}
                placeholder="Maoni yako (si lazima)"
                rows={3}
                style={{
                  width: '100%', borderRadius: 12, border: '1px solid #E5E7EB', padding: '12px 14px',
                  fontFamily: 'Inter', fontSize: 14, color: '#1A1A1A', resize: 'none',
                  outline: 'none', marginBottom: 20, boxSizing: 'border-box',
                }}
              />

              {/* Submit */}
              <button
                onClick={submitRating}
                disabled={goodService === null || submitting}
                style={{
                  width: '100%', height: 48, borderRadius: 12, border: 'none',
                  background: goodService === null || submitting ? '#9CA3AF' : '#1A5C2A',
                  color: '#fff', fontFamily: 'Inter', fontSize: 15, fontWeight: 600,
                  cursor: goodService === null || submitting ? 'not-allowed' : 'pointer',
                }}
              >
                {submitting ? 'Inawasilisha...' : 'Wasilisha'}
              </button>
            </>
          )}
        </div>
      </div>
    )
  }



  /* ---------------------------------------------------------------- */
  /*  Main render                                                      */
  /* ---------------------------------------------------------------- */

  return (
    <div className="page">
      <AppBar title="Safari Zangu" />

      <div className="scroll" style={{ padding: '16px 16px 0', paddingBottom: 100 }}>
        {/* Tabs */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto', marginBottom: 16,
          scrollbarWidth: 'none', msOverflowStyle: 'none',
          WebkitOverflowScrolling: 'touch',
        }}>
          {TABS.map(tab => {
            const isActive = activeTab === tab.key
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                style={{
                  flexShrink: 0, padding: '8px 16px', borderRadius: 100, border: 'none',
                  background: isActive ? '#1A5C2A' : '#F3F4F6',
                  color: isActive ? '#fff' : '#6B7280',
                  fontFamily: 'Inter', fontSize: 13, fontWeight: 600,
                  cursor: 'pointer', WebkitTapHighlightColor: 'transparent',
                }}
              >
                {tab.label}
              </button>
            )
          })}
        </div>

        {/* Error */}
        {error && (
          <div style={{
            background: '#FFEBEE', borderRadius: 12, padding: 14, marginBottom: 16,
            fontFamily: 'Inter', fontSize: 13, color: '#D32F2F', textAlign: 'center',
          }}>
            {error}
            <br />
            <button
              onClick={fetchRequests}
              style={{ background: 'none', border: 'none', color: '#D32F2F', fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter', fontSize: 13, marginTop: 4 }}
            >
              Jaribu Tena
            </button>
          </div>
        )}

        {/* Loading */}
        {loading && renderSkeleton()}

        {/* Content */}
        {!loading && !error && filtered.length === 0 && renderEmpty()}
        {!loading && !error && filtered.length > 0 && filtered.map(renderCard)}
      </div>

      {/* Rating modal */}
      {renderRatingModal()}

      <style>{`
        @keyframes slideUp {
          from { transform: translateY(100%); }
          to { transform: translateY(0); }
        }
      `}</style>

      <BottomNav />
    </div>
  )
}