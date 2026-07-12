import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'

export default function ProfileScreen() {
  const nav = useNavigate()
  const [user, setUser] = useState<{ name: string; phone: string; email?: string } | null>(null)
  const [stats, setStats] = useState({ requests: 0, completed: 0, wallet: 0 })

  useEffect(() => {
    const uid = Session.uid()
    if (!uid) return
    supabase.from('users')
      .select('name, phone, email, wallet_balance')
      .eq('id', uid)
      .single()
      .then(({ data }) => {
        if (data) {
          setUser({ name: data.name || 'Mteja', phone: data.phone || '', email: data.email })
          setStats(s => ({ ...s, wallet: data.wallet_balance || 0 }))
        }
      })
    supabase.from('requests')
      .select('id, status')
      .eq('customer_id', uid)
      .then(({ data }) => {
        if (data) setStats(s => ({
          ...s,
          requests: data.length,
          completed: data.filter(r => r.status === 'completed').length,
        }))
      })
  }, [])

  const handleLogout = async () => {
    await supabase.auth.signOut()
    Session.clear()
    nav('/login', { replace: true })
  }

  const C = { primary: '#1A5C2A', gold: '#F9A825', white: '#fff', bg: '#F8F9FA', textSec: '#6B7280', border: '#E5E7EB' }

  return (
    <div className="page">
      <div style={{ background: C.primary, paddingTop: 'env(safe-area-inset-top, 0px)', paddingBottom: 0 }}>
        <div style={{ padding: '20px 20px 0' }}>
          <h1 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: C.white, marginBottom: 20 }}>Wasifu Wangu</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, paddingBottom: 24 }}>
            <div style={{ width: 72, height: 72, borderRadius: 36, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 36 }}>👤</div>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: C.white }}>{user?.name || '...'}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.75)' }}>{user?.phone || ''}</div>
              <div style={{ marginTop: 6, background: C.gold, color: '#1A1A1A', fontSize: 11, fontWeight: 700, padding: '3px 10px', borderRadius: 20, display: 'inline-block', fontFamily: 'Inter' }}>Mteja</div>
            </div>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ background: C.bg }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, padding: '16px 20px' }}>
          {[
            { label: 'Safari', value: stats.requests, icon: '🛍️' },
            { label: 'Zilizokamilika', value: stats.completed, icon: '✅' },
            { label: 'Pochi (TZS)', value: stats.wallet.toLocaleString(), icon: '💰' },
          ].map(s => (
            <div key={s.label} style={{ background: C.white, borderRadius: 14, padding: '14px 10px', textAlign: 'center', border: `1px solid ${C.border}` }}>
              <div style={{ fontSize: 22, marginBottom: 4 }}>{s.icon}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: C.primary }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: C.textSec }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Menu */}
        <div style={{ margin: '0 20px', background: C.white, borderRadius: 16, overflow: 'hidden', border: `1px solid ${C.border}` }}>
          {[
            { icon: '📋', label: 'Safari Zangu', action: () => nav('/requests') },
            { icon: '💳', label: 'Malipo & Pochi', action: () => nav('/earnings') },
            { icon: '🎁', label: 'Alika Marafiki', action: () => {} },
            { icon: '⚙️', label: 'Mipangilio', action: () => {} },
            { icon: '❓', label: 'Msaada', action: () => {} },
          ].map((item, i, arr) => (
            <div key={item.label} onClick={item.action}
              style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '16px 20px', cursor: 'pointer', borderBottom: i < arr.length - 1 ? `1px solid ${C.border}` : 'none' }}>
              <span style={{ fontSize: 20 }}>{item.icon}</span>
              <span style={{ flex: 1, fontFamily: 'Inter', fontSize: 14, fontWeight: 500 }}>{item.label}</span>
              <span style={{ color: '#D1D5DB' }}>›</span>
            </div>
          ))}
        </div>

        <div style={{ margin: '16px 20px' }}>
          <button onClick={handleLogout} style={{
            width: '100%', height: 50, background: '#FFF5F5', color: '#D32F2F',
            border: '1px solid #FECACA', borderRadius: 14,
            fontFamily: 'Inter', fontSize: 15, fontWeight: 600, cursor: 'pointer',
          }}>
            🚪 Toka kwenye Akaunti
          </button>
        </div>
        <div style={{ height: 100 }} />
      </div>
      <BottomNav active="profile" />
    </div>
  )
}
