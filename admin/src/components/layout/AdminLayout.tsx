import Sidebar from './Sidebar'
import Header from './Header'

interface AdminLayoutProps {
  children: React.ReactNode
  title: string
  subtitle?: string
  notifCount?: number
}

export default function AdminLayout({ children, title, subtitle, notifCount = 3 }: AdminLayoutProps) {
  return (
    <div className="flex h-screen bg-[#F8F9FA] overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-[210px] overflow-hidden">
        <Header title={title} subtitle={subtitle} notifCount={notifCount} />
        <main className="flex-1 overflow-y-auto p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
