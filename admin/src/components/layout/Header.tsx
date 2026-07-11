'use client'
import { Bell, Search, ChevronDown, Menu } from 'lucide-react'

interface HeaderProps {
  title: string
  subtitle?: string
}

export default function Header({ title, subtitle }: HeaderProps) {
  return (
    <header className="h-14 bg-white border-b border-gray-100 flex items-center px-6 gap-4 sticky top-0 z-20">
      {/* Page title (shown on mobile) */}
      <button className="lg:hidden p-1.5 rounded-lg hover:bg-gray-100">
        <Menu className="w-5 h-5 text-gray-600" />
      </button>

      {/* Page heading */}
      <div className="hidden lg:block">
        <h1 className="text-base font-bold text-gray-900">{title}</h1>
        {subtitle && <p className="text-xs text-gray-500">{subtitle}</p>}
      </div>

      <div className="flex-1" />

      {/* Search */}
      <div className="relative hidden md:block">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          type="text"
          placeholder="Search anything..."
          className="pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg w-56 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40 transition-all"
        />
      </div>

      {/* Notification bell */}
      <button className="relative p-2 rounded-lg hover:bg-gray-100 transition-colors">
        <Bell className="w-5 h-5 text-gray-600" />
        <span className="absolute top-1.5 right-1.5 w-4 h-4 bg-primary text-white text-[9px] font-bold rounded-full flex items-center justify-center">5</span>
      </button>

      {/* Admin profile */}
      <button className="flex items-center gap-2.5 pl-3 pr-2 py-1.5 rounded-xl hover:bg-gray-50 border border-gray-100 transition-colors">
        <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center">
          <span className="text-xs font-bold text-primary">A</span>
        </div>
        <div className="text-left hidden sm:block">
          <div className="text-xs font-semibold text-gray-800 leading-tight">Admin</div>
          <div className="text-[10px] text-gray-500 leading-tight">Super Admin</div>
        </div>
        <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
      </button>
    </header>
  )
}
