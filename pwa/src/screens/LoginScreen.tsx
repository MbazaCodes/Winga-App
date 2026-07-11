import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

export default function LoginScreen() {
  const nav = useNavigate()
  const [phone, setPhone] = useState('')
  const [step, setStep] = useState<'phone'|'otp'>('phone')
  const [otp, setOtp] = useState(['','','','','',''])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [countdown, setCountdown] = useState(0)

  const sendOtp = async () => {
    if (phone.length < 9) return
    setLoading(true); setError('')
    try {
      const clean = phone.replace(/^(0|\+?255)/, '')
      await supabase.auth.signInWithOtp({ phone: `+255${clean}` })
      setStep('otp')
      // Start countdown
      let c = 45
      setCountdown(c)
      const t = setInterval(() => { c--; setCountdown(c); if (c <= 0) clearInterval(t) }, 1000)
    } catch (e: any) {
      setError(e.message || 'Hitilafu imetokea')
    }
    setLoading(false)
  }

  const verifyOtp = async () => {
    const code = otp.join('')
    if (code.length < 6) return
    setLoading(true); setError('')
    try {
      const clean = phone.replace(/^(0|\+?255)/, '')
      const { data, error: e } = await supabase.auth.verifyOtp({ phone: `+255${clean}`, token: code, type: 'sms' })
      if (e) throw e
      const uid = data.user?.id || ''
      // Check user type
      const { data: user } = await supabase.from('users').select('user_type').eq('id', uid).single()
      const type = user?.user_type === 'winga' ? 'winga' : 'customer'
      Session.set(uid, type)
      nav(type === 'winga' ? '/winga/home' : '/home', { replace: true })
    } catch (e: any) {
      setError('Code si sahihi. Jaribu tena.')
    }
    setLoading(false)
  }

  return (
    <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: '#fff' }}>
      {/* Green header */}
      <div style={{ background: '#1A5C2A', padding: 'calc(env(safe-area-inset-top) + 40px) 28px 40px', textAlign: 'center' }}>
        <div style={{ fontSize: 48, marginBottom: 8 }}>📍</div>
        <div style={{ fontFamily: 'Inter', fontSize: 28, fontWeight: 800, color: '#fff', letterSpacing: 3 }}>WINGA</div>
        <div style={{ fontFamily: 'Inter', fontSize: 11, fontWeight: 600, color: '#F9A825', letterSpacing: 5 }}>APP</div>
      </div>

      <div style={{ flex: 1, padding: '32px 24px', overflow: 'auto' }}>
        {step === 'phone' ? (
          <>
            <h2 style={{ fontFamily: 'Inter', fontSize: 24, fontWeight: 700, color: '#1A5C2A', marginBottom: 6 }}>Karibu! 👋</h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280', marginBottom: 28 }}>Ingia au jiunge na Winga App</p>

            {error && <div style={{ background: '#FFEBEE', color: '#D32F2F', padding: '12px 16px', borderRadius: 12, marginBottom: 16, fontSize: 13, fontFamily: 'Inter' }}>{error}</div>}

            <label style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#1A1A1A', display: 'block', marginBottom: 8 }}>Namba ya Simu</label>
            <div style={{ display: 'flex', gap: 10, marginBottom: 20 }}>
              <div style={{ background: '#F8F9FA', border: '1px solid #E5E7EB', borderRadius: 12, padding: '0 12px', display: 'flex', alignItems: 'center', gap: 6, fontSize: 14, fontFamily: 'Inter', fontWeight: 600 }}>
                🇹🇿 +255
              </div>
              <input value={phone} onChange={e => setPhone(e.target.value)} type="tel" placeholder="712 345 678"
                style={{ flex: 1, border: '1px solid #E5E7EB', borderRadius: 12, padding: '14px 16px', fontSize: 16, fontFamily: 'Inter', outline: 'none' }} />
            </div>

            <button onClick={sendOtp} disabled={loading || phone.length < 9} className="btn"
              style={{ marginBottom: 16 }}>
              {loading ? '⏳ Inatuma...' : 'Endelea →'}
            </button>

            <div style={{ textAlign: 'center', marginTop: 24, display: 'flex', flexDirection: 'column', gap: 10 }}>
              <button onClick={() => nav('/register')} style={{ background: 'none', border: 'none', fontFamily: 'Inter', fontSize: 14, color: '#6B7280', cursor: 'pointer' }}>
                Mteja mpya? <span style={{ color: '#1A5C2A', fontWeight: 600 }}>Jisajili hapa</span>
              </button>
              <button onClick={() => nav('/winga-register')} style={{ background: 'none', border: 'none', fontFamily: 'Inter', fontSize: 14, color: '#6B7280', cursor: 'pointer' }}>
                Ungependa kuwa Winga? <span style={{ color: '#1A5C2A', fontWeight: 600 }}>Jiunge hapa</span>
              </button>
            </div>
          </>
        ) : (
          <>
            <button onClick={() => setStep('phone')} style={{ background: 'none', border: 'none', fontSize: 20, cursor: 'pointer', marginBottom: 16 }}>←</button>
            <h2 style={{ fontFamily: 'Inter', fontSize: 22, fontWeight: 700, marginBottom: 8 }}>Thibitisha Namba</h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280', marginBottom: 28 }}>Tumetuma code kwenda +255 {phone}</p>

            {error && <div style={{ background: '#FFEBEE', color: '#D32F2F', padding: '12px', borderRadius: 12, marginBottom: 16, fontSize: 13, fontFamily: 'Inter' }}>{error}</div>}

            {/* OTP boxes */}
            <div style={{ display: 'flex', gap: 8, marginBottom: 20, justifyContent: 'center' }}>
              {otp.map((v, i) => (
                <input key={i} value={v} maxLength={1} type="tel"
                  onChange={e => {
                    const val = e.target.value.replace(/\D/, '')
                    const next = [...otp]; next[i] = val; setOtp(next)
                    if (val && i < 5) (document.querySelector(`#otp-${i+1}`) as HTMLInputElement)?.focus()
                  }}
                  id={`otp-${i}`}
                  style={{ width: 48, height: 56, textAlign: 'center', fontSize: 22, fontWeight: 700, border: '2px solid', borderColor: v ? '#1A5C2A' : '#E5E7EB', borderRadius: 12, fontFamily: 'Inter', outline: 'none' }} />
              ))}
            </div>

            <p style={{ textAlign: 'center', fontFamily: 'Inter', fontSize: 13, color: '#6B7280', marginBottom: 20 }}>
              {countdown > 0 ? `Resend katika 00:${String(countdown).padStart(2,'0')}` : <button onClick={sendOtp} style={{ background: 'none', border: 'none', color: '#1A5C2A', fontWeight: 600, cursor: 'pointer', fontSize: 13 }}>Tuma tena</button>}
            </p>

            <button onClick={verifyOtp} disabled={loading || otp.join('').length < 6} className="btn">
              {loading ? '⏳ Inathibitisha...' : 'Thibitisha →'}
            </button>
          </>
        )}
      </div>
    </div>
  )
}
