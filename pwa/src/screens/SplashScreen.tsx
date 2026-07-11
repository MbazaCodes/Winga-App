import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

export default function SplashScreen() {
  const nav = useNavigate()

  useEffect(() => {
    let mounted = true

    const run = async () => {
      await new Promise(r => setTimeout(r, 1800)) // minimum splash
      if (!mounted) return

      try {
        // 1. Check real Supabase session (survives app close/reopen)
        const { data: { session } } = await supabase.auth.getSession()

        if (!mounted) return

        if (session?.user?.id) {
          // Fetch user type from our table
          const { data: user } = await supabase
            .from('users')
            .select('user_type')
            .eq('id', session.user.id)
            .maybeSingle()

          const type = user?.user_type === 'winga' ? 'winga' : 'customer'
          Session.set(session.user.id, type)

          nav(type === 'winga' ? '/winga/home' : '/home', { replace: true })
          return
        }
      } catch {
        // Supabase unreachable — fall through to localStorage check
      }

      if (!mounted) return

      // 2. Fall back to localStorage (offline / fast re-open)
      if (Session.isLoggedIn()) {
        nav(Session.isWinga() ? '/winga/home' : '/home', { replace: true })
        return
      }

      // 3. New user
      nav(Session.isOnboarded() ? '/login' : '/onboarding', { replace: true })
    }

    run()
    return () => { mounted = false }
  }, [nav])

  return (
    <div style={{
      height: '100dvh', background: '#1A5C2A',
      display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', gap: 16
    }}>
      {/* Logo mark */}
      <div style={{
        width: 100, height: 100, borderRadius: 50,
        background: 'rgba(255,255,255,0.15)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        position: 'relative'
      }}>
        <span style={{ fontSize: 52 }}>📍</span>
        <span style={{
          position: 'absolute', top: 18, fontSize: 24
        }}>⭐</span>
      </div>

      {/* Wordmark */}
      <div style={{ textAlign: 'center' }}>
        <div style={{
          fontFamily: 'Inter', fontSize: 40, fontWeight: 800,
          color: '#fff', letterSpacing: 5
        }}>WINGA</div>
        <div style={{
          fontFamily: 'Inter', fontSize: 12, fontWeight: 600,
          color: '#F9A825', letterSpacing: 6
        }}>APP</div>
      </div>

      {/* Spinner */}
      <div style={{
        marginTop: 32, width: 32, height: 32,
        border: '3px solid rgba(255,255,255,0.3)',
        borderTop: '3px solid white',
        borderRadius: 16,
        animation: 'spin 1s linear infinite'
      }} />

      <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
    </div>
  )
}
