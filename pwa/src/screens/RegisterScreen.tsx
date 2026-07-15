import { useState, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#fff',
  textSec: '#6B7280', error: '#D32F2F', errorBg: '#FFEBEE',
  border: '#E5E7EB', primarySurface: '#E8F5E9',
}

function cleanPhone(raw: string) {
  return raw.replace(/[\s\-]/g, '').replace(/^(\+?00255|\+?255|0)/, '')
}

export default function RegisterScreen() {
  const nav = useNavigate()
  const [phone, setPhone] = useState('')
  const [name, setName] = useState('')
  const [step, setStep] = useState<'form' | 'otp'>('form')
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [countdown, setCountdown] = useState(0)
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)

  const clean = cleanPhone(phone)

  const startCountdown = () => {
    if (timerRef.current) clearInterval(timerRef.current)
    let c = 60; setCountdown(c)
    timerRef.current = setInterval(() => { c--; setCountdown(c); if (c <= 0) clearInterval(timerRef.current!) }, 1000)
  }

  const submit = async () => {
    if (!name.trim() || clean.length < 9) return
    setLoading(true); setError('')
    try {
      const { error: e } = await supabase.auth.signInWithOtp({ phone: `+255${clean}` })
      if (e) throw e
      setStep('otp'); startCountdown()
    } catch (e: any) { setError(e.message || 'Hitilafu') }
    setLoading(false)
  }

  const verify = async () => {
    const code = otp.join('')
    if (code.length < 6) return
    setLoading(true); setError('')
    try {
      const { data, error: e } = await supabase.auth.verifyOtp({ phone: `+255${clean}`, token: code, type: 'sms' })
      if (e) throw e
      const uid = data.user?.id
      if (!uid) throw new Error('Uthibitisho umeshindwa')

      // Create customer record
      const { error: insertErr } = await supabase.from('users').upsert({
        id: uid, phone: `+255${clean}`, name: name.trim(),
        user_type: 'customer', is_verified: true,
      }, { onConflict: 'id' })
      if (insertErr) throw insertErr

      Session.set(uid, 'customer')
      nav('/home', { replace: true })
    } catch (e: any) {
      setError(e.message?.includes('Invalid') ? 'Code si sahihi.' : 'Hitilafu. Jaribu tena.')
      setLoading(false)
    }
  }

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white }}>
      <div style={{ background: C.primary, padding: 'calc(env(safe-area-inset-top,0px) + 28px) 24px 28px' }}>
        <button onClick={() => nav('/login')} style={{ background: 'none', border: 'none', color: C.white, fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
        <h1 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: C.white, marginTop: 12 }}>Jisajili kama Mteja</h1>
        <p style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.8)' }}>Jiunge na Winga App — ni bure kabisa</p>
      </div>

      <div style={{ flex: 1, padding: '24px', overflowY: 'auto' }}>
        {step === 'form' ? (
          <>
            {error && <div style={{ background: C.errorBg, color: C.error, padding: '12px', borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13 }}>⚠️ {error}</div>}
            
            {[
              { label: 'Jina Lako Kamili *', value: name, set: setName, placeholder: 'Mfano: Ahmed Juma', type: 'text' },
            ].map(f => (
              <div key={f.label} style={{ marginBottom: 16 }}>
                <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>{f.label}</label>
                <input value={f.value} onChange={e => f.set(e.target.value)} type={f.type} placeholder={f.placeholder}
                  style={{ width: '100%', border: `1.5px solid ${C.border}`, borderRadius: 12, padding: '14px 16px', fontSize: 15, fontFamily: 'Inter', outline: 'none', boxSizing: 'border-box' }} />
              </div>
            ))}

            <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>Namba ya Simu *</label>
            <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
              <div style={{ background: C.primarySurface, border: `1px solid ${C.border}`, borderRadius: 12, padding: '14px', fontFamily: 'Inter', fontWeight: 600, fontSize: 14, color: C.primary }}>
                🇹🇿 +255
              </div>
              <input value={phone} onChange={e => setPhone(e.target.value)} type="tel" placeholder="712 345 678"
                style={{ flex: 1, border: `1.5px solid ${C.border}`, borderRadius: 12, padding: '14px 16px', fontSize: 15, fontFamily: 'Inter', outline: 'none' }} />
            </div>

            <button onClick={submit} disabled={loading || !name.trim() || clean.length < 9}
              style={{ width: '100%', height: 54, background: C.primary, color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: 'pointer' }}>
              {loading ? '⏳ Inatuma...' : 'Endelea →'}
            </button>
          </>
        ) : (
          <>
            <button onClick={() => setStep('form')} style={{ background: 'none', border: 'none', fontSize: 22, cursor: 'pointer', marginBottom: 16 }}>←</button>
            <h2 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, marginBottom: 8 }}>Thibitisha Namba</h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 24 }}>Tumetuma code kwenda +255 {phone}</p>
            {error && <div style={{ background: C.errorBg, color: C.error, padding: '12px', borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13 }}>⚠️ {error}</div>}
            <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginBottom: 20 }}>
              {otp.map((v, i) => (
                <input key={i} id={`reg-otp-${i}`} value={v} type="tel" maxLength={1}
                  onChange={e => {
                    const d = e.target.value.replace(/\D/, '')
                    const next = [...otp]; next[i] = d; setOtp(next)
                    if (d && i < 5) (document.getElementById(`reg-otp-${i+1}`) as HTMLInputElement)?.focus()
                  }}
                  style={{ width: 48, height: 56, textAlign: 'center', fontSize: 20, fontWeight: 700, border: `2px solid ${v ? C.primary : C.border}`, borderRadius: 12, fontFamily: 'Inter', outline: 'none', background: v ? C.primarySurface : C.white }} />
              ))}
            </div>
            <div style={{ textAlign: 'center', marginBottom: 20 }}>
              {countdown > 0 ? <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>Tuma tena baada ya 00:{String(countdown).padStart(2,'0')}</span>
                : <button onClick={() => { setLoading(false); submit() }} style={{ background: 'none', border: 'none', color: C.primary, fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter' }}>🔄 Tuma tena</button>}
            </div>
            <button onClick={verify} disabled={loading || otp.join('').length < 6}
              style={{ width: '100%', height: 54, background: otp.join('').length === 6 ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: 'pointer' }}>
              {loading ? '⏳...' : 'Thibitisha →'}
            </button>
          </>
        )}
      </div>
    </div>
  )
}
