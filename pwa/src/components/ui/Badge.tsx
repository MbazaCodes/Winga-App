import { BADGES } from '../../lib/constants'

export function WingaBadge({ tier, badge }: { tier?: string; badge?: string }) {
  const key = tier || badge || ''
  const cfg = BADGES[key]
  if (!cfg) return null
  return (
    <span style={{
      background: cfg.bg, color: cfg.color,
      padding: '3px 10px', borderRadius: 100,
      fontSize: 11, fontWeight: 700, fontFamily: 'Inter',
      display: 'inline-flex', alignItems: 'center', gap: 4,
      whiteSpace: 'nowrap',
    }}>
      {cfg.emoji} {key}
    </span>
  )
}

export function StatusBadge({ status }: { status: string }) {
  const configs: Record<string, { bg: string; color: string; label: string }> = {
    searching:    { bg: '#E8F5E9', color: '#1A5C2A',  label: 'Inatafuta' },
    accepted:     { bg: '#E3F2FD', color: '#1565C0',  label: 'Imekubaliwa' },
    shopping:     { bg: '#FFF8E1', color: '#F57F17',  label: 'Inanunua' },
    completed:    { bg: '#E8F5E9', color: '#2E7D32',  label: 'Imekamilika' },
    cancelled:    { bg: '#FFEBEE', color: '#D32F2F',  label: 'Imefutwa' },
    pending:      { bg: '#FFF8E1', color: '#F57F17',  label: 'Inasubiri' },
    under_review: { bg: '#EDE7F6', color: '#4527A0',  label: 'Inakaguliwa' },
  }
  const cfg = configs[status.toLowerCase()] || { bg: '#F5F5F5', color: '#9E9E9E', label: status }
  return (
    <span style={{
      background: cfg.bg, color: cfg.color,
      padding: '3px 10px', borderRadius: 100,
      fontSize: 11, fontWeight: 600, fontFamily: 'Inter',
      display: 'inline-flex', alignItems: 'center', gap: 4,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 3, background: cfg.color, display: 'inline-block' }} />
      {cfg.label}
    </span>
  )
}
