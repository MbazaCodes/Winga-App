import AdminLayout from '@/components/layout/AdminLayout'
import StatCard from '@/components/ui/StatCard'
import StatusBadge from '@/components/ui/StatusBadge'
import TrendsChart from '@/components/charts/TrendsChart'
import EarningsBarChart from '@/components/charts/EarningsBarChart'
import { wingas, formatTZS } from '@/lib/data'
import { Wallet, TrendingUp, TrendingDown, Receipt, Users } from 'lucide-react'

export default function EarningsPage() {
  return (
    <AdminLayout title="Earnings & Payouts" subtitle="Platform revenue and Winga payout management">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Revenue" value="TZS 328,500" change={10.8} up icon={<Wallet className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Platform Fees (20%)" value="TZS 65,700" change={10.8} up icon={<TrendingUp className="w-5 h-5 text-blue-600" />} iconBg="bg-blue-50" mini />
        <StatCard label="Winga Payouts (80%)" value="TZS 262,800" change={10.8} up icon={<Users className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Tax Collected (3%)" value="TZS 9,855" icon={<Receipt className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5"><h3 className="text-sm font-semibold text-gray-900 mb-4">Weekly Earnings</h3><EarningsBarChart /></div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5"><h3 className="text-sm font-semibold text-gray-900 mb-4">Monthly Growth Trends</h3><TrendsChart /></div>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100 flex items-center justify-between">
          <h2 className="text-base font-semibold text-gray-900">Top Earning Wingas</h2>
          <button className="text-xs font-semibold text-primary border border-primary/20 bg-primary/5 px-3 py-1.5 rounded-lg">View All</button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead><tr className="border-b border-gray-100 bg-gray-50/50">{['Rank','Winga','Total Trips','Gross Earnings','Tax (3%)','Net Earnings','Status'].map(h => (<th key={h} className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider">{h}</th>))}</tr></thead>
            <tbody>
              {[...wingas].sort((a,b) => b.earnings-a.earnings).map((w,i) => {
                const tax=Math.round(w.earnings*0.03); const net=w.earnings-tax;
                return (<tr key={w.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                  <td className="px-4 py-3.5"><span className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${i===0?'bg-amber-100 text-amber-700':i===1?'bg-gray-100 text-gray-600':i===2?'bg-orange-100 text-orange-700':'bg-gray-50 text-gray-400'}`}>{i+1}</span></td>
                  <td className="px-4 py-3.5"><div className="flex items-center gap-2"><div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center"><span className="text-[10px] font-bold text-primary">{w.name.split(' ').map(n=>n[0]).join('')}</span></div><div><div className="text-sm font-semibold text-gray-800">{w.name}</div><div className="text-[10px] text-gray-400">{w.wingaId}</div></div></div></td>
                  <td className="px-4 py-3.5 text-sm font-medium text-gray-700">{w.trips}</td>
                  <td className="px-4 py-3.5 text-sm font-bold text-gray-800">{formatTZS(w.earnings)}</td>
                  <td className="px-4 py-3.5 text-sm text-red-500 font-medium">- {formatTZS(tax)}</td>
                  <td className="px-4 py-3.5 text-sm font-bold text-primary">{formatTZS(net)}</td>
                  <td className="px-4 py-3.5"><StatusBadge status={w.status as any} /></td>
                </tr>)
              })}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
