import AdminLayout from '@/components/layout/AdminLayout'
import StatCard from '@/components/ui/StatCard'
import { transactions, formatTZS } from '@/lib/data'
import { Receipt, TrendingUp, FileText, AlertCircle } from 'lucide-react'

export default function TaxesPage() {
  const successTx = transactions.filter(t => t.status === 'Success')
  const totalTax = successTx.reduce((s, t) => s + t.tax, 0)
  const totalGross = successTx.reduce((s, t) => s + t.amount, 0)

  return (
    <AdminLayout title="Taxes" subtitle="TRA tax compliance and reporting">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Tax Collected (This Month)" value={formatTZS(totalTax)} change={10.3} up icon={<Receipt className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Gross Revenue" value={formatTZS(totalGross)} change={10.8} up icon={<TrendingUp className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Effective Rate" value="3.0%" icon={<FileText className="w-5 h-5 text-blue-500" />} iconBg="bg-blue-50" mini />
        <StatCard label="Pending TRA Filing" value="0" icon={<AlertCircle className="w-5 h-5 text-amber-400" />} iconBg="bg-amber-50" mini />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        {/* Tax summary by period */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <h2 className="text-base font-semibold text-gray-900 mb-4">Tax Summary by Period</h2>
          <div className="space-y-3">
            {[
              { period: 'Today', gross: 18500, tax: 555, rate: '3%' },
              { period: 'This Week', gross: 72000, tax: 2160, rate: '3%' },
              { period: 'This Month', gross: 328500, tax: 9855, rate: '3%' },
              { period: 'Last Month', gross: 298000, tax: 8940, rate: '3%' },
              { period: 'This Year (YTD)', gross: 1845000, tax: 55350, rate: '3%' },
            ].map(item => (
              <div key={item.period} className="flex items-center justify-between py-2.5 border-b border-gray-50 last:border-0">
                <div>
                  <span className="text-sm font-semibold text-gray-800">{item.period}</span>
                  <div className="text-xs text-gray-400 mt-0.5">Gross: {formatTZS(item.gross)}</div>
                </div>
                <div className="text-right">
                  <div className="text-sm font-bold text-red-500">- {formatTZS(item.tax)}</div>
                  <div className="text-xs text-gray-400">TRA Rate: {item.rate}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* TRA compliance */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <h2 className="text-base font-semibold text-gray-900 mb-4">TRA Compliance Status</h2>
          <div className="space-y-4">
            <div className="flex items-start gap-3 p-3 bg-green-50 rounded-xl border border-green-100">
              <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-white text-sm font-bold">✓</span>
              </div>
              <div>
                <div className="text-sm font-semibold text-green-700">TIN Registered</div>
                <div className="text-xs text-green-600 mt-0.5">TIN: 123-456-789 · Winga Technologies Ltd</div>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-green-50 rounded-xl border border-green-100">
              <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-white text-sm font-bold">✓</span>
              </div>
              <div>
                <div className="text-sm font-semibold text-green-700">April 2026 Filed</div>
                <div className="text-xs text-green-600 mt-0.5">Filed on May 5, 2026 · TZS 8,940 paid</div>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-amber-50 rounded-xl border border-amber-100">
              <div className="w-8 h-8 bg-amber-400 rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-white text-sm font-bold">!</span>
              </div>
              <div>
                <div className="text-sm font-semibold text-amber-700">May 2026 — Due Jun 7</div>
                <div className="text-xs text-amber-600 mt-0.5">Estimated: TZS 9,855 · 27 days remaining</div>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-blue-50 rounded-xl border border-blue-100">
              <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-white text-xs font-bold">i</span>
              </div>
              <div>
                <div className="text-sm font-semibold text-blue-700">Tax Rate: 3%–5% of gross</div>
                <div className="text-xs text-blue-600 mt-0.5">Per TRA Digital Platform regulations 2024</div>
              </div>
            </div>
          </div>
          <button className="mt-4 w-full text-sm font-semibold text-white bg-primary py-2.5 rounded-xl hover:bg-primary-dark transition-colors">
            Download Tax Report (PDF)
          </button>
        </div>
      </div>

      {/* Transaction-level tax table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100 flex items-center justify-between">
          <h2 className="text-base font-semibold text-gray-900">Tax Breakdown per Transaction</h2>
          <button className="text-xs font-semibold text-primary border border-primary/20 bg-primary/5 px-3 py-1.5 rounded-lg">Export CSV</button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/50">
                {['Transaction', 'Date', 'Gross Amount', 'Tax (3%)', 'Platform Fee', 'Winga Net', 'Method'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {transactions.filter(t => t.status === 'Success').map(tx => (
                <tr key={tx.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                  <td className="px-4 py-3.5"><span className="text-xs font-mono text-primary">{tx.id}</span></td>
                  <td className="px-4 py-3.5 text-xs text-gray-500">{tx.date}</td>
                  <td className="px-4 py-3.5 text-sm font-semibold text-gray-800">{formatTZS(tx.amount)}</td>
                  <td className="px-4 py-3.5 text-sm font-semibold text-red-500">- {formatTZS(tx.tax)}</td>
                  <td className="px-4 py-3.5 text-sm text-blue-600">{formatTZS(tx.platformFee)}</td>
                  <td className="px-4 py-3.5 text-sm font-bold text-primary">{formatTZS(tx.wingaPayout)}</td>
                  <td className="px-4 py-3.5"><span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-md">{tx.method}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
