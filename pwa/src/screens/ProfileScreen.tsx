import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { fmt } from '../lib/constants'
import { uploadProfilePhoto, pickPhoto } from '../lib/upload'

const C = { primary: '#1A5C2A', gold: '#F9A825', white: '#fff', bg: '#F8F9FA', textSec: '#6B7280', border: '#E5E7EB' }

export default function ProfileScreen() {
  const nav = useNavigate()
  const [name, setName]           = useState('')
  const [phone, setPhone]         = useState('')
  const [wallet, setWallet]       = useState(0)
  const [requests, setRequests]   = useState(0)
  const [completed, setCompleted] = useState(0)
  const [photoUrl, setPhotoUrl]   = useState<string | null>(null)
  const [loading, setLoading]     = useState(true)
  const [uploadingPhoto, setUploadingPhoto] = useState(false)
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
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || Session.uid()
    if (!uid) { setLoading(false); return }
    try {
      const { data } = await supabase.from('users')
        .select('name, phone, wallet_balance, profile_image_url')
        .eq('id', uid).maybeSingle()
      if (data && mounted.current) {
        setName(data.name || '')
        setNameInput(data.name || '')
        setPhone(data.phone || '')
        setWallet(data.wallet_balance || 0)
        setPhotoUrl(data.profile_image_url || null)
      }
    } catch {}
    try {
      const { data: reqs } = await supabase.from('requests')
        .select('id, status').eq('customer_id', uid)
      if (reqs && mounted.current) {
        setRequests(reqs.length)
        setCompleted(reqs.filter(r => r.status === 'completed').length)
      }
    } catch {}
    if (mounted.current) setLoading(false)
  }

  const handlePhotoChange = async () => {
    const file = await pickPhoto()
    if (!file) return
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || Session.uid() || ''
    setUploadingPhoto(true)
    try {
      const url = await uploadProfilePhoto(file, uid)
      await supabase.from('users').update({ profile_image_url: url }).eq('id', uid)
      if (mounted.current) setPhotoUrl(url)
    } catch (e: any) {
      alert('Imeshindwa kupakia picha: ' + e.message)
    }
    if (mounted.current) setUploadingPhoto(false)
  }

  const handleSaveName = async () => {
    const trimmed = nameInput.trim()
    if (trimmed.length < 2) return
    setSavingName(true)
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || Session.uid() || ''
    try {
      await supabase.from('users').update({ name: trimmed }).eq('id', uid)
      if (mounted.current) { setName(trimmed); setEditingName(false) }
    } catch {}
    if (mounted.current) setSavingName(false)
  }

  const handleLogout = async () => {
    try { await supabase.auth.signOut() } catch {}
    Session.clear()
    nav('/login', { replace: true })
  }

  return (
    <div className="page">
      {/* Green header */}
      <div style={{ background: C.primary, paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0 }}>
        <div style={{ padding: '20px 20px 28px' }}>
          <h1 style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: C.white, marginBottom: 20 }}>Wasifu Wangu</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            {/* Profile photo */}
            <div style={{ position: 'relative', flexShrink: 0 }} onClick={handlePhotoChange}>
              <div style={{ width: 76, height: 76, borderRadius: 38, background: 'rgba(255,255,255,0.2)', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', border: '2.5px solid rgba(255,255,255,0.5)' }}>
                {photoUrl
                  ? <img src={photoUrl} alt="profile" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  : <span style={{ fontSize: 34 }}>👤</span>}
              </div>
              <div style={{ position: 'absolute', bottom: 0, right: 0, width: 26, height: 26, borderRadius: 13, background: C.gold, display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid white', cursor: 'pointer' }}>
                {uploadingPhoto
                  ? <span style={{ width: 12, height: 12, border: '2px solid #fff', borderTop: '2px solid #1A1A1A', borderRadius: 6, animation: 'spin 1s linear infinite', display: 'block' }} />
                  : <span style={{ fontSize: 12 }}>📷</span>}
              </div>
            </div>
            {/* Name + edit */}
            <div style={{ flex: 1 }}>
              {editingName ? (
                <div>
                  <input value={nameInput} onChange={e => setNameInput(e.target.value)} autoFocus
                    onKeyDown={e => e.key === 'Enter' && handleSaveName()}
                    style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, background: 'rgba(255,255,255,0.2)', border: '1.5px solid rgba(255,255,255,0.5)', borderRadius: 8, padding: '7px 10px', color: C.white, outline: 'none', width: '100%', boxSizing: 'border-box', marginBottom: 8 }} />
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button onClick={handleSaveName} disabled={savingName}
                      style={{ background: C.gold, border: 'none', borderRadius: 8, padding: '6px 14px', fontFamily: 'Inter', fontSize: 12, fontWeight: 700, color: '#1A1A1A', cursor: 'pointer' }}>
                      {savingName ? '...' : '✓ Hifadhi'}
                    </button>
                    <button onClick={() => { setEditingName(false); setNameInput(name) }}
                      style={{ background: 'rgba(255,255,255,0.15)', border: 'none', borderRadius: 8, padding: '6px 10px', color: C.white, cursor: 'pointer', fontFamily: 'Inter', fontSize: 12 }}>Ghairi</button>
                  </div>
                </div>
              ) : (
                <div onClick={() => setEditingName(true)} style={{ cursor: 'pointer' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: C.white }}>{loading ? '...' : (name || 'Bonyeza kubadilisha jina')}</div>
                    <span style={{ fontSize: 14, opacity: 0.7 }}>✏️</span>
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>{phone}</div>
                  <div style={{ marginTop: 8, background: C.gold, color: '#1A1A1A', fontSize: 11, fontWeight: 700, padding: '3px 12px', borderRadius: 20, display: 'inline-block', fontFamily: 'Inter' }}>Mteja</div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ background: C.bg }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, padding: '16px 16px 0' }}>
          {[
            { icon: '🛍️', label: 'Safari', value: String(requests) },
            { icon: '✅', label: 'Zilizokamilika', value: String(completed) },
            { icon: '💰', label: 'Pochi', value: wallet > 0 ? fmt(wallet) : '0' },
          ].map(s => (
            <div key={s.label} style={{ background: C.white, borderRadius: 14, padding: '12px 8px', textAlign: 'center', border: `1px solid ${C.border}` }}>
              <div style={{ fontSize: 20, marginBottom: 4 }}>{s.icon}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: C.primary }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: C.textSec }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Menu */}
        <div style={{ margin: '14px 16px 0', background: C.white, borderRadius: 16, overflow: 'hidden', border: `1px solid ${C.border}` }}>
          {[
            { icon: '📋', label: 'Safari Zangu',     sub: 'Maombi yako yote',          action: () => nav('/requests') },
            { icon: '💳', label: 'Matumizi',          sub: 'Historia ya malipo',         action: () => nav('/earnings') },
            { icon: '💬', label: 'Ujumbe',            sub: 'Mazungumzo na Wingas',       action: () => nav('/messages') },
            { icon: '🎁', label: 'Alika Marafiki',   sub: 'Pata TZS 2,000 kwa rafiki', action: () => {} },
            { icon: '🔔', label: 'Arifa',             sub: 'Mipangilio ya arifa',        action: () => {} },
          ].map((item, i, arr) => (
            <div key={item.label} onClick={item.action}
              style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 16px', cursor: 'pointer', borderBottom: i < arr.length - 1 ? `1px solid ${C.border}` : 'none', WebkitTapHighlightColor: 'transparent' }}>
              <div style={{ width: 38, height: 38, borderRadius: 10, background: '#F8F9FA', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, flexShrink: 0 }}>{item.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 600 }}>{item.label}</div>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec }}>{item.sub}</div>
              </div>
              <span style={{ color: '#D1D5DB', fontSize: 18 }}>›</span>
            </div>
          ))}
        </div>

        {/* Become Winga CTA */}
        <div style={{ margin: '14px 16px 0', background: '#FFF8E1', border: '1px solid rgba(249,168,37,0.4)', borderRadius: 16, padding: 16 }}>
          <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: '#F57F17', marginBottom: 4 }}>🛍️ Ungependa Kuwa Winga?</div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec, marginBottom: 12 }}>Chapisha TZS 12,000–32,000 kwa saa ukisaidia wateja kununua</div>
          <button onClick={() => nav('/winga-register')}
            style={{ background: '#F9A825', color: '#1A1A1A', border: 'none', borderRadius: 10, padding: '10px 20px', fontFamily: 'Inter', fontSize: 13, fontWeight: 700, cursor: 'pointer' }}>
            Jiunge kama Winga →
          </button>
        </div>

        {/* Version + Logout */}
        <div style={{ margin: '14px 16px' }}>
          <button onClick={handleLogout}
            style={{ width: '100%', height: 50, background: '#FFF5F5', color: C.primary === '#1A5C2A' ? '#D32F2F' : '#D32F2F', border: '1px solid #FECACA', borderRadius: 14, fontFamily: 'Inter', fontSize: 15, fontWeight: 600, cursor: 'pointer' }}>
            🚪 Toka kwenye Akaunti
          </button>
        </div>
        <div style={{ textAlign: 'center', paddingBottom: 8 }}>
          <p style={{ fontFamily: 'Inter', fontSize: 11, color: '#9CA3AF' }}>Winga App v1.3.0</p>
        </div>
        <div style={{ height: 20 }} />
      </div>

      <BottomNav />
      <style>{`@keyframes spin{to{transform:rotate(360deg)}}`}</style>
    </div>
  )
}
