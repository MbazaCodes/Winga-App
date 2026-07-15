'use client'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { monthlyTrendsData } from '@/lib/data'

export default function TrendsChart() {
  return (
    <ResponsiveContainer width="100%" height={200}>
      <AreaChart data={monthlyTrendsData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
        <defs>
          <linearGradient id="colorRequests" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#1A5C2A" stopOpacity={0.15} />
            <stop offset="95%" stopColor="#1A5C2A" stopOpacity={0} />
          </linearGradient>
          <linearGradient id="colorClients" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#1565C0" stopOpacity={0.15} />
            <stop offset="95%" stopColor="#1565C0" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
        <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }} axisLine={false} tickLine={false} />
        <YAxis tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }} axisLine={false} tickLine={false} />
        <Tooltip contentStyle={{ fontFamily: 'Inter', fontSize: 12, borderRadius: 10, border: '1px solid #E5E7EB' }} />
        <Legend wrapperStyle={{ fontSize: '11px', fontFamily: 'Inter', paddingTop: '10px' }} iconType="circle" iconSize={8} />
        <Area type="monotone" dataKey="requests" name="Requests" stroke="#1A5C2A" strokeWidth={2.5} fill="url(#colorRequests)" dot={{ r: 3, fill: '#1A5C2A', strokeWidth: 0 }} />
        <Area type="monotone" dataKey="clients" name="Clients" stroke="#1565C0" strokeWidth={2.5} fill="url(#colorClients)" dot={{ r: 3, fill: '#1565C0', strokeWidth: 0 }} />
      </AreaChart>
    </ResponsiveContainer>
  )
}
