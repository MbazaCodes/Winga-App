import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import { useT } from '../lib/i18n'

function cleanPhone(raw: string): string {
  return raw.replace(/[\s\-]/g, '').replace(/^(\+?00255|\+?255|0)/, '')
}

// A name is "real" if it's set, non-empty, and not a placeholder
function isPlaceholderName(name: string | null | undefined): boolean {
  if (!name) return true
  const n = name.trim().toLowerCase()
  return n === '' || n === 'mteja' || n === 'mteja mpya' || n === 'customer' || n === 'user'
}

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#ffffff',
  textSec: '#6B7280', error: '#D32F2F', errorBg: '#FFEBEE',
  border: '#E5E7EB', primarySurface: '#E8F5E9',
}

type Step = 'phone' | 'otp' | 'name'
type LoginMethod = 'phone' | 'winga_id'

export default function LoginScreen() {
  const nav = useNavigate()
  const t = useT()
  const [step, setStep] = useState<Step>('phone')
  const [method, setMethod] = useState<LoginMethod>('phone')
  const [phone, setPhone] = useState('')
  const [wingaIdInput, setWingaIdInput] = useState('')
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [newName, setNewName] = useState('')
  const [pendingUid, setPendingUid] = useState('')
  const [loading, setLoading] = useState(false)
  const [resending, setResending] = useState(false)
  const [error, setError] = useState('')
  const [countdown, setCountdown] = useState(0)
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const mounted = useRef(true)

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

  // ── Winga ID Login Flow ──────────────────────────────
  const loginWithWingaId = async () => {
    const wid = wingaIdInput.trim().toUpperCase()
    if (!wid || wid.length < 5) return
    setLoading(true); setError('')
    try {
      // Look up phone via RPC
      const { data, error: rpcErr } = await supabase.rpc('lookup_winga_by_id', { p_winga_id: wid })
      if (rpcErr) throw rpcErr
      if (!data?.found) {
        setError(t('login.wingaIdNotFound', { id: wid }))
        setLoading(false)
        return
      }

      // Extract phone from lookup result
      const lookupPhone = data.phone as string
      // Use the looked-up phone to send OTP
      setPhone(lookupPhone.replace('+255', ''))
      setMethod('phone')

      // Send OTP to the looked-up phone
      const { error: otpErr } = await supabase.auth.signInWithOtp({ phone: lookupPhone })
      if (otpErr) throw otpErr
      if (!mounted.current) return
      setStep('otp')
      startCountdown()
      setLoading(false)
    } catch (e: any) {
      if (mounted.current) setError(e.message || `${t('common.errorOccurred')} ${t('common.tryAgain')}`)
      setLoading(false)
    }
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
      if (mounted.current) setError(e.message || `${t('common.errorOccurred')} ${t('common.tryAgain')}`)
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
      if (!uid) throw new Error(t('login.codeExpired'))

      const { data: existing } = await supabase
        .from('users').select('user_type, name').eq('id', uid).maybeSingle()

      if (!mounted.current) return

      if (!existing) {
        // Brand new user — create record + ask name
        await supabase.from('users').insert({
          id: uid, phone: `+255${clean}`,
          user_type: 'customer', is_verified: true, name: '',
        })
        Session.set(uid, 'customer')
        setPendingUid(uid)
        setStep('name')
        setLoading(false)
        return
      }

      // Existing user — check if they still have a placeholder name
      if (isPlaceholderName(existing.name)) {
        Session.set(uid, existing.user_type === 'winga' ? 'winga' : 'customer')
        setPendingUid(uid)
        setStep('name')
        setLoading(false)
        return
      }

      // Fully registered user — route by type
      Session.set(uid, existing.user_type === 'winga' ? 'winga' : 'customer')
      nav(existing.user_type === 'winga' ? '/winga/home' : '/home', { replace: true })
    } catch (e: any) {
      if (!mounted.current) return
      setError(
        e.message?.includes('expired') ? t('login.codeExpired') :
        e.message?.includes('Invalid') ? t('login.codeInvalid') :
        `${t('common.errorOccurred')} ${t('common.tryAgain')}`
      )
      setLoading(false)
    }
  }

  const saveName = async () => {
    const name = newName.trim()
    const uid = pendingUid || Session.uid() || ''
    if (name.length >= 2 && uid) {
      try {
        await supabase.from('users').update({ name }).eq('id', uid)
      } catch {}
    }
    const type = Session.type()
    nav(type === 'winga' ? '/winga/home' : '/home', { replace: true })
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
    if (digits && i < 5) (document.getElementById(`otp-${i + 1}`) as HTMLInputElement)?.focus()
    else if (!digits && i > 0) (document.getElementById(`otp-${i - 1}`) as HTMLInputElement)?.focus()
    if (next.join('').length === 6) setTimeout(verifyOtp, 100)
  }

  const wingaIdValid = wingaIdInput.trim().length >= 5

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: C.white }}>
      {/* Header */}
      <div style={{ background: C.primary, padding: 'calc(env(safe-area-inset-top,0px) + 28px) 28px 28px', textAlign: 'center', flexShrink: 0 }}>
        <div style={{ width: 90, height: 90, margin: '0 auto 8px', borderRadius: 20, background: 'rgba(255,255,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 6 }}>
          <img src="/winga-logo.png" alt="Winga" style={{ width: '100%', height: '100%', objectFit: 'contain' }}
            onError={(e) => { const t2 = e.target as HTMLImageElement; t2.style.display = 'none'; t2.parentElement!.innerHTML = '<span style="font-size:40px">📍</span>'; }} />
        </div>
        <div style={{ fontFamily: 'Inter', fontSize: 26, fontWeight: 800, color: C.white, letterSpacing: 3 }}>WINGA</div>
        <div style={{ fontFamily: 'Inter', fontSize: 11, fontWeight: 600, color: C.gold, letterSpacing: 5 }}>APP</div>
        <div style={{ fontFamily: 'Inter', fontSize: 12, color: 'rgba(255,255,255,0.8)', marginTop: 4 }}>{t('login.tagline')}</div>
      </div>

      {/* ── PHONE ── */}
      {step === 'phone' && (
        <div style={{ flex: 1, padding: '24px 24px', overflowY: 'auto' }}>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, color: C.primary, marginBottom: 4 }}>{t('login.welcome')} 👋</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec, marginBottom: 16 }}>{t('login.subtitle')}</p>

          {/* Method tabs */}
          <div style={{ display: 'flex', gap: 0, marginBottom: 20, background: '#F3F4F6', borderRadius: 12, padding: 4 }}>
            <button
              onClick={() => setMethod('phone')}
              style={{
                flex: 1, height: 42, border: 'none', borderRadius: 10,
                background: method === 'phone' ? C.primary : 'transparent',
                color: method === 'phone' ? '#fff' : C.textSec,
                fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer',
                transition: 'all 0.2s',
              }}>
              📱 {t('login.phoneNumber')}
            </button>
            <button
              onClick={() => setMethod('winga_id')}
              style={{
                flex: 1, height: 42, border: 'none', borderRadius: 10,
                background: method === 'winga_id' ? C.primary : 'transparent',
                color: method === 'winga_id' ? '#fff' : C.textSec,
                fontFamily: 'Inter', fontSize: 13, fontWeight: 600, cursor: 'pointer',
                transition: 'all 0.2s',
              }}>
              🪪 {t('login.wingaId')}
            </button>
          </div>

          {error && <div style={{ background: C.errorBg, color: C.error, padding: 12, borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13 }}>⚠️ {error}</div>}

          {/* ── Phone input ── */}
          {method === 'phone' && (
            <>
              <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>{t('login.phoneNumber')} *</label>
              <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
                <div style={{ background: C.primarySurface, border: `1px solid ${C.border}`, borderRadius: 12, padding: '13px 12px', fontFamily: 'Inter', fontWeight: 600, fontSize: 14, color: C.primary, whiteSpace: 'nowrap' }}>🇹🇿 +255</div>
                <input value={phone} onChange={e => { setPhone(e.target.value); setError('') }}
                  type="tel" placeholder="712 345 678"
                  onKeyDown={e => e.key === 'Enter' && clean.length >= 9 && sendOtp()}
                  style={{ flex: 1, border: `1.5px solid ${C.border}`, borderRadius: 12, padding: '13px 14px', fontSize: 16, fontFamily: 'Inter', outline: 'none' }} />
              </div>
              <p style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginBottom: 20 }}>{t('login.phoneHint')}</p>
              <button onClick={() => sendOtp()} disabled={loading || clean.length < 9}
                style={{ width: '100%', height: 52, background: clean.length >= 9 ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: clean.length >= 9 ? 'pointer' : 'not-allowed', marginBottom: 16 }}>
                {loading ? `⏳ ${t('login.sending')}` : `${t('login.getOtp')} →`}
              </button>
            </>
          )}

          {/* ── Winga ID input ── */}
          {method === 'winga_id' && (
            <>
              <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>{t('login.wingaId')} *</label>
              <input
                value={wingaIdInput}
                onChange={e => { setWingaIdInput(e.target.value.toUpperCase()); setError('') }}
                type="text"
                placeholder="Mfano: WNGA01001"
                onKeyDown={e => e.key === 'Enter' && wingaIdValid && loginWithWingaId()}
                style={{
                  width: '100%', border: `1.5px solid ${wingaIdValid ? C.primary : C.border}`,
                  borderRadius: 12, padding: '14px 16px', fontSize: 20,
                  fontFamily: 'monospace', fontWeight: 700, letterSpacing: 3,
                  outline: 'none', marginBottom: 8, textTransform: 'uppercase',
                  transition: 'border-color 0.2s',
                }}
              />
              <p style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, marginBottom: 20 }}>
                {t('login.wingaIdHint')}
              </p>
              <button onClick={loginWithWingaId} disabled={loading || !wingaIdValid}
                style={{ width: '100%', height: 52, background: wingaIdValid ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: wingaIdValid ? 'pointer' : 'not-allowed', marginBottom: 16 }}>
                {loading ? t('login.searching') : t('login.loginWithWingaId')}
              </button>
            </>
          )}

          <div style={{ background: C.primarySurface, borderRadius: 12, padding: 12, marginBottom: 20, display: 'flex', gap: 8 }}>
            <span>🔒</span><span style={{ fontFamily: 'Inter', fontSize: 12, color: C.primary }}>{t('login.otpSafe')}</span>
          </div>
          <div style={{ textAlign: 'center' }}>
            <button onClick={() => nav('/winga-register')} style={{ background: 'none', border: 'none', fontFamily: 'Inter', fontSize: 14, color: C.textSec, cursor: 'pointer' }}>
              {t('login.wantWinga')} <span style={{ color: C.primary, fontWeight: 600 }}>{t('login.joinHere')} →</span>
            </button>
          </div>
        </div>
      )}

      {/* ── OTP ── */}
      {step === 'otp' && (
        <div style={{ flex: 1, padding: '24px', overflowY: 'auto' }}>
          <button onClick={() => { setStep('phone'); setOtp(['', '', '', '', '', '']); setError('') }}
            style={{ background: 'none', border: 'none', fontSize: 22, cursor: 'pointer', marginBottom: 16, padding: 0 }}>←</button>
          <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 6 }}>{t('login.enterOtp')}</h2>
          <p style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec, marginBottom: 24 }}>
            {t('login.sentTo')} <strong style={{ color: C.primary }}>+255 {phone}</strong>
          </p>
          {error && <div style={{ background: C.errorBg, color: C.error, padding: 12, borderRadius: 12, marginBottom: 16, fontFamily: 'Inter', fontSize: 13 }}>⚠️ {error}</div>}
          <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginBottom: 20 }}>
            {otp.map((v, i) => (
              <input key={i} id={`otp-${i}`} value={v} type="tel" inputMode="numeric" maxLength={6}
                onChange={e => handleOtpChange(e.target.value, i)}
                onKeyDown={e => { if (e.key === 'Backspace' && !v && i > 0) (document.getElementById(`otp-${i - 1}`) as HTMLInputElement)?.focus() }}
                style={{ width: 48, height: 58, textAlign: 'center', fontSize: 22, fontWeight: 700, fontFamily: 'Inter', border: `2px solid ${v ? C.primary : C.border}`, borderRadius: 12, outline: 'none', background: v ? C.primarySurface : C.white }} />
            ))}
          </div>
          <div style={{ textAlign: 'center', marginBottom: 16 }}>
            {countdown > 0
              ? <span style={{ fontFamily: 'Inter', fontSize: 13, color: C.textSec }}>{t('login.resendAfter')} 00:{String(countdown).padStart(2, '0')}</span>
              : <button onClick={() => sendOtp(true)} disabled={resending}
                style={{ background: 'none', border: 'none', color: C.primary, fontWeight: 600, cursor: 'pointer', fontFamily: 'Inter', fontSize: 13 }}>
                {resending ? '⏳...' : `🔄 ${t('login.resendCode')}`}
              </button>}
          </div>
          <button onClick={verifyOtp} disabled={loading || otp.join('').length < 6}
            style={{ width: '100%', height: 52, background: otp.join('').length === 6 ? C.primary : '#9CA3AF', color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: otp.join('').length === 6 ? 'pointer' : 'not-allowed' }}>
            {loading ? `⏳ ${t('login.verifying')}` : `${t('login.verifyContinue')} →`}
          </button>
        </div>
      )}

      {/* ── NAME (new users OR users who skipped) ── */}
      {step === 'name' && (
        <div style={{ flex: 1, padding: '32px 24px', overflowY: 'auto' }}>
          <div style={{ textAlign: 'center', marginBottom: 28 }}>
            <div style={{ fontSize: 52, marginBottom: 12 }}>🎉</div>
            <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 8 }}>
              {pendingUid ? t('login.welcomeApp') : t('login.yourName')}
            </h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec }}>
              {t('login.enterRealName')}. {t('login.wingasWillKnow')}.
            </p>
          </div>
          <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>{t('login.yourFullName')}</label>
          <input
            value={newName} onChange={e => setNewName(e.target.value)}
            type="text" autoFocus placeholder="Mfano: David Mbazza"
            onKeyDown={e => e.key === 'Enter' && newName.trim().length >= 2 && saveName()}
            style={{ width: '100%', border: `1.5px solid ${newName.trim().length >= 2 ? C.primary : C.border}`, borderRadius: 12, padding: '14px 16px', fontSize: 16, fontFamily: 'Inter', outline: 'none', marginBottom: 20, boxSizing: 'border-box' }} />
          <button onClick={saveName}
            style={{ width: '100%', height: 52, background: C.primary, color: C.white, border: 'none', borderRadius: 14, fontFamily: 'Inter', fontSize: 16, fontWeight: 600, cursor: 'pointer', marginBottom: 12 }}>
            {newName.trim().length >= 2 ? `${t('login.saveContinue')} →` : `${t('login.skipForNow')} →`}
          </button>
          <p style={{ fontFamily: 'Inter', fontSize: 12, color: C.textSec, textAlign: 'center' }}>
            {t('login.canChangeName')}
          </p>
        </div>
      )}
    </div>
  )
}