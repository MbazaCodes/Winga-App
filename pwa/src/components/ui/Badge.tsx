import { BADGES } from '../../lib/constants'

export function WingaBadge({ tier }: { tier: string }) {
  const cfg = BADGES[tier]
  if (!cfg) return null
  return (
    <span style={{ background: cfg.bg, color: cfg.color, padding: '3px 10px', borderRadius: 100, fontSize: 11, fontWeight: 700, fontFamily: 'Inter', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
      {cfg.emoji} {tier}
    </span>
  )
}

export function StatusBadge({ status }: { status: string }) {
  const configs: Record<string, { bg: string; color: string }> = {
    'Completed': { bg: '#E8F5E9', color: '#2E7D32' },
    'In Progress': { bg: '#E3F2FD', color: '#1565C0' },
    'Pending': { bg: '#FFF8E1', color: '#F57F17' },
    'Cancelled': { bg: '#FFEBEE', color: '#D32F2F' },
    'Searching': { bg: '#E8F5E9', color: '#1A5C2A' },
  }
  const cfg = configs[status] || { bg: '#F5F5F5', color: '#9E9E9E' }
  return (
    <span style={{ background: cfg.bg, color: cfg.color, padding: '3px 10px', borderRadius: 100, fontSize: 11, fontWeight: 600, fontFamily: 'Inter', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
      <span style={{ width: 6, height: 6, borderRadius: 3, background: cfg.color, display: 'inline-block' }} />
      {status}
    </span>
  )
}
