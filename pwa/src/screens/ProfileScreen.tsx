import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { fmt } from '../lib/constants'

export default function ProfileScreen() {
  const nav = useNavigate()
  const [name, setName]       = useState('Mteja')
  const [phone, setPhone]     = useState('')
  const [wallet, setWallet]   = useState(0)
  const [requests, setRequests] = useState(0)
  const [completed, setCompleted] = useState(0)
  const [loading, setLoading] = useState(true)
  const [editingName, setEditingName] = useState(false)
  const [nameInput, setNameInput] = useState('')
  const [savingName, setSavingName] = useState(false)
  const mounted = useRef(true)

  useEffect(() => {
    mounted.current = true
    loadData()
    return () => { mounted.current = false }
  }, [])

  async function loadData() {
    const uid = Session.uid()
    if (!uid) { setLoading(false); return }
    try {
      const { data: user } = await supabase
        .from('users')
        .select('name, phone, wallet_balance')
        .eq('id', uid)
        .maybeSingle()
      if (!mounted.current) return
      if (user) {
        setName(user.name || 'Mteja')
        setPhone(user.phone || '')
        setWallet(user.wallet_balance || 0)
      }
    } catch {}

    try {
      const { data: reqs } = await supabase
        .from('requests')
        .select('id, status')
        .eq('customer_id', uid)
      if (!mounted.current) return
      if (reqs) {
        setRequests(reqs.length)
        setCompleted(reqs.filter(r => r.status === 'completed').length)
      }
    } catch {}

    if (mounted.current) setLoading(false)
  }

  const handleSaveName = async () => {
    if (!nameInput.trim() || nameInput.trim().length < 2) return
    setSavingName(true)
    try {
      const uid = Session.uid()
      if (uid) await supabase.from('users').update({ name: nameInput.trim() }).eq('id', uid)
      setName(nameInput.trim())
      setEditingName(false)
    } catch {}
    setSavingName(false)
  }

  const handleLogout = async () => {
    try { await supabase.auth.signOut() } catch {}
    Session.clear()
    nav('/login', { replace: true })
  }

  const C = {
    primary: '#1A5C2A', gold: '#F9A825', white: '#fff',
    bg: '#F8F9FA', textSec: '#6B7280', border: '#E5E7EB',
  }

  return (
    <div className="page">
      {/* Green header */}
      <div style={{ background: C.primary, paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0 }}>
        <div style={{ padding: '20px 20px 28px' }}>
          <h1 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: C.white, marginBottom: 20 }}>
            Wasifu Wangu
          </h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <div style={{
              width: 72, height: 72, borderRadius: 36,
              background: 'rgba(255,255,255,0.2)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 32,
            }}>👤</div>
            <div>
              {loading
                ? <div style={{ height: 20, width: 120, background: 'rgba(255,255,255,0.2)', borderRadius: 8 }} />
                : editingName
                  ? (
                    <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      <input value={nameInput} onChange={e => setNameInput(e.target.value)} autoFocus
                        onKeyDown={e => e.key === 'Enter' && handleSaveName()}
                        style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, background: 'rgba(255,255,255,0.2)', border: '1.5px solid rgba(255,255,255,0.5)', borderRadius: 8, padding: '6px 10px', color: C.white, outline: 'none', width: 160 }} />
                      <button onClick={handleSaveName} disabled={savingName}
                        style={{ background: C.gold, border: 'none', borderRadius: 8, padding: '6px 12px', fontFamily: 'Inter', fontSize: 12, fontWeight: 700, color: '#1A1A1A', cursor: 'pointer' }}>
                        {savingName ? '...' : 'Hifadhi'}
                      </button>
                      <button onClick={() => { setEditingName(false); setNameInput(name) }}
                        style={{ background: 'none', border: 'none', color: 'rgba(255,255,255,0.7)', cursor: 'pointer', fontSize: 18 }}>✕</button>
                    </div>
                  )
                  : (
                    <div onClick={() => setEditingName(true)} style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
                      <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: C.white }}>{name}</div>
                      <span style={{ fontSize: 14, opacity: 0.7 }}>✏️</span>
                    </div>
                  )}
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>{phone}</div>
              <div style={{
                marginTop: 8, display: 'inline-block',
                background: C.gold, color: '#1A1A1A',
                fontSize: 11, fontWeight: 700,
                padding: '3px 12px', borderRadius: 20, fontFamily: 'Inter',
              }}>Mteja</div>
            </div>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ background: C.bg }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, padding: '16px 20px 0' }}>
          {[
            { icon: '🛍️', label: 'Safari Zote', value: String(requests) },
            { icon: '✅', label: 'Zilizokamilika', value: String(completed) },
            { icon: '💰', label: 'Pochi (TZS)', value: wallet > 0 ? fmt(wallet) : '0' },
          ].map(s => (
            <div key={s.label} style={{
              background: C.white, borderRadius: 14, padding: '14px 10px',
              textAlign: 'center', border: `1px solid ${C.border}`,
            }}>
              <div style={{ fontSize: 22, marginBottom: 4 }}>{s.icon}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 700, color: C.primary }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: C.textSec }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Menu */}
        <div style={{ margin: '16px 20px 0', background: C.white, borderRadius: 16, overflow: 'hidden', border: `1px solid ${C.border}` }}>
          {[
            { icon: '📋', label: 'Safari Zangu',     sub: 'Angalia maombi yako yote', action: () => nav('/requests') },
            { icon: '💳', label: 'Matumizi',          sub: 'Historia ya malipo',        action: () => nav('/earnings') },
            { icon: '🎁', label: 'Alika Marafiki',   sub: 'Pata TZS 2,000 kwa kila rafiki', action: () => {} },
            { icon: '⭐', label: 'Wingas Wapendwa', sub: 'Wingas unaowapenda',         action: () => nav('/home') },
            { icon: '❓', label: 'Msaada',            sub: 'Maswali & Majibu',           action: () => {} },
          ].map((item, i, arr) => (
            <div key={item.label} onClick={item.action}
              style={{
                display: 'flex', alignItems: 'center', gap: 14,
                padding: '14px 16px', cursor: 'pointer',
                borderBottom: i < arr.length - 1 ? `1px solid ${C.border}` : 'none',
                WebkitTapHighlightColor: 'transparent',
              }}>
              <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: '#F8F9FA',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, flexShrink: 0,
              }}>{item.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600, color: '#1A1A1A' }}>{item.label}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec }}>{item.sub}</div>
              </div>
              <span style={{ color: '#D1D5DB', fontSize: 18 }}>›</span>
            </div>
          ))}
        </div>

        {/* Become Winga CTA */}
        <div style={{ margin: '16px 20px 0', background: '#FFF8E1', border: '1px solid rgba(249,168,37,0.3)', borderRadius: 16, padding: '16px' }}>
          <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#F57F17', marginBottom: 4 }}>
            🛍️ Ungependa Kuwa Winga?
          </div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 12 }}>
            Chapisha TZS 12,000–32,000 kwa saa ukisaidia wateja kununua
          </div>
          <button onClick={() => nav('/winga-register')}
            style={{ background: '#F9A825', color: '#1A1A1A', border: 'none', borderRadius: 10, padding: '10px 20px', fontFamily: 'Inter', fontSize: 13, fontWeight: 700, cursor: 'pointer', WebkitTapHighlightColor: 'transparent' }}>
            Jiunge kama Winga →
          </button>
        </div>

        {/* Logout */}
        <div style={{ margin: '16px 20px' }}>
          <button onClick={handleLogout}
            style={{
              width: '100%', height: 50,
              background: '#FFF5F5', color: '#D32F2F',
              border: '1px solid #FECACA', borderRadius: 14,
              fontFamily: 'Inter', fontSize: 15, fontWeight: 600, cursor: 'pointer',
              WebkitTapHighlightColor: 'transparent',
            }}>
            🚪 Toka kwenye Akaunti
          </button>
        </div>
        <div style={{ height: 20 }} />
      </div>

      <BottomNav />
    </div>
  )
}
