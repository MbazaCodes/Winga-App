'use client'
import { useState, useMemo } from 'react'
import { useReactTable, getCoreRowModel, getSortedRowModel, getFilteredRowModel, getPaginationRowModel, flexRender, type ColumnDef, type SortingState } from '@tanstack/react-table'
import AdminLayout from '@/components/layout/AdminLayout'
import StatusBadge from '@/components/ui/StatusBadge'
import StatCard from '@/components/ui/StatCard'
import { clients, formatTZS, type Client } from '@/lib/data'
import { Search, Users, UserCheck, TrendingUp, AlertCircle, Eye, Ban, ChevronLeft, ChevronRight, ChevronUp, ChevronDown } from 'lucide-react'

export default function ClientsPage() {
  const [sorting, setSorting] = useState<SortingState>([])
  const [globalFilter, setGlobalFilter] = useState('')
  const [tab, setTab] = useState('All')
  const filtered = useMemo(() => tab === 'All' ? clients : clients.filter(c => c.status === tab), [tab])

  const columns = useMemo<ColumnDef<Client>[]>(() => [
    {
      accessorKey: 'name', header: 'Client',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-blue-50 border-2 border-blue-100 flex items-center justify-center">
            <span className="text-xs font-bold text-blue-600">{row.original.name.split(' ').map((n: string) => n[0]).join('')}</span>
          </div>
          <div>
            <div className="text-sm font-semibold text-gray-800">{row.original.name}</div>
            <div className="text-[10px] text-gray-400">{row.original.email}</div>
          </div>
        </div>
      )
    },
    { accessorKey: 'phone', header: 'Phone', cell: ({ getValue }) => <span className="text-xs text-gray-600 font-mono">{getValue() as string}</span> },
    { accessorKey: 'location', header: 'Location', cell: ({ getValue }) => <span className="text-xs text-gray-500">{getValue() as string}</span> },
    { accessorKey: 'totalRequests', header: 'Requests', cell: ({ row }) => <div className="text-xs"><span className="font-bold text-gray-800">{row.original.totalRequests}</span><span className="text-gray-400"> / {row.original.completedRequests} done</span></div> },
    { accessorKey: 'totalSpent', header: 'Total Spent', cell: ({ getValue }) => <span className="text-sm font-bold text-primary">{formatTZS(getValue() as number)}</span> },
    { accessorKey: 'status', header: 'Status', cell: ({ getValue }) => <StatusBadge status={getValue() as any} /> },
    { accessorKey: 'lastActivity', header: 'Last Active', cell: ({ getValue }) => <span className="text-xs text-gray-500">{getValue() as string}</span> },
    { accessorKey: 'joinDate', header: 'Joined', cell: ({ getValue }) => <span className="text-xs text-gray-400">{getValue() as string}</span> },
    {
      id: 'actions', header: '',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <button className="p-1.5 rounded-lg hover:bg-primary/10"><Eye className="w-3.5 h-3.5 text-primary" /></button>
          {row.original.status !== 'Banned' && <button className="p-1.5 rounded-lg hover:bg-red-50"><Ban className="w-3.5 h-3.5 text-red-400" /></button>}
        </div>
      )
    },
  ], [])

  const table = useReactTable({ data: filtered, columns, state: { sorting, globalFilter }, onSortingChange: setSorting, onGlobalFilterChange: setGlobalFilter, getCoreRowModel: getCoreRowModel(), getSortedRowModel: getSortedRowModel(), getFilteredRowModel: getFilteredRowModel(), getPaginationRowModel: getPaginationRowModel(), initialState: { pagination: { pageSize: 8 } } })

  return (
    <AdminLayout title="Clients (Users)" subtitle="Manage registered app users">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Clients" value={2534} change={8.3} up icon={<Users className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Active Clients" value={2189} change={6.1} up icon={<UserCheck className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="New This Month" value={124} change={14.2} up icon={<TrendingUp className="w-5 h-5 text-blue-500" />} iconBg="bg-blue-50" mini />
        <StatCard label="Banned/Inactive" value={56} icon={<AlertCircle className="w-5 h-5 text-red-400" />} iconBg="bg-red-50" mini />
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        <div className="p-5 border-b border-gray-100">
          <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
            <div className="flex gap-1">
              {['All', 'Active', 'Inactive', 'Banned'].map(t => (
                <button key={t} onClick={() => setTab(t)} className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${tab === t ? 'bg-primary text-white' : 'text-gray-500 hover:bg-gray-100'}`}>{t}</button>
              ))}
            </div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-400" />
              <input value={globalFilter} onChange={e => setGlobalFilter(e.target.value)} placeholder="Search clients..." className="pl-8 pr-4 py-1.5 text-xs bg-gray-50 border border-gray-200 rounded-lg w-48 focus:outline-none focus:ring-2 focus:ring-primary/20" />
            </div>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>{table.getHeaderGroups().map(hg => (<tr key={hg.id} className="border-b border-gray-100 bg-gray-50/50">{hg.headers.map(h => (<th key={h.id} onClick={h.column.getToggleSortingHandler()} className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider cursor-pointer hover:text-gray-700 whitespace-nowrap select-none"><div className="flex items-center gap-1">{flexRender(h.column.columnDef.header, h.getContext())}{h.column.getIsSorted() === 'asc' && <ChevronUp className="w-3 h-3" />}{h.column.getIsSorted() === 'desc' && <ChevronDown className="w-3 h-3" />}</div></th>))}</tr>))}</thead>
            <tbody>{table.getRowModel().rows.map(row => (<tr key={row.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">{row.getVisibleCells().map(cell => (<td key={cell.id} className="px-4 py-3.5">{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>))}</tr>))}</tbody>
          </table>
        </div>
        <div className="px-5 py-4 border-t border-gray-100 flex items-center justify-between">
          <span className="text-xs text-gray-500">Showing {filtered.length} clients</span>
          <div className="flex items-center gap-1">
            <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50"><ChevronLeft className="w-4 h-4 text-gray-600" /></button>
            <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50"><ChevronRight className="w-4 h-4 text-gray-600" /></button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
