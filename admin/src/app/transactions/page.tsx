import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import StatCard from '@/components/ui/StatCard'
import { transactions, formatTZS } from '@/lib/data'
import { CreditCard, TrendingUp, CheckCircle, XCircle } from 'lucide-react'

export default function TransactionsPage() {
  return (
    <AdminLayout title="Transactions" subtitle="All payment transactions">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Transactions" value={transactions.length} icon={<CreditCard className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Successful" value={transactions.filter(t=>t.status==='Success').length} change={15.2} up icon={<CheckCircle className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Total Volume" value="TZS 159,000" change={10.8} up icon={<TrendingUp className="w-5 h-5 text-blue-600" />} iconBg="bg-blue-50" mini />
        <StatCard label="Failed/Refunded" value={transactions.filter(t=>t.status!=='Success'&&t.status!=='Pending').length} icon={<XCircle className="w-5 h-5 text-red-400" />} iconBg="bg-red-50" mini />
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100"><h2 className="text-base font-semibold text-gray-900">All Transactions</h2></div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead><tr className="border-b border-gray-100 bg-gray-50/50">{['TX ID','Request ID','Client','Winga','Amount','Platform Fee','Winga Payout','Tax','Method','Status','Date'].map(h => (<th key={h} className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">{h}</th>))}</tr></thead>
            <tbody>
              {transactions.map(tx => (
                <tr key={tx.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                  <td className="px-4 py-3.5"><span className="text-xs font-mono font-semibold text-primary bg-primary/8 px-2 py-0.5 rounded-md">{tx.id}</span></td>
                  <td className="px-4 py-3.5"><span className="text-xs text-gray-500 font-mono">{tx.requestId}</span></td>
                  <td className="px-4 py-3.5 text-xs font-medium text-gray-800">{tx.client}</td>
                  <td className="px-4 py-3.5 text-xs text-gray-600">{tx.winga}</td>
                  <td className="px-4 py-3.5 text-sm font-bold text-gray-800">{formatTZS(tx.amount)}</td>
                  <td className="px-4 py-3.5 text-xs font-medium text-blue-600">{formatTZS(tx.platformFee)}</td>
                  <td className="px-4 py-3.5 text-xs font-medium text-primary">{tx.wingaPayout > 0 ? formatTZS(tx.wingaPayout) : '—'}</td>
                  <td className="px-4 py-3.5 text-xs text-red-400">{tx.tax > 0 ? formatTZS(tx.tax) : '—'}</td>
                  <td className="px-4 py-3.5"><span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-md font-medium">{tx.method}</span></td>
                  <td className="px-4 py-3.5"><StatusBadge status={tx.status as any} /></td>
                  <td className="px-4 py-3.5 text-xs text-gray-400">{tx.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
