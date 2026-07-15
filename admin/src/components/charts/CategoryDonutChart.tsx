'use client'
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts'
import { categoryData } from '@/lib/data'

const CustomLabel = ({ cx, cy, total }: { cx: number; cy: number; total: number }) => (
  <>
    <text x={cx} y={cy - 8} textAnchor="middle" fill="#1A1A1A" style={{ fontSize: 26, fontWeight: 800, fontFamily: 'Inter' }}>
      {total}
    </text>
    <text x={cx} y={cy + 14} textAnchor="middle" fill="#9CA3AF" style={{ fontSize: 11, fontFamily: 'Inter', fontWeight: 500 }}>
      Total
    </text>
  </>
)

export default function CategoryDonutChart() {
  return (
    <div className="flex items-center gap-6">
      <div className="flex-shrink-0">
        <ResponsiveContainer width={180} height={180}>
          <PieChart>
            <Pie
              data={categoryData}
              cx="50%"
              cy="50%"
              innerRadius={55}
              outerRadius={82}
              paddingAngle={2}
              dataKey="value"
              labelLine={false}
              label={({ cx, cy }) => <CustomLabel cx={cx} cy={cy} total={1248} />}
            >
              {categoryData.map((entry, i) => (
                <Cell key={i} fill={entry.color} stroke="none" />
              ))}
            </Pie>
            <Tooltip
              formatter={(value: number) => [`${value}%`, '']}
              contentStyle={{ fontFamily: 'Inter', fontSize: 12, borderRadius: 10, border: '1px solid #E5E7EB' }}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Legend */}
      <div className="flex flex-col gap-2.5 flex-1">
        {categoryData.map((item) => (
          <div key={item.name} className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2 min-w-0">
              <span className="w-[10px] h-[10px] rounded-full flex-shrink-0" style={{ background: item.color }} />
              <span className="text-xs text-gray-600 truncate font-medium">{item.name}</span>
            </div>
            <span className="text-xs font-bold text-gray-800 flex-shrink-0">{item.value}%</span>
          </div>
        ))}
      </div>
    </div>
  )
}
