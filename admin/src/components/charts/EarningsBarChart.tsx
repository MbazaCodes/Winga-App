'use client'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { weeklyEarningsData } from '@/lib/data'

const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-white border border-gray-100 rounded-xl shadow-elevated p-3 text-xs">
        <p className="font-semibold text-gray-700 mb-1.5">{label}</p>
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-primary" />
          <span className="text-gray-500">Earnings:</span>
          <span className="font-bold text-gray-800">TZS {payload[0]?.value?.toLocaleString()}</span>
        </div>
      </div>
    )
  }
  return null
}

export default function EarningsBarChart() {
  return (
    <ResponsiveContainer width="100%" height={180}>
      <BarChart data={weeklyEarningsData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }} barSize={22}>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" vertical={false} />
        <XAxis dataKey="day" tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }} axisLine={false} tickLine={false} />
        <YAxis tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }} axisLine={false} tickLine={false} tickFormatter={(v) => `${v/1000}k`} />
        <Tooltip content={<CustomTooltip />} cursor={{ fill: '#F3F4F6', radius: 6 }} />
        <Bar dataKey="earnings" fill="#1A5C2A" radius={[6, 6, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  )
}
