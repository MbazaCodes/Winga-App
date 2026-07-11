'use client'
import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/AdminLayout'
import StatCard from '@/components/ui/StatCard'
import StatusBadge from '@/components/ui/StatusBadge'
import { SectionHeader, DateRangePicker, ViewAllLink } from '@/components/ui/SectionHeader'
import RequestsOverviewChart from '@/components/charts/RequestsOverviewChart'
import CategoryDonutChart from '@/components/charts/CategoryDonutChart'
import EarningsBarChart from '@/components/charts/EarningsBarChart'
import {
  dashboardStats, earningsSummary, recentRequests, formatTZS
} from '@/lib/data'
import {
  ShoppingBag, CheckCircle, Clock, XCircle, Users,
  Wallet, UserPlus, TrendingUp, TrendingDown,
  CheckCircle2, Activity
} from 'lucide-react'

export default function DashboardPage() {
  const [stats, setStats] = useState<any>(null)

  useEffect(() => {
    fetch('/api/stats')
      .then(r => r.json())
      .then(setStats)
      .catch(() => {})
  }, [])

  const s = dashboardStats
  const e = earningsSummary

  return (
    <AdminLayout
      title="Dashboard"
      subtitle="Overview of Winga platform activities and performance."
    >
      {/* Date Range */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-sm text-gray-500 mt-0.5">Overview of Winga platform activities and performance.</p>
        </div>
        <DateRangePicker />
      </div>

      {/* ── Top 5 Stat Cards ──────────────────────────────────────── */}
      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
        <StatCard
          label="Total Requests"
          value={s.totalRequests.value}
          change={s.totalRequests.change}
          up={s.totalRequests.up}
          icon={<ShoppingBag className="w-5 h-5 text-primary" />}
          iconBg="bg-primary/10"
        />
        <StatCard
          label="Completed Requests"
          value={s.completedRequests.value}
          change={s.completedRequests.change}
          up={s.completedRequests.up}
          icon={<CheckCircle className="w-5 h-5 text-blue-600" />}
          iconBg="bg-blue-50"
        />
        <StatCard
          label="In Progress"
          value={s.inProgress.value}
          change={s.inProgress.change}
          up={s.inProgress.up}
          icon={<Clock className="w-5 h-5 text-amber-500" />}
          iconBg="bg-amber-50"
        />
        <StatCard
          label="Cancelled Requests"
          value={s.cancelled.value}
          change={s.cancelled.change}
          up={s.cancelled.up}
          icon={<XCircle className="w-5 h-5 text-purple-600" />}
          iconBg="bg-purple-50"
        />
        <StatCard
          label="Active Winga"
          value={s.activeWingas.value}
          change={s.activeWingas.change}
          up={s.activeWingas.up}
          icon={<Users className="w-5 h-5 text-primary" />}
          iconBg="bg-primary/10"
        />
      </div>

      {/* ── Middle Row: Earnings + Clients + Signups ──────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        {/* Total Earnings card with mini chart */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Wallet className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold text-gray-700">Total Earnings (After Tax)</span>
            </div>
            <button className="text-xs font-medium text-gray-500 bg-gray-50 border border-gray-200 px-2.5 py-1 rounded-lg flex items-center gap-1">
              This Week <span className="text-gray-400">▾</span>
            </button>
          </div>
          <div className="text-3xl font-extrabold text-gray-900 mb-1">{formatTZS(s.totalEarnings.value)}</div>
          <div className="flex items-center gap-1.5 text-green-600 text-xs font-semibold mb-3">
            <TrendingUp className="w-3.5 h-3.5" />
            {s.totalEarnings.change}% vs last week
          </div>
          <EarningsBarChart />
        </div>

        {/* Total Clients */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Users className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold text-gray-700">Total Clients (Users)</span>
            </div>
            <button className="text-xs font-medium text-gray-500 bg-gray-50 border border-gray-200 px-2.5 py-1 rounded-lg">This Week ▾</button>
          </div>
          <div className="text-3xl font-extrabold text-gray-900 mb-1">{s.totalClients.value.toLocaleString()}</div>
          <div className="flex items-center gap-1.5 text-green-600 text-xs font-semibold mb-6">
            <TrendingUp className="w-3.5 h-3.5" />{s.totalClients.change}% vs last week
          </div>
          {/* Mini stats grid */}
          <div className="grid grid-cols-2 gap-3 mt-2">
            {[
              { label: 'New This Week', value: '124', color: 'text-primary' },
              { label: 'Returning', value: '2,410', color: 'text-blue-600' },
              { label: 'DSM', value: '1,890', color: 'text-gray-700' },
              { label: 'Other Cities', value: '644', color: 'text-gray-700' },
            ].map(item => (
              <div key={item.label} className="bg-gray-50 rounded-xl p-3">
                <div className={`text-lg font-bold ${item.color}`}>{item.value}</div>
                <div className="text-[10px] text-gray-500 font-medium mt-0.5">{item.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* New Winga Signups */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <UserPlus className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold text-gray-700">New Winga Signups</span>
            </div>
            <button className="text-xs font-medium text-gray-500 bg-gray-50 border border-gray-200 px-2.5 py-1 rounded-lg">This Week ▾</button>
          </div>
          <div className="text-3xl font-extrabold text-gray-900 mb-1">{s.newWingaSignups.value}</div>
          <div className="flex items-center gap-1.5 text-green-600 text-xs font-semibold mb-6">
            <TrendingUp className="w-3.5 h-3.5" />{s.newWingaSignups.change}% vs last week
          </div>
          <div className="space-y-3">
            {[
              { label: 'Verified', value: 38, color: 'bg-primary' },
              { label: 'Pending Verification', value: 7, color: 'bg-amber-400' },
            ].map(item => (
              <div key={item.label}>
                <div className="flex justify-between text-xs font-medium mb-1">
                  <span className="text-gray-600">{item.label}</span>
                  <span className="text-gray-800 font-semibold">{item.value}</span>
                </div>
                <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                  <div className={`h-full rounded-full ${item.color}`} style={{ width: `${(item.value / 45) * 100}%` }} />
                </div>
              </div>
            ))}
          </div>
          <div className="mt-4 pt-4 border-t border-gray-100">
            <div className="flex items-center justify-between text-xs">
              <span className="text-gray-500">Approval rate this week</span>
              <span className="font-bold text-primary">84.4%</span>
            </div>
          </div>
        </div>
      </div>

      {/* ── Bottom Row: Charts + Recent Requests ─────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        {/* Requests Overview (spans 2 cols) */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <SectionHeader title="Requests Overview" periodSelector />
          <RequestsOverviewChart />
        </div>

        {/* By Category donut */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <SectionHeader title="Requests by Category" />
          <CategoryDonutChart />
        </div>
      </div>

      {/* ── Recent Requests + Earnings Summary + System Status ────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Recent Requests (2 col) */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card p-5">
          <SectionHeader title="Recent Requests" action={<ViewAllLink href="/requests" />} />
          <div className="space-y-2">
            {recentRequests.slice(0, 4).map((req) => (
              <div key={req.id} className="flex items-center gap-3 py-2.5 border-b border-gray-50 last:border-0">
                {/* Avatar */}
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-xs font-bold text-primary">{req.client.split(' ').map(n => n[0]).join('')}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-semibold text-gray-800 truncate">{req.category}</span>
                  </div>
                  <div className="text-xs text-gray-500 truncate">{req.location} • {req.date} • {req.time}</div>
                </div>
                <StatusBadge status={req.status} />
              </div>
            ))}
          </div>
        </div>

        {/* Earnings Summary + System Status */}
        <div className="flex flex-col gap-4">
          {/* Earnings Summary */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">Earnings Summary (After Tax)</h3>
            <div className="grid grid-cols-2 gap-3">
              {[
                { label: 'Today', value: e.today.value, change: e.today.change, up: e.today.up },
                { label: 'This Week', value: e.thisWeek.value, change: e.thisWeek.change, up: e.thisWeek.up },
                { label: 'This Month', value: e.thisMonth.value, change: e.thisMonth.change, up: e.thisMonth.up },
                { label: 'Last Month', value: e.lastMonth.value, change: e.lastMonth.change, up: e.lastMonth.up },
              ].map(item => (
                <div key={item.label} className="bg-gray-50 rounded-xl p-3">
                  <div className="text-[10px] text-gray-500 font-medium mb-1">{item.label}</div>
                  <div className="text-sm font-bold text-gray-900 leading-tight">{formatTZS(item.value)}</div>
                  <div className={`flex items-center gap-0.5 text-[10px] font-semibold mt-0.5 ${item.up ? 'text-green-600' : 'text-red-500'}`}>
                    {item.up ? <TrendingUp className="w-2.5 h-2.5" /> : <TrendingDown className="w-2.5 h-2.5" />}
                    {item.change}%
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* System Status */}
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
            <h3 className="text-sm font-semibold text-gray-900 mb-3">System Status</h3>
            <div className="flex items-center gap-2 mb-3">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              <span className="text-sm font-semibold text-green-600">All Systems Operational</span>
            </div>
            <p className="text-xs text-gray-400 mb-4">Last checked: May 16, 2026 10:45 AM</p>
            {[
              { name: 'API Server', status: 99.9 },
              { name: 'Payment Gateway', status: 99.7 },
              { name: 'Maps Service', status: 100 },
              { name: 'Push Notifications', status: 98.5 },
            ].map(item => (
              <div key={item.name} className="flex items-center justify-between mb-2 last:mb-0">
                <div className="flex items-center gap-2">
                  <Activity className="w-3 h-3 text-green-500" />
                  <span className="text-xs text-gray-600">{item.name}</span>
                </div>
                <span className="text-xs font-semibold text-green-600">{item.status}%</span>
              </div>
            ))}
            <button className="mt-4 w-full text-xs font-semibold text-primary border border-primary/20 bg-primary/5 py-2 rounded-lg hover:bg-primary/10 transition-colors">
              View Status
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
