'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  LayoutDashboard, ClipboardList, Users, UserCircle,
  Wallet, CreditCard, Star, Receipt, BarChart3,
  Bell, Settings, Shield, HeadphonesIcon, LogOut,
  MapPin, Smartphone
} from 'lucide-react'
import clsx from 'clsx'

const navItems = [
  { label: 'Dashboard', href: '/', icon: LayoutDashboard },
  { label: 'Requests', href: '/requests', icon: ClipboardList },
  { label: 'Winga (Shoppers)', href: '/wingas', icon: UserCircle },
  { label: 'Clients (Users)', href: '/clients', icon: Users },
  { label: 'Earnings & Payouts', href: '/earnings', icon: Wallet },
  { label: 'Transactions', href: '/transactions', icon: CreditCard },
  { label: 'Ratings & Reviews', href: '/ratings', icon: Star },
  { label: 'Taxes', href: '/taxes', icon: Receipt },
  { label: 'Reports', href: '/reports', icon: BarChart3 },
  { label: 'Notifications', href: '/notifications', icon: Bell },
  { label: 'Settings', href: '/settings', icon: Settings },
  { label: 'Admins & Roles', href: '/admins', icon: Shield },
  { label: 'Support', href: '/support', icon: HeadphonesIcon },
]

const externalLinks = [
  { label: 'Mobile App (PWA)', href: 'https://winga-pwa.vercel.app', icon: Smartphone },
]

async function handleLogout() {
  try {
    await fetch('/api/auth/logout', { method: 'POST' })
  } finally {
    window.location.href = '/login'
  }
}

export default function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="fixed left-0 top-0 h-screen w-[210px] bg-[#1A5C2A] flex flex-col z-30 overflow-y-auto">
      {/* Logo */}
      <div className="flex items-center gap-3 px-5 py-5 border-b border-white/10">
        <div className="w-9 h-9 bg-white/15 rounded-xl flex items-center justify-center flex-shrink-0">
          <MapPin className="w-5 h-5 text-[#F9A825]" />
        </div>
        <div>
          <div className="text-white font-bold text-base tracking-wide leading-tight">Winga</div>
          <div className="text-white/50 text-[10px] font-medium tracking-widest uppercase">Admin Panel</div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 py-4 px-2">
        {navItems.map((item) => {
          const Icon = item.icon
          const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href))
          return (
            <Link
              key={item.href}
              href={item.href}
              className={clsx(
                'flex items-center gap-3 px-3 py-2.5 rounded-xl mb-0.5 transition-all duration-150 group',
                isActive
                  ? 'bg-white/15 text-white'
                  : 'text-white/60 hover:bg-white/[0.08] hover:text-white/90'
              )}
            >
              <Icon
                className={clsx(
                  'w-4 h-4 flex-shrink-0',
                  isActive ? 'text-[#F9A825]' : 'text-white/50 group-hover:text-white/80'
                )}
              />
              <span className="text-[13px] font-medium truncate">{item.label}</span>
              {item.label === 'Notifications' && (
                <span className="ml-auto bg-[#F9A825] text-[#1A5C2A] text-[9px] font-bold w-4 h-4 rounded-full flex items-center justify-center flex-shrink-0">5</span>
              )}
              {item.label === 'Winga (Shoppers)' && (
                <span className="ml-auto bg-blue-400/20 text-blue-300 text-[9px] font-bold px-1.5 py-0.5 rounded-full flex-shrink-0">1</span>
              )}
            </Link>
          )
        })}
      </nav>

      {/* External Links */}
      <div className="px-2 pb-2">
        <div className="text-[10px] text-white/30 font-semibold uppercase tracking-widest px-3 mb-2">Apps</div>
        {externalLinks.map((item) => {
          const Icon = item.icon
          return (
            <a
              key={item.href}
              href={item.href}
              className="flex items-center gap-3 px-3 py-2.5 rounded-xl mb-0.5 transition-all duration-150 group text-white/60 hover:bg-white/[0.08] hover:text-white/90"
            >
              <Icon className="w-4 h-4 flex-shrink-0 text-white/50 group-hover:text-white/80" />
              <span className="text-[13px] font-medium truncate">{item.label}</span>
            </a>
          )
        })}
      </div>

      {/* Logout */}
      <div className="px-2 py-4 border-t border-white/10">
        <button onClick={handleLogout} className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-white/50 hover:bg-red-500/15 hover:text-red-300 transition-all w-full">
          <LogOut className="w-4 h-4 flex-shrink-0" />
          <span className="text-[13px] font-medium">Logout</span>
        </button>
      </div>
    </aside>
  )
}
