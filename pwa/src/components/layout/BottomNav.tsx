import { useNavigate, useLocation } from 'react-router-dom'
import { Session } from '../../lib/session'
import { useT } from '../../lib/i18n'

const customerTabs = [
  { path: '/home',     icon: '🏠', key: 'nav.home' },
  { path: '/explore',  icon: '🔍', key: 'nav.discover' },
  { path: '/book',     icon: null, key: 'nav.trips' },
  { path: '/messages', icon: '💬', key: 'nav.messages' },
  { path: '/profile',  icon: '👤', key: 'nav.profile' },
]
const wingaTabs = [
  { path: '/winga/home',     icon: '📊', key: 'nav.home', label: 'Dashboard' },
  { path: '/winga/requests', icon: '📋', key: 'nav.trips', label: 'Requests' },
  { path: '/book',           icon: null, key: 'nav.trips', label: 'Search' },
  { path: '/winga/earnings', icon: '💰', key: 'nav.trips', label: 'Earnings' },
  { path: '/winga/profile',  icon: '👤', key: 'nav.profile', label: 'Profile' },
]

export default function BottomNav() {
  const nav = useNavigate()
  const { pathname } = useLocation()
  const t = useT()
  const tabs = Session.isWinga() ? wingaTabs : customerTabs

  return (
    <nav style={{
      position: 'fixed', bottom: 0, left: 0, right: 0,
      height: 'calc(62px + env(safe-area-inset-bottom))',
      paddingBottom: 'env(safe-area-inset-bottom)',
      background: '#fff', borderTop: '1px solid #F3F4F6',
      display: 'flex', alignItems: 'center',
      boxShadow: '0 -2px 12px rgba(0,0,0,0.06)', zIndex: 100,
    }}>
      {tabs.map(tab => {
        const active = pathname === tab.path || (tab.path !== '/home' && tab.path !== '/winga/home' && tab.path !== '/explore' && pathname.startsWith(tab.path))
        // Centre FAB button
        if (!tab.icon) return (
          <button key={tab.path} onClick={() => nav('/book')}
            style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', background: 'none', border: 'none', cursor: 'pointer' }}>
            <div style={{
              width: 48, height: 48, borderRadius: 24,
              background: '#1A5C2A', display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 4px 12px rgba(26,92,42,0.4)', color: 'white', fontSize: 24,
            }}>+</div>
          </button>
        )
        const label = tab.label || t(tab.key)
        return (
          <button key={tab.path} onClick={() => nav(tab.path)}
            style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, background: 'none', border: 'none', cursor: 'pointer', padding: '8px 0', WebkitTapHighlightColor: 'transparent' }}>
            <span style={{ fontSize: 20 }}>{tab.icon}</span>
            <span style={{ fontSize: 10, fontWeight: active ? 600 : 400, color: active ? '#1A5C2A' : '#9CA3AF', fontFamily: 'Inter' }}>{label}</span>
          </button>
        )
      })}
    </nav>
  )
}