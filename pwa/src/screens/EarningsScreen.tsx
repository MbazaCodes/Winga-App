import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { fmt } from '../lib/constants'

type Period = 'week' | 'month' | 'all'

export default function EarningsScreen() {
  const nav = useNavigate()
  const [period, setPeriod] = useState<Period>('month')
  const [spent, setSpent] = useState(0)
  const [trips, setTrips] = useState<any[]>([])
  const [wallet, setWallet] = useState(0)
  const [loading, setLoading] = useState(true)
  const mounted = useRef(true)

  useEffect(() => {
    mounted.current = true
    load()
    return () => { mounted.current = false }
  }, [period])

  async function load() {
    const { data: { user: _authUser } } = await supabase.auth.getUser()
    const uid = _authUser?.id || Session.uid(); if (!uid) return
    setLoading(true)
    try {
      const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', uid).maybeSingle()
      if (!mounted.current) return
      setWallet(user?.wallet_balance || 0)

      const now = new Date()
      let from: Date | null = null
      if (period === 'week') from = new Date(now.getTime() - 7 * 86400000)
      else if (period === 'month') from = new Date(now.getFullYear(), now.getMonth(), 1)

      let q = supabase.from('requests')
        .select('id,created_at,total_price,status,service_type,winga:winga_id(name,badge)')
        .eq('customer_id', uid)
        .eq('status', 'completed')
        .order('created_at', { ascending: false })
      if (from) q = q.gte('created_at', from.toISOString())

      const { data } = await q
      const rows = data || []
      if (!mounted.current) return
      setTrips(rows as any)
      setSpent(rows.reduce((s: number, r: any) => s + (r.total_price || 0), 0))
    } finally { if (mounted.current) setLoading(false) }
  }

  const svcLabel: Record<string, string> = { hourly: 'Saa 1', half_day: 'Nusu Siku', full_day: 'Siku Nzima' }

  return (
    <div className="page">
      <div style={{ background: '#1A5C2A', paddingTop: 'env(safe-area-inset-top,0px)' }}>
        <div style={{ padding: '16px 20px 24px' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff', marginBottom: 8 }}>Matumizi Yangu 💳</div>
          <div style={{ display: 'flex', gap: 12 }}>
            <div style={{ flex: 1, background: 'rgba(255,255,255,0.15)', borderRadius: 14, padding: '14px 16px' }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Jumla Nililolipa</div>
              <div style={{ fontFamily: 'Inter', fontSize: 24, fontWeight: 800, color: '#F9A825' }}>{fmt(spent)}</div>
            </div>
            <div style={{ flex: 1, background: 'rgba(255,255,255,0.15)', borderRadius: 14, padding: '14px 16px' }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Pochi Yangu</div>
              <div style={{ fontFamily: 'Inter', fontSize: 24, fontWeight: 800, color: '#4ADE80' }}>{fmt(wallet)}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="scroll">
        <div style={{ display: 'flex', gap: 8, padding: '16px 20px 0' }}>
          {([['week','Wiki 7'],['month','Mwezi'],['all','Yote']] as [Period,string][]).map(([k,l]) => (
            <button key={k} onClick={() => setPeriod(k)}
              style={{ padding: '8px 16px', borderRadius: 20, border: 'none', cursor: 'pointer', fontFamily: 'Inter', fontSize: 13, fontWeight: 600, background: period === k ? '#1A5C2A' : '#F3F4F6', color: period === k ? '#fff' : '#6B7280' }}>
              {l}
            </button>
          ))}
        </div>
        <div style={{ padding: '12px 20px 0' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>
            {trips.length} safari · {fmt(spent)} nililolipa
          </div>
          {loading ? [1,2,3].map(i => <div key={i} style={{ height: 72, background: '#F3F4F6', borderRadius: 14, marginBottom: 8 }} />) :
            trips.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '40px 20px' }}>
                <div style={{ fontSize: 40, marginBottom: 12 }}>🛍️</div>
                <div style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280' }}>Hakuna safari katika kipindi hiki</div>
                <button onClick={() => nav('/book')} style={{ marginTop: 16, background: '#1A5C2A', color: '#fff', border: 'none', borderRadius: 12, padding: '12px 24px', fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer' }}>Omba Winga</button>
              </div>
            ) : trips.map(t => (
              <div key={t.id} style={{ background: '#fff', border: '1px solid #F3F4F6', borderRadius: 14, padding: '12px 16px', marginBottom: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>{t.winga?.name || 'Winga'}</div>
                  <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                    {svcLabel[t.service_type] || t.service_type} · {new Date(t.created_at).toLocaleDateString('sw-TZ')}
                  </div>
                </div>
                <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#D32F2F' }}>{fmt(t.total_price || 0)}</div>
              </div>
            ))
          }
        </div>
        <div style={{ height: 100 }} />
      </div>
      <BottomNav />
    </div>
  )
}
