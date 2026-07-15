'use client'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer
} from 'recharts'
import { requestsOverviewData } from '@/lib/data'

const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-white border border-gray-100 rounded-xl shadow-elevated p-3 text-xs">
        <p className="font-semibold text-gray-700 mb-2">{label}</p>
        {payload.map((p: any) => (
          <div key={p.dataKey} className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full" style={{ background: p.color }} />
            <span className="text-gray-500">{p.name}:</span>
            <span className="font-semibold text-gray-800">{p.value}</span>
          </div>
        ))}
      </div>
    )
  }
  return null
}

export default function RequestsOverviewChart() {
  return (
    <ResponsiveContainer width="100%" height={220}>
      <LineChart data={requestsOverviewData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
        <XAxis
          dataKey="date"
          tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tick={{ fontSize: 11, fill: '#9CA3AF', fontFamily: 'Inter' }}
          axisLine={false}
          tickLine={false}
        />
        <Tooltip content={<CustomTooltip />} />
        <Legend
          wrapperStyle={{ fontSize: '11px', fontFamily: 'Inter', paddingTop: '12px' }}
          iconType="circle"
          iconSize={8}
        />
        <Line
          type="monotone"
          dataKey="completed"
          name="Completed"
          stroke="#1A5C2A"
          strokeWidth={2.5}
          dot={{ fill: '#1A5C2A', r: 3, strokeWidth: 0 }}
          activeDot={{ r: 5 }}
        />
        <Line
          type="monotone"
          dataKey="inProgress"
          name="In Progress"
          stroke="#F9A825"
          strokeWidth={2.5}
          dot={{ fill: '#F9A825', r: 3, strokeWidth: 0 }}
          activeDot={{ r: 5 }}
        />
        <Line
          type="monotone"
          dataKey="cancelled"
          name="Cancelled"
          stroke="#EF4444"
          strokeWidth={2}
          strokeDasharray="4 4"
          dot={{ fill: '#EF4444', r: 3, strokeWidth: 0 }}
          activeDot={{ r: 5 }}
        />
      </LineChart>
    </ResponsiveContainer>
  )
}
