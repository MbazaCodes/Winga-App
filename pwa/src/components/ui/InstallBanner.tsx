import { useState, useEffect } from 'react'

// iOS install instructions banner
export default function InstallBanner() {
  const [show, setShow] = useState(false)
  const [isIOS, setIsIOS] = useState(false)

  useEffect(() => {
    const ios = /iphone|ipad|ipod/i.test(navigator.userAgent)
    const standalone = window.matchMedia('(display-mode: standalone)').matches
    const dismissed = localStorage.getItem('install_dismissed')
    setIsIOS(ios)
    if (ios && !standalone && !dismissed) {
      setTimeout(() => setShow(true), 3000)
    }
  }, [])

  if (!show) return null

  return (
    <div style={{
      position: 'fixed', bottom: 'calc(70px + env(safe-area-inset-bottom))',
      left: 16, right: 16, zIndex: 200,
      background: '#1A5C2A', color: 'white',
      borderRadius: 16, padding: '16px',
      boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
      animation: 'slideUp 0.3s ease',
    }}>
      <style>{`@keyframes slideUp { from { transform: translateY(20px); opacity:0; } to { transform: translateY(0); opacity:1; } }`}</style>
      <button onClick={() => { setShow(false); localStorage.setItem('install_dismissed', '1') }}
        style={{ position: 'absolute', top: 12, right: 12, background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white', width: 28, height: 28, borderRadius: 14, cursor: 'pointer', fontSize: 16 }}>
        ✕
      </button>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
        <span style={{ fontSize: 32 }}>📲</span>
        <div>
          <div style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 700 }}>Sakinisha Winga App</div>
          <div style={{ fontFamily: 'Inter', fontSize: 12, opacity: 0.85 }}>Ongeza kwenye Home Screen yako</div>
        </div>
      </div>
      <div style={{ background: 'rgba(255,255,255,0.15)', borderRadius: 12, padding: '10px 12px' }}>
        <Step n={1} text='Bonyeza kitufe cha "Share" (🔗) chini ya Safari' />
        <Step n={2} text='Chagua "Add to Home Screen"' />
        <Step n={3} text='Bonyeza "Add" juu kulia — imemaliza! 🎉' />
      </div>
      <div style={{ marginTop: 10, textAlign: 'center', fontSize: 11, opacity: 0.7, fontFamily: 'Inter' }}>
        Inafanya kazi kama app ya kawaida — bila kutumia data nyingi
      </div>
    </div>
  )
}

function Step({ n, text }: { n: number; text: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8, marginBottom: 6 }}>
      <span style={{ background: '#F9A825', color: '#1A5C2A', borderRadius: '50%', width: 20, height: 20, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, flexShrink: 0 }}>{n}</span>
      <span style={{ fontFamily: 'Inter', fontSize: 12, lineHeight: 1.4 }}>{text}</span>
    </div>
  )
}
