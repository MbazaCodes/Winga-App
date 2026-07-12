import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

function cleanPhone(raw: string): string {
  return raw.replace(/[\s\-]/g, '').replace(/^(\+?00255|\+?255|0)/, '')
}

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#ffffff',
  textSec: '#6B7280', error: '#D32F2F', errorBg: '#FFEBEE',
  border: '#E5E7EB', primarySurface: '#E8F5E9',
}

type Step = 'phone' | 'otp' | 'name'

export default function LoginScreen() {
  const nav = useNavigate()
  const [step, setStep]           = useState<Step>('phone')
  const [phone, setPhone]         = useState('')
  const [otp, setOtp]             = useState(['', '', '', '', '', ''])
  const [newName, setNewName]     = useState('')
  const [newUserId, setNewUserId] = useState('')
  const [loading, setLoading]     = useState(false)
  const [resending, setResending] = useState(false)
  const [error, setError]         = useState('')
  const [countdown, setCountdown] = useState(0)
  const timerRef  = useRef<ReturnType<typeof setInterval> | null>(null)
  const mounted   = useRef(true)

  useEffect(() => () => {
    mounted.current = false
    if (timerRef.current) clearInterval(timerRef.current)
  }, [])

  const clean = cleanPhone(phone)

  const startCountdown = (s = 60) => {
    if (timerRef.current) clearInterval(timerRef.current)
    setCountdown(s); let c = s
    timerRef.current = setInterval(() => {
      c--
      if (!mounted.current) { clearInterval(timerRef.current!); return }
      setCountdown(c)
      if (c <= 0) clearInterval(timerRef.current!)
    }, 1000)
  }

  const sendOtp = async (isResend = false) => {
    if (isResend) setResending(true); else setLoading(true)
    setError('')
    try {
      const { error: e } = await supabase.auth.signInWithOtp({ phone: `+255${clean}` })
      if (e) throw e
      if (!mounted.current) return
      if (!isResend) setStep('otp')
      startCountdown()
    } catch (e: any) {
      if (mounted.current) setError(e.message || 'Hitilafu imetokea. Jaribu tena.')
    } finally {
      if (mounted.current) { setLoading(false); setResending(false) }
    }
  }

  const verifyOtp = async () => {
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

      // Check existing user
      const { data: existing } = await supabase
        .from('users').select('user_type, name').eq('id', uid).maybeSingle()

      if (!mounted.current) return

      if (!existing) {
        // New user — create record, then ask for name
        await supabase.from('users').insert({
          id: uid, phone: `+255${clean}`,
          user_type: 'customer', is_verified: true, name: 'Mteja',
        })
        Session.set(uid, 'customer')
        setNewUserId(uid)
        setStep('name')
        setLoading(false)
        return
      }

      // Existing user — route by type
      Session.set(uid, existing.user_type === 'winga' ? 'winga' : 'customer')
      nav(existing.user_type === 'winga' ? '/winga/home' : '/home', { replace: true })
    } catch (e: any) {
      if (!mounted.current) return
      setError(
        e.message?.includes('expired') ? 'Code imeisha muda. Tuma tena.' :
        e.message?.includes('Invalid') ? 'Code si sahihi. Jaribu tena.' :
        'Hitilafu imetokea. Jaribu tena.'
      )
      setLoading(false)
    }
  }

  const saveName = async () => {
    const name = newName.trim()
    if (name.length >= 2) {
      try { await supabase.from('users').update({ name }).eq('id', newUserId) } catch {}
    }
    nav('/home', { replace: true })
  }

  const handleOtpChange = (val: string, i: number) => {
    const digits = val.replace(/\D/g, '')
    if (digits.length > 1) {
      const next = [...otp]
      digits.split('').forEach((d, j) => { if (i + j < 6) next[i + j] = d })
      setOtp(next)
      if (next.join('').length === 6) setTimeout(verifyOtp, 100)
      return
    }
    const next = [...otp]; next[i] = digits; setOtp(next)
    if (digits && i < 5) (document.getElementById(`otp-${i+1}`) as HTMLInputElement)?.focus()
    else if (!digits && i > 0) (document.getElementById(`otp-${i-1}`) as HTMLInputElement)?.focus()
    if (next.join('').length === 6) setTimeout(verifyOtp, 100)
  }

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white }}>
      {/* Green header */}
      <div style={{ background: C.primary, padding: 'calc(env(safe-area-inset-top,0px) + 32px) 28px 32px', textAlign: 'center', flexShrink: 0 }}>
        <div style={{ fontSize: 44, marginBottom: 6 }}>📍</div>
        <div style={{ fontFamily: 'Inter', fontSize: 28, fontWeight: 800, color: C.white, letterSpacing: 3 }}>WINGA</div>
        <div style={{ fontFamily: 'Inter', fontSize: 11, fontWeight: 600, color: C.gold, letterSpacing: 5, marginBottom: 4 }}>APP</div>
        <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.8)' }}>Mwongozo Wako wa Ununuzi Tanzania</div>
      </div>

      {/* ── STEP: phone ── */}
      {step === 'phone' && (
        <div style={{ flex: 1, padding: '28px 24px', overflowY: 'auto', WebkitOverflowScrolling: 'touch' }}>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: C.primary, marginBottom: 4 }}>Karibu! 👋</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 24 }}>Ingiza namba yako — tutatuma code ya OTP bure</p>

          {error && (
            <div style={{ background: C.errorBg, color: C.error, padding: '12px 16px', borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13, display: 'flex', gap: 8 }}>
              ⚠️ {error}
            </div>
          )}

          <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>Namba ya Simu *</label>
          <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
            <div style={{ background: C.primarySurface, border: `1px solid ${C.border}`, borderRadius: 12, padding: '14px 12px', fontFamily: 'Inter', fontWeight: 600, fontSize: 14, color: C.primary, whiteSpace: 'nowrap' }}>
              🇹🇿 +255
            </div>
            <input value={phone} onChange={e => { setPhone(e.target.value); setError('') }}
              type="tel" placeholder="712 345 678"
              onKeyDown={e => e.key === 'Enter' && clean.length >= 9 && sendOtp()}
              style={{ flex: 1, border: `1.5px solid ${C.border}`, borderRadius: 12, padding: '14px 16px', fontSize: 16, fontFamily: 'Inter', outline: 'none', background: C.white }} />
          </div>
          <p style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginBottom: 20 }}>Bila +255 au 0 mwanzoni</p>

          <button onClick={() => sendOtp()} disabled={loading || clean.length < 9}
            style={{ width: '100%', height: 54, background: clean.length >= 9 ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: clean.length >= 9 ? 'pointer' : 'not-allowed', marginBottom: 16 }}>
            {loading ? '⏳ Inatuma...' : 'Pata Code ya OTP →'}
          </button>

          <div style={{ background: C.primarySurface, borderRadius: 12, padding: 12, marginBottom: 24, display: 'flex', gap: 8 }}>
            <span>🔒</span>
            <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>SMS ya OTP ni ya bure na salama kabisa.</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, textAlign: 'center' }}>
            <button onClick={() => nav('/winga-register')}
              style={{ background: 'none', border: 'none', fontFamily: 'Inter', fontSize: 14, color: C.textSec, cursor: 'pointer' }}>
              Ungependa kuwa Winga? <span style={{ color: C.primary, fontWeight: 600 }}>Jiunge hapa →</span>
            </button>
          </div>
        </div>
      )}

      {/* ── STEP: otp ── */}
      {step === 'otp' && (
        <div style={{ flex: 1, padding: '24px 24px', overflowY: 'auto' }}>
          <button onClick={() => { setStep('phone'); setOtp(['','','','','','']); setError('') }}
            style={{ background: 'none', border: 'none', fontSize: 22, cursor: 'pointer', marginBottom: 16, padding: 0 }}>←</button>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 6 }}>Ingiza Code ya OTP</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 28 }}>
            Tumetuma SMS kwenda <strong style={{ color: C.primary }}>+255 {phone}</strong>
          </p>

          {error && (
            <div style={{ background: C.errorBg, color: C.error, padding: '12px', borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13 }}>⚠️ {error}</div>
          )}

          <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginBottom: 20 }}>
            {otp.map((v, i) => (
              <input key={i} id={`otp-${i}`} value={v} type="tel" inputMode="numeric" maxLength={6}
                onChange={e => handleOtpChange(e.target.value, i)}
                onKeyDown={e => { if (e.key === 'Backspace' && !v && i > 0) (document.getElementById(`otp-${i-1}`) as HTMLInputElement)?.focus() }}
                style={{ width: 48, height: 58, textAlign: 'center', fontSize: 22, fontWeight: 700, fontFamily: 'Inter', border: `2px solid ${v ? C.primary : C.border}`, borderRadius: 12, outline: 'none', background: v ? C.primarySurface : C.white, transition: 'all 0.15s' }} />
            ))}
          </div>

          <div style={{ textAlign: 'center', marginBottom: 20 }}>
            {countdown > 0
              ? <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>Tuma tena baada ya 00:{String(countdown).padStart(2, '0')}</span>
              : <button onClick={() => sendOtp(true)} disabled={resending}
                  style={{ background: 'none', border: 'none', color: C.primary, fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter', fontSize: 13 }}>
                  {resending ? '⏳ Inatuma...' : '🔄 Tuma Code Tena'}
                </button>}
          </div>

          <button onClick={verifyOtp} disabled={loading || otp.join('').length < 6}
            style={{ width: '100%', height: 54, background: otp.join('').length === 6 ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: otp.join('').length === 6 ? 'pointer' : 'not-allowed', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
            {loading
              ? <><span style={{ width: 18, height: 18, border: '2px solid rgba(255,255,255,0.4)', borderTop: '2px solid white', borderRadius: 9, display: 'inline-block', animation: 'spin 1s linear infinite' }} />Inathibitisha...</>
              : 'Thibitisha na Endelea →'}
          </button>

          <div style={{ background: C.primarySurface, borderRadius: 12, padding: 12, marginTop: 16 }}>
            <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>🔒 Kamwe usishirikishe code hii na mtu yeyote.</span>
          </div>

          <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
        </div>
      )}

      {/* ── STEP: name (new users only) ── */}
      {step === 'name' && (
        <div style={{ flex: 1, padding: '32px 24px', overflowY: 'auto' }}>
          <div style={{ textAlign: 'center', marginBottom: 28 }}>
            <div style={{ fontSize: 56, marginBottom: 12 }}>🎉</div>
            <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 6 }}>Karibu Winga App!</h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec }}>
              Akaunti yako imetengenezwa. Ingiza jina lako halisi ili Wingas wakujue.
            </p>
          </div>

          <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>Jina Lako Kamili</label>
          <input
            value={newName}
            onChange={e => setNewName(e.target.value)}
            type="text"
            autoFocus
            placeholder="Mfano: David Mbazza"
            onKeyDown={e => e.key === 'Enter' && newName.trim().length >= 2 && saveName()}
            style={{
              width: '100%', border: `1.5px solid ${newName.trim().length >= 2 ? C.primary : C.border}`,
              borderRadius: 12, padding: '14px 16px', fontSize: 16, fontFamily: 'Inter',
              outline: 'none', marginBottom: 20, boxSizing: 'border-box',
            }}
          />

          <button onClick={saveName}
            style={{ width: '100%', height: 54, background: C.primary, color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: 'pointer', marginBottom: 12 }}>
            {newName.trim().length >= 2 ? 'Endelea →' : 'Ruka — ingiza baadaye →'}
          </button>

          <p style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec, textAlign: 'center' }}>
            Unaweza kubadilisha jina lako kwenye Wasifu wako baadaye.
          </p>
        </div>
      )}
    </div>
  )
}
