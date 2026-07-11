import AdminLayout from '@/components/layout/AdminLayout'
import StatCard from '@/components/ui/StatCard'
import { reviews } from '@/lib/data'
import { Star, ThumbsUp, MessageSquare, TrendingUp } from 'lucide-react'

export default function RatingsPage() {
  return (
    <AdminLayout title="Ratings & Reviews" subtitle="Platform ratings and customer feedback">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard label="Average Rating" value="4.8 ★" icon={<Star className="w-5 h-5 text-amber-400" />} iconBg="bg-amber-50" mini />
        <StatCard label="Total Reviews" value={reviews.length} change={8.3} up icon={<MessageSquare className="w-5 h-5 text-primary" />} mini />
        <StatCard label="5-Star Reviews" value={reviews.filter(r=>r.rating===5).length} icon={<ThumbsUp className="w-5 h-5 text-green-600" />} iconBg="bg-green-50" mini />
        <StatCard label="Response Rate" value="94%" change={2.1} up icon={<TrendingUp className="w-5 h-5 text-blue-500" />} iconBg="bg-blue-50" mini />
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-5">
        <h2 className="text-base font-semibold text-gray-900 mb-4">Recent Reviews</h2>
        <div className="space-y-4">
          {reviews.map(r => (
            <div key={r.id} className="border border-gray-100 rounded-xl p-4">
              <div className="flex items-start justify-between gap-3 mb-2">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center">
                    <span className="text-xs font-bold text-primary">{r.client.split(' ').map(n=>n[0]).join('')}</span>
                  </div>
                  <div>
                    <div className="text-sm font-semibold text-gray-800">{r.client}</div>
                    <div className="text-xs text-gray-500">Reviewed <span className="font-medium text-primary">{r.winga}</span> · {r.category}</div>
                  </div>
                </div>
                <div className="flex items-center gap-1 flex-shrink-0">
                  {Array.from({length:5}).map((_,i) => (<Star key={i} className={`w-[14px] h-[14px] ${i<r.rating?'text-amber-400 fill-amber-400':'text-gray-200'}`} />))}
                  <span className="text-xs font-bold text-gray-700 ml-1">{r.rating}.0</span>
                </div>
              </div>
              <p className="text-sm text-gray-600 leading-relaxed">{r.comment}</p>
              <div className="flex items-center gap-4 mt-3 text-xs text-gray-400">
                <span>{r.date}</span>
                <button className="flex items-center gap-1 hover:text-primary transition-colors"><ThumbsUp className="w-3 h-3" />{r.helpful} helpful</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  )
}
