import { ChevronDown } from 'lucide-react'

interface SectionHeaderProps {
  title: string
  subtitle?: string
  action?: React.ReactNode
  periodSelector?: boolean
}

export function SectionHeader({ title, subtitle, action, periodSelector }: SectionHeaderProps) {
  return (
    <div className="flex items-center justify-between mb-4">
      <div>
        <h2 className="text-base font-semibold text-gray-900">{title}</h2>
        {subtitle && <p className="text-xs text-gray-500 mt-0.5">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-2">
        {periodSelector && (
          <button className="flex items-center gap-1.5 text-xs font-medium text-gray-600 bg-gray-50 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-100 transition-colors">
            This Week <ChevronDown className="w-3.5 h-3.5" />
          </button>
        )}
        {action}
      </div>
    </div>
  )
}

export function DateRangePicker() {
  return (
    <button className="flex items-center gap-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 px-3 py-2 rounded-xl hover:bg-gray-50 transition-colors shadow-sm">
      <svg className="w-4 h-4 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
      May 10 – May 16, 2026
      <ChevronDown className="w-4 h-4 text-gray-400" />
    </button>
  )
}

export function ViewAllLink({ href = '#' }: { href?: string }) {
  return (
    <a href={href} className="text-xs font-semibold text-primary hover:text-primary-dark border border-primary/20 bg-primary/5 px-3 py-1.5 rounded-lg transition-colors">
      View All
    </a>
  )
}
