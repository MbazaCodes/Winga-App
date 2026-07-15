# Winga PWA — iPhone & iOS Support

A full Progressive Web App (PWA) for iOS users who can't install from App Store.
Works exactly like a native app when installed on iPhone home screen.

## 🍎 iPhone Install (Share your link with users)

Send users to: **https://app.winga.co.tz**

iPhone install steps (shown automatically in-app):
1. Open the link in **Safari** (must be Safari, not Chrome)
2. Tap the **Share** button (🔗 at the bottom)
3. Scroll down → tap **"Add to Home Screen"**
4. Tap **"Add"** top right
5. App appears on home screen — opens full screen like native! ✅

## 🌐 Deploy to Vercel

1. Go to vercel.com/new
2. Import MbazaCodes/Winga-App
3. Set **Root Directory** to `pwa`
4. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Deploy → get URL like `winga-pwa.vercel.app`

## ✨ PWA Features

| Feature | Status |
|---|---|
| Install to home screen (iOS Safari) | ✅ |
| Fullscreen (no browser bar) | ✅ |
| Offline support (service worker) | ✅ |
| iOS safe area (notch support) | ✅ |
| Install prompt banner in Swahili | ✅ |
| All iPhone sizes (SE → 15 Pro Max) | ✅ |
| Splash screen for every iPhone | ✅ |
| App icon all sizes | ✅ |
| PWA shortcuts (Book, Requests) | ✅ |
| Supabase auth (OTP) | ✅ |
| Route protection | ✅ |
| Customer + Winga flows | ✅ |

## 📁 Structure

```
pwa/
├── index.html          ← Full iOS meta tags, splash screens, icons
├── vite.config.ts      ← Vite + vite-plugin-pwa (auto service worker)
├── src/
│   ├── App.tsx         ← Routes + auth guards
│   ├── lib/
│   │   ├── supabase.ts ← Supabase client
│   │   ├── session.ts  ← localStorage session
│   │   └── constants.ts
│   ├── screens/        ← All app screens
│   ├── components/
│   │   ├── layout/     ← AppBar, BottomNav
│   │   └── ui/         ← InstallBanner (iOS prompt), Badge
│   └── index.css       ← CSS variables, iOS safe areas
└── public/
    ├── icons/          ← App icons all sizes
    └── screenshots/    ← App store screenshots
```

## 🚀 Run Locally

```bash
cd pwa
npm install
npm run dev
# Open http://localhost:5173
```

## 📱 Generate App Icons

Use https://realfavicongenerator.net or https://pwabuilder.com
Upload one 512×512 PNG icon → download all sizes → put in public/icons/
