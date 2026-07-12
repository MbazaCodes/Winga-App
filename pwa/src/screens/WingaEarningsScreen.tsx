import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { fmt } from '../lib/constants'

type Period = 'today' | 'week' | 'month' | 'all'

interface TripRow {
  id: string; created_at: string; total_price: number; status: string
  service_type: string; customer: { name: string } | null; tip?: number
}

export default function WingaEarningsScreen() {
  const nav = useNavigate()
  const [period, setPeriod] = useState<Period>('week')
  const [trips, setTrips] = useState<TripRow[]>([])
  const [tips, setTips] = useState(0)
  const [loading, setLoading] = useState(true)
  const [wingaId, setWingaId] = useState('')

  useEffect(() => { loadData() }, [period])

  async function loadData() {
    const uid = Session.uid()
    if (!uid) return
    setLoading(true)
    try {
      const { data: w } = await supabase.from('wingas').select('id,total_earnings').eq('user_id', uid).maybeSingle()
      if (!w) return
      setWingaId(w.id)

      const now = new Date()
      let from: Date | null = null
      if (period === 'today') { from = new Date(now.toDateString()) }
      else if (period === 'week') { from = new Date(now.getTime() - 7 * 86400000) }
      else if (period === 'month') { from = new Date(now.getFullYear(), now.getMonth(), 1) }

      let q = supabase.from('requests')
        .select('id,created_at,total_price,status,service_type,customer:customer_id(name)')
        .eq('winga_id', w.id)
        .eq('status', 'completed')
        .order('created_at', { ascending: false })
      if (from) q = q.gte('created_at', from.toISOString())

      const { data: rows } = await q
      setTrips((rows || []) as any)

      // Tips total
      const { data: tipRows } = await supabase.from('tips').select('amount').eq('winga_id', w.id)
      setTips((tipRows || []).reduce((s, t) => s + (t.amount || 0), 0))
    } finally { setLoading(false) }
  }

  const total = trips.reduce((s, t) => s + (t.total_price || 0), 0)
  const commission = Math.round(total * 0.85) // 85% to Winga
  const svcLabel: Record<string, string> = { hourly: 'Saa 1', half_day: 'Nusu Siku', full_day: 'Siku Nzima' }

  return (
    <div className="page">
      <div style={{ background: '#1A5C2A', paddingTop: 'env(safe-area-inset-top,0px)' }}>
        <div style={{ padding: '16px 20px 24px' }}>
          <button onClick={() => nav(-1)} style={{ background: 'none', border: 'none', color: '#fff', fontSize: 22, cursor: 'pointer', marginBottom: 12 }}>←</button>
          <div style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: '#fff', marginBottom: 4 }}>Mapato Yangu 💰</div>
          <div style={{ fontFamily: 'Inter', fontSize: 36, fontWeight: 800, color: '#F9A825' }}>{fmt(commission)}</div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.7)', marginTop: 2 }}>
            + {fmt(tips)} tips · {trips.length} safari
          </div>
        </div>
      </div>

      <div className="scroll">
        {/* Period tabs */}
        <div style={{ display: 'flex', gap: 8, padding: '16px 20px 0', overflowX: 'auto', scrollbarWidth: 'none' }}>
          {([['today','Leo'],['week','Wiki'],['month','Mwezi'],['all','Yote']] as [Period,string][]).map(([k,l]) => (
            <button key={k} onClick={() => setPeriod(k)}
              style={{ flexShrink: 0, padding: '8px 16px', borderRadius: 20, border: 'none', cursor: 'pointer', fontFamily: 'Inter', fontSize: 13, fontWeight: 600, background: period === k ? '#1A5C2A' : '#F3F4F6', color: period === k ? '#fff' : '#6B7280' }}>
              {l}
            </button>
          ))}
        </div>

        {/* Summary */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, padding: '16px 20px 0' }}>
          {[
            { label: 'Jumla', value: fmt(total), icon: '💵' },
            { label: 'Kipato (85%)', value: fmt(commission), icon: '💰' },
            { label: 'Tips', value: fmt(tips), icon: '🎁' },
          ].map(s => (
            <div key={s.label} style={{ background: '#fff', border: '1px solid #E5E7EB', borderRadius: 14, padding: '12px 10px', textAlign: 'center' }}>
              <div style={{ fontSize: 20, marginBottom: 4 }}>{s.icon}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 700, color: '#1A5C2A' }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#6B7280' }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Transactions */}
        <div style={{ padding: '16px 20px 0' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, marginBottom: 12 }}>📋 Miamala</div>
          {loading ? (
            [1,2,3].map(i => <div key={i} style={{ height: 72, background: '#F3F4F6', borderRadius: 14, marginBottom: 8, animation: 'pulse 1.5s infinite' }} />)
          ) : trips.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <div style={{ fontSize: 40, marginBottom: 12 }}>📭</div>
              <div style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280' }}>Hakuna safari katika kipindi hiki</div>
            </div>
          ) : trips.map(t => (
            <div key={t.id} style={{ background: '#fff', border: '1px solid #F3F4F6', borderRadius: 14, padding: '12px 16px', marginBottom: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>{(t.customer as any)?.name || 'Mteja'}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280' }}>
                  {svcLabel[t.service_type] || t.service_type} · {new Date(t.created_at).toLocaleDateString('sw-TZ')}
                </div>
              </div>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#1A5C2A' }}>+{fmt(Math.round((t.total_price||0)*0.85))}</div>
            </div>
          ))}
        </div>
        <div style={{ height: 100 }} />
      </div>
      <BottomNav />
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.5}}`}</style>
    </div>
  )
}
