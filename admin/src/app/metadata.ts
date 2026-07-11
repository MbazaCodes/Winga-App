import type { Metadata } from 'next'

export const siteMetadata: Metadata = {
  title: {
    template: '%s | Winga Admin',
    default: 'Winga Admin Panel',
  },
  description: 'Winga App Admin Dashboard — Verify Wingas, manage requests, view analytics',
  keywords: ['Winga', 'Tanzania', 'Shopping Guide', 'Admin'],
  authors: [{ name: 'Winga Technologies Ltd' }],
  creator: 'Winga Technologies Ltd',
  icons: {
    icon: '/favicon.svg',
    shortcut: '/favicon.svg',
    apple: '/apple-touch-icon.png',
  },
  openGraph: {
    type: 'website',
    locale: 'sw_TZ',
    url: 'https://admin.winga.co.tz',
    siteName: 'Winga Admin',
    title: 'Winga Admin Panel',
    description: 'Winga App Admin Dashboard',
    images: [{ url: '/og-image.png', width: 1200, height: 630, alt: 'Winga Admin' }],
  },
  themeColor: '#1A5C2A',
  viewport: 'width=device-width, initial-scale=1',
  manifest: '/manifest.json',
}
