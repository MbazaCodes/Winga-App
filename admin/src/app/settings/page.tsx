import AdminLayout from '@/components/layout/AdminLayout'

export default function Page() {
  return (
    <AdminLayout title="Module" subtitle="Coming soon">
      <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-12 text-center">
        <div className="text-5xl mb-4">🚧</div>
        <h2 className="text-xl font-bold text-gray-700 mb-2">Module Ready</h2>
        <p className="text-gray-400 text-sm">Data wired — full UI in next iteration.</p>
      </div>
    </AdminLayout>
  )
}
