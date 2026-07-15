import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import { wingas, formatTZS } from '@/lib/data'
import { ArrowLeft, Star, CheckCircle } from 'lucide-react'
import Link from 'next/link'

export default function WingaDetailPage({ params }: { params: { id: string } }) {
  const winga = wingas.find(w => w.id === params.id) ?? wingas[0]
  return (
    <AdminLayout title={winga.name} subtitle={`Winga ID: ${winga.wingaId}`}>
      <div className="mb-4">
        <Link href="/wingas" className="flex items-center gap-1.5 text-sm text-primary hover:underline">
          <ArrowLeft className="w-4 h-4" /> Back to Wingas
        </Link>
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
            <div className="flex items-center gap-4 mb-5">
              <div className="w-16 h-16 rounded-2xl bg-primary/10 border-2 border-primary/20 flex items-center justify-center">
                <span className="text-2xl font-bold text-primary">{winga.name.split(' ').map(n=>n[0]).join('')}</span>
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="text-xl font-bold text-gray-900">{winga.name}</h2>
                  {winga.verified && <CheckCircle className="w-5 h-5 text-primary" />}
                </div>
                <div className="text-sm text-gray-500 font-mono mt-0.5">{winga.wingaId}</div>
                <div className="flex items-center gap-2 mt-1">
                  <StatusBadge status={winga.status as any} />
                  <span className="text-xs font-semibold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-md">{winga.badge} Badge</span>
                </div>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                ['Phone', winga.phone], ['Email', winga.email], ['Specialty', winga.specialty],
                ['Location', winga.location], ['Joined', winga.joinDate], ['National ID', winga.verified ? 'Verified ✓' : 'Pending'],
              ].map(([l, v]) => (
                <div key={l as string}>
                  <div className="text-xs text-gray-400 font-medium">{l}</div>
                  <div className="text-sm font-semibold text-gray-800 mt-0.5">{v as string}</div>
                </div>
              ))}
            </div>
          </div>
          <div className="grid grid-cols-4 gap-3">
            {[
              { label: 'Rating', value: `${winga.rating} ★` },
              { label: 'Total Trips', value: winga.trips },
              { label: 'Completion', value: `${winga.completionRate}%` },
              { label: 'Earnings', value: formatTZS(winga.earnings) },
            ].map(s => (
              <div key={s.label} className="bg-white rounded-xl border border-gray-100 shadow-card p-4 text-center">
                <div className="text-lg font-extrabold text-primary">{s.value}</div>
                <div className="text-xs text-gray-400 font-medium mt-0.5">{s.label}</div>
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5 h-fit">
          <h3 className="text-sm font-semibold text-gray-900 mb-3">Actions</h3>
          <div className="space-y-2">
            {!winga.verified && <button className="w-full text-sm font-medium text-white bg-primary py-2 rounded-lg">Approve Winga</button>}
            <button className="w-full text-sm font-medium text-gray-600 border border-gray-200 py-2 rounded-lg hover:bg-gray-50">Send Message</button>
            <button className="w-full text-sm font-medium text-amber-600 border border-amber-100 bg-amber-50 py-2 rounded-lg">Suspend Account</button>
            <button className="w-full text-sm font-medium text-red-600 border border-red-100 bg-red-50 py-2 rounded-lg">Ban Account</button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
