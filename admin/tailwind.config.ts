import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1A5C2A',
          dark: '#0F3D1A',
          light: '#2E7D40',
          surface: '#E8F5E9',
        },
        gold: {
          DEFAULT: '#F9A825',
          light: '#FFF8E1',
          dark: '#F57F17',
        },
        status: {
          completed: '#2E7D32',
          'completed-bg': '#E8F5E9',
          progress: '#1565C0',
          'progress-bg': '#E3F2FD',
          pending: '#F57F17',
          'pending-bg': '#FFF8E1',
          cancelled: '#D32F2F',
          'cancelled-bg': '#FFEBEE',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 2px 12px rgba(0,0,0,0.06)',
        elevated: '0 4px 20px rgba(0,0,0,0.10)',
      },
    },
  },
  plugins: [],
}
export default config
