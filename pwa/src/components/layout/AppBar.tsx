import { useNavigate } from 'react-router-dom'
import { LangToggle } from '../../lib/i18n'

interface AppBarProps {
  title: string
  back?: boolean
  action?: React.ReactNode
  transparent?: boolean
}

export default function AppBar({ title, back, action, transparent }: AppBarProps) {
  const nav = useNavigate()
  return (
    <header style={{
      position: 'sticky', top: 0, zIndex: 50,
      background: transparent ? 'transparent' : '#fff',
      borderBottom: transparent ? 'none' : '1px solid #F3F4F6',
      paddingTop: 'env(safe-area-inset-top)',
      display: 'flex', alignItems: 'center',
      height: 'calc(56px + env(safe-area-inset-top))',
      padding: 'env(safe-area-inset-top) 16px 0',
    }}>
      {back && (
        <button onClick={() => nav(-1)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '8px', marginLeft: -8, fontSize: 20 }}>
          ←
        </button>
      )}
      <h1 style={{ flex: 1, textAlign: 'center', fontFamily: 'Inter', fontSize: 17, fontWeight: 600, color: '#1A1A1A' }}>
        {title}
      </h1>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, width: back ? 100 : 60, justifyContent: 'flex-end' }}>
        {action}
        <LangToggle />
      </div>
    </header>
  )
}