# 🛍️ Winga App

**Your Trusted Shopping Guide in All Markets**

Winga connects customers with verified local shopping guides (Wingas) in markets like Kariakoo, Mwenge, Arusha, and beyond.

## 📁 Repository Structure

```
Winga-App/
├── mobile/          # Flutter App (Customer + Winga Partner)
│   ├── lib/
│   │   ├── core/           # Theme, router, shared widgets
│   │   │   ├── theme/      # WingaColors, typography, shadows
│   │   │   ├── router/     # GoRouter with all 20+ routes
│   │   │   └── widgets/    # Buttons, cards, shells, nav bars
│   │   ├── features/
│   │   │   ├── auth/       # Splash, onboarding, login, OTP, register
│   │   │   ├── home/       # Customer home, Winga dashboard
│   │   │   ├── booking/    # 6-step booking flow
│   │   │   ├── tracking/   # On-the-way, shopping live view
│   │   │   ├── payment/    # Final payment with M-Pesa etc.
│   │   │   ├── earnings/   # Earnings & transactions
│   │   │   ├── requests/   # My requests with filters
│   │   │   └── profile/    # Winga profile, settings, logout
│   │   └── main.dart
│   └── pubspec.yaml
│
└── admin/           # Next.js Admin Panel (admin.winga.co.tz)
    ├── src/
    │   ├── app/            # App Router pages
    │   │   ├── page.tsx              # Dashboard
    │   │   ├── requests/page.tsx     # Requests + TanStack Table
    │   │   ├── wingas/page.tsx       # Winga management
    │   │   ├── clients/page.tsx      # Client management
    │   │   ├── earnings/page.tsx     # Earnings & payouts
    │   │   ├── transactions/page.tsx # Transaction ledger
    │   │   ├── ratings/page.tsx      # Reviews & ratings
    │   │   └── notifications/page.tsx
    │   ├── components/
    │   │   ├── layout/     # Sidebar, Header, AdminLayout
    │   │   ├── charts/     # Recharts line, bar, donut, area
    │   │   └── ui/         # StatCard, StatusBadge, SectionHeader
    │   └── lib/
    │       └── data.ts     # Mock data & TypeScript types
    ├── package.json
    └── tailwind.config.ts
```

## 🚀 Tech Stack

### Mobile (Flutter)
- **Framework:** Flutter + Riverpod + GoRouter
- **Backend:** Supabase (Auth + DB + Storage)
- **Maps:** Google Maps Flutter
- **Payments:** M-Pesa, Airtel Money, Tigo Pesa, HaloPesa
- **Notifications:** Firebase Cloud Messaging
- **Font:** Inter

### Admin Panel (Next.js)
- **Framework:** Next.js 14 App Router + TypeScript
- **Styling:** Tailwind CSS
- **Charts:** Recharts (Line, Bar, Area, Donut)
- **Tables:** TanStack Table v8
- **Icons:** Lucide React

## 🎨 Design System

| Token | Value |
|---|---|
| Primary (Forest Green) | `#1A5C2A` |
| Gold Accent | `#F9A825` |
| Background | `#F8F9FA` |
| Font | Inter (300–800) |

## 📱 Mobile Screens (28 Dart files)

| Screen | Status |
|---|---|
| Splash + Onboarding | ✅ |
| Login (Phone OTP + Social) | ✅ |
| OTP Verification | ✅ |
| Customer Home | ✅ |
| Choose Service (6-step flow) | ✅ |
| Booking Details + Preferences | ✅ |
| Find a Winga | ✅ |
| Request Confirm + Sent | ✅ |
| Delivery Method | ✅ |
| Winga On The Way (Live Map) | ✅ |
| Winga Shopping (Live Updates) | ✅ |
| Final Payment | ✅ |
| My Requests (12 records, filters) | ✅ |
| Earnings Dashboard | ✅ |
| Winga Profile | ✅ |
| Winga Home Dashboard | ✅ |
| Winga Registration (5-step) | ✅ |

## 🖥️ Admin Panel Pages

| Page | Features |
|---|---|
| Dashboard | 8 stat cards, 3 charts, recent requests, system status |
| Requests | TanStack Table, sorting, pagination, CSV export |
| Wingas | Verification workflow, badges, completion rates |
| Clients | Ban/unban, spending history, activity tracking |
| Earnings | Revenue split (20% platform / 80% Winga), tax reports |
| Transactions | Full ledger with platform fee / payout / tax breakdown |
| Ratings | Star reviews, helpful counts |
| Notifications | Typed alerts (info/success/warning/error) |

## ⚙️ Setup

### Mobile
```bash
cd mobile
flutter pub get
# Add Inter fonts to assets/fonts/
flutter run
```

### Admin Panel
```bash
cd admin
npm install
npm run dev
# Open http://localhost:3000
```

## 🏗️ Business Model
- **Pricing:** TZS 15,000 (Hourly) · 25,000 (Half Day) · 40,000 (Full Day)
- **Commission:** Platform 20% · Winga 80%
- **Tax:** 3–5% per TRA regulations
- **Target Markets:** Kariakoo · Mwenge · Arusha · Moshi

---
Built for the Tanzanian market 🇹🇿
