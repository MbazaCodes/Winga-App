import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

// Normalise phone: strip spaces, dashes, country code, leading zero
function cleanPhone(raw: string): string {
  return raw
    .replace(/[\s\-]/g, '')
    .replace(/^(\+?00255|\+?255|0)/, '')
}

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#ffffff',
  bg: '#f8f9fa', textSec: '#6B7280', error: '#D32F2F',
  errorBg: '#FFEBEE', border: '#E5E7EB', primarySurface: '#E8F5E9',
}

export default function LoginScreen() {
  const nav = useNavigate()
  const [phone, setPhone] = useState('')
  const [step, setStep] = useState<'phone' | 'otp'>('phone')
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [loading, setLoading] = useState(false)
  const [resending, setResending] = useState(false)
  const [error, setError] = useState('')
  const [countdown, setCountdown] = useState(0)
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const mountedRef = useRef(true)

  useEffect(() => () => {
    mountedRef.current = false
    if (timerRef.current) clearInterval(timerRef.current)
  }, [])

  const startCountdown = (seconds = 60) => {
    if (timerRef.current) clearInterval(timerRef.current)
    setCountdown(seconds)
    let c = seconds
    timerRef.current = setInterval(() => {
      c--
      if (!mountedRef.current) { clearInterval(timerRef.current!); return }
      setCountdown(c)
      if (c <= 0) clearInterval(timerRef.current!)
    }, 1000)
  }

  const sendOtp = async (isResend = false) => {
    const clean = cleanPhone(phone)
    if (clean.length < 9) return

    if (isResend) setResending(true)
    else setLoading(true)
    setError('')

    try {
      const { error: e } = await supabase.auth.signInWithOtp({ phone: `+255${clean}` })
      if (e) throw e
      if (!mountedRef.current) return
      if (!isResend) setStep('otp')
      startCountdown(60)
    } catch (e: any) {
      if (!mountedRef.current) return
      setError(e.message || 'Hitilafu imetokea. Jaribu tena.')
    } finally {
      if (mountedRef.current) {
        setLoading(false)
        setResending(false)
      }
    }
  }

  const verifyOtp = async () => {
    const code = otp.join('')
    if (code.length < 6) return
    setLoading(true)
    setError('')

    try {
      const clean = cleanPhone(phone)
      const { data, error: e } = await supabase.auth.verifyOtp({
        phone: `+255${clean}`,
        token: code,
        type: 'sms',
      })
      if (e) throw e

      const uid = data.user?.id
      if (!uid) throw new Error('Uthibitisho umeshindwa')

      // Check or create user record
      const { data: existing } = await supabase
        .from('users')
        .select('user_type')
        .eq('id', uid)
        .maybeSingle()

      let userType = existing?.user_type ?? 'customer'

      if (!existing) {
        // New user — auto-create customer record
        await supabase.from('users').insert({
          id: uid,
          phone: `+255${clean}`,
          user_type: 'customer',
          is_verified: true,
          name: 'Mteja Mpya',
        })
        userType = 'customer'
      }

      if (!mountedRef.current) return
      Session.set(uid, userType === 'winga' ? 'winga' : 'customer')
      nav(userType === 'winga' ? '/winga/home' : '/home', { replace: true })
    } catch (e: any) {
      if (!mountedRef.current) return
      setError(
        e.message?.includes('expired') ? 'Code imeisha muda. Tuma tena.' :
        e.message?.includes('Invalid') ? 'Code si sahihi. Jaribu tena.' :
        'Hitilafu imetokea. Jaribu tena.'
      )
      setLoading(false)
    }
  }

  const handleOtpChange = (val: string, i: number) => {
    const digit = val.replace(/\D/, '')
    // Handle paste of full 6-digit code
    if (digit.length > 1) {
      const digits = digit.slice(0, 6).split('')
      const next = [...otp]
      digits.forEach((d, j) => { if (i + j < 6) next[i + j] = d })
      setOtp(next)
      if (next.join('').length === 6) setTimeout(verifyOtp, 100)
      return
    }
    const next = [...otp]
    next[i] = digit
    setOtp(next)
    if (digit && i < 5) {
      ;(document.getElementById(`otp-${i + 1}`) as HTMLInputElement)?.focus()
    } else if (!digit && i > 0) {
      ;(document.getElementById(`otp-${i - 1}`) as HTMLInputElement)?.focus()
    }
    if (next.join('').length === 6) setTimeout(verifyOtp, 100)
  }

  const clean = cleanPhone(phone)
  const canContinue = clean.length >= 9

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white }}>
      {/* Green header */}
      <div style={{
        background: C.primary,
        padding: 'calc(env(safe-area-inset-top, 0px) + 36px) 28px 36px',
        textAlign: 'center',
      }}>
        <div style={{ fontSize: 44, marginBottom: 6 }}>📍</div>
        <div style={{ fontFamily: 'Inter', fontSize: 28, fontWeight: 800, color: C.white, letterSpacing: 3 }}>
          WINGA
        </div>
        <div style={{ fontFamily: 'Inter', fontSize: 11, fontWeight: 600, color: C.gold, letterSpacing: 5, marginBottom: 6 }}>
          APP
        </div>
        <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(255,255,255,0.8)' }}>
          Mwongozo Wako wa Ununuzi Tanzania
        </div>
      </div>

      {/* Form area */}
      <div style={{ flex: 1, padding: '28px 24px', overflowY: 'auto', WebkitOverflowScrolling: 'touch' }}>
        {step === 'phone' ? (
          <>
            <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: C.primary, marginBottom: 4 }}>
              Karibu! 👋
            </h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 24 }}>
              Ingiza namba yako — tutatuma code ya OTP bure
            </p>

            {error && (
              <div style={{ background: C.errorBg, color: C.error, padding: '12px 16px', borderRadius: 12, marginBottom: 16, fontSize: 13, fontFamily: 'Inter', display: 'flex', gap: 8, alignItems: 'flex-start' }}>
                <span>⚠️</span><span>{error}</span>
              </div>
            )}

            <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>
              Namba ya Simu *
            </label>
            <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
              <div style={{
                background: C.primarySurface, border: `1px solid ${C.border}`,
                borderRadius: 12, padding: '0 14px',
                display: 'flex', alignItems: 'center', gap: 6,
                fontFamily: 'Inter', fontWeight: 600, fontSize: 14, color: C.primary,
                whiteSpace: 'nowrap',
              }}>
                🇹🇿 +255
              </div>
              <input
                value={phone}
                onChange={e => { setPhone(e.target.value); setError('') }}
                type="tel"
                placeholder="712 345 678"
                onKeyDown={e => e.key === 'Enter' && canContinue && sendOtp()}
                style={{
                  flex: 1, border: `1.5px solid ${error ? C.error : C.border}`,
                  borderRadius: 12, padding: '14px 16px',
                  fontSize: 16, fontFamily: 'Inter', outline: 'none',
                  background: C.white,
                }}
              />
            </div>
            <p style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginBottom: 20 }}>
              Mfano: 712 345 678 (bila +255)
            </p>

            <button
              onClick={() => sendOtp(false)}
              disabled={loading || !canContinue}
              style={{
                width: '100%', height: 54, background: canContinue ? C.primary : '#9CA3AF',
                color: C.white, border: 'none', borderRadius: 14,
                fontFamily: 'Inter', fontSize: 16, fontWeight: 600,
                cursor: canContinue ? 'pointer' : 'not-allowed',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                marginBottom: 20,
              }}
            >
              {loading ? '⏳ Inatuma SMS...' : 'Pata Code ya OTP →'}
            </button>

            <div style={{ background: C.primarySurface, borderRadius: 12, padding: 12, marginBottom: 24, display: 'flex', gap: 8, alignItems: 'flex-start' }}>
              <span style={{ fontSize: 14 }}>🔒</span>
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>
                SMS ya OTP ni ya bure na salama kabisa. Huhitaji nenosiri.
              </span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, textAlign: 'center' }}>
              <button onClick={() => nav('/winga-register')}
                style={{ background: 'none', border: 'none', fontFamily: 'Inter', fontSize: 14, color: C.textSec, cursor: 'pointer' }}>
                Ungependa kuwa Winga?{' '}
                <span style={{ color: C.primary, fontWeight: 600 }}>Jiunge hapa →</span>
              </button>
            </div>
          </>
        ) : (
          <>
            <button onClick={() => { setStep('phone'); setOtp(['','','','','','']); setError('') }}
              style={{ background: 'none', border: 'none', fontSize: 22, cursor: 'pointer', marginBottom: 16, padding: 0 }}>
              ←
            </button>

            <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 6 }}>
              Ingiza Code ya OTP
            </h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 28 }}>
              Tumetuma SMS kwenda{' '}
              <strong style={{ color: C.primary }}>+255 {phone}</strong>
            </p>

            {error && (
              <div style={{ background: C.errorBg, color: C.error, padding: '12px', borderRadius: 12, marginBottom: 16, fontSize: 13, fontFamily: 'Inter', display: 'flex', gap: 8 }}>
                <span>⚠️</span><span>{error}</span>
              </div>
            )}

            {/* OTP boxes */}
            <div style={{ display: 'flex', gap: 8, marginBottom: 20, justifyContent: 'center' }}>
              {otp.map((v, i) => (
                <input
                  key={i}
                  id={`otp-${i}`}
                  value={v}
                  type="tel"
                  inputMode="numeric"
                  maxLength={6}
                  onChange={e => handleOtpChange(e.target.value, i)}
                  onKeyDown={e => {
                    if (e.key === 'Backspace' && !v && i > 0) {
                      ;(document.getElementById(`otp-${i - 1}`) as HTMLInputElement)?.focus()
                    }
                  }}
                  style={{
                    width: 48, height: 58, textAlign: 'center',
                    fontSize: 22, fontWeight: 700, fontFamily: 'Inter',
                    border: `2px solid ${error ? C.error : v ? C.primary : C.border}`,
                    borderRadius: 12, outline: 'none',
                    background: v ? C.primarySurface : C.white,
                    transition: 'border-color 0.15s, background 0.15s',
                  }}
                />
              ))}
            </div>

            {/* Countdown / Resend */}
            <div style={{ textAlign: 'center', marginBottom: 20 }}>
              {countdown > 0 ? (
                <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>
                  Tuma tena baada ya 00:{String(countdown).padStart(2, '0')}
                </span>
              ) : (
                <button
                  onClick={() => sendOtp(true)}
                  disabled={resending}
                  style={{ background: 'none', border: 'none', color: C.primary, fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter', fontSize: 13 }}
                >
                  {resending ? '⏳ Inatuma...' : '🔄 Tuma Code Tena'}
                </button>
              )}
            </div>

            <button
              onClick={verifyOtp}
              disabled={loading || otp.join('').length < 6}
              style={{
                width: '100%', height: 54,
                background: otp.join('').length === 6 ? C.primary : '#9CA3AF',
                color: C.white, border: 'none', borderRadius: 14,
                fontFamily: 'Inter', fontSize: 16, fontWeight: 600,
                cursor: otp.join('').length === 6 ? 'pointer' : 'not-allowed',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              }}
            >
              {loading ? (
                <>
                  <span style={{ width: 18, height: 18, border: '2px solid rgba(255,255,255,0.4)', borderTop: '2px solid white', borderRadius: 9, display: 'inline-block', animation: 'spin 1s linear infinite' }} />
                  Inathibitisha...
                </>
              ) : 'Thibitisha na Endelea →'}
            </button>

            <div style={{ background: C.primarySurface, borderRadius: 12, padding: 12, marginTop: 20, display: 'flex', gap: 8, alignItems: 'flex-start' }}>
              <span>🔒</span>
              <span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>
                Kamwe usishirikishe code hii na mtu yeyote, hata wafanyakazi wa Winga.
              </span>
            </div>

            <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
          </>
        )}
      </div>
    </div>
  )
}
