import { useState, useEffect, useRef, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { StatusBadge, WingaBadge } from '../components/ui/Badge'
import { fmt } from '../lib/constants'

interface Request {
  id: string; status: string; service_type: string; note: string | null
  created_at: string; total_price: number; estimated_price: number
  category: string; meeting_point: string; shopping_area: string; delivery_method: string
  customer: { name: string; phone: string } | null
}
interface WingaProfile {
  id: string; name: string; badge: string; is_online: boolean
  total_trips: number; total_earnings: number; winga_score: number
  rated_trips: number; total_points: number; current_city: string; winga_id: string
  profile_complete: boolean
}

interface ProfileStatus {
  success: boolean; profile_complete: boolean; filled: number; total: number
  percent: number; winga_id: string; fields: { field: string; done: boolean }[]
}

export default function WingaHomeScreen() {
  const nav = useNavigate()
  const [profile, setProfile] = useState<WingaProfile | null>(null)
  const [profileStatus, setProfileStatus] = useState<ProfileStatus | null>(null)
  const [availableReqs, setAvailableReqs] = useState<Request[]>([])
  const [myReqs, setMyReqs] = useState<Request[]>([])
  const [todayEarnings, setTodayEarnings] = useState(0)
  const [loading, setLoading] = useState(true)
  const [toggling, setToggling] = useState(false)
  const [claiming, setClaiming] = useState<string | null>(null)
  const channelRef = useRef<any>(null)

  const loadData = useCallback(async () => {
    const uid = Session.uid()
    if (!uid) return
    try {
      const { data: w } = await supabase.from('wingas')
        .select('id,name,badge,is_online,total_trips,total_earnings,winga_score,rated_trips,total_points,current_city,winga_id,profile_complete')
        .eq('user_id', uid).maybeSingle()
      if (w) {
        setProfile(w)
        // Check profile completion status
        const { data: status } = await supabase.rpc('get_winga_profile_status', { p_user_id: uid })
        if (status) {
          setProfileStatus(status as ProfileStatus)
          if (status.profile_complete !== w.profile_complete) {
            setProfile({ ...w, profile_complete: status.profile_complete })
          }
        }

        // ── LOAD 1: Available searching requests (winga_id IS NULL) ──
        // These are customer requests waiting for any winga to claim
        if (w.is_online && w.profile_complete) {
          const { data: searching } = await supabase.from('requests')
            .select('id,status,service_type,note,created_at,total_price,estimated_price,category,meeting_point,shopping_area,delivery_method,customer:customer_id(name,phone)')
            .is('winga_id', null)
            .eq('status', 'searching')
            .order('created_at', { ascending: false })
            .limit(10)
          if (searching) setAvailableReqs(searching as any)
        } else {
          setAvailableReqs([])
        }

        // ── LOAD 2: My accepted/active/recent requests ──
        const { data: mine } = await supabase.from('requests')
          .select('id,status,service_type,note,created_at,total_price,estimated_price,category,meeting_point,shopping_area,delivery_method,customer:customer_id(name,phone)')
          .eq('winga_id', w.id)
          .in('status', ['accepted', 'shopping', 'completed'])
          .order('created_at', { ascending: false })
          .limit(20)
        if (mine) {
          setMyReqs(mine as any)
          const today = new Date().toDateString()
          const todayTotal = mine
            .filter(r => r.status === 'completed' && new Date(r.created_at).toDateString() === today)
            .reduce((s, r) => s + (r.total_price || 0), 0)
          setTodayEarnings(todayTotal)
        }

        // ── REALTIME: Listen for ALL new searching requests ──
        if (!channelRef.current) {
          channelRef.current = supabase.channel(`winga-available-${w.id}`)
            .on('postgres_changes', {
              event: 'INSERT', schema: 'public', table: 'requests',
              filter: 'status=eq.searching',
            }, () => loadData())
            .subscribe()
        }
      }
    } finally { setLoading(false) }
  }, [])

  useEffect(() => {
    loadData()
    return () => { channelRef.current?.unsubscribe(); channelRef.current = null }
  }, [loadData])

  const toggleOnline = async () => {
    if (!profile) return
    if (!profile.profile_complete) return
    setToggling(true)
    const next = !profile.is_online
    await supabase.from('wingas').update({ is_online: next }).eq('id', profile.id)
    setProfile(p => p ? { ...p, is_online: next } : p)
    setToggling(false)
    // Reload to fetch/stop fetching available requests
    if (next) loadData()
    else setAvailableReqs([])
  }

  // ── CLAIM: Atomic accept — only succeeds if winga_id is still NULL ──
  const claimRequest = async (reqId: string) => {
    if (!profile || claiming) return
    setClaiming(reqId)
    try {
      // Atomic claim: only set winga_id if it's still NULL
      const { data, error } = await supabase
        .from('requests')
        .update({ winga_id: profile.id, status: 'accepted', accepted_at: new Date().toISOString() })
        .eq('id', reqId)
        .is('winga_id', null)   // ← Race condition protection
        .eq('status', 'searching')
        .select('id')
        .single()

      if (error || !data) {
        // Someone else claimed it — remove from list
        setAvailableReqs(rs => rs.filter(r => r.id !== reqId))
        return
      }
      // Claimed successfully — move to my requests
      setAvailableReqs(rs => rs.filter(r => r.id !== reqId))
      loadData() // Refresh my requests
    } catch {
      // Silently fail — will be refreshed on next loadData
    } finally {
      setClaiming(null)
    }
  }

  const updateStatus = async (reqId: string, status: string) => {
    await supabase.from('requests').update({ status }).eq('id', reqId)
    setMyReqs(rs => rs.map(r => r.id === reqId ? { ...r, status } : r))
  }

  const myActive = myReqs.filter(r => ['accepted', 'shopping'].includes(r.status))
  const recent = myReqs.filter(r => r.status === 'completed').slice(0, 5)

  if (loading) return <LoadingPage />

  const incomplete = profile && !profile.profile_complete
  const pct = profileStatus?.percent || 0
  const svcLabel: Record<string, string> = { hourly: 'Saa 1', half_day: 'Nusu Siku', full_day: 'Siku Nzima' }

  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: profile?.is_online ? '#1A5C2A' : '#374151', paddingTop: 'env(safe-area-inset-top,0px)', paddingBottom: 0, transition: 'background 0.3s' }}>
        <div style={{ padding: '16px 20px 20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.7)' }}>Habari,</div>
              <div style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: '#fff' }}>{profile?.name?.split(' ')[0] || 'Winga'} 👋</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6 }}>
                <WingaBadge badge={profile?.badge || 'Starter'} />
                <span style={{ fontFamily: 'Inter', fontSize: 11, color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>
                  {profile?.winga_id || ''}
                </span>
              </div>
            </div>
            {/* Online toggle */}
            <div
              onClick={toggling ? undefined : (incomplete ? () => nav('/winga/profile') : toggleOnline)}
              style={{
                background: incomplete ? 'rgba(255,77,77,0.3)' : 'rgba(255,255,255,0.15)',
                borderRadius: 20, padding: '10px 16px', cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: 8,
                border: incomplete ? '1.5px solid rgba(255,77,77,0.6)' : '1.5px solid rgba(255,255,255,0.3)',
              }}>
              {toggling ? <span style={{ width: 14, height: 14, borderRadius: 7, border: '2px solid rgba(255,255,255,0.4)', borderTop: '2px solid white', animation: 'spin 1s linear infinite', display: 'inline-block' }} />
                : <div style={{ width: 10, height: 10, borderRadius: 5, background: incomplete ? '#EF5350' : profile?.is_online ? '#4ADE80' : '#9CA3AF' }} />}
              <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#fff' }}>
                {incomplete ? 'Wasifu Haujakamilika' : profile?.is_online ? 'Mtandaoni' : 'Nje'}
              </span>
            </div>
          </div>
          {/* Stats row */}
          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            {[
              { label: 'Leo', value: fmt(todayEarnings) },
              { label: 'Safari Zote', value: String(profile?.total_trips || 0) },
              { label: 'Alama', value: `${Math.round((profile?.winga_score || 0) * 100)}%` },
            ].map(s => (
              <div key={s.label} style={{ flex: 1, background: 'rgba(255,255,255,0.15)', borderRadius: 12, padding: '10px 12px', textAlign: 'center' }}>
                <div style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 700, color: '#fff' }}>{s.value}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 10, color: 'rgba(255,255,255,0.7)' }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="scroll">
        {/* ═══ PROFILE COMPLETION BANNER ═══ */}
        {incomplete && (
          <div style={{ margin: '16px 20px 0', background: '#FFEBEE', border: '2px solid #D32F2F', borderRadius: 16, padding: '16px', display: 'flex', gap: 12, alignItems: 'flex-start' }}>
            <span style={{ fontSize: 28, flexShrink: 0 }}>🚫</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#D32F2F', marginBottom: 4 }}>
                Wasifu Wako Haujakamilika
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#5D4037', marginBottom: 10, lineHeight: 1.5 }}>
                Lazima uwasilishe wasifu wako 100% kabla ya kupokea maombi ya wateja.
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#D32F2F', fontWeight: 600 }}>
                  Maendeleo: {pct}%
                </span>
                <span style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                  {profileStatus?.filled || 0}/{profileStatus?.total || 6} fields
                </span>
              </div>
              <div style={{ height: 8, background: '#FFCDD2', borderRadius: 4, marginBottom: 12 }}>
                <div style={{ height: '100%', borderRadius: 4, width: `${pct}%`, background: pct >= 100 ? '#1A5C2A' : '#D32F2F', transition: 'width 0.5s' }} />
              </div>
              {profileStatus?.fields && (
                <div style={{ marginBottom: 12 }}>
                  {profileStatus.fields.filter(f => !f.done).map(f => (
                    <div key={f.field} style={{ fontFamily: 'Inter', fontSize: 11, color: '#C62828', padding: '2px 0' }}>⬜ {f.field}</div>
                  ))}
                </div>
              )}
              <button onClick={() => nav('/winga/profile')}
                style={{ width: '100%', height: 42, background: '#D32F2F', color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
                📋 Maliza Wasifu Sasa
              </button>
            </div>
          </div>
        )}

        {/* ═══ NEAR-COMPLETE REMINDER ═══ */}
        {profile?.profile_complete === false && profileStatus && profileStatus.percent >= 80 && profileStatus.percent < 100 && !incomplete && (
          <div style={{ margin: '12px 20px 0', background: '#FFF8E1', border: '1px solid #F9A825', borderRadius: 14, padding: '12px 16px', display: 'flex', gap: 10, alignItems: 'center' }}>
            <span style={{ fontSize: 20 }}>⚡</span>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#F57F17' }}>
                Karibu kukamilisha — {100 - pct}% zimebaki tu!
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>
                {profileStatus.fields.filter(f => !f.done).map(f => f.field).join(', ')}
              </div>
            </div>
          </div>
        )}

        {/* Not online warning */}
        {!profile?.is_online && !incomplete && (
          <div style={{ margin: '16px 20px 0', background: '#FFF8E1', border: '1px solid #F9A825', borderRadius: 14, padding: '12px 16px', display: 'flex', gap: 10, alignItems: 'center' }}>
            <span style={{ fontSize: 20 }}>⚠️</span>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#F57F17' }}>Uko nje ya mtandao</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>Washa "Mtandaoni" ili kupokea maombi</div>
            </div>
          </div>
        )}

        {/* ═══════════════════════════════════════════════════════════
            AVAILABLE REQUESTS (from customers, winga_id = NULL)
           ═══════════════════════════════════════════════════════════ */}
        {availableReqs.length > 0 && (
          <div style={{ padding: '16px 20px 0' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: '#D32F2F' }}>
                🔔 Maombi Mapya ({availableReqs.length})
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                Bonyeza "Kubali" kupata
              </div>
            </div>
            {availableReqs.map(r => (
              <div key={r.id} style={{
                background: '#fff', border: '2px solid #D32F2F',
                borderRadius: 16, padding: '14px 16px', marginBottom: 12,
                animation: 'pulse-border 2s ease-in-out infinite',
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                  <div>
                    <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>
                      {(r.customer as any)?.name || 'Mteja'}
                    </div>
                    <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>
                      {r.category} · {svcLabel[r.service_type] || r.service_type}
                    </div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 700, color: '#1A5C2A' }}>
                      {fmt(r.total_price || r.estimated_price || 0)}
                    </div>
                    <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#9CA3AF' }}>
                      {new Date(r.created_at).toLocaleTimeString('sw-TZ', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: 12, marginBottom: 10, fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                  <span>📍 {r.meeting_point}</span>
                  <span>🛒 {r.shopping_area}</span>
                </div>
                {r.note && (
                  <div style={{ background: '#F8F9FA', borderRadius: 10, padding: '8px 12px', fontFamily: 'Inter', fontSize: 12, color: '#374151', marginBottom: 10 }}>
                    📝 {r.note}
                  </div>
                )}
                <button
                  onClick={() => claimRequest(r.id)}
                  disabled={claiming !== null}
                  style={{
                    width: '100%', height: 42,
                    background: claiming === r.id ? '#9CA3AF' : '#1A5C2A',
                    color: '#fff', border: 'none', borderRadius: 10,
                    fontFamily: 'Inter', fontSize: 14, fontWeight: 700,
                    cursor: claiming ? 'not-allowed' : 'pointer',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                  }}>
                  {claiming === r.id ? '⏳ Inakubali...' : '✅ Kubali Maombi Hii'}
                </button>
              </div>
            ))}
          </div>
        )}

        {/* ═══ MY ACTIVE REQUESTS (accepted/shopping) ═══ */}
        {myActive.length > 0 && (
          <div style={{ padding: '16px 20px 0' }}>
            <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>
              🔵 Maombi Yanayoendelea ({myActive.length})
            </div>
            {myActive.map(r => (
              <div key={r.id} style={{ background: '#fff', border: '2px solid #1A5C2A', borderRadius: 16, padding: '14px 16px', marginBottom: 12 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
                  <div>
                    <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>{(r.customer as any)?.name || 'Mteja'}</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>
                      {r.category} · {svcLabel[r.service_type] || r.service_type} · {fmt(r.total_price || 0)}
                    </div>
                  </div>
                  <StatusBadge status={r.status} />
                </div>
                {r.note && <div style={{ background: '#F8F9FA', borderRadius: 10, padding: '8px 12px', fontFamily: 'Inter', fontSize: 12, color: '#374151', marginBottom: 12 }}>📝 {r.note}</div>}
                <div style={{ display: 'flex', gap: 8 }}>
                  {r.status === 'accepted' && (
                    <button onClick={() => updateStatus(r.id, 'shopping')} style={{ flex: 1, height: 40, background: '#1565C0', color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>🛒 Ninaenda Kununua</button>
                  )}
                  {r.status === 'shopping' && (
                    <button onClick={() => updateStatus(r.id, 'completed')} style={{ flex: 1, height: 40, background: C.primary, color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>✅ Imekamilika</button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Quick actions */}
        <div style={{ padding: '16px 20px 0' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>Vitendo vya Haraka</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {[
              { icon: '💰', label: 'Mapato Yangu', path: '/winga/earnings' },
              { icon: '📋', label: 'Maombi Yote', path: '/winga/requests' },
              { icon: '👤', label: 'Wasifu Wangu', path: '/winga/profile' },
              { icon: '📊', label: 'Alama Zangu', path: '/winga/profile' },
            ].map(a => (
              <button key={a.label} onClick={() => nav(a.path)}
                style={{ background: '#fff', border: '1px solid #E5E7EB', borderRadius: 14, padding: '16px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 8, cursor: 'pointer' }}>
                <span style={{ fontSize: 24 }}>{a.icon}</span>
                <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#1A1A1A' }}>{a.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Recent trips */}
        {recent.length > 0 && (
          <div style={{ padding: '16px 20px 0' }}>
            <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>📜 Safari za Hivi Karibuni</div>
            {recent.map(r => (
              <div key={r.id} style={{ background: '#fff', border: '1px solid #F3F4F6', borderRadius: 14, padding: '12px 16px', marginBottom: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>{(r.customer as any)?.name || 'Mteja'}</div>
                  <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>{new Date(r.created_at).toLocaleDateString('sw-TZ')}</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 700, color: '#1A5C2A' }}>{fmt(r.total_price || 0)}</div>
                  <StatusBadge status="completed" />
                </div>
              </div>
            ))}
          </div>
        )}
        {availableReqs.length === 0 && myActive.length === 0 && recent.length === 0 && (
          <div style={{ textAlign: 'center', padding: '40px 20px' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>🛍️</div>
            <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: '#1A1A1A', marginBottom: 6 }}>Hakuna maombi bado</div>
            <div style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280' }}>
              {incomplete
                ? 'Maliza wasifu wako 100% kwanza, kisha washa "Mtandaoni" na subiri wateja!'
                : 'Washa "Mtandaoni" na subiri wateja watakapokuja!'}
            </div>
          </div>
        )}
        <div style={{ height: 100 }} />
      </div>
      <BottomNav />
      <style>{`
        @keyframes spin{to{transform:rotate(360deg)}}
        @keyframes pulse-border{0%,100%{border-color:#D32F2F}50%{border-color:#FF8A65}}
      `}</style>
    </div>
  )
}

const C = { primary: '#1A5C2A' }

function LoadingPage() {
  return (
    <div style={{ height: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1A5C2A' }}>
      <div style={{ textAlign: 'center', color: '#fff' }}>
        <div style={{ width: 80, height: 80, margin: '0 auto 16px', borderRadius: 18, background: 'rgba(255,255,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 6 }}>
          <img src="/winga-logo.png" alt="" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
        </div>
        <div style={{ fontFamily: 'Inter', fontSize: 14 }}>Inapakia dashboard...</div>
      </div>
    </div>
  )
}