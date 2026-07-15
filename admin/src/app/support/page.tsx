import AdminLayout from '@/components/layout/AdminLayout'
import StatCard from '@/components/ui/StatCard'
import { HeadphonesIcon, Clock, CheckCircle, AlertCircle } from 'lucide-react'

const tickets = [
  { id: 'TKT-001', user: 'Sarah Kiprotich', type: 'Customer', issue: 'Payment not confirmed after M-Pesa deduction', priority: 'High', status: 'Open', time: '2 hours ago' },
  { id: 'TKT-002', user: 'Ahmed Juma', type: 'Winga', issue: 'Earnings not reflecting in wallet after completed trip', priority: 'High', status: 'In Progress', time: '4 hours ago' },
  { id: 'TKT-003', user: 'John Mwangi', type: 'Customer', issue: 'Winga cancelled without notice — request for refund', priority: 'Medium', status: 'Open', time: '6 hours ago' },
  { id: 'TKT-004', user: 'Bakari Said', type: 'Winga', issue: 'Unable to upload verification documents', priority: 'Low', status: 'Resolved', time: '1 day ago' },
  { id: 'TKT-005', user: 'Amina Hassan', type: 'Customer', issue: 'App crashes on OTP screen', priority: 'Medium', status: 'In Progress', time: '1 day ago' },
]

const priorityColors: Record<string, string> = {
  High: 'bg-red-50 text-red-600',
  Medium: 'bg-amber-50 text-amber-600',
  Low: 'bg-blue-50 text-blue-600',
}

const statusColors: Record<string, string> = {
  Open: 'bg-red-50 text-red-600',
  'In Progress': 'bg-blue-50 text-blue-600',
  Resolved: 'bg-green-50 text-green-600',
}

export default function SupportPage() {
  return (
    <AdminLayout title="Support" subtitle="Customer and Winga support tickets">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Open Tickets" value={3} icon={<AlertCircle className="w-5 h-5 text-red-400" />} iconBg="bg-red-50" mini />
        <StatCard label="In Progress" value={2} icon={<Clock className="w-5 h-5 text-blue-500" />} iconBg="bg-blue-50" mini />
        <StatCard label="Resolved Today" value={8} change={14.2} up icon={<CheckCircle className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Avg Response Time" value="42 min" icon={<HeadphonesIcon className="w-5 h-5 text-primary" />} mini />
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="flex items-center justify-between p-5 border-b border-gray-100">
          <div className="flex items-center gap-2">
            <HeadphonesIcon className="w-4 h-4 text-primary" />
            <h2 className="text-base font-semibold text-gray-900">Support Tickets</h2>
          </div>
          <div className="flex gap-1">
            {['All', 'Open', 'In Progress', 'Resolved'].map(t => (
              <button key={t} className={`px-3 py-1.5 rounded-lg text-xs font-semibold ${t === 'All' ? 'bg-primary text-white' : 'text-gray-500 hover:bg-gray-100'}`}>{t}</button>
            ))}
          </div>
        </div>
        <div className="divide-y divide-gray-50">
          {tickets.map(t => (
            <div key={t.id} className="flex items-start gap-4 px-5 py-4 hover:bg-gray-50/60 transition-colors">
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                <span className="text-[10px] font-bold text-primary">{t.user.split(' ').map(n=>n[0]).join('')}</span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="text-sm font-semibold text-gray-800">{t.user}</span>
                  <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-md ${t.type === 'Winga' ? 'bg-primary/10 text-primary' : 'bg-blue-50 text-blue-600'}`}>{t.type}</span>
                  <span className="text-[10px] text-gray-400 font-mono">{t.id}</span>
                </div>
                <p className="text-xs text-gray-600 mt-1 leading-relaxed">{t.issue}</p>
                <p className="text-[10px] text-gray-400 mt-1">{t.time}</p>
              </div>
              <div className="flex flex-col items-end gap-2 flex-shrink-0">
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md ${priorityColors[t.priority]}`}>{t.priority}</span>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md ${statusColors[t.status]}`}>{t.status}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  )
}
