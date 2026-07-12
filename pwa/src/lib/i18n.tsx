import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react'

/* ------------------------------------------------------------------ */
/*  Translation maps                                                   */
/* ------------------------------------------------------------------ */

type Translations = Record<string, string>

const sw: Translations = {
  // Common
  'common.online': 'Mtandaoni',
  'common.offline': 'Nje',
  'common.trips': 'safari',
  'common.ratings': 'Makadirio',
  'common.rating': 'Ukadiriaji',
  'common.view': 'Tazama',
  'common.discover': 'Gundua',
  'common.select': 'Teua',
  'common.sending': 'Inatuma...',
  'common.submitting': 'Inawasilisha...',
  'common.tryAgain': 'Jaribu tena',
  'common.errorOccurred': 'Hitilafu imetokea',
  'common.please': 'Tafadhali',
  'common.all': 'Wote',

  // HomeScreen
  'home.morning': 'Habari za Asubuhi',
  'home.afternoon': 'Habari za Mchana',
  'home.evening': 'Habari za Jioni',
  'home.welcomeUser': 'Karibu, {name}!',
  'home.welcome': 'Karibu Winga App!',
  'home.requestWinga': 'Omba Winga',
  'home.requestDesc': 'Tuma ombi kwa Winga zote waliopo',
  'home.request': 'Omba',
  'home.discoverWingas': 'Gundua Wingas',
  'home.discoverDesc': 'Tazama na teua Winga wako',
  'home.discover': 'Gundua',
  'home.searchPlaceholder': 'Tafuta Winga au bidhaa...',
  'home.categories': 'Kategoria za Safari',
  'home.viewAll': 'Tazama Zote',
  'home.topWingas': 'Wingas Bora',
  'home.discoverMore': 'Gundua Zaidi',
  'home.availableWingas': 'Wingas Waliopo',
  'home.online': 'mtandaoni',
  'home.results': 'Matokeo',
  'home.noWingaFor': 'Hakuna Winga kwa',
  'home.noOnlineWingas': 'Hakuna Winga mtandaoni sasa hivi',
  'home.viewAll2': 'Tazama wote',
  'home.discoverAllWingas': 'Gundua Wingas Zote',
  'home.top': 'TOP',
  'home.wingasFound': 'Wingas waliopatikana',

  // BookingScreen
  'booking.title': 'Omba Winga',
  'booking.category': 'Kategoria',
  'booking.meetingPoint': 'Mahali pa Kukutana',
  'booking.shoppingArea': 'Eneo la Manunuzi',
  'booking.serviceType': 'Aina ya Huduma',
  'booking.1hour': 'Saa 1',
  'booking.halfDay': 'Nusu Siku',
  'booking.fullDay': 'Siku Nzima',
  'booking.deliveryMethod': 'Njia ya Upoaji',
  'booking.withCustomer': 'Na Mteja',
  'booking.weDeliver': 'Tunawasilisha',
  'booking.note': 'Maoni',
  'booking.optional': 'hiari',
  'booking.notePlaceholder': 'Maoni ya ziada...',
  'booking.estimatedCost': 'Gharama Inayokadiriwa',
  'booking.selectCategory': 'Tafadhali chagua kategoria.',
  'booking.enterMeetingPoint': 'Tafadhali weka mahali pa kukutana.',
  'booking.enterShoppingArea': 'Tafadhali weka eneo la manunuzi.',
  'booking.selectServiceType': 'Tafadhali chagua aina ya huduma.',
  'booking.selectDeliveryMethod': 'Tafadhali chagua njia ya upoaji.',
  'booking.pleaseLogin': 'Tafadhali ingia tena.',
  'booking.permissionError': 'Hitilafu ya ruhusa. Tafadhali toka na uingie tena.',
  'booking.accountError': 'Tatizo la akaunti. Tafadhali toka na uingie tena.',
  'booking.sendRequest': 'Tuma Ombi',
  'booking.sending': 'Inatuma...',

  // LoginScreen
  'login.welcome': 'Karibu!',
  'login.subtitle': 'Ingiza namba yako au Winga ID — tutatuma code ya OTP bure',
  'login.phoneNumber': 'Namba ya Simu',
  'login.wingaId': 'Winga ID',
  'login.getOtp': 'Pata Code ya OTP',
  'login.sending': 'Inatuma...',
  'login.enterOtp': 'Ingiza Code ya OTP',
  'login.sentTo': 'Tumetuma SMS kwenda',
  'login.resendAfter': 'Tuma tena baada ya',
  'login.resendCode': 'Tuma Code Tena',
  'login.verifyContinue': 'Thibitisha na Endelea',
  'login.verifying': 'Inathibitisha...',
  'login.welcomeApp': 'Karibu Winga App!',
  'login.yourName': 'Jina Lako',
  'login.enterRealName': 'Ingiza jina lako halisi',
  'login.wingasWillKnow': 'Wingas watakujua kwa jina hili',
  'login.yourFullName': 'Jina Lako Kamili',
  'login.saveContinue': 'Hifadhi na Endelea',
  'login.skipForNow': 'Ruka kwa sasa',
  'login.canChangeName': 'Unaweza kubadilisha jina lako kwenye Wasifu wako baadaye',
  'login.codeExpired': 'Code imeisha muda. Tuma tena.',
  'login.codeInvalid': 'Code si sahihi. Jaribu tena.',
  'login.phoneHint': 'Bila +255 au 0 mwanzoni',
  'login.wingaIdHint': 'Winga ID inaanza na "WNGA"',
  'login.otpSafe': 'SMS ya OTP ni ya bure na salama kabisa.',
  'login.wantWinga': 'Ungependa kuwa Winga?',
  'login.joinHere': 'Jiunge hapa',
  'login.tagline': 'Mwongozo Wako wa Ununuzi Tanzania',
  'login.wingaIdNotFound': 'Winga ID "{id}" haipatikani. Angalia na urudi tena.',
  'login.searching': '⏳ Inatafuta...',
  'login.loginWithWingaId': 'Ingia kwa Winga ID →',

  // RequestsScreen
  'requests.myTrips': 'Safari Zangu',
  'requests.all': 'Zote',
  'requests.active': 'Inaendelea',
  'requests.completed': 'Zilizokamilika',
  'requests.cancelled': 'Zilizohairishwa',
  'requests.searching': 'Inatafuta Winga...',
  'requests.accepted': 'Imekubaliwa',
  'requests.shopping': 'Winga Ananunua...',
  'requests.completedStatus': 'Imekamilika',
  'requests.cancelledStatus': 'Imehairishwa',
  'requests.noTrips': 'Huna safari bado',
  'requests.noTripsDesc': 'Omba Winga sasa na upate huduma bora',
  'requests.requestNow': 'Omba Winga Sasa',
  'requests.rateService': 'Pima Huduma',
  'requests.ratedGood': '👍 Umepima huduma: Nzuri',
  'requests.ratedBad': '👎 Umepima huduma: Mbaya',
  'requests.howWasService': 'Jinsi gani ulipata huduma?',
  'requests.tripWith': 'Safari na',
  'requests.goodService': 'Huduma Nzuri',
  'requests.badService': 'Huduma Mbaya',
  'requests.feedbackPlaceholder': 'Maoni yako (si lazima)',
  'requests.submit': 'Wasilisha',
  'requests.thanksRating': 'Asante kwa pima yako!',
  'requests.ratingSubmitted': 'Pima yako imewasilishwa',
  'requests.loadFailed': 'Imeshindwa kupakia safari',
  'requests.submitFailed': 'Imeshindwa kuwasilisha pima',
  'requests.justNow': 'Dakika 0 iliyopita',
  'requests.minutesAgo': '{m}m iliyopita',
  'requests.hoursAgo': '{h}h iliyopita',
  'requests.daysAgo': '{d}d iliyopita',
  'requests.monthsAgo': '{mo}mo iliyopita',
  'requests.request': 'Ombi',
  'requests.shoppingShort': 'Inanunua',
  'requests.directRequest': 'Ombi la moja kwa moja kwa',
  'requests.tryAgain': 'Jaribu Tena',

  // ProfileScreen
  'profile.myProfile': 'Wasifu Wangu',
  'profile.tapToChange': 'Bonyeza kubadilisha jina',
  'profile.customer': 'Mteja',
  'profile.trips': 'Safari',
  'profile.completed': 'Zilizokamilika',
  'profile.wallet': 'Pochi',
  'profile.myTrips': 'Safari Zangu',
  'profile.allRequests': 'Maombi yako yote',
  'profile.spending': 'Matumizi',
  'profile.paymentHistory': 'Historia ya malipo',
  'profile.messages': 'Ujumbe',
  'profile.wingaConvos': 'Mazungumzo na Wingas',
  'profile.inviteFriends': 'Alika Marafiki',
  'profile.inviteDesc': 'Pata TZS 2,000 kwa rafiki',
  'profile.notifications': 'Arifa',
  'profile.notifSettings': 'Mipangilio ya arifa',
  'profile.wantWinga': 'Ungependa Kuwa Winga?',
  'profile.earnText': 'Chapisha TZS 12,000–32,000 kwa saa ukisaidia wateja kununua',
  'profile.joinAsWinga': 'Jiunge kama Winga',
  'profile.logout': 'Toka kwenye Akaunti',
  'profile.save': 'Hifadhi',
  'profile.cancel': 'Ghairi',
  'profile.uploadFailed': 'Imeshindwa kupakia picha',

  // NearbyWingasScreen
  'nearby.title': 'Gundua Wingas',
  'nearby.cards': 'Kadi',
  'nearby.list': 'Orodha',
  'nearby.searchPlaceholder': 'Tafuta jina, eneo, au specialty...',
  'nearby.all': 'Wote',
  'nearby.noCategoryWingas': 'Hakuna Winga kwa kategoria hii bado',
  'nearby.noAvailableWingas': 'Hakuna Winga waliopo sasa hivi',
  'nearby.tryLater': 'Jaribu tena baadaye au badilisha chujio',
  'nearby.tapViewProfile': 'Bonyeza kuona wasifu kamili',
  'nearby.selectWinga': 'Teua Winga Huu',
  'nearby.sendingRequest': 'Inatuma ombi...',
  'nearby.swipeHint': 'Teleka kadi kulia/kushoto au bonyeza kitufe',
  'nearby.wingasFound': 'Wingas waliopatikana',
  'nearby.wingaProfile': 'Wasifu wa Winga',
  'nearby.info': 'Taarifa',
  'nearby.about': 'Kuhusu',
  'nearby.selectNow': 'Teua Winga Huu Sasa',
  'nearby.wingaOffline': 'Winga Huyu Hayuko Mtandaoni',
  'nearby.wingaOfflineDesc': 'Winga huyu hayuko mtandaoni. Unaweza kutuma ombi la jumla litakalofikishwa apo atakapoingia.',
  'nearby.topRated': 'TOP RATED',
  'nearby.offlineBtn': 'Nje ya Mtandao',

  // BottomNav
  'nav.home': 'Nyumbani',
  'nav.discover': 'Gundua',
  'nav.trips': 'Safari',
  'nav.messages': 'Ujumbe',
  'nav.profile': 'Wasifu',
}

const en: Translations = {
  // Common
  'common.online': 'Online',
  'common.offline': 'Offline',
  'common.trips': 'trips',
  'common.ratings': 'Ratings',
  'common.rating': 'Rating',
  'common.view': 'View',
  'common.discover': 'Discover',
  'common.select': 'Select',
  'common.sending': 'Sending...',
  'common.submitting': 'Submitting...',
  'common.tryAgain': 'Try again',
  'common.errorOccurred': 'An error occurred',
  'common.please': 'Please',
  'common.all': 'All',

  // HomeScreen
  'home.morning': 'Good Morning',
  'home.afternoon': 'Good Afternoon',
  'home.evening': 'Good Evening',
  'home.welcomeUser': 'Welcome, {name}!',
  'home.welcome': 'Welcome to Winga App!',
  'home.requestWinga': 'Request a Winga',
  'home.requestDesc': 'Send request to all available Wingas',
  'home.request': 'Request',
  'home.discoverWingas': 'Discover Wingas',
  'home.discoverDesc': 'Browse and select your Winga',
  'home.discover': 'Discover',
  'home.searchPlaceholder': 'Search Winga or product...',
  'home.categories': 'Shopping Categories',
  'home.viewAll': 'View All',
  'home.topWingas': 'Top Wingas',
  'home.discoverMore': 'Discover More',
  'home.availableWingas': 'Available Wingas',
  'home.online': 'online',
  'home.results': 'Results',
  'home.noWingaFor': 'No Winga found for',
  'home.noOnlineWingas': 'No Wingas online right now',
  'home.viewAll2': 'View all',
  'home.discoverAllWingas': 'Discover All Wingas',
  'home.top': 'TOP',
  'home.wingasFound': 'Wingas found',

  // BookingScreen
  'booking.title': 'Request a Winga',
  'booking.category': 'Category',
  'booking.meetingPoint': 'Meeting Point',
  'booking.shoppingArea': 'Shopping Area',
  'booking.serviceType': 'Service Type',
  'booking.1hour': '1 Hour',
  'booking.halfDay': 'Half Day',
  'booking.fullDay': 'Full Day',
  'booking.deliveryMethod': 'Delivery Method',
  'booking.withCustomer': 'With Customer',
  'booking.weDeliver': 'We Deliver',
  'booking.note': 'Note',
  'booking.optional': 'optional',
  'booking.notePlaceholder': 'Additional notes...',
  'booking.estimatedCost': 'Estimated Cost',
  'booking.selectCategory': 'Please select a category.',
  'booking.enterMeetingPoint': 'Please enter meeting point.',
  'booking.enterShoppingArea': 'Please enter shopping area.',
  'booking.selectServiceType': 'Please select service type.',
  'booking.selectDeliveryMethod': 'Please select delivery method.',
  'booking.pleaseLogin': 'Please log in again.',
  'booking.permissionError': 'Permission error. Please log out and log in again.',
  'booking.accountError': 'Account issue. Please log out and log in again.',
  'booking.sendRequest': 'Send Request',
  'booking.sending': 'Sending...',

  // LoginScreen
  'login.welcome': 'Welcome!',
  'login.subtitle': 'Enter your number or Winga ID — we\'ll send a free OTP code',
  'login.phoneNumber': 'Phone Number',
  'login.wingaId': 'Winga ID',
  'login.getOtp': 'Get OTP Code',
  'login.sending': 'Sending...',
  'login.enterOtp': 'Enter OTP Code',
  'login.sentTo': 'We sent SMS to',
  'login.resendAfter': 'Resend after',
  'login.resendCode': 'Resend Code',
  'login.verifyContinue': 'Verify & Continue',
  'login.verifying': 'Verifying...',
  'login.welcomeApp': 'Welcome to Winga App!',
  'login.yourName': 'Your Name',
  'login.enterRealName': 'Enter your real name',
  'login.wingasWillKnow': 'Wingas will know you by this name',
  'login.yourFullName': 'Your Full Name',
  'login.saveContinue': 'Save & Continue',
  'login.skipForNow': 'Skip for now',
  'login.canChangeName': 'You can change your name in your Profile later',
  'login.codeExpired': 'Code expired. Please resend.',
  'login.codeInvalid': 'Invalid code. Please try again.',
  'login.phoneHint': 'Without +255 or 0 at the start',
  'login.wingaIdHint': 'Winga ID starts with "WNGA"',
  'login.otpSafe': 'OTP SMS is free and completely safe.',
  'login.wantWinga': 'Want to be a Winga?',
  'login.joinHere': 'Join here',
  'login.tagline': 'Your Shopping Guide Tanzania',
  'login.wingaIdNotFound': 'Winga ID "{id}" not found. Check and try again.',
  'login.searching': '⏳ Searching...',
  'login.loginWithWingaId': 'Login with Winga ID →',

  // RequestsScreen
  'requests.myTrips': 'My Trips',
  'requests.all': 'All',
  'requests.active': 'Active',
  'requests.completed': 'Completed',
  'requests.cancelled': 'Cancelled',
  'requests.searching': 'Searching for Winga...',
  'requests.accepted': 'Accepted',
  'requests.shopping': 'Winga is Shopping...',
  'requests.completedStatus': 'Completed',
  'requests.cancelledStatus': 'Cancelled',
  'requests.noTrips': 'No trips yet',
  'requests.noTripsDesc': 'Request a Winga now and get great service',
  'requests.requestNow': 'Request a Winga Now',
  'requests.rateService': 'Rate Service',
  'requests.ratedGood': '👍 You rated: Good',
  'requests.ratedBad': '👎 You rated: Bad',
  'requests.howWasService': 'How was your service?',
  'requests.tripWith': 'Trip with',
  'requests.goodService': 'Good Service',
  'requests.badService': 'Bad Service',
  'requests.feedbackPlaceholder': 'Your feedback (optional)',
  'requests.submit': 'Submit',
  'requests.thanksRating': 'Thanks for your rating!',
  'requests.ratingSubmitted': 'Your rating has been submitted',
  'requests.loadFailed': 'Failed to load trips',
  'requests.submitFailed': 'Failed to submit rating',
  'requests.justNow': 'Just now',
  'requests.minutesAgo': '{m}m ago',
  'requests.hoursAgo': '{h}h ago',
  'requests.daysAgo': '{d}d ago',
  'requests.monthsAgo': '{mo}mo ago',
  'requests.request': 'Request',
  'requests.shoppingShort': 'Shopping',
  'requests.directRequest': 'Direct request to',
  'requests.tryAgain': 'Try Again',

  // ProfileScreen
  'profile.myProfile': 'My Profile',
  'profile.tapToChange': 'Tap to change name',
  'profile.customer': 'Customer',
  'profile.trips': 'Trips',
  'profile.completed': 'Completed',
  'profile.wallet': 'Wallet',
  'profile.myTrips': 'My Trips',
  'profile.allRequests': 'All your requests',
  'profile.spending': 'Spending',
  'profile.paymentHistory': 'Payment history',
  'profile.messages': 'Messages',
  'profile.wingaConvos': 'Conversations with Wingas',
  'profile.inviteFriends': 'Invite Friends',
  'profile.inviteDesc': 'Get TZS 2,000 per friend',
  'profile.notifications': 'Notifications',
  'profile.notifSettings': 'Notification settings',
  'profile.wantWinga': 'Want to be a Winga?',
  'profile.earnText': 'Earn TZS 12,000–32,000/hr helping customers shop',
  'profile.joinAsWinga': 'Join as Winga',
  'profile.logout': 'Log Out',
  'profile.save': 'Save',
  'profile.cancel': 'Cancel',
  'profile.uploadFailed': 'Failed to upload photo',

  // NearbyWingasScreen
  'nearby.title': 'Discover Wingas',
  'nearby.cards': 'Cards',
  'nearby.list': 'List',
  'nearby.searchPlaceholder': 'Search name, area, or specialty...',
  'nearby.all': 'All',
  'nearby.noCategoryWingas': 'No Wingas in this category yet',
  'nearby.noAvailableWingas': 'No Wingas available right now',
  'nearby.tryLater': 'Try again later or change filter',
  'nearby.tapViewProfile': 'Tap to view full profile',
  'nearby.selectWinga': 'Select This Winga',
  'nearby.sendingRequest': 'Sending request...',
  'nearby.swipeHint': 'Swipe card left/right or tap buttons',
  'nearby.wingasFound': 'Wingas found',
  'nearby.wingaProfile': 'Winga Profile',
  'nearby.info': 'Information',
  'nearby.about': 'About',
  'nearby.selectNow': 'Select This Winga Now',
  'nearby.wingaOffline': 'This Winga is Offline',
  'nearby.wingaOfflineDesc': 'This Winga is not online. You can send a general request that will be delivered when they come online.',
  'nearby.topRated': 'TOP RATED',
  'nearby.offlineBtn': 'Offline',

  // BottomNav
  'nav.home': 'Home',
  'nav.discover': 'Discover',
  'nav.trips': 'Trips',
  'nav.messages': 'Messages',
  'nav.profile': 'Profile',
}

/* ------------------------------------------------------------------ */
/*  Context                                                            */
/* ------------------------------------------------------------------ */

type Lang = 'sw' | 'en'

interface LangCtxValue {
  lang: Lang
  setLang: (l: Lang) => void
}

const LangContext = createContext<LangCtxValue>({
  lang: 'sw',
  setLang: () => {},
})

const STORAGE_KEY = 'winga_lang'

/* ------------------------------------------------------------------ */
/*  Provider                                                           */
/* ------------------------------------------------------------------ */

export function LangProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<Lang>(() => {
    if (typeof window === 'undefined') return 'sw'
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'en' || stored === 'sw') return stored
    return 'sw'
  })

  const setLang = useCallback((l: Lang) => {
    setLangState(l)
    localStorage.setItem(STORAGE_KEY, l)
  }, [])

  const value = useMemo(() => ({ lang, setLang }), [lang, setLang])

  return <LangContext.Provider value={value}>{children}</LangContext.Provider>
}

/* ------------------------------------------------------------------ */
/*  Hooks                                                              */
/* ------------------------------------------------------------------ */

export function useLang(): LangCtxValue {
  return useContext(LangContext)
}

export function useT(): (key: string, params?: Record<string, string>) => string {
  const { lang } = useLang()
  const dict = lang === 'en' ? en : sw

  return useCallback(
    (key: string, params?: Record<string, string>) => {
      let str = dict[key] || sw[key] || en[key] || key
      if (params) {
        Object.entries(params).forEach(([k, v]) => {
          str = str.replaceAll(`{${k}}`, v)
        })
      }
      return str
    },
    [lang],
  )
}

/* ------------------------------------------------------------------ */
/*  LangToggle component                                               */
/* ------------------------------------------------------------------ */

export function LangToggle() {
  const { lang, setLang } = useLang()
  const other = lang === 'sw' ? 'EN' : 'SW'

  return (
    <button
      onClick={() => setLang(lang === 'sw' ? 'en' : 'sw')}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 4,
        padding: '4px 10px',
        borderRadius: 20,
        border: '1.5px solid #E5E7EB',
        background: lang === 'en' ? '#1A5C2A' : '#fff',
        color: lang === 'en' ? '#fff' : '#374151',
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: 700,
        cursor: 'pointer',
        letterSpacing: 0.5,
        lineHeight: 1,
        transition: 'all 0.2s',
      }}
    >
      {other}
    </button>
  )
}