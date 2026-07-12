import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import { SPECIALTIES, CITIES, AREAS } from '../lib/constants'

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#fff',
  bg: '#F8F9FA', textSec: '#6B7280', error: '#D32F2F',
  errorBg: '#FFEBEE', border: '#E5E7EB', surface: '#E8F5E9',
}

function cleanPhone(raw: string) {
  return raw.replace(/[\s\-]/g, '').replace(/^(\+?00255|\+?255|0)/, '')
}

type Step = 'personal' | 'work' | 'otp'

export default function WingaRegisterScreen() {
  const nav = useNavigate()
  const [step, setStep] = useState<Step>('personal')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Personal info
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName]   = useState('')
  const [phone, setPhone]         = useState('')
  const [email, setEmail]         = useState('')

  // Work info
  const [specialty, setSpecialty] = useState('')
  const [city, setCity]           = useState('Dar es Salaam')
  const [area, setArea]           = useState('Kariakoo')
  const [bio, setBio]             = useState('')

  // OTP
  const [otp, setOtp]         = useState(['', '', '', '', '', ''])
  const [countdown, setCountdown] = useState(0)
  const [resending, setResending] = useState(false)
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const mountedRef = useRef(true)

  useEffect(() => () => {
    mountedRef.current = false
    if (timerRef.current) clearInterval(timerRef.current)
  }, [])

  const clean = cleanPhone(phone)
  const step1Valid = firstName.trim() && lastName.trim() && clean.length >= 9
  const step2Valid = specialty && city && area

  const startCountdown = (s = 60) => {
    if (timerRef.current) clearInterval(timerRef.current)
    setCountdown(s)
    let c = s
    timerRef.current = setInterval(() => {
      c--
      if (!mountedRef.current) { clearInterval(timerRef.current!); return }
      setCountdown(c)
      if (c <= 0) clearInterval(timerRef.current!)
    }, 1000)
  }

  const sendOtp = async (isResend = false) => {
    if (isResend) setResending(true)
    else setLoading(true)
    setError('')
    try {
      const { error: e } = await supabase.auth.signInWithOtp({ phone: `+255${clean}` })
      if (e) throw e
      if (!mountedRef.current) return
      if (!isResend) setStep('otp')
      startCountdown()
    } catch (e: any) {
      if (mountedRef.current) setError(e.message || 'Hitilafu imetokea')
    } finally {
      if (mountedRef.current) { setLoading(false); setResending(false) }
    }
  }

  const verify = async () => {
    const code = otp.join('')
    if (code.length < 6) return
    setLoading(true); setError('')
    try {
      const { data, error: e } = await supabase.auth.verifyOtp({
        phone: `+255${clean}`, token: code, type: 'sms',
      })
      if (e) throw e
      const uid = data.user?.id
      if (!uid) throw new Error('Uthibitisho umeshindwa')

      const fullName = `${firstName.trim()} ${lastName.trim()}`

      // 1. Create/update user record
      await supabase.from('users').upsert({
        id: uid,
        phone: `+255${clean}`,
        email: email.trim() || null,
        name: fullName,
        user_type: 'winga',
        is_verified: true,
      }, { onConflict: 'id' })

      // 2. Create winga record
      const { error: wingaErr } = await supabase.from('wingas').insert({
        user_id: uid,
        name: fullName,
        phone: `+255${clean}`,
        email: email.trim() || null,
        specialty,
        home_location: `${area}, ${city}`,
        current_city: city,
        current_area: area,
        bio: bio.trim() || null,
        status: 'active',
        verification_status: 'verified',
        badge: 'Starter',
        is_online: true,
      })
      if (wingaErr && !wingaErr.message.includes('duplicate')) throw wingaErr

      if (!mountedRef.current) return
      Session.set(uid, 'winga')
      nav('/winga/home', { replace: true })
    } catch (e: any) {
      if (!mountedRef.current) return
      setError(e.message?.includes('Invalid') ? 'Code si sahihi.' : e.message || 'Hitilafu')
      setLoading(false)
    }
  }

  const handleOtpChange = (val: string, i: number) => {
    const digits = val.replace(/\D/g, '')
    if (digits.length > 1) {
      const next = [...otp]
      digits.split('').forEach((d, j) => { if (i + j < 6) next[i + j] = d })
      setOtp(next)
      const filled = next.join('').length
      if (filled === 6) setTimeout(verify, 100)
      return
    }
    const next = [...otp]; next[i] = digits; setOtp(next)
    if (digits && i < 5) (document.getElementById(`wotp-${i + 1}`) as HTMLInputElement)?.focus()
    else if (!digits && i > 0) (document.getElementById(`wotp-${i - 1}`) as HTMLInputElement)?.focus()
    if (next.join('').length === 6) setTimeout(verify, 100)
  }

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white, overflowY: 'hidden' }}>
      {/* Header */}
      <div style={{ background: C.primary, paddingTop: 'calc(env(safe-area-inset-top,0px) + 16px)', paddingBottom: 20, paddingLeft: 20, paddingRight: 20, flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
          <button onClick={() => step === 'personal' ? nav('/login') : step === 'work' ? setStep('personal') : setStep('work')}
            style={{ background: 'none', border: 'none', color: C.white, fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
          <div>
            <div style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: C.white }}>Jiunge kama Winga</div>
            <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.75)' }}>
              {step === 'personal' ? 'Hatua 1 / 3 — Taarifa Zako' : step === 'work' ? 'Hatua 2 / 3 — Kazi Yako' : 'Hatua 3 / 3 — Thibitisha Simu'}
            </div>
          </div>
        </div>
        {/* Progress bar */}
        <div style={{ height: 4, background: 'rgba(255,255,255,0.2)', borderRadius: 2 }}>
          <div style={{ height: '100%', background: C.gold, borderRadius: 2, width: step === 'personal' ? '33%' : step === 'work' ? '66%' : '100%', transition: 'width 0.3s ease' }} />
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', WebkitOverflowScrolling: 'touch', padding: '20px 20px 0' }}>
        {error && (
          <div style={{ background: C.errorBg, color: C.error, padding: '12px 16px', borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13, display: 'flex', gap: 8 }}>
            ⚠️ {error}
          </div>
        )}

        {/* ── STEP 1: Personal ── */}
        {step === 'personal' && (
          <>
            <div style={{ background: C.surface, borderRadius: 14, padding: '14px 16px', marginBottom: 20 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 22, marginBottom: 4 }}>👤</div>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: C.primary }}>Taarifa za Kibinafsi</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec }}>Jina lako kamili litaonekana kwa wateja</div>
            </div>
            {[
              { label: 'Jina la Kwanza *', val: firstName, set: setFirstName, placeholder: 'Ahmed', type: 'text' },
              { label: 'Jina la Mwisho *', val: lastName,  set: setLastName,  placeholder: 'Juma',  type: 'text' },
            ].map(f => <Field key={f.label} {...f} />)}
            <div style={{ marginBottom: 14 }}>
              <label style={labelStyle}>Namba ya Simu *</label>
              <div style={{ display: 'flex', gap: 8 }}>
                <div style={{ background: C.surface, border: `1px solid ${C.border}`, borderRadius: 12, padding: '14px 12px', fontFamily: 'Inter', fontWeight: 600, fontSize: 14, color: C.primary, whiteSpace: 'nowrap' }}>🇹🇿 +255</div>
                <input value={phone} onChange={e => setPhone(e.target.value)} type="tel" placeholder="712 345 678" style={inputStyle(C)} />
              </div>
            </div>
            <Field label="Barua Pepe (hiari)" val={email} set={setEmail} placeholder="ahmed@example.com" type="email" />
            <div style={{ height: 16 }} />
            <Btn label="Endelea →" onClick={() => { setError(''); setStep('work') }} disabled={!step1Valid} loading={false} />
          </>
        )}

        {/* ── STEP 2: Work ── */}
        {step === 'work' && (
          <>
            <div style={{ background: C.surface, borderRadius: 14, padding: '14px 16px', marginBottom: 20 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 22, marginBottom: 4 }}>🛍️</div>
              <div style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: 700, color: C.primary }}>Kazi yako na Eneo</div>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec }}>Wateja watakupata kulingana na taarifa hizi</div>
            </div>

            <div style={{ marginBottom: 14 }}>
              <label style={labelStyle}>Utaalamu Wako *</label>
              <select value={specialty} onChange={e => setSpecialty(e.target.value)} style={{ ...inputStyle(C), width: '100%' }}>
                <option value="">Chagua utaalamu...</option>
                {SPECIALTIES.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>

            <div style={{ marginBottom: 14 }}>
              <label style={labelStyle}>Mji / Jiji *</label>
              <select value={city} onChange={e => { setCity(e.target.value); setArea(AREAS[e.target.value]?.[0] || '') }} style={{ ...inputStyle(C), width: '100%' }}>
                {Object.keys(AREAS).map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>

            <div style={{ marginBottom: 14 }}>
              <label style={labelStyle}>Eneo / Mtaa *</label>
              <select value={area} onChange={e => setArea(e.target.value)} style={{ ...inputStyle(C), width: '100%' }}>
                {(AREAS[city] || []).map(a => <option key={a} value={a}>{a}</option>)}
              </select>
            </div>

            <div style={{ marginBottom: 14 }}>
              <label style={labelStyle}>Jielezesha (hiari)</label>
              <textarea value={bio} onChange={e => setBio(e.target.value)} rows={3} maxLength={200}
                placeholder="Ninafahamu Kariakoo vizuri sana, nimefanya kazi zaidi ya miaka 5..."
                style={{ ...inputStyle(C), width: '100%', resize: 'none', fontFamily: 'Inter' }} />
            </div>

            {/* Tier info */}
            <div style={{ border: `1px solid ${C.border}`, borderRadius: 14, padding: 16, marginBottom: 20 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 700, marginBottom: 10, color: C.primary }}>📊 Mfumo wa Ubora wa Winga</div>
              {[
                { badge: '🥉', name: 'Starter', desc: 'Unaanza mara moja — bure', color: '#FFF3E0', border: '#CD7F32' },
                { badge: '🥈', name: 'Mid', desc: '10+ safari + score 60%', color: '#F5F5F5', border: '#9E9E9E' },
                { badge: '🥇', name: 'Verified', desc: '30+ safari + score 80%', color: '#FFF8E1', border: '#F9A825' },
              ].map(t => (
                <div key={t.name} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0', borderBottom: t.name !== 'Verified' ? `1px solid ${C.border}` : 'none' }}>
                  <span style={{ fontSize: 20 }}>{t.badge}</span>
                  <div>
                    <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600 }}>{t.name}</div>
                    <div style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec }}>{t.desc}</div>
                  </div>
                </div>
              ))}
              <div style={{ marginTop: 10, background: C.surface, borderRadius: 10, padding: 10 }}>
                <div style={{ fontFamily: 'Inter', fontSize: 11, color: C.primary }}>
                  ✅ Utaanza na badge ya Starter mara moja bila malipo. Badge inaboreshwa kiotomatiki kulingana na alama za wateja.
                </div>
              </div>
            </div>
            <Btn label="Endelea — Thibitisha Simu →" onClick={() => { setError(''); sendOtp(false) }} disabled={!step2Valid} loading={loading} />
          </>
        )}

        {/* ── STEP 3: OTP ── */}
        {step === 'otp' && (
          <>
            <div style={{ textAlign: 'center', padding: '20px 0 24px' }}>
              <div style={{ fontSize: 52, marginBottom: 12 }}>📱</div>
              <div style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, marginBottom: 6 }}>Thibitisha Namba Yako</div>
              <div style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>
                Tumetuma SMS kwenda <strong style={{ color: C.primary }}>+255 {phone}</strong>
              </div>
            </div>
            <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginBottom: 20 }}>
              {otp.map((v, i) => (
                <input key={i} id={`wotp-${i}`} value={v} type="tel" inputMode="numeric" maxLength={6}
                  onChange={e => handleOtpChange(e.target.value, i)}
                  onKeyDown={e => { if (e.key === 'Backspace' && !v && i > 0) (document.getElementById(`wotp-${i-1}`) as HTMLInputElement)?.focus() }}
                  style={{ width: 48, height: 58, textAlign: 'center', fontSize: 22, fontWeight: 700, fontFamily: 'Inter', border: `2px solid ${v ? C.primary : C.border}`, borderRadius: 12, outline: 'none', background: v ? C.surface : C.white, transition: 'all 0.15s' }} />
              ))}
            </div>
            <div style={{ textAlign: 'center', marginBottom: 20 }}>
              {countdown > 0
                ? <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>Tuma tena baada ya 00:{String(countdown).padLeft(2, '0')}</span>
                : <button onClick={() => sendOtp(true)} disabled={resending}
                    style={{ background: 'none', border: 'none', color: C.primary, fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter', fontSize: 13 }}>
                    {resending ? '⏳ Inatuma...' : '🔄 Tuma Code Tena'}
                  </button>}
            </div>
            <Btn label="Thibitisha na Jiunge →" onClick={verify} disabled={otp.join('').length < 6} loading={loading} />
            <div style={{ background: C.surface, borderRadius: 12, padding: 12, marginTop: 16 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>🔒 Kamwe usishirikishe code hii na mtu yeyote.</div>
            </div>
          </>
        )}
        <div style={{ height: 40 }} />
      </div>
    </div>
  )
}

const labelStyle: React.CSSProperties = { fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 6 }
const inputStyle = (C: any): React.CSSProperties => ({
  border: `1.5px solid ${C.border}`, borderRadius: 12, padding: '13px 14px',
  fontSize: 15, fontFamily: 'Inter', outline: 'none', background: C.white, boxSizing: 'border-box',
})
function Field({ label, val, set, placeholder, type = 'text' }: { label: string; val: string; set: (v: string) => void; placeholder: string; type?: string }) {
  const C = { border: '#E5E7EB', white: '#fff' }
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={labelStyle}>{label}</label>
      <input value={val} onChange={e => set(e.target.value)} type={type} placeholder={placeholder} style={{ ...inputStyle(C), width: '100%' }} />
    </div>
  )
}
function Btn({ label, onClick, disabled, loading }: { label: string; onClick: () => void; disabled: boolean; loading: boolean }) {
  return (
    <button onClick={onClick} disabled={disabled || loading}
      style={{ width: '100%', height: 54, background: disabled ? '#9CA3AF' : '#1A5C2A', color: '#fff', border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: disabled ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
      {loading ? <><span style={{ width: 18, height: 18, border: '2px solid rgba(255,255,255,0.4)', borderTop: '2px solid white', borderRadius: 9, display: 'inline-block', animation: 'spin 1s linear infinite' }} />Inaweka...</> : label}
      <style>{`@keyframes spin{to{transform:rotate(360deg)}}`}</style>
    </button>
  )
}

// String.prototype.padLeft shim
declare global { interface String { padLeft(n: number, c: string): string } }
if (!String.prototype.padLeft) String.prototype.padLeft = function(n: number, c: string) { return String(this).padStart(n, c) }
