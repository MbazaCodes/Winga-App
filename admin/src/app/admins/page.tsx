import AdminLayout from '@/components/layout/AdminLayout'
import { Shield, UserPlus } from 'lucide-react'

const admins = [
  { name: 'Winga Support', email: 'support@winga.com', role: 'Super Admin', status: 'Active', lastLogin: 'Today 10:45 AM' },
  { name: 'Ops Manager', email: 'ops@winga.co.tz', role: 'Operations', status: 'Active', lastLogin: 'Today 09:00 AM' },
  { name: 'Finance Lead', email: 'finance@winga.co.tz', role: 'Finance', status: 'Active', lastLogin: 'Yesterday' },
  { name: 'Support Agent', email: 'support@winga.co.tz', role: 'Support', status: 'Active', lastLogin: '2 days ago' },
]

const roles = [
  { name: 'Super Admin', perms: ['All access', 'Manage admins', 'System settings'], color: 'bg-red-50 text-red-700' },
  { name: 'Operations', perms: ['Requests', 'Wingas', 'Clients'], color: 'bg-blue-50 text-blue-700' },
  { name: 'Finance', perms: ['Earnings', 'Transactions', 'Taxes', 'Reports'], color: 'bg-green-50 text-green-700' },
  { name: 'Support', perms: ['View requests', 'Notifications', 'Support tickets'], color: 'bg-purple-50 text-purple-700' },
]

export default function AdminsPage() {
  return (
    <AdminLayout title="Admins & Roles" subtitle="Manage admin users and permissions">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card">
          <div className="flex items-center justify-between p-5 border-b border-gray-100">
            <div className="flex items-center gap-2"><Shield className="w-4 h-4 text-primary" /><h2 className="text-base font-semibold text-gray-900">Admin Users</h2></div>
            <button className="flex items-center gap-1.5 text-xs font-semibold text-white bg-primary px-3 py-1.5 rounded-lg">
              <UserPlus className="w-[14px] h-[14px]" /> Add Admin
            </button>
          </div>
          <div className="divide-y divide-gray-50">
            {admins.map(a => (
              <div key={a.email} className="flex items-center gap-4 px-5 py-4 hover:bg-gray-50/60 transition-colors">
                <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-xs font-bold text-primary">{a.name.split(' ').map(n=>n[0]).join('')}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-semibold text-gray-800">{a.name}</div>
                  <div className="text-xs text-gray-400">{a.email}</div>
                </div>
                <span className="text-xs bg-primary/10 text-primary font-semibold px-2.5 py-1 rounded-lg">{a.role}</span>
                <div className="text-xs text-gray-400 hidden sm:block">{a.lastLogin}</div>
                <span className="w-2 h-2 bg-green-400 rounded-full" />
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
          <div className="p-5 border-b border-gray-100"><h2 className="text-base font-semibold text-gray-900">Roles & Permissions</h2></div>
          <div className="p-4 space-y-3">
            {roles.map(r => (
              <div key={r.name} className="border border-gray-100 rounded-xl p-3">
                <span className={`text-xs font-bold px-2 py-0.5 rounded-md ${r.color}`}>{r.name}</span>
                <ul className="mt-2 space-y-1">
                  {r.perms.map(p => <li key={p} className="text-xs text-gray-500 flex items-center gap-1.5"><span className="w-1 h-1 bg-gray-300 rounded-full" />{p}</li>)}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
