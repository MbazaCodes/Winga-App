import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import { recentRequests, formatTZS } from '@/lib/data'
import { ArrowLeft, MapPin, User, Clock, CreditCard } from 'lucide-react'
import Link from 'next/link'

export default function RequestDetailPage({ params }: { params: { id: string } }) {
  const req = recentRequests.find(r => r.id === params.id) ?? recentRequests[0]
  return (
    <AdminLayout title={`Request ${req.id}`} subtitle="Full request details">
      <div className="mb-4">
        <Link href="/requests" className="flex items-center gap-1.5 text-sm text-primary hover:underline">
          <ArrowLeft className="w-4 h-4" /> Back to Requests
        </Link>
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-bold text-gray-900">{req.category}</h2>
              <StatusBadge status={req.status} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { icon: User, label: 'Client', value: req.client },
                { icon: User, label: 'Winga', value: req.winga },
                { icon: MapPin, label: 'Location', value: req.location },
                { icon: Clock, label: 'Date & Time', value: `${req.date} • ${req.time}` },
                { icon: Clock, label: 'Duration', value: req.duration },
                { icon: CreditCard, label: 'Amount', value: formatTZS(req.amount) },
              ].map(item => (
                <div key={item.label} className="flex items-start gap-3">
                  <div className="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center flex-shrink-0">
                    <item.icon className="w-4 h-4 text-primary" />
                  </div>
                  <div>
                    <div className="text-xs text-gray-400 font-medium">{item.label}</div>
                    <div className="text-sm font-semibold text-gray-800">{item.value}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5 h-fit">
          <h3 className="text-sm font-semibold text-gray-900 mb-3">Quick Actions</h3>
          <div className="space-y-2">
            <button className="w-full text-sm font-medium text-white bg-primary py-2 rounded-lg hover:bg-primary-dark transition-colors">View on Map</button>
            <button className="w-full text-sm font-medium text-gray-600 border border-gray-200 py-2 rounded-lg hover:bg-gray-50 transition-colors">Contact Client</button>
            <button className="w-full text-sm font-medium text-gray-600 border border-gray-200 py-2 rounded-lg hover:bg-gray-50 transition-colors">Contact Winga</button>
            <button className="w-full text-sm font-medium text-red-600 border border-red-100 bg-red-50 py-2 rounded-lg hover:bg-red-100 transition-colors">Cancel Request</button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
