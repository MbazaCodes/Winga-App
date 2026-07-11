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
import { Search, Filter, Download, Eye, CheckCircle, XCircle, Users, Star, UserCheck, Clock, ChevronLeft, ChevronRight, ChevronUp, ChevronDown } from 'lucide-react'

const TABS = ['All', 'Active', 'Inactive', 'Pending Verification', 'Suspended']

export default function WingasPage() {
  const [sorting, setSorting] = useState<SortingState>([])
  const [globalFilter, setGlobalFilter] = useState('')
  const [tab, setTab] = useState('All')

  const filtered = useMemo(() =>
    tab === 'All' ? wingas : wingas.filter(w => w.status === tab), [tab])

  const columns = useMemo<ColumnDef<Winga>[]>(() => [
    {
      accessorKey: 'name',
      header: 'Winga',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-primary/10 border-2 border-primary/20 flex items-center justify-center flex-shrink-0">
            <span className="text-xs font-bold text-primary">{row.original.name.split(' ').map(n => n[0]).join('')}</span>
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="text-sm font-semibold text-gray-800">{row.original.name}</span>
              {row.original.verified && <CheckCircle className="w-3.5 h-3.5 text-primary" />}
            </div>
            <div className="text-[10px] text-gray-400 font-mono">{row.original.wingaId}</div>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'badge',
      header: 'Badge',
      cell: ({ getValue }) => {
        const badge = getValue() as string
        const colors: Record<string, string> = {
          Gold: 'bg-amber-50 text-amber-700 border-amber-200',
          Silver: 'bg-gray-100 text-gray-600 border-gray-300',
          Bronze: 'bg-orange-50 text-orange-700 border-orange-200',
        }
        return (
          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${colors[badge]}`}>
            {badge === 'Gold' ? '🥇' : badge === 'Silver' ? '🥈' : '🥉'} {badge}
          </span>
        )
      },
    },
    { accessorKey: 'specialty', header: 'Specialty', cell: ({ getValue }) => <span className="text-xs bg-primary/[0.08] text-primary px-2 py-0.5 rounded-md font-medium">{getValue() as string}</span> },
    { accessorKey: 'location', header: 'Location', cell: ({ getValue }) => <span className="text-xs text-gray-500">{getValue() as string}</span> },
    {
      accessorKey: 'rating',
      header: 'Rating',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
          <span className="text-sm font-bold text-gray-800">{row.original.rating}</span>
          <span className="text-xs text-gray-400">({row.original.trips})</span>
        </div>
      ),
    },
    {
      accessorKey: 'completionRate',
      header: 'Completion',
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
    {
      accessorKey: 'earnings',
      header: 'Total Earnings',
      cell: ({ getValue }) => <span className="text-sm font-bold text-primary">{formatTZS(getValue() as number)}</span>,
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ getValue }) => <StatusBadge status={getValue() as any} />,
    },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <button className="p-1.5 rounded-lg hover:bg-primary/10 transition-colors" title="View">
            <Eye className="w-3.5 h-3.5 text-primary" />
          </button>
          {row.original.status === 'Pending Verification' && (
            <>
              <button className="p-1.5 rounded-lg hover:bg-green-50 transition-colors" title="Approve">
                <CheckCircle className="w-3.5 h-3.5 text-green-600" />
              </button>
              <button className="p-1.5 rounded-lg hover:bg-red-50 transition-colors" title="Reject">
                <XCircle className="w-3.5 h-3.5 text-red-500" />
              </button>
            </>
          )}
        </div>
      ),
    },
  ], [])

  const table = useReactTable({
    data: filtered,
    columns,
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
    <AdminLayout title="Winga (Shoppers)" subtitle="Manage verified shopping guides">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Wingas" value={342} change={10.1} up icon={<Users className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Active Now" value={298} change={5.4} up icon={<UserCheck className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Avg Rating" value="4.8 ★" icon={<Star className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
        <StatCard label="Pending Verification" value={7} change={2} up={false} icon={<Clock className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
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
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${tab === t ? 'bg-primary text-white' : 'text-gray-500 hover:bg-gray-100'}`}>
                  {t}
                </button>
              ))}
            </div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-400" />
              <input value={globalFilter} onChange={e => setGlobalFilter(e.target.value)} placeholder="Search wingas..."
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
                        {h.column.getIsSorted() === 'asc' && <ChevronUp className="w-3 h-3" />}
                        {h.column.getIsSorted() === 'desc' && <ChevronDown className="w-3 h-3" />}
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
          <span className="text-xs text-gray-500">Showing {filtered.length} of {wingas.length} wingas</span>
          <div className="flex items-center gap-1">
            <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">
              <ChevronLeft className="w-4 h-4 text-gray-600" />
            </button>
            <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50">
              <ChevronRight className="w-4 h-4 text-gray-600" />
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
