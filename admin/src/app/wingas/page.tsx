'use client'
import { useState, useMemo } from 'react'
import {
  useReactTable, getCoreRowModel, getSortedRowModel,
  getFilteredRowModel, getPaginationRowModel,
  flexRender, type ColumnDef, type SortingState,
} from '@tanstack/react-table'
import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import StatCard from '@/components/ui/StatCard'
import { wingas, formatTZS, type Winga } from '@/lib/data'
import {
  Search, Filter, Download, Eye, CheckCircle, XCircle,
  Users, UserCheck, Star, Clock, ChevronLeft, ChevronRight,
  ChevronUp, ChevronDown, Shield, Award
} from 'lucide-react'

const TABS = ['All', 'Active', 'Inactive', 'Pending Verification', 'Suspended']

const BADGE_CONFIG = {
  none:   { label: '—',             bg: 'bg-gray-100',   text: 'text-gray-400' },
  Gold:   { label: '\u{1F947} Gold',   bg: 'bg-amber-50',   text: 'text-amber-700' },
  Silver: { label: '\u{1F948} Silver', bg: 'bg-gray-100',   text: 'text-gray-600' },
  Bronze: { label: '\u{1F949} Bronze', bg: 'bg-orange-50',  text: 'text-orange-700' },
}

// Assign Badge Modal
function AssignBadgeModal({ winga, onClose, onAssign }: {
  winga: Winga, onClose: () => void,
  onAssign: (badge: string) => void
}) {
  const [selected, setSelected] = useState('')
  const [loading, setLoading] = useState(false)

  const tiers = [
    { name: 'Gold',   fee: 'TZS 30,000/mo', emoji: '\u{1F947}', color: 'border-amber-200 bg-amber-50',   desc: 'Top placement + featured' },
    { name: 'Silver', fee: 'TZS 15,000/mo', emoji: '\u{1F948}', color: 'border-gray-300 bg-gray-50',     desc: 'Priority listing + analytics' },
    { name: 'Bronze', fee: 'TZS 5,000/mo',  emoji: '\u{1F949}', color: 'border-orange-200 bg-orange-50',  desc: 'Basic verified listing' },
  ]

  const handleAssign = async () => {
    if (!selected) return
    setLoading(true)
    await new Promise(r => setTimeout(r, 800))
    onAssign(selected)
    setLoading(false)
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
        <div className="p-6 border-b border-gray-100">
          <h2 className="text-lg font-bold text-gray-900">Assign Badge — {winga.name}</h2>
          <p className="text-sm text-gray-500 mt-1">Select the badge tier for this Winga</p>
        </div>
        <div className="p-6 space-y-3">
          {tiers.map(tier => (
            <button key={tier.name} onClick={() => setSelected(tier.name)}
              className={`w-full flex items-center gap-4 p-4 rounded-xl border-2 transition-all text-left ${
                selected === tier.name ? 'border-primary bg-primary/5' : `${tier.color} border`
              }`}>
              <span className="text-3xl">{tier.emoji}</span>
              <div className="flex-1">
                <div className="font-semibold text-gray-800">{tier.name}</div>
                <div className="text-xs text-gray-500">{tier.desc}</div>
              </div>
              <div className="text-right">
                <div className="text-sm font-bold text-primary">{tier.fee}</div>
                {selected === tier.name && (
                  <CheckCircle className="w-4 h-4 text-primary ml-auto mt-1" />
                )}
              </div>
            </button>
          ))}
        </div>
        <div className="p-6 border-t border-gray-100 flex gap-3">
          <button onClick={onClose}
            className="flex-1 py-2.5 rounded-xl border border-gray-200 text-sm font-medium text-gray-600 hover:bg-gray-50">
            Cancel
          </button>
          <button onClick={handleAssign} disabled={!selected || loading}
            className="flex-1 py-2.5 rounded-xl bg-primary text-white text-sm font-semibold disabled:opacity-50 flex items-center justify-center gap-2">
            {loading ? <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Award className="w-4 h-4" />}
            Assign Badge
          </button>
        </div>
      </div>
    </div>
  )
}

// Verify Modal
function VerifyModal({ winga, onClose, onVerify, onReject }: {
  winga: Winga, onClose: () => void,
  onVerify: (tier: string, notes: string) => void,
  onReject: (reason: string) => void,
}) {
  const [tier, setTier] = useState('Gold')
  const [notes, setNotes] = useState('')
  const [rejectMode, setRejectMode] = useState(false)
  const [rejectReason, setRejectReason] = useState('')
  const [loading, setLoading] = useState(false)

  const handleVerify = async () => {
    setLoading(true)
    await new Promise(r => setTimeout(r, 800))
    onVerify(tier, notes)
    setLoading(false)
    onClose()
  }

  const handleReject = async () => {
    if (!rejectReason) return
    setLoading(true)
    await new Promise(r => setTimeout(r, 600))
    onReject(rejectReason)
    setLoading(false)
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg">
        <div className="p-6 border-b border-gray-100">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              <span className="text-sm font-bold text-primary">{winga.name.split(' ').map(n=>n[0]).join('')}</span>
            </div>
            <div>
              <h2 className="text-base font-bold text-gray-900">Review Winga — {winga.name}</h2>
              <p className="text-xs text-gray-500">{winga.phone} · {winga.specialty}</p>
            </div>
          </div>
        </div>

        <div className="p-6">
          {!rejectMode ? (
            <div className="space-y-4">
              <div>
                <label className="text-sm font-semibold text-gray-700 block mb-2">Assign Tier & Badge</label>
                <div className="grid grid-cols-3 gap-2">
                  {['Bronze','Silver','Gold'].map(t => (
                    <button key={t} onClick={() => setTier(t)}
                      className={`py-2 rounded-lg text-xs font-semibold border transition-all ${
                        tier===t ? 'bg-primary text-white border-primary' : 'border-gray-200 text-gray-600 hover:bg-gray-50'
                      }`}>
                      {t==='Bronze'?'🥉':t==='Silver'?'🥈':'🥇'} {t}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="text-sm font-semibold text-gray-700 block mb-2">Verification Notes (optional)</label>
                <textarea value={notes} onChange={e=>setNotes(e.target.value)} rows={3}
                  placeholder="e.g. All documents verified. National ID confirmed."
                  className="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 resize-none" />
              </div>
            </div>
          ) : (
            <div>
              <label className="text-sm font-semibold text-red-600 block mb-2">Rejection Reason *</label>
              <textarea value={rejectReason} onChange={e=>setRejectReason(e.target.value)} rows={3}
                placeholder="e.g. National ID photo is unclear. Please resubmit."
                className="w-full px-3 py-2 text-sm border border-red-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-100 resize-none" />
            </div>
          )}
        </div>

        <div className="p-6 border-t border-gray-100 flex gap-2">
          <button onClick={onClose} className="px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50">Cancel</button>
          {!rejectMode ? (
            <>
              <button onClick={() => setRejectMode(true)}
                className="px-4 py-2 rounded-xl bg-red-50 text-red-600 border border-red-100 text-sm font-medium flex items-center gap-1.5">
                <XCircle className="w-3.5 h-3.5" /> Reject
              </button>
              <button onClick={handleVerify} disabled={loading}
                className="flex-1 py-2 rounded-xl bg-primary text-white text-sm font-semibold flex items-center justify-center gap-2 disabled:opacity-50">
                {loading ? <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                Verify as {tier}
              </button>
            </>
          ) : (
            <>
              <button onClick={() => setRejectMode(false)} className="px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600">Back</button>
              <button onClick={handleReject} disabled={!rejectReason || loading}
                className="flex-1 py-2 rounded-xl bg-red-600 text-white text-sm font-semibold flex items-center justify-center gap-2 disabled:opacity-50">
                {loading ? <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <XCircle className="w-4 h-4" />}
                Confirm Rejection
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default function WingasPage() {
  const [sorting, setSorting] = useState<SortingState>([])
  const [globalFilter, setGlobalFilter] = useState('')
  const [tab, setTab] = useState('All')
  const [verifyModal, setVerifyModal] = useState<Winga | null>(null)
  const [badgeModal, setBadgeModal] = useState<Winga | null>(null)

  const filtered = useMemo(() =>
    tab === 'All' ? wingas : wingas.filter(w => w.status === tab), [tab])

  const columns = useMemo<ColumnDef<Winga>[]>(() => [
    {
      accessorKey: 'name', header: 'Winga',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-primary/10 border-2 border-primary/20 flex items-center justify-center flex-shrink-0">
            <span className="text-xs font-bold text-primary">{row.original.name.split(' ').map(n=>n[0]).join('')}</span>
          </div>
          <div>
            <div className="flex items-center gap-1">
              <span className="text-sm font-semibold text-gray-800">{row.original.name}</span>
              {row.original.verified && <CheckCircle className="w-3.5 h-3.5 text-primary" />}
            </div>
            <div className="text-[10px] text-gray-400 font-mono">{row.original.wingaId}</div>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'badge', header: 'Badge',
      cell: ({ getValue }) => {
        const b = (getValue() as string) || 'none'
        const cfg = BADGE_CONFIG[b as keyof typeof BADGE_CONFIG] || BADGE_CONFIG.none
        return (
          <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${cfg.bg} ${cfg.text}`}>
            {cfg.label}
          </span>
        )
      },
    },
    { accessorKey: 'specialty', header: 'Specialty', cell: ({ getValue }) => <span className="text-xs bg-primary/[0.08] text-primary px-2 py-0.5 rounded-md font-medium">{getValue() as string}</span> },
    { accessorKey: 'location', header: 'Location', cell: ({ getValue }) => <span className="text-xs text-gray-500">{getValue() as string}</span> },
    {
      accessorKey: 'rating', header: 'Rating',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
          <span className="text-sm font-bold text-gray-800">{row.original.rating}</span>
          <span className="text-xs text-gray-400">({row.original.trips})</span>
        </div>
      ),
    },
    {
      accessorKey: 'completionRate', header: 'Completion',
      cell: ({ getValue }) => {
        const rate = getValue() as number
        return (
          <div className="flex items-center gap-2 w-24">
            <div className="flex-1 h-1.5 bg-gray-100 rounded-full overflow-hidden">
              <div className="h-full bg-primary rounded-full" style={{ width: `${rate}%` }} />
            </div>
            <span className="text-xs font-semibold text-gray-700 w-9 text-right">{rate}%</span>
          </div>
        )
      },
    },
    { accessorKey: 'earnings', header: 'Earnings', cell: ({ getValue }) => <span className="text-sm font-bold text-primary">{formatTZS(getValue() as number)}</span> },
    { accessorKey: 'status', header: 'Status', cell: ({ getValue }) => <StatusBadge status={getValue() as any} /> },
    {
      id: 'actions', header: 'Actions',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <button className="p-1.5 rounded-lg hover:bg-primary/10 transition-colors" title="View profile">
            <Eye className="w-3.5 h-3.5 text-primary" />
          </button>
          <button onClick={() => setBadgeModal(row.original)}
            className="p-1.5 rounded-lg hover:bg-amber-50 transition-colors" title="Assign badge">
            <Award className="w-3.5 h-3.5 text-amber-500" />
          </button>
          {(row.original.status === 'Pending Verification' || !row.original.verified) && (
            <>
              <button onClick={() => setVerifyModal(row.original)}
                className="px-2.5 py-1 rounded-lg bg-green-50 hover:bg-green-100 text-green-700 text-[11px] font-semibold flex items-center gap-1 transition-colors">
                <Shield className="w-3 h-3" /> Verify
              </button>
            </>
          )}
        </div>
      ),
    },
  ], [])

  const table = useReactTable({
    data: filtered, columns,
    state: { sorting, globalFilter },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: { pagination: { pageSize: 8 } },
  })

  return (
    <AdminLayout title="Winga (Shoppers)" subtitle="Verify Wingas, assign badges, manage subscriptions">
      {verifyModal && (
        <VerifyModal
          winga={verifyModal}
          onClose={() => setVerifyModal(null)}
          onVerify={(tier, notes) => console.log('Verify', verifyModal.id, tier, notes)}
          onReject={(reason) => console.log('Reject', verifyModal.id, reason)}
        />
      )}
      {badgeModal && (
        <AssignBadgeModal
          winga={badgeModal}
          onClose={() => setBadgeModal(null)}
          onAssign={(badge) => console.log('Badge', badgeModal.id, badge)}
        />
      )}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Wingas" value={342} change={10.1} up icon={<Users className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Active Verified" value={298} change={5.4} up icon={<UserCheck className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Avg Rating" value="4.8 ★" icon={<Star className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
        <StatCard label="Pending Review" value={7} icon={<Clock className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
      </div>

      {/* Badge summary strip */}
      <div className="flex gap-3 mb-4">
        {[
          { label: '🥇 Gold', count: 145, bg: 'bg-amber-50 border-amber-100', text: 'text-amber-700' },
          { label: '🥈 Silver', count: 98, bg: 'bg-gray-50 border-gray-200', text: 'text-gray-600' },
          { label: '🥉 Bronze', count: 55, bg: 'bg-orange-50 border-orange-100', text: 'text-orange-700' },
          { label: 'No Badge', count: 44, bg: 'bg-red-50 border-red-100', text: 'text-red-500' },
        ].map(b => (
          <div key={b.label} className={`flex items-center gap-2 px-4 py-2 rounded-xl border ${b.bg}`}>
            <span className={`text-sm font-bold ${b.text}`}>{b.label}</span>
            <span className={`text-xs font-semibold ${b.text} opacity-70`}>{b.count}</span>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-semibold text-gray-900">All Wingas</h2>
            <div className="flex items-center gap-2">
              <button className="flex items-center gap-1.5 text-xs font-medium text-gray-600 bg-gray-50 border border-gray-200 px-3 py-2 rounded-lg hover:bg-gray-100">
                <Filter className="w-3.5 h-3.5" /> Filter
              </button>
              <button className="flex items-center gap-1.5 text-xs font-medium text-primary bg-primary/[0.08] border border-primary/20 px-3 py-2 rounded-lg">
                <Download className="w-3.5 h-3.5" /> Export
              </button>
            </div>
          </div>
          <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
            <div className="flex gap-1 flex-wrap">
              {TABS.map(t => (
                <button key={t} onClick={() => setTab(t)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${tab===t?'bg-primary text-white':'text-gray-500 hover:bg-gray-100'}`}>
                  {t}
                </button>
              ))}
            </div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-400" />
              <input value={globalFilter} onChange={e=>setGlobalFilter(e.target.value)} placeholder="Search wingas..."
                className="pl-8 pr-4 py-1.5 text-xs bg-gray-50 border border-gray-200 rounded-lg w-48 focus:outline-none focus:ring-2 focus:ring-primary/20" />
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              {table.getHeaderGroups().map(hg => (
                <tr key={hg.id} className="border-b border-gray-100 bg-gray-50/50">
                  {hg.headers.map(h => (
                    <th key={h.id} onClick={h.column.getToggleSortingHandler()}
                      className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider cursor-pointer hover:text-gray-700 whitespace-nowrap select-none">
                      <div className="flex items-center gap-1">
                        {flexRender(h.column.columnDef.header, h.getContext())}
                        {h.column.getIsSorted()==='asc'&&<ChevronUp className="w-3 h-3" />}
                        {h.column.getIsSorted()==='desc'&&<ChevronDown className="w-3 h-3" />}
                      </div>
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.map(row => (
                <tr key={row.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                  {row.getVisibleCells().map(cell => (
                    <td key={cell.id} className="px-4 py-3.5">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="px-5 py-4 border-t border-gray-100 flex items-center justify-between">
          <span className="text-xs text-gray-500">
            Showing {table.getState().pagination.pageIndex * 8 + 1}–
            {Math.min((table.getState().pagination.pageIndex + 1) * 8, filtered.length)} of {filtered.length}
          </span>
          <div className="flex items-center gap-1">
            <button onClick={()=>table.previousPage()} disabled={!table.getCanPreviousPage()}
              className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">
              <ChevronLeft className="w-4 h-4 text-gray-600" />
            </button>
            <button onClick={()=>table.nextPage()} disabled={!table.getCanNextPage()}
              className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">
              <ChevronRight className="w-4 h-4 text-gray-600" />
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
