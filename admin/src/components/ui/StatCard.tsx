import { TrendingUp, TrendingDown } from 'lucide-react'
import clsx from 'clsx'

interface StatCardProps {
  label: string
  value: string | number
  change?: number
  up?: boolean
  icon: React.ReactNode
  iconBg?: string
  mini?: boolean
}

export default function StatCard({ label, value, change, up, icon, iconBg = 'bg-primary/10', mini = false }: StatCardProps) {
  return (
    <div className={clsx(
      'bg-white rounded-2xl border border-gray-100 shadow-card',
      mini ? 'p-4' : 'p-5'
    )}>
      <div className="flex items-start justify-between gap-3">
        <div className={clsx('rounded-xl flex items-center justify-center flex-shrink-0', iconBg, mini ? 'w-10 h-10' : 'w-11 h-11')}>
          {icon}
        </div>
        <div className="flex-1 min-w-0">
          <p className={clsx('text-gray-500 font-medium truncate', mini ? 'text-[11px]' : 'text-xs')}>{label}</p>
          <p className={clsx('font-bold text-gray-900 mt-0.5 leading-tight', mini ? 'text-xl' : 'text-2xl')}>{typeof value === 'number' ? value.toLocaleString() : value}</p>
          {change !== undefined && (
            <div className={clsx('flex items-center gap-1 mt-1', up ? 'text-green-600' : 'text-red-500')}>
              {up ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
              <span className="text-[11px] font-semibold">{change}% vs last week</span>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
