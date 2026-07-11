import AdminLayout from '@/components/layout/AdminLayout'
import { notifications } from '@/lib/data'
import { Bell, CheckCircle2, AlertTriangle, XCircle, Info } from 'lucide-react'

const typeConfig = {
  info: { icon: Info, color: 'text-blue-500', bg: 'bg-blue-50' },
  success: { icon: CheckCircle2, color: 'text-green-500', bg: 'bg-green-50' },
  warning: { icon: AlertTriangle, color: 'text-amber-500', bg: 'bg-amber-50' },
  error: { icon: XCircle, color: 'text-red-500', bg: 'bg-red-50' },
}

export default function NotificationsPage() {
  return (
    <AdminLayout title="Notifications" subtitle="System alerts and notifications">
      <div className="max-w-2xl">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <Bell className="w-5 h-5 text-primary" />
            <span className="text-sm font-semibold text-gray-700">{notifications.filter(n=>!n.read).length} unread notifications</span>
          </div>
          <button className="text-xs font-semibold text-primary border border-primary/20 bg-primary/5 px-3 py-1.5 rounded-lg">Mark all read</button>
        </div>
        <div className="space-y-3">
          {notifications.map(n => {
            const cfg = typeConfig[n.type]
            const Icon = cfg.icon
            return (
              <div key={n.id} className={`bg-white rounded-xl border shadow-card p-4 flex items-start gap-4 ${!n.read ? 'border-primary/20' : 'border-gray-100'}`}>
                <div className={`w-9 h-9 rounded-xl ${cfg.bg} flex items-center justify-center flex-shrink-0`}>
                  <Icon className={`w-4.5 h-4.5 ${cfg.color}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className="text-sm font-semibold text-gray-800">{n.title}</p>
                    {!n.read && <span className="w-2 h-2 bg-primary rounded-full flex-shrink-0 mt-1.5" />}
                  </div>
                  <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">{n.message}</p>
                  <p className="text-[10px] text-gray-400 mt-1.5">{n.time}</p>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </AdminLayout>
  )
}
