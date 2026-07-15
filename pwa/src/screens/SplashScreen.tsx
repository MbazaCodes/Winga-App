import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'

const LOGO = '/winga-logo.png'

export default function SplashScreen() {
  const nav = useNavigate()
  const [phase, setPhase] = useState<'logo' | 'text' | 'glow' | 'done'>('logo')

  useEffect(() => {
    let mounted = true

    // Phase 1: Logo appears (0-0.6s)
    const t1 = setTimeout(() => { if (mounted) setPhase('text') }, 600)
    // Phase 2: Text reveals (0.6-1.2s)
    const t2 = setTimeout(() => { if (mounted) setPhase('glow') }, 1200)
    // Phase 3: Glow pulse (1.2-2.5s)
    const t3 = setTimeout(() => { if (mounted) setPhase('done') }, 2500)
    // Phase 4: Navigate
    const t4 = setTimeout(async () => {
      if (!mounted) return

      try {
        const { data: { session } } = await supabase.auth.getSession()
        if (!mounted) return

        if (session?.user?.id) {
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
        // Supabase unreachable
      }

      if (!mounted) return

      if (Session.isLoggedIn()) {
        nav(Session.isWinga() ? '/winga/home' : '/home', { replace: true })
        return
      }

      nav(Session.isOnboarded() ? '/login' : '/onboarding', { replace: true })
    }, 3000)

    return () => {
      mounted = false
      clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); clearTimeout(t4)
    }
  }, [nav])

  return (
    <div className="splash-container">
      {/* Background particles */}
      <div className="splash-particles">
        {[...Array(12)].map((_, i) => (
          <div key={i} className="splash-particle" style={{
            left: `${8 + (i * 7.5) % 84}%`,
            top: `${10 + (i * 13) % 80}%`,
            animationDelay: `${i * 0.15}s`,
            width: 4 + (i % 3) * 2,
            height: 4 + (i % 3) * 2,
          }} />
        ))}
      </div>

      {/* Radial glow behind logo */}
      <div className={`splash-glow ${phase === 'glow' || phase === 'done' ? 'active' : ''}`} />

      {/* Logo container */}
      <div className={`splash-logo-wrap ${phase !== 'logo' ? 'visible' : ''}`}>
        <div className="splash-logo-bg" />
        <img
          src={LOGO}
          alt="Winga App"
          className="splash-logo-img"
          onError={(e) => {
            const target = e.target as HTMLImageElement
            target.style.display = 'none'
            const parent = target.parentElement!
            const span = document.createElement('span')
            span.textContent = '📍'
            span.style.fontSize = '52px'
            parent.appendChild(span)
          }}
        />
      </div>

      {/* Wordmark */}
      <div className={`splash-text ${phase !== 'logo' && phase !== 'text' ? 'visible' : ''}`}>
        <div className="splash-title">
          {'WINGA'.split('').map((ch, i) => (
            <span key={i} className="splash-letter" style={{ animationDelay: `${0.6 + i * 0.08}s` }}>{ch}</span>
          ))}
        </div>
        <div className="splash-subtitle">APP</div>
        <div className={`splash-tagline ${phase === 'glow' || phase === 'done' ? 'visible' : ''}`}>
          Mwongozo Wako wa Ununuzi Tanzania
        </div>
      </div>

      {/* Loading bar */}
      <div className="splash-loader-wrap">
        <div className={`splash-loader-bar ${phase !== 'logo' ? 'active' : ''}`} />
      </div>

      <style>{`
        .splash-container {
          height: 100dvh; background: #1A5C2A;
          display: flex; flex-direction: column;
          align-items: center; justify-content: center; gap: 20px;
          position: relative; overflow: hidden;
        }

        /* ── Particles ── */
        .splash-particles {
          position: absolute; inset: 0; pointer-events: none;
        }
        .splash-particle {
          position: absolute; border-radius: 50%;
          background: rgba(255,255,255,0.12);
          animation: float-up 3s ease-in-out infinite;
        }
        @keyframes float-up {
          0%, 100% { transform: translateY(0) scale(1); opacity: 0.3; }
          50% { transform: translateY(-20px) scale(1.3); opacity: 0.7; }
        }

        /* ── Glow ── */
        .splash-glow {
          position: absolute; width: 200px; height: 200px; border-radius: 50%;
          background: radial-gradient(circle, rgba(249,168,37,0.25) 0%, transparent 70%);
          opacity: 0; transition: opacity 0.8s ease;
          pointer-events: none;
        }
        .splash-glow.active { opacity: 1; animation: glow-pulse 1.5s ease-in-out infinite; }
        @keyframes glow-pulse {
          0%, 100% { transform: scale(1); opacity: 0.6; }
          50% { transform: scale(1.4); opacity: 1; }
        }

        /* ── Logo ── */
        .splash-logo-wrap {
          width: 120px; height: 120px; position: relative;
          display: flex; align-items: center; justify: center;
          opacity: 0; transform: scale(0.3) rotate(-15deg);
          transition: all 0.7s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .splash-logo-wrap.visible { opacity: 1; transform: scale(1) rotate(0deg); }

        .splash-logo-bg {
          position: absolute; inset: 0; border-radius: 28px;
          background: rgba(255,255,255,0.1);
          border: 1px solid rgba(255,255,255,0.15);
          animation: logo-border-rotate 4s linear infinite;
        }
        @keyframes logo-border-rotate {
          0% { border-color: rgba(255,255,255,0.15); box-shadow: 0 0 0 0 rgba(249,168,37,0); }
          50% { border-color: rgba(249,168,37,0.3); box-shadow: 0 0 20px 4px rgba(249,168,37,0.15); }
          100% { border-color: rgba(255,255,255,0.15); box-shadow: 0 0 0 0 rgba(249,168,37,0); }
        }

        .splash-logo-img {
          width: 80px; height: 80px; object-fit: contain; position: relative; z-index: 1;
          filter: drop-shadow(0 4px 12px rgba(0,0,0,0.3));
        }

        /* ── Text ── */
        .splash-text {
          text-align: center; opacity: 0; transform: translateY(15px);
          transition: all 0.6s ease 0.2s;
        }
        .splash-text.visible { opacity: 1; transform: translateY(0); }

        .splash-title {
          display: flex; gap: 4px; justify-content: center;
        }
        .splash-letter {
          font-family: 'Inter', sans-serif; font-size: 42px; font-weight: 800;
          color: #fff; display: inline-block; opacity: 0; transform: translateY(20px);
          animation: letter-in 0.5s ease forwards;
        }
        @keyframes letter-in {
          to { opacity: 1; transform: translateY(0); }
        }

        .splash-subtitle {
          font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 600;
          color: #F9A825; letter-spacing: 8px; margin-top: -2px;
        }
        .splash-tagline {
          font-family: 'Inter', sans-serif; font-size: 12px;
          color: rgba(255,255,255,0.6); margin-top: 8px;
          opacity: 0; transform: translateY(8px);
          transition: all 0.5s ease;
        }
        .splash-tagline.visible { opacity: 1; transform: translateY(0); }

        /* ── Loader ── */
        .splash-loader-wrap {
          position: absolute; bottom: 60px; width: 120px; height: 3px;
          background: rgba(255,255,255,0.15); border-radius: 2px; overflow: hidden;
        }
        .splash-loader-bar {
          height: 100%; width: 0; background: linear-gradient(90deg, #F9A825, #fff);
          border-radius: 2px;
        }
        .splash-loader-bar.active {
          animation: load-fill 2s ease-in-out forwards;
        }
        @keyframes load-fill {
          0% { width: 0; }
          60% { width: 75%; }
          100% { width: 100%; }
        }
      `}</style>
    </div>
  )
}