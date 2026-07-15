import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import { clients, formatTZS } from '@/lib/data'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export default function ClientDetailPage({ params }: { params: { id: string } }) {
  const client = clients.find(c => c.id === params.id) ?? clients[0]
  return (
    <AdminLayout title={client.name} subtitle="Client profile">
      <div className="mb-4">
        <Link href="/clients" className="flex items-center gap-1.5 text-sm text-primary hover:underline">
          <ArrowLeft className="w-4 h-4" /> Back to Clients
        </Link>
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
            <div className="flex items-center gap-4 mb-5">
              <div className="w-14 h-14 rounded-2xl bg-blue-50 border-2 border-blue-100 flex items-center justify-center">
                <span className="text-xl font-bold text-blue-600">{client.name.split(' ').map(n=>n[0]).join('')}</span>
              </div>
              <div>
                <h2 className="text-xl font-bold text-gray-900">{client.name}</h2>
                <StatusBadge status={client.status as any} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                ['Phone', client.phone], ['Email', client.email], ['Location', client.location],
                ['Joined', client.joinDate], ['Last Active', client.lastActivity],
                ['Total Requests', client.totalRequests], ['Completed', client.completedRequests],
                ['Total Spent', formatTZS(client.totalSpent)],
              ].map(([l, v]) => (
                <div key={l as string}>
                  <div className="text-xs text-gray-400 font-medium">{l}</div>
                  <div className="text-sm font-semibold text-gray-800 mt-0.5">{v as string}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5 h-fit">
          <h3 className="text-sm font-semibold text-gray-900 mb-3">Actions</h3>
          <div className="space-y-2">
            <button className="w-full text-sm font-medium text-gray-600 border border-gray-200 py-2 rounded-lg hover:bg-gray-50">View Requests</button>
            <button className="w-full text-sm font-medium text-gray-600 border border-gray-200 py-2 rounded-lg hover:bg-gray-50">Send Notification</button>
            {client.status !== 'Banned' && <button className="w-full text-sm font-medium text-red-600 border border-red-100 bg-red-50 py-2 rounded-lg">Ban Client</button>}
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
