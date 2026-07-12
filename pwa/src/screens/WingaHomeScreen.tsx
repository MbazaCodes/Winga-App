import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { StatusBadge, WingaBadge } from '../components/ui/Badge'
import { fmt } from '../lib/constants'

interface Request {
  id: string; status: string; service_type: string; note: string | null
  created_at: string; total_price: number; customer: { name: string; phone: string } | null
}
interface WingaProfile {
  id: string; name: string; badge: string; is_online: boolean
  total_trips: number; total_earnings: number; winga_score: number
  rated_trips: number; total_points: number; current_city: string; winga_id: string
}

export default function WingaHomeScreen() {
  const nav = useNavigate()
  const [profile, setProfile] = useState<WingaProfile | null>(null)
  const [requests, setRequests] = useState<Request[]>([])
  const [todayEarnings, setTodayEarnings] = useState(0)
  const [loading, setLoading] = useState(true)
  const [toggling, setToggling] = useState(false)
  const channelRef = useRef<any>(null)

  useEffect(() => {
    loadData()
    return () => { channelRef.current?.unsubscribe() }
  }, [])

  async function loadData() {
    const uid = Session.uid()
    if (!uid) return
    try {
      const { data: w } = await supabase.from('wingas')
        .select('id,name,badge,is_online,total_trips,total_earnings,winga_score,rated_trips,total_points,current_city,winga_id')
        .eq('user_id', uid).maybeSingle()
      if (w) {
        setProfile(w)
        // Load active + recent requests
        const { data: reqs } = await supabase.from('requests')
          .select('id,status,service_type,note,created_at,total_price,customer:customer_id(name,phone)')
          .eq('winga_id', w.id)
          .in('status', ['searching','accepted','shopping','completed'])
          .order('created_at', { ascending: false })
          .limit(20)
        if (reqs) {
          setRequests(reqs as any)
          const today = new Date().toDateString()
          const todayTotal = reqs
            .filter(r => r.status === 'completed' && new Date(r.created_at).toDateString() === today)
            .reduce((s, r) => s + (r.total_price || 0), 0)
          setTodayEarnings(todayTotal)
        }
        // Realtime for new incoming requests
        channelRef.current = supabase.channel(`winga-requests-${w.id}`)
          .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'requests', filter: `winga_id=eq.${w.id}` },
            () => loadData())
          .subscribe()
      }
    } finally { setLoading(false) }
  }

  const toggleOnline = async () => {
    if (!profile) return
    setToggling(true)
    const next = !profile.is_online
    await supabase.from('wingas').update({ is_online: next }).eq('id', profile.id)
    setProfile(p => p ? { ...p, is_online: next } : p)
    setToggling(false)
  }

  const acceptRequest = async (reqId: string) => {
    await supabase.from('requests').update({ status: 'accepted' }).eq('id', reqId)
    setRequests(rs => rs.map(r => r.id === reqId ? { ...r, status: 'accepted' } : r))
  }

  const updateStatus = async (reqId: string, status: string) => {
    await supabase.from('requests').update({ status }).eq('id', reqId)
    setRequests(rs => rs.map(r => r.id === reqId ? { ...r, status } : r))
  }

  const active = requests.filter(r => ['searching','accepted','shopping'].includes(r.status))
  const recent = requests.filter(r => r.status === 'completed').slice(0, 5)

  if (loading) return <LoadingPage />

  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: profile?.is_online ? '#1A5C2A' : '#374151', paddingTop: 'env(safe-area-inset-top,0px)', paddingBottom: 0, transition: 'background 0.3s' }}>
        <div style={{ padding: '16px 20px 20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.7)' }}>Habari,</div>
              <div style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: '#fff' }}>{profile?.name?.split(' ')[0] || 'Winga'} 👋</div>
              <div style={{ marginTop: 6 }}><WingaBadge badge={profile?.badge || 'Starter'} /></div>
            </div>
            {/* Online toggle */}
            <div onClick={toggling ? undefined : toggleOnline}
              style={{ background: 'rgba(255,255,255,0.15)', borderRadius: 20, padding: '10px 16px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8, border: '1.5px solid rgba(255,255,255,0.3)' }}>
              {toggling ? <span style={{ width: 14, height: 14, borderRadius: 7, border: '2px solid rgba(255,255,255,0.4)', borderTop: '2px solid white', animation: 'spin 1s linear infinite', display: 'inline-block' }} />
                : <div style={{ width: 10, height: 10, borderRadius: 5, background: profile?.is_online ? '#4ADE80' : '#9CA3AF' }} />}
              <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#fff' }}>
                {profile?.is_online ? 'Mtandaoni' : 'Nje'}
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
        {/* Not online warning */}
        {!profile?.is_online && (
          <div style={{ margin: '16px 20px 0', background: '#FFF8E1', border: '1px solid #F9A825', borderRadius: 14, padding: '12px 16px', display: 'flex', gap: 10, alignItems: 'center' }}>
            <span style={{ fontSize: 20 }}>⚠️</span>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#F57F17' }}>Uko nje ya mtandao</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>Washa "Mtandaoni" ili kupokea maombi</div>
            </div>
          </div>
        )}

        {/* Active requests */}
        {active.length > 0 && (
          <div style={{ padding: '16px 20px 0' }}>
            <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>🔴 Maombi Yanayoendelea</div>
            {active.map(r => (
              <RequestCard key={r.id} req={r}
                onAccept={() => acceptRequest(r.id)}
                onShopping={() => updateStatus(r.id, 'shopping')}
                onComplete={() => updateStatus(r.id, 'completed')}
              />
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
        {active.length === 0 && recent.length === 0 && (
          <div style={{ textAlign: 'center', padding: '40px 20px' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>🛍️</div>
            <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: '#1A1A1A', marginBottom: 6 }}>Hakuna maombi bado</div>
            <div style={{ fontFamily: 'Inter', fontSize: 13, color: '#6B7280' }}>Washa "Mtandaoni" na subiri wateja watakapokuja!</div>
          </div>
        )}
        <div style={{ height: 100 }} />
      </div>
      <BottomNav />
      <style>{`@keyframes spin{to{transform:rotate(360deg)}}`}</style>
    </div>
  )
}

function RequestCard({ req, onAccept, onShopping, onComplete }: { req: Request; onAccept: () => void; onShopping: () => void; onComplete: () => void }) {
  const C = { primary: '#1A5C2A', border: '#E5E7EB', bg: '#F8F9FA' }
  const svcLabel: Record<string, string> = { hourly: 'Saa 1', half_day: 'Nusu Siku', full_day: 'Siku Nzima' }
  return (
    <div style={{ background: '#fff', border: '2px solid #1A5C2A', borderRadius: 16, padding: '14px 16px', marginBottom: 12 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
        <div>
          <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>{(req.customer as any)?.name || 'Mteja'}</div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280' }}>{svcLabel[req.service_type] || req.service_type} · {fmt(req.total_price || 0)}</div>
        </div>
        <StatusBadge status={req.status} />
      </div>
      {req.note && <div style={{ background: '#F8F9FA', borderRadius: 10, padding: '8px 12px', fontFamily: 'Inter', fontSize: 12, color: '#374151', marginBottom: 12 }}>📝 {req.note}</div>}
      <div style={{ display: 'flex', gap: 8 }}>
        {req.status === 'searching' && (
          <button onClick={onAccept} style={{ flex: 1, height: 40, background: C.primary, color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>✅ Kubali</button>
        )}
        {req.status === 'accepted' && (
          <button onClick={onShopping} style={{ flex: 1, height: 40, background: '#1565C0', color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>🛒 Ninaenda Kununua</button>
        )}
        {req.status === 'shopping' && (
          <button onClick={onComplete} style={{ flex: 1, height: 40, background: C.primary, color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>✅ Imekamilika</button>
        )}
      </div>
    </div>
  )
}

function LoadingPage() {
  return (
    <div style={{ height: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1A5C2A' }}>
      <div style={{ textAlign: 'center', color: '#fff' }}>
        <div style={{ fontSize: 40, marginBottom: 16 }}>📊</div>
        <div style={{ fontFamily: 'Inter', fontSize: 14 }}>Inapakia dashboard...</div>
      </div>
    </div>
  )
}
