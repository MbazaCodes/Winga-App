import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  base: '/',
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['icons/*.png', 'screenshots/*.png'],
      manifest: {
        name: 'Winga App',
        short_name: 'Winga',
        description: 'Your Trusted Shopping Guide in All Markets',
        theme_color: '#1A5C2A',
        background_color: '#1A5C2A',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '/',
        scope: '/',
        id: 'com.winga.app',
        icons: [
          { src: '/mobile/icons/icon-72.png',   sizes: '72x72',   type: 'image/png' },
          { src: '/mobile/icons/icon-96.png',   sizes: '96x96',   type: 'image/png' },
          { src: '/mobile/icons/icon-128.png',  sizes: '128x128', type: 'image/png' },
          { src: '/mobile/icons/icon-144.png',  sizes: '144x144', type: 'image/png' },
          { src: '/mobile/icons/icon-152.png',  sizes: '152x152', type: 'image/png' },
          { src: '/mobile/icons/icon-192.png',  sizes: '192x192', type: 'image/png', purpose: 'any maskable' },
          { src: '/mobile/icons/icon-384.png',  sizes: '384x384', type: 'image/png' },
          { src: '/mobile/icons/icon-512.png',  sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
        ],
        screenshots: [
          { src: '/mobile/screenshots/home.png', sizes: '390x844', type: 'image/png', form_factor: 'narrow', label: 'Home Screen' },
          { src: '/mobile/screenshots/booking.png', sizes: '390x844', type: 'image/png', form_factor: 'narrow', label: 'Book a Winga' },
        ],
        categories: ['shopping', 'lifestyle', 'utilities'],
        shortcuts: [
          {
            name: 'Book a Winga',
            short_name: 'Book Now',
            description: 'Quickly book a shopping guide',
            url: '/mobile/book',
            icons: [{ src: '/mobile/icons/icon-96.png', sizes: '96x96' }],
          },
          {
            name: 'My Requests',
            short_name: 'Requests',
            description: 'View your shopping requests',
            url: '/mobile/requests',
            icons: [{ src: '/mobile/icons/icon-96.png', sizes: '96x96' }],
          },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/kevdbsyiqelksxvmuped\.supabase\.co\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'supabase-api-cache',
              expiration: { maxEntries: 100, maxAgeSeconds: 300 },
              networkTimeoutSeconds: 10,
            },
          },
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: { cacheName: 'google-fonts-cache', expiration: { maxEntries: 10, maxAgeSeconds: 31536000 } },
          },
        ],
      },
      devOptions: { enabled: true },
    }),
  ],
  server: { port: 5173 },
})