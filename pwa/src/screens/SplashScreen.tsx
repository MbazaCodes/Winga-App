import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Session } from '../lib/session'

export default function SplashScreen() {
  const nav = useNavigate()

  useEffect(() => {
    const timer = setTimeout(() => {
      if (Session.isLoggedIn()) {
        nav(Session.isWinga() ? '/winga/home' : '/home', { replace: true })
      } else if (Session.isOnboarded()) {
        nav('/login', { replace: true })
      } else {
        nav('/onboarding', { replace: true })
      }
    }, 2000)
    return () => clearTimeout(timer)
  }, [nav])

  return (
    <div style={{ height: '100dvh', background: '#1A5C2A', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 16 }}>
      <div style={{ width: 100, height: 100, borderRadius: 50, background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 50 }}>
        📍
      </div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontFamily: 'Inter', fontSize: 40, fontWeight: 800, color: '#fff', letterSpacing: 4 }}>WINGA</div>
        <div style={{ fontFamily: 'Inter', fontSize: 13, fontWeight: 600, color: '#F9A825', letterSpacing: 6 }}>APP</div>
      </div>
      <div style={{ marginTop: 32, width: 36, height: 36, border: '3px solid rgba(255,255,255,0.3)', borderTop: '3px solid white', borderRadius: 18, animation: 'spin 1s linear infinite' }} />
      <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
    </div>
  )
}
