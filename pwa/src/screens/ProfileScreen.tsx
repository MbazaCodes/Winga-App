import { useNavigate } from 'react-router-dom'
import AppBar from '../components/layout/AppBar'
import BottomNav from '../components/layout/BottomNav'

export default function ProfileScreen() {
  const nav = useNavigate()
  return (
    <div className="page">
      <AppBar title="Wasifu" back={true} />
      <div className="scroll" style={{ padding: 20 }}>
        <div style={{ textAlign: 'center', paddingTop: 60 }}>
          <div style={{ fontSize: 48, marginBottom: 16 }}>🚧</div>
          <p style={{ fontFamily: 'Inter', fontSize: 14, color: '#6B7280' }}>
            Wasifu — Coming in next update
          </p>
        </div>
      </div>
      <BottomNav />
    </div>
  )
}
