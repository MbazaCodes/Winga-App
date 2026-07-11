import AdminLayout from '@/components/layout/AdminLayout'
import TrendsChart from '@/components/charts/TrendsChart'
import EarningsBarChart from '@/components/charts/EarningsBarChart'
import RequestsOverviewChart from '@/components/charts/RequestsOverviewChart'
import { formatTZS } from '@/lib/data'
import { BarChart3, Download, FileText, TrendingUp } from 'lucide-react'

const reports = [
  { title: 'Monthly Revenue Report', period: 'May 2026', size: '248 KB', type: 'PDF' },
  { title: 'Winga Performance Report', period: 'May 2026', size: '185 KB', type: 'PDF' },
  { title: 'Tax Compliance Report', period: 'May 2026', size: '96 KB', type: 'PDF' },
  { title: 'Requests Summary', period: 'May 2026', size: '312 KB', type: 'XLSX' },
  { title: 'Client Activity Report', period: 'May 2026', size: '204 KB', type: 'PDF' },
  { title: 'Transaction Ledger', period: 'May 2026', size: '445 KB', type: 'XLSX' },
]

export default function ReportsPage() {
  return (
    <AdminLayout title="Reports" subtitle="Platform analytics and downloadable reports">
      {/* KPI summary */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Monthly Requests', value: '1,248', change: '12.5%', up: true },
          { label: 'Monthly Revenue', value: formatTZS(328500), change: '10.8%', up: true },
          { label: 'Active Wingas', value: '342', change: '10.1%', up: true },
          { label: 'Client Satisfaction', value: '4.8 / 5', change: '2.1%', up: true },
        ].map(k => (
          <div key={k.label} className="bg-white rounded-2xl border border-gray-100 shadow-card p-4">
            <div className="text-xs text-gray-500 font-medium mb-1">{k.label}</div>
            <div className="text-xl font-extrabold text-gray-900">{k.value}</div>
            <div className={`flex items-center gap-1 text-xs font-semibold mt-1 ${k.up ? 'text-green-600' : 'text-red-500'}`}>
              <TrendingUp className="w-3 h-3" /> {k.change} vs last month
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Requests Overview</h3>
          <RequestsOverviewChart />
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Platform Growth</h3>
          <TrendsChart />
        </div>
      </div>

      {/* Downloadable reports */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <BarChart3 className="w-4 h-4 text-primary" />
            <h2 className="text-base font-semibold text-gray-900">Downloadable Reports</h2>
          </div>
          <button className="flex items-center gap-1.5 text-xs font-semibold text-primary border border-primary/20 bg-primary/5 px-3 py-1.5 rounded-lg">
            <Download className="w-3.5 h-3.5" /> Download All
          </button>
        </div>
        <div className="divide-y divide-gray-50">
          {reports.map(r => (
            <div key={r.title} className="flex items-center gap-4 px-5 py-4 hover:bg-gray-50/60 transition-colors">
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${r.type === 'PDF' ? 'bg-red-50' : 'bg-green-50'}`}>
                <FileText className={`w-4.5 h-4.5 ${r.type === 'PDF' ? 'text-red-500' : 'text-green-600'}`} />
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-sm font-semibold text-gray-800">{r.title}</div>
                <div className="text-xs text-gray-400 mt-0.5">{r.period} · {r.size} · {r.type}</div>
              </div>
              <button className="flex items-center gap-1.5 text-xs font-semibold text-primary border border-primary/20 px-3 py-1.5 rounded-lg hover:bg-primary/5 transition-colors">
                <Download className="w-3 h-3" /> Download
              </button>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  )
}
