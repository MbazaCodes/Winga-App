import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import BottomNav from '../components/layout/BottomNav'
import { WingaBadge } from '../components/ui/Badge'
import { SPECIALTIES, AREAS, fmt } from '../lib/constants'
import { uploadProfilePhoto, pickPhoto } from '../lib/upload'

const C = { primary: '#1A5C2A', gold: '#F9A825', white: '#fff', bg: '#F8F9FA', textSec: '#6B7280', border: '#E5E7EB' }

interface WingaData {
  id: string; name: string; phone: string; email: string | null
  specialty: string; current_city: string; current_area: string | null
  bio: string | null; badge: string; is_online: boolean
  total_trips: number; total_earnings: number
  winga_score: number; rated_trips: number; total_points: number
  winga_id: string; is_top_rated: boolean
  profile_photo_url: string | null
  tin_number: string | null
  instagram: string | null; facebook: string | null
  tiktok: string | null; twitter: string | null; whatsapp: string | null
}

type EditSection = 'profile' | 'social' | 'tax' | null

export default function WingaProfileScreen() {
  const nav = useNavigate()
  const [winga, setWinga] = useState<WingaData | null>(null)
  const [editSection, setEditSection] = useState<EditSection>(null)
  const [form, setForm] = useState({
    specialty: '', city: '', area: '', bio: '',
    instagram: '', facebook: '', tiktok: '', twitter: '', whatsapp: '',
    tin_number: '',
  })
  const [saving, setSaving] = useState(false)
  const [loading, setLoading] = useState(true)
  const [uploadingPhoto, setUploadingPhoto] = useState(false)
  const mounted = useRef(true)

  useEffect(() => { mounted.current = true; load(); return () => { mounted.current = false } }, [])

  async function load() {
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || Session.uid()
    if (!uid) { setLoading(false); return }
    const { data } = await supabase.from('wingas')
      .select('id,name,phone,email,specialty,current_city,current_area,bio,badge,is_online,total_trips,total_earnings,winga_score,rated_trips,total_points,winga_id,is_top_rated,profile_photo_url,tin_number,instagram,facebook,tiktok,twitter,whatsapp')
      .eq('user_id', uid).maybeSingle()
    if (data && mounted.current) {
      setWinga(data as WingaData)
      setForm({
        specialty: data.specialty || '', city: data.current_city || '',
        area: data.current_area || '', bio: data.bio || '',
        instagram: data.instagram || '', facebook: data.facebook || '',
        tiktok: data.tiktok || '', twitter: data.twitter || '',
        whatsapp: data.whatsapp || '', tin_number: data.tin_number || '',
      })
    }
    if (mounted.current) setLoading(false)
  }

  const handlePhoto = async () => {
    const file = await pickPhoto()
    if (!file || !winga) return
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || Session.uid() || ''
    setUploadingPhoto(true)
    try {
      const url = await uploadProfilePhoto(file, uid)
      await supabase.from('wingas').update({ profile_photo_url: url }).eq('id', winga.id)
      await supabase.from('users').update({ profile_image_url: url }).eq('id', uid)
      if (mounted.current) setWinga(w => w ? { ...w, profile_photo_url: url } : w)
    } catch (e: any) { alert('Imeshindwa: ' + e.message) }
    if (mounted.current) setUploadingPhoto(false)
  }

  const save = async (fields: Partial<typeof form>) => {
    if (!winga) return
    setSaving(true)
    const update: any = {}
    if (fields.specialty !== undefined) update.specialty = fields.specialty
    if (fields.city !== undefined) { update.current_city = fields.city; update.home_location = `${fields.area || form.area}, ${fields.city}` }
    if (fields.area !== undefined) update.current_area = fields.area
    if (fields.bio !== undefined) update.bio = fields.bio || null
    if (fields.tin_number !== undefined) update.tin_number = fields.tin_number || null
    if (fields.instagram !== undefined) update.instagram = fields.instagram || null
    if (fields.facebook !== undefined) update.facebook = fields.facebook || null
    if (fields.tiktok !== undefined) update.tiktok = fields.tiktok || null
    if (fields.twitter !== undefined) update.twitter = fields.twitter || null
    if (fields.whatsapp !== undefined) update.whatsapp = fields.whatsapp || null
    await supabase.from('wingas').update(update).eq('id', winga.id)
    await load()
    if (mounted.current) { setSaving(false); setEditSection(null) }
  }

  const logout = async () => {
    try { await supabase.auth.signOut() } catch {}
    Session.clear(); nav('/login', { replace: true })
  }

  if (loading) return <div style={{ height: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><div style={{ fontFamily: 'Inter', color: C.textSec }}>Inapakia...</div></div>
  if (!winga) return null

  const scorePercent = Math.round((winga.winga_score || 0) * 100)
  const grossEarnings = winga.total_earnings || 0
  const taxDeducted = Math.round(grossEarnings * 0.03)
  const netEarnings = grossEarnings - taxDeducted

  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: C.primary, paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0 }}>
        <div style={{ padding: '14px 20px 24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <button onClick={() => nav(-1)} style={{ background: 'none', border: 'none', color: C.white, fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
            <span style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: C.white }}>Wasifu Wangu</span>
            <button onClick={logout} style={{ background: 'rgba(255,255,255,0.15)', border: 'none', color: C.white, borderRadius: 8, padding: '6px 12px', fontFamily: 'Inter', fontSize: 12, cursor: 'pointer' }}>Toka</button>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            {/* Photo */}
            <div style={{ position: 'relative', flexShrink: 0, cursor: 'pointer' }} onClick={handlePhoto}>
              <div style={{ width: 76, height: 76, borderRadius: 38, background: 'rgba(255,255,255,0.2)', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2.5px solid rgba(255,255,255,0.5)' }}>
                {winga.profile_photo_url
                  ? <img src={winga.profile_photo_url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  : <span style={{ fontSize: 34 }}>👤</span>}
              </div>
              <div style={{ position: 'absolute', bottom: 0, right: 0, width: 26, height: 26, borderRadius: 13, background: C.gold, display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid white' }}>
                {uploadingPhoto ? <span style={{ width: 12, height: 12, border: '2px solid #1A1A1A', borderTop: '2px solid transparent', borderRadius: 6, animation: 'spin 1s linear infinite', display: 'block' }} /> : <span style={{ fontSize: 12 }}>📷</span>}
              </div>
            </div>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 19, fontWeight: 700, color: C.white }}>{winga.name}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.7)', marginBottom: 6 }}>{winga.winga_id}</div>
              <WingaBadge badge={winga.badge} />
            </div>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ background: C.bg }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8, padding: '14px 16px 0' }}>
          {[
            { label: 'Safari', value: String(winga.total_trips) },
            { label: 'Alama', value: `${scorePercent}%` },
            { label: 'Pointi', value: `${winga.total_points}/${winga.rated_trips}` },
          ].map(s => (
            <div key={s.label} style={{ background: C.white, borderRadius: 14, padding: '12px 8px', textAlign: 'center', border: `1px solid ${C.border}` }}>
              <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 700, color: C.primary }}>{s.value}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 10, color: C.textSec }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* TAX BREAKDOWN */}
        <div style={{ margin: '12px 16px 0', background: C.white, borderRadius: 16, padding: '14px 16px', border: `1px solid ${C.border}` }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>💰 Mapato & Kodi (TRA 3%)</span>
            <button onClick={() => setEditSection(editSection === 'tax' ? null : 'tax')}
              style={{ background: C.primary + '15', border: 'none', color: C.primary, borderRadius: 8, padding: '4px 10px', fontFamily: 'Inter', fontSize: 12, fontWeight: 600, cursor: 'pointer' }}>
              {winga.tin_number ? '✏️ TIN' : '+ TIN'}
            </button>
          </div>
          {[
            { label: 'Jumla ya Mapato', value: fmt(grossEarnings), color: C.primary },
            { label: 'Kodi ya TRA (3%)', value: `- ${fmt(taxDeducted)}`, color: '#D32F2F' },
            { label: 'Mapato Halisi', value: fmt(netEarnings), color: C.primary, bold: true },
          ].map(row => (
            <div key={row.label} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>{row.label}</span>
              <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: row.bold ? 700 : 500, color: row.color }}>{row.value}</span>
            </div>
          ))}
          {winga.tin_number && (
            <div style={{ marginTop: 8, background: '#E8F5E9', borderRadius: 8, padding: '8px 12px' }}>
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>📋 TIN: <strong>{winga.tin_number}</strong></span>
            </div>
          )}
          {editSection === 'tax' && (
            <div style={{ marginTop: 12, borderTop: `1px solid ${C.border}`, paddingTop: 12 }}>
              <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>Namba ya TIN (TRA) *</label>
              <input value={form.tin_number} onChange={e => setForm(f => ({ ...f, tin_number: e.target.value }))}
                placeholder="Mfano: 100-123-456"
                style={{ width: '100%', border: `1.5px solid ${C.border}`, borderRadius: 10, padding: '11px 14px', fontFamily: 'Inter', fontSize: 14, outline: 'none', boxSizing: 'border-box', marginBottom: 10 }} />
              <div style={{ background: '#FFF8E1', borderRadius: 10, padding: '10px 12px', marginBottom: 10 }}>
                <p style={{ fontFamily: 'Inter', fontSize: 12, color: '#F57F17', margin: 0 }}>
                  ℹ️ Kodi ya 3% itakatwa kiotomatiki kutoka kwa mapato yako kwa mujibu wa sheria za TRA Tanzania.
                </p>
              </div>
              <BtnsRow onSave={() => save({ tin_number: form.tin_number })} onCancel={() => setEditSection(null)} saving={saving} />
            </div>
          )}
        </div>

        {/* PROFILE INFO */}
        <div style={{ margin: '12px 16px 0', background: C.white, borderRadius: 16, border: `1px solid ${C.border}`, overflow: 'hidden' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 16px', borderBottom: `1px solid ${C.border}` }}>
            <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>📝 Taarifa za Kazi</span>
            <button onClick={() => setEditSection(editSection === 'profile' ? null : 'profile')}
              style={{ background: C.primary + '15', border: 'none', color: C.primary, borderRadius: 8, padding: '4px 10px', fontFamily: 'Inter', fontSize: 12, fontWeight: 600, cursor: 'pointer' }}>
              {editSection === 'profile' ? 'Funga' : '✏️ Hariri'}
            </button>
          </div>
          {editSection !== 'profile' ? (
            [
              { icon: '🛍️', label: 'Utaalamu', val: winga.specialty },
              { icon: '📍', label: 'Eneo', val: `${winga.current_area || ''}, ${winga.current_city}`.replace(/^, /, '') },
              { icon: '📱', label: 'Simu', val: winga.phone },
              { icon: '📧', label: 'Barua Pepe', val: winga.email || 'Haijaongezwa' },
              { icon: '📝', label: 'Kuhusu', val: winga.bio || 'Haijaongezwa' },
            ].map((row, i, arr) => (
              <div key={row.label} style={{ display: 'flex', gap: 12, padding: '12px 16px', borderBottom: i < arr.length-1 ? `1px solid ${C.border}` : 'none' }}>
                <span style={{ fontSize: 16 }}>{row.icon}</span>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginBottom: 2 }}>{row.label}</div>
                  <div style={{ fontFamily: 'Inter', fontSize: 14, color: '#1A1A1A' }}>{row.val}</div>
                </div>
              </div>
            ))
          ) : (
            <div style={{ padding: '14px 16px' }}>
              <SelField label="Utaalamu" val={form.specialty} set={v => setForm(f => ({ ...f, specialty: v }))} opts={SPECIALTIES} />
              <SelField label="Mji" val={form.city} set={v => setForm(f => ({ ...f, city: v, area: AREAS[v]?.[0] || '' }))} opts={Object.keys(AREAS)} />
              <SelField label="Eneo" val={form.area} set={v => setForm(f => ({ ...f, area: v }))} opts={AREAS[form.city] || []} />
              <TxtField label="Kuhusu Mimi" val={form.bio} set={v => setForm(f => ({ ...f, bio: v }))} placeholder="Ninafahamu Kariakoo vizuri..." rows={3} />
              <BtnsRow onSave={() => save({ specialty: form.specialty, city: form.city, area: form.area, bio: form.bio })} onCancel={() => setEditSection(null)} saving={saving} />
            </div>
          )}
        </div>

        {/* SOCIAL MEDIA */}
        <div style={{ margin: '12px 16px 0', background: C.white, borderRadius: 16, border: `1px solid ${C.border}`, overflow: 'hidden' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 16px', borderBottom: `1px solid ${C.border}` }}>
            <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700 }}>📱 Mitandao ya Kijamii</span>
            <button onClick={() => setEditSection(editSection === 'social' ? null : 'social')}
              style={{ background: C.primary + '15', border: 'none', color: C.primary, borderRadius: 8, padding: '4px 10px', fontFamily: 'Inter', fontSize: 12, fontWeight: 600, cursor: 'pointer' }}>
              {editSection === 'social' ? 'Funga' : '✏️ Hariri'}
            </button>
          </div>
          {editSection !== 'social' ? (
            <div style={{ padding: '10px 16px' }}>
              {[
                { icon: '📸', label: 'Instagram', val: winga.instagram, prefix: '@' },
                { icon: '📘', label: 'Facebook', val: winga.facebook, prefix: '' },
                { icon: '🎵', label: 'TikTok', val: winga.tiktok, prefix: '@' },
                { icon: '🐦', label: 'Twitter/X', val: winga.twitter, prefix: '@' },
                { icon: '💚', label: 'WhatsApp', val: winga.whatsapp, prefix: '+' },
              ].map((s, i, arr) => (
                <div key={s.label} style={{ display: 'flex', gap: 12, padding: '8px 0', borderBottom: i < arr.length-1 ? `1px solid ${C.border}` : 'none' }}>
                  <span style={{ fontSize: 18, width: 24, textAlign: 'center' }}>{s.icon}</span>
                  <div>
                    <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec }}>{s.label}: </span>
                    <span style={{ fontFamily: 'Inter', fontSize: 13, color: s.val ? C.primary : '#9CA3AF', fontWeight: s.val ? 600 : 400 }}>
                      {s.val ? `${s.prefix}${s.val}` : 'Haijaongezwa'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div style={{ padding: '14px 16px' }}>
              <TxtField label="Instagram" val={form.instagram} set={v => setForm(f => ({ ...f, instagram: v }))} placeholder="username (bila @)" />
              <TxtField label="Facebook" val={form.facebook} set={v => setForm(f => ({ ...f, facebook: v }))} placeholder="Jina au URL" />
              <TxtField label="TikTok" val={form.tiktok} set={v => setForm(f => ({ ...f, tiktok: v }))} placeholder="username (bila @)" />
              <TxtField label="Twitter / X" val={form.twitter} set={v => setForm(f => ({ ...f, twitter: v }))} placeholder="username (bila @)" />
              <TxtField label="WhatsApp" val={form.whatsapp} set={v => setForm(f => ({ ...f, whatsapp: v }))} placeholder="255712345678" keyboard="tel" />
              <BtnsRow onSave={() => save({ instagram: form.instagram, facebook: form.facebook, tiktok: form.tiktok, twitter: form.twitter, whatsapp: form.whatsapp })} onCancel={() => setEditSection(null)} saving={saving} />
            </div>
          )}
        </div>

        {/* Score bar */}
        <div style={{ margin: '12px 16px 0', background: C.white, borderRadius: 14, padding: '14px 16px', border: `1px solid ${C.border}` }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>Alama ya Huduma</span>
            <span style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 700, color: scorePercent >= 80 ? C.primary : '#F57F17' }}>{scorePercent}%</span>
          </div>
          <div style={{ height: 8, background: '#F3F4F6', borderRadius: 4 }}>
            <div style={{ height: '100%', borderRadius: 4, width: `${scorePercent}%`, background: scorePercent >= 80 ? C.primary : '#F9A825', transition: 'width 0.5s' }} />
          </div>
          <p style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginTop: 6 }}>
            {winga.is_top_rated ? '⭐ Wewe ni Winga Bora!' : scorePercent >= 80 ? 'Karibu na badge ya Verified!' : 'Toa huduma nzuri ili alama yako iongezeke'}
          </p>
        </div>

        <div style={{ height: 20 }} />
      </div>

      <BottomNav />
      <style>{`@keyframes spin{to{transform:rotate(360deg)}}`}</style>
    </div>
  )
}

function BtnsRow({ onSave, onCancel, saving }: { onSave: () => void; onCancel: () => void; saving: boolean }) {
  const C = { primary: '#1A5C2A', border: '#E5E7EB' }
  return (
    <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
      <button onClick={onCancel} style={{ flex: 1, height: 44, background: '#F3F4F6', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 14, cursor: 'pointer' }}>Ghairi</button>
      <button onClick={onSave} disabled={saving} style={{ flex: 2, height: 44, background: C.primary, color: '#fff', border: 'none', borderRadius: 10, fontFamily: 'Inter', fontSize: 14, fontWeight: 600, cursor: 'pointer' }}>
        {saving ? '⏳ Inahifadhi...' : '💾 Hifadhi'}
      </button>
    </div>
  )
}

function TxtField({ label, val, set, placeholder, rows = 1, keyboard = 'text' }: { label: string; val: string; set: (v: string) => void; placeholder: string; rows?: number; keyboard?: string }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 6 }}>{label}</label>
      {rows > 1
        ? <textarea value={val} onChange={e => set(e.target.value)} rows={rows} placeholder={placeholder}
            style={{ width: '100%', border: '1.5px solid #E5E7EB', borderRadius: 10, padding: '11px 14px', fontFamily: 'Inter', fontSize: 14, outline: 'none', resize: 'none', boxSizing: 'border-box' }} />
        : <input value={val} onChange={e => set(e.target.value)} type={keyboard} placeholder={placeholder}
            style={{ width: '100%', border: '1.5px solid #E5E7EB', borderRadius: 10, padding: '11px 14px', fontFamily: 'Inter', fontSize: 14, outline: 'none', boxSizing: 'border-box' }} />}
    </div>
  )
}

function SelField({ label, val, set, opts }: { label: string; val: string; set: (v: string) => void; opts: string[] }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 6 }}>{label}</label>
      <select value={val} onChange={e => set(e.target.value)}
        style={{ width: '100%', border: '1.5px solid #E5E7EB', borderRadius: 10, padding: '11px 14px', fontFamily: 'Inter', fontSize: 14, outline: 'none', background: '#fff', boxSizing: 'border-box' }}>
        {opts.map(o => <option key={o} value={o}>{o}</option>)}
      </select>
    </div>
  )
}
