export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#1A5C2A', dark: '#0F3D1A', light: '#2E7D40', surface: '#E8F5E9' },
        gold: { DEFAULT: '#F9A825', dark: '#F57F17', light: '#FFF8E1' },
      },
      fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
    },
  },
  plugins: [],
}
