import type { Metadata } from 'next'
import './globals.css'

export const dynamic = 'force-dynamic'
export const metadata: Metadata = {
  title: 'Winga Admin Panel',
  description: 'Winga App Administration Dashboard',
  icons: {
    icon: '/favicon.ico',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
