import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { SPECIALTIES, CITIES, AREAS, fmt } from '../lib/constants'

interface WingaData {
  id: string; name: string; phone: string; email: string | null
  specialty: string; current_city: string; current_area: string | null
  bio: string | null; badge: string; is_online: boolean
  total_trips: number; total_earnings: number
  winga_score: number; rated_trips: number; total_points: number
  winga_id: string; is_top_rated: boolean
}

export default function WingaProfileScreen() {
  const nav = useNavigate()
  const [winga, setWinga] = useState<WingaData | null>(null)
  const [editing, setEditing] = useState(false)
  const [form, setForm] = useState({ specialty: '', city: '', area: '', bio: '' })
  const [saving, setSaving] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => { load() }, [])

  async function load() {
    const uid = Session.uid()
    if (!uid) return
    const { data } = await supabase.from('wingas')
      .select('id,name,phone,email,specialty,current_city,current_area,bio,badge,is_online,total_trips,total_earnings,winga_score,rated_trips,total_points,winga_id,is_top_rated')
      .eq('user_id', uid).maybeSingle()
    if (data) {
      setWinga(data as WingaData)
      setForm({ specialty: data.specialty || '', city: data.current_city || '', area: data.current_area || '', bio: data.bio || '' })
    }
    setLoading(false)
  }

  const save = async () => {
    if (!winga) return
    setSaving(true)
    await supabase.from('wingas').update({
      specialty: form.specialty,
      current_city: form.city,
      current_area: form.area,
      home_location: `${form.area}, ${form.city}`,
      bio: form.bio || null,
    }).eq('id', winga.id)
    setWinga(w => w ? { ...w, specialty: form.specialty, current_city: form.city, current_area: form.area, bio: form.bio } : w)
    setSaving(false); setEditing(false)
  }

  const logout = async () => {
    await supabase.auth.signOut()
    Session.clear()
    nav('/login', { replace: true })
  }

  if (loading) return <div style={{ height: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><div style={{ fontFamily: 'Inter', color: '#6B7280' }}>Inapakia...</div></div>
  if (!winga) return null

  const scorePercent = Math.round((winga.winga_score || 0) * 100)

  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: '#1A5C2A', paddingTop: 'env(safe-area-inset-top,0px)' }}>
        <div style={{ padding: '16px 20px 24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
            <button onClick={() => nav(-1)} style={{ background: 'none', border: 'none', color: '#fff', fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
            <button onClick={() => setEditing(!editing)}
              style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: '#fff', borderRadius: 10, padding: '8px 14px', fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
              {editing ? '✕ Ghairi' : '✏️ Hariri'}
            </button>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{ width: 72, height: 72, borderRadius: 36, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 34 }}>👤</div>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#fff' }}>{winga.name}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.75)', marginBottom: 6 }}>{winga.winga_id || '#WNGA...'}</div>
              <WingaBadge badge={winga.badge} />
            </div>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ background: '#F8F9FA' }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, padding: '16px 20px 0' }}>
          {[
            { label: 'Safari', value: winga.total_trips },
            { label: 'Alama %', value: `${scorePercent}%` },
            { label: 'Pointi', value: `${winga.total_points}/${winga.rated_trips}` },
          ].map(s => (
            <div key={s.label} style={{ background: '#fff', borderRadius: 14, padding: '14px 10px', textAlign: 'center', border: '1px solid #E5E7EB' }}>
              <div style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: '#1A5C2A' }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: '#6B7280' }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Score bar */}
        <div style={{ margin: '12px 20px 0', background: '#fff', borderRadius: 14, padding: '14px 16px', border: '1px solid #E5E7EB' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>Alama ya Huduma</span>
            <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 700, color: scorePercent >= 80 ? '#1A5C2A' : scorePercent >= 60 ? '#F57F17' : '#D32F2F' }}>{scorePercent}%</span>
          </div>
          <div style={{ height: 8, background: '#F3F4F6', borderRadius: 4 }}>
            <div style={{ height: '100%', borderRadius: 4, background: scorePercent >= 80 ? '#1A5C2A' : scorePercent >= 60 ? '#F9A825' : '#D32F2F', width: `${scorePercent}%`, transition: 'width 0.5s ease' }} />
          </div>
          <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280', marginTop: 6 }}>
            {winga.is_top_rated ? '⭐ Wewe ni Winga Bora!' : scorePercent >= 80 ? 'Karibu na badge ya Verified!' : 'Toa huduma nzuri ili alama yako iongezeke'}
          </div>
        </div>

        {/* Edit form / info */}
        <div style={{ margin: '12px 20px 0', background: '#fff', borderRadius: 14, border: '1px solid #E5E7EB', overflow: 'hidden' }}>
          {editing ? (
            <div style={{ padding: '16px' }}>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, marginBottom: 14 }}>✏️ Hariri Wasifu</div>
              <Sel label="Utaalamu" val={form.specialty} set={v => setForm(f => ({ ...f, specialty: v }))} opts={SPECIALTIES} />
              <Sel label="Mji" val={form.city} set={v => setForm(f => ({ ...f, city: v, area: AREAS[v]?.[0] || '' }))} opts={Object.keys(AREAS)} />
              <Sel label="Eneo" val={form.area} set={v => setForm(f => ({ ...f, area: v }))} opts={AREAS[form.city] || []} />
              <div style={{ marginBottom: 14 }}>
                <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 6 }}>Kuhusu Mimi</label>
                <textarea value={form.bio} onChange={e => setForm(f => ({ ...f, bio: e.target.value }))} rows={3} maxLength={200}
                  style={{ width: '100%', border: '1.5px solid #E5E7EB', borderRadius: 12, padding: '12px', fontFamily: 'Inter', fontSize: 14, outline: 'none', resize: 'none', boxSizing: 'border-box' }} />
              </div>
              <button onClick={save} disabled={saving}
                style={{ width: '100%', height: 48, background: '#1A5C2A', color: '#fff', border: 'none', borderRadius: 12, fontFamily: 'Inter', fontSize: 15, fontWeight: 600, cursor: 'pointer' }}>
                {saving ? '⏳ Inahifadhi...' : '💾 Hifadhi Mabadiliko'}
              </button>
            </div>
          ) : (
            [
              { icon: '📱', label: 'Simu', val: winga.phone },
              { icon: '📧', label: 'Barua Pepe', val: winga.email || 'Haijaongezwa' },
              { icon: '🛍️', label: 'Utaalamu', val: winga.specialty },
              { icon: '📍', label: 'Eneo', val: `${winga.current_area || ''}, ${winga.current_city}`.replace(/^, /, '') },
              { icon: '📝', label: 'Kuhusu Mimi', val: winga.bio || 'Haijaongezwa' },
            ].map((row, i, arr) => (
              <div key={row.label} style={{ display: 'flex', gap: 12, padding: '14px 16px', borderBottom: i < arr.length-1 ? '1px solid #F3F4F6' : 'none' }}>
                <span style={{ fontSize: 18 }}>{row.icon}</span>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: 11, color: '#6B7280', marginBottom: 2 }}>{row.label}</div>
                  <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 500, color: '#1A1A1A' }}>{row.val}</div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Menu */}
        <div style={{ margin: '12px 20px 0', background: '#fff', borderRadius: 14, overflow: 'hidden', border: '1px solid #E5E7EB' }}>
          {[
            { icon: '📊', label: 'Dashboard', path: '/winga/home' },
            { icon: '💰', label: 'Mapato Yangu', path: '/winga/earnings' },
            { icon: '📋', label: 'Maombi Yote', path: '/winga/requests' },
          ].map((item, i, arr) => (
            <div key={item.label} onClick={() => nav(item.path)}
              style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 16px', cursor: 'pointer', borderBottom: i < arr.length-1 ? '1px solid #F3F4F6' : 'none' }}>
              <span style={{ fontSize: 20 }}>{item.icon}</span>
              <span style={{ flex: 1, fontFamily: 'Inter', fontSize: 14, fontWeight: 500 }}>{item.label}</span>
              <span style={{ color: '#D1D5DB' }}>›</span>
            </div>
          ))}
        </div>

        <div style={{ margin: '12px 20px' }}>
          <button onClick={logout}
            style={{ width: '100%', height: 50, background: '#FFF5F5', color: '#D32F2F', border: '1px solid #FECACA', borderRadius: 14, fontFamily: 'Inter', fontSize: 15, fontWeight: 600, cursor: 'pointer' }}>
            🚪 Toka kwenye Akaunti
          </button>
        </div>
        <div style={{ height: 100 }} />
      </div>
      <BottomNav />
    </div>
  )
}

function Sel({ label, val, set, opts }: { label: string; val: string; set: (v: string) => void; opts: string[] }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 6 }}>{label}</label>
      <select value={val} onChange={e => set(e.target.value)} style={{ width: '100%', border: '1.5px solid #E5E7EB', borderRadius: 12, padding: '12px 14px', fontFamily: 'Inter', fontSize: 14, outline: 'none', background: '#fff', boxSizing: 'border-box' }}>
        {opts.map(o => <option key={o} value={o}>{o}</option>)}
      </select>
    </div>
  )
}
