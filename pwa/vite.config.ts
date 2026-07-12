import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Service worker DISABLED — was preventing updates from reaching users.
// The app works fully without it. Re-enable after launch when caching strategy
// is production-tested.

export default defineConfig({
  base: '/',
  plugins: [
    react(),
  ],
  server: { port: 5173 },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
        }
      }
    }
  }
})
