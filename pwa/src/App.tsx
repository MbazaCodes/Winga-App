import { Routes, Route, Navigate } from 'react-router-dom'
import { Session } from './lib/session'
import { Suspense, lazy } from 'react'
import InstallBanner from './components/ui/InstallBanner'

// Screens
import SplashScreen from './screens/SplashScreen'
import OnboardingScreen from './screens/OnboardingScreen'
import LoginScreen from './screens/LoginScreen'
import HomeScreen from './screens/HomeScreen'

const BookingScreen     = lazy(() => import('./screens/BookingScreen'))
const RequestsScreen    = lazy(() => import('./screens/RequestsScreen'))
const EarningsScreen    = lazy(() => import('./screens/EarningsScreen'))
const ProfileScreen     = lazy(() => import('./screens/ProfileScreen'))
const WingaHomeScreen   = lazy(() => import('./screens/WingaHomeScreen'))
const WingaEarningsScreen = lazy(() => import('./screens/WingaEarningsScreen'))
const WingaProfileScreen  = lazy(() => import('./screens/WingaProfileScreen'))

// Auth guard
function PrivateRoute({ children }: { children: React.ReactNode }) {
  return Session.isLoggedIn() ? <>{children}</> : <Navigate to="/login" replace />
}

function WingaRoute({ children }: { children: React.ReactNode }) {
  if (!Session.isLoggedIn()) return <Navigate to="/login" replace />
  if (!Session.isWinga()) return <Navigate to="/home" replace />
  return <>{children}</>
}

const Loader = () => (
  <div style={{ height: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1A5C2A' }}>
    <div style={{ width: 40, height: 40, border: '3px solid rgba(255,255,255,0.3)', borderTop: '3px solid white', borderRadius: 20, animation: 'spin 1s linear infinite' }} />
    <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
  </div>
)

export default function App() {
  return (
    <>
      <InstallBanner />
      <Suspense fallback={<Loader />}>
        <Routes>
          {/* Public */}
          <Route path="/"           element={<SplashScreen />} />
          <Route path="/onboarding" element={<OnboardingScreen />} />
          <Route path="/login"      element={<LoginScreen />} />

          {/* Customer routes */}
          <Route path="/home"     element={<PrivateRoute><HomeScreen /></PrivateRoute>} />
          <Route path="/book"     element={<PrivateRoute><BookingScreen /></PrivateRoute>} />
          <Route path="/requests" element={<PrivateRoute><RequestsScreen /></PrivateRoute>} />
          <Route path="/earnings" element={<PrivateRoute><EarningsScreen /></PrivateRoute>} />
          <Route path="/profile"  element={<PrivateRoute><ProfileScreen /></PrivateRoute>} />

          {/* Winga partner routes */}
          <Route path="/winga/home"     element={<WingaRoute><WingaHomeScreen /></WingaRoute>} />
          <Route path="/winga/requests" element={<WingaRoute><RequestsScreen /></WingaRoute>} />
          <Route path="/winga/earnings" element={<WingaRoute><WingaEarningsScreen /></WingaRoute>} />
          <Route path="/winga/profile"  element={<WingaRoute><WingaProfileScreen /></WingaRoute>} />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
    </>
  )
}
