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
import { recentRequests, formatTZS, type Request } from '@/lib/data'
import { Search, Filter, Download, Eye, ChevronUp, ChevronDown, ChevronLeft, ChevronRight, ClipboardList, CheckCircle, Clock, XCircle } from 'lucide-react'

const STATUS_TABS = ['All', 'In Progress', 'Completed', 'Pending', 'Cancelled'] as const

export default function RequestsPage() {
  const [sorting, setSorting] = useState<SortingState>([])
  const [globalFilter, setGlobalFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('All')

  const filtered = useMemo(() =>
    statusFilter === 'All'
      ? recentRequests
      : recentRequests.filter(r => r.status === statusFilter),
    [statusFilter]
  )

  const columns = useMemo<ColumnDef<Request>[]>(() => [
    {
      accessorKey: 'id',
      header: 'Request ID',
      cell: ({ getValue }) => (
        <span className="text-xs font-mono font-semibold text-primary bg-primary/[0.08] px-2 py-0.5 rounded-md">{getValue() as string}</span>
      ),
    },
    {
      accessorKey: 'client',
      header: 'Client',
      cell: ({ getValue }) => (
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
            <span className="text-[10px] font-bold text-primary">{(getValue() as string).split(' ').map(n => n[0]).join('')}</span>
          </div>
          <span className="text-sm font-medium text-gray-800 truncate max-w-[100px]">{getValue() as string}</span>
        </div>
      ),
    },
    {
      accessorKey: 'winga',
      header: 'Winga',
      cell: ({ getValue }) => (
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-full bg-green-50 border border-green-200 flex items-center justify-center flex-shrink-0">
            <span className="text-[10px] font-bold text-primary">{(getValue() as string).split(' ').map(n => n[0]).join('')}</span>
          </div>
          <span className="text-sm text-gray-700 truncate max-w-[90px]">{getValue() as string}</span>
        </div>
      ),
    },
    { accessorKey: 'category', header: 'Category', cell: ({ getValue }) => <span className="text-xs text-gray-700 font-medium">{getValue() as string}</span> },
    { accessorKey: 'location', header: 'Location', cell: ({ getValue }) => <span className="text-xs text-gray-500">{getValue() as string}</span> },
    {
      accessorKey: 'amount',
      header: 'Amount',
      cell: ({ getValue }) => <span className="text-sm font-bold text-primary">{formatTZS(getValue() as number)}</span>,
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ getValue }) => <StatusBadge status={getValue() as any} />,
    },
    {
      accessorKey: 'date',
      header: 'Date',
      cell: ({ row }) => (
        <div className="text-xs text-gray-500">
          <div className="font-medium text-gray-700">{row.original.date}</div>
          <div>{row.original.time}</div>
        </div>
      ),
    },
    {
      id: 'actions',
      header: '',
      cell: () => (
        <button className="p-1.5 rounded-lg hover:bg-primary/10 transition-colors">
          <Eye className="w-4 h-4 text-primary" />
        </button>
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
    <AdminLayout title="Requests" subtitle="Manage and monitor all client requests">
      {/* Stats row */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Requests" value={1248} change={12.5} up icon={<ClipboardList className="w-5 h-5 text-primary" />} mini />
        <StatCard label="Completed" value={956} change={15.2} up icon={<CheckCircle className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="In Progress" value={198} change={4.3} up={false} icon={<Clock className="w-5 h-5 text-amber-500" />} iconBg="bg-amber-50" mini />
        <StatCard label="Cancelled" value={94} change={8.7} up={false} icon={<XCircle className="w-5 h-5 text-red-500" />} iconBg="bg-red-50" mini />
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
        {/* Toolbar */}
        <div className="p-5 border-b border-gray-100">
          <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between mb-4">
            <h2 className="text-base font-semibold text-gray-900">All Requests</h2>
            <div className="flex items-center gap-2">
              <button className="flex items-center gap-1.5 text-xs font-medium text-gray-600 bg-gray-50 border border-gray-200 px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors">
                <Filter className="w-[14px] h-[14px]" /> Filter
              </button>
              <button className="flex items-center gap-1.5 text-xs font-medium text-primary bg-primary/[0.08] border border-primary/20 px-3 py-2 rounded-lg hover:bg-primary/15 transition-colors">
                <Download className="w-[14px] h-[14px]" /> Export CSV
              </button>
            </div>
          </div>

          {/* Status tabs + search */}
          <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
            <div className="flex gap-1 flex-wrap">
              {STATUS_TABS.map(tab => (
                <button
                  key={tab}
                  onClick={() => setStatusFilter(tab)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    statusFilter === tab
                      ? 'bg-primary text-white'
                      : 'text-gray-500 hover:bg-gray-100'
                  }`}
                >
                  {tab}
                </button>
              ))}
            </div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-[14px] h-[14px] text-gray-400" />
              <input
                value={globalFilter}
                onChange={e => setGlobalFilter(e.target.value)}
                placeholder="Search requests..."
                className="pl-8 pr-4 py-1.5 text-xs bg-gray-50 border border-gray-200 rounded-lg w-48 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40"
              />
            </div>
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              {table.getHeaderGroups().map(hg => (
                <tr key={hg.id} className="border-b border-gray-100 bg-gray-50/50">
                  {hg.headers.map(header => (
                    <th
                      key={header.id}
                      className="px-4 py-3 text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider cursor-pointer hover:text-gray-700 whitespace-nowrap select-none"
                      onClick={header.column.getToggleSortingHandler()}
                    >
                      <div className="flex items-center gap-1">
                        {flexRender(header.column.columnDef.header, header.getContext())}
                        {header.column.getIsSorted() === 'asc' && <ChevronUp className="w-3 h-3" />}
                        {header.column.getIsSorted() === 'desc' && <ChevronDown className="w-3 h-3" />}
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

        {/* Pagination */}
        <div className="px-5 py-4 border-t border-gray-100 flex items-center justify-between">
          <span className="text-xs text-gray-500">
            Showing {table.getState().pagination.pageIndex * table.getState().pagination.pageSize + 1}–
            {Math.min((table.getState().pagination.pageIndex + 1) * table.getState().pagination.pageSize, table.getFilteredRowModel().rows.length)} of {table.getFilteredRowModel().rows.length} requests
          </span>
          <div className="flex items-center gap-1">
            <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50 transition-colors">
              <ChevronLeft className="w-4 h-4 text-gray-600" />
            </button>
            {Array.from({ length: table.getPageCount() }, (_, i) => (
              <button
                key={i}
                onClick={() => table.setPageIndex(i)}
                className={`w-7 h-7 rounded-lg text-xs font-semibold transition-colors ${
                  table.getState().pagination.pageIndex === i
                    ? 'bg-primary text-white'
                    : 'border border-gray-200 text-gray-600 hover:bg-gray-50'
                }`}
              >
                {i + 1}
              </button>
            ))}
            <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()} className="p-1.5 rounded-lg border border-gray-200 disabled:opacity-40 hover:bg-gray-50 transition-colors">
              <ChevronRight className="w-4 h-4 text-gray-600" />
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
