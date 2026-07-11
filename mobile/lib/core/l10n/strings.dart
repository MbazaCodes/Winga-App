// Winga App — Bilingual Strings
// Usage: WingaStrings.of(context).home (reads current language from provider)
// Or: WingaStrings.t(langCode, 'home')

class WingaStrings {
  final String langCode;
  const WingaStrings(this.langCode);

  bool get isSw => langCode == 'sw';

  String get appName => 'Winga App';

  // ── Auth ────────────────────────────────────────────────────────────────
  String get welcome         => isSw ? 'Karibu!' : 'Welcome!';
  String get loginTitle      => isSw ? 'Ingia kwenye Akaunti' : 'Sign in to your account';
  String get phoneLabel      => isSw ? 'Namba ya Simu' : 'Phone Number';
  String get phonePlaceholder => isSw ? '712 345 678' : '712 345 678';
  String get continueBtn     => isSw ? 'Endelea' : 'Continue';
  String get otpTitle        => isSw ? 'Thibitisha Namba' : 'Verify your number';
  String get otpSentTo       => isSw ? 'Tumetuma code kwenda' : 'We sent a code to';
  String get verifyBtn       => isSw ? 'Thibitisha' : 'Verify';
  String get resendCode      => isSw ? 'Tuma tena' : 'Resend code';
  String get resendIn        => isSw ? 'Tuma tena katika' : 'Resend in';
  String get newCustomer     => isSw ? 'Mteja mpya? Jisajili hapa' : 'New customer? Register here';
  String get becomeWinga     => isSw ? 'Ungependa kuwa Winga? Jiunge' : 'Want to be a Winga? Join here';
  String get logoutTitle     => isSw ? 'Toka kwenye Akaunti' : 'Sign Out';
  String get logoutConfirm   => isSw ? 'Una uhakika unataka kutoka?' : 'Are you sure you want to sign out?';
  String get logout          => isSw ? 'Toka' : 'Sign Out';
  String get cancel          => isSw ? 'Ghairi' : 'Cancel';

  // ── Onboarding ───────────────────────────────────────────────────────────
  String get skip            => isSw ? 'Ruka' : 'Skip';
  String get next            => isSw ? 'Endelea →' : 'Next →';
  String get getStarted      => isSw ? 'Anza Sasa →' : 'Get Started →';
  String get onb1Title       => isSw ? 'Karibu Winga App!' : 'Welcome to Winga App!';
  String get onb1Sub         => isSw ? 'Mwongozo wako wa kuaminika katika masoko ya Tanzania' : 'Your trusted shopping guide in Tanzania\'s markets';
  String get onb2Title       => isSw ? 'Pata Winga Wako' : 'Find Your Winga';
  String get onb2Sub         => isSw ? 'Wingas wetu ni wabobezi walioidhinishwa — watakusaidia kupata bidhaa bora kwa bei nzuri' : 'Our verified Wingas are experts who help you find great products at fair prices';
  String get onb3Title       => isSw ? 'Salama na Rahisi' : 'Safe & Easy';
  String get onb3Sub         => isSw ? 'Lipa baada ya huduma. Fuatilia Winga wako wakati wote.' : 'Pay after service. Track your Winga at all times.';

  // ── Home ─────────────────────────────────────────────────────────────────
  String get home            => isSw ? 'Nyumbani' : 'Home';
  String get chooseLocation  => isSw ? 'Chagua Mahali' : 'Choose Location';
  String get greetingMorning => isSw ? 'Habari za Asubuhi' : 'Good Morning';
  String get greetingDay     => isSw ? 'Habari za Mchana' : 'Good Afternoon';
  String get greetingEvening => isSw ? 'Habari za Jioni' : 'Good Evening';
  String get heroTitle       => isSw ? 'Pata Winga wako' : 'Find Your Winga';
  String get heroSub         => isSw ? 'Mwongozo wa kuaminika katika soko lako' : 'Your trusted guide in any market';
  String get bookWinga       => isSw ? 'Omba Winga →' : 'Book a Winga →';
  String get categories      => isSw ? 'Kategoria Maarufu' : 'Popular Categories';
  String get nearbyWingas    => isSw ? 'Wingas Waliopo Karibu' : 'Nearby Wingas';
  String get featuredWingas  => isSw ? 'Wingas Bora' : 'Top Rated Wingas';
  String get seeAll          => isSw ? 'Tazama zote' : 'See all';
  String get online          => isSw ? 'Mtandaoni' : 'Online';
  String get offline         => isSw ? 'Nje ya Mtandao' : 'Offline';
  String get book            => isSw ? 'Omba' : 'Book';
  String get safetyTitle     => isSw ? 'Usalama wako ni muhimu!' : 'Your safety matters!';
  String get safetySub       => isSw ? 'Wingas wetu wote wameidhinishwa na kupitishwa ukaguzi.' : 'All our Wingas are verified and background-checked.';
  String get topRated        => isSw ? 'Top Rated' : 'Top Rated';

  // ── Booking ──────────────────────────────────────────────────────────────
  String get requests        => isSw ? 'Safari Zangu' : 'My Requests';
  String get newRequest      => isSw ? 'Ombi Jipya' : 'New Request';
  String get chooseService   => isSw ? 'Chagua Huduma' : 'Choose Service';
  String get hourly          => isSw ? 'Kwa Saa' : 'Hourly';
  String get halfDay         => isSw ? 'Nusu Siku' : 'Half Day';
  String get fullDay         => isSw ? 'Siku Nzima' : 'Full Day';
  String get meetingPoint    => isSw ? 'Mahali pa Kukutana' : 'Meeting Point';
  String get shoppingArea    => isSw ? 'Eneo la Ununuzi' : 'Shopping Area';
  String get findWinga       => isSw ? 'Tafuta Winga' : 'Find a Winga';
  String get confirmRequest  => isSw ? 'Thibitisha Ombi' : 'Confirm Request';
  String get requestSent     => isSw ? 'Ombi Limetumwa!' : 'Request Sent!';
  String get deliveryMethod  => isSw ? 'Njia ya Kupokea' : 'Delivery Method';
  String get withClient      => isSw ? 'Pamoja nawe' : 'With you';
  String get deliver         => isSw ? 'Niletee nyumbani' : 'Deliver to me';
  String get pickup          => isSw ? 'Nitachukua mwenyewe' : 'I\'ll pick up';
  String get note            => isSw ? 'Maelezo zaidi' : 'Additional notes';
  String get submit          => isSw ? 'Tuma' : 'Submit';
  String get preferredWinga  => isSw ? 'Winga Wako wa Kupenda' : 'Your Preferred Winga';
  String get bookAgain       => isSw ? 'Mwomba tena?' : 'Book again?';

  // ── Status ───────────────────────────────────────────────────────────────
  String get searching       => isSw ? 'Inatafuta Winga' : 'Searching for Winga';
  String get accepted        => isSw ? 'Imekubaliwa' : 'Accepted';
  String get shopping        => isSw ? 'Inanunua' : 'Shopping';
  String get completed       => isSw ? 'Imekamilika' : 'Completed';
  String get cancelled       => isSw ? 'Imefutwa' : 'Cancelled';
  String get pending         => isSw ? 'Inasubiri' : 'Pending';

  // ── Tracking ─────────────────────────────────────────────────────────────
  String get wingaOnTheWay   => isSw ? 'Winga Anakuja' : 'Winga On The Way';
  String get wingaShopping   => isSw ? 'Winga Ananunua' : 'Winga is Shopping';
  String get liveTracking    => isSw ? 'Ufuatiliaji wa Moja kwa Moja' : 'Live Tracking';
  String get eta             => isSw ? 'Muda wa Kuwasili' : 'Estimated Arrival';

  // ── Chat ─────────────────────────────────────────────────────────────────
  String get chat            => isSw ? 'Mazungumzo' : 'Chat';
  String get typeMessage     => isSw ? 'Andika ujumbe...' : 'Type a message...';
  String get startChat       => isSw ? 'Anza mazungumzo na Winga wako' : 'Start chatting with your Winga';
  String get substituteTitle => isSw ? 'Ombi la Kubadilisha Bidhaa' : 'Item Substitution Request';
  String get outOfStock      => isSw ? 'Haipatikani' : 'Out of stock';
  String get suggest         => isSw ? 'Pendekezo' : 'Suggestion';
  String get approve         => isSw ? 'Kubali' : 'Approve';
  String get reject          => isSw ? 'Kataa' : 'Reject';
  String get proposeSubstitute => isSw ? 'Pendekeza Mbadala' : 'Propose Substitute';
  String get photo           => isSw ? 'Picha' : 'Photo';
  String get sendPhoto       => isSw ? 'Tuma Picha' : 'Send Photo';

  // ── Shopping List ────────────────────────────────────────────────────────
  String get shoppingList    => isSw ? 'Orodha ya Ununuzi' : 'Shopping List';
  String get addItem         => isSw ? '+ Ongeza Bidhaa' : '+ Add Item';
  String get itemName        => isSw ? 'Jina la bidhaa *' : 'Item name *';
  String get quantity        => isSw ? 'Idadi' : 'Quantity';
  String get unit            => isSw ? 'Kipimo' : 'Unit';
  String get estimatedPrice  => isSw ? 'Makisio ya bei (TZS)' : 'Estimated price (TZS)';
  String get itemNotes       => isSw ? 'Maelezo zaidi' : 'Additional notes';
  String get totalEstimate   => isSw ? 'Jumla ya Makisio' : 'Total Estimate';
  String get sendList        => isSw ? 'Tuma Orodha kwa Winga' : 'Send List to Winga';

  // ── Payment ──────────────────────────────────────────────────────────────
  String get payment         => isSw ? 'Malipo' : 'Payment';
  String get payNow          => isSw ? 'Lipa Sasa' : 'Pay Now';
  String get total           => isSw ? 'Jumla' : 'Total';
  String get serviceFee      => isSw ? 'Ada ya Huduma' : 'Service Fee';
  String get platformFee     => isSw ? 'Ada ya Mfumo' : 'Platform Fee';
  String get tax             => isSw ? 'Kodi (TRA)' : 'Tax (TRA)';
  String get paymentSuccess  => isSw ? 'Malipo Yamefanikiwa!' : 'Payment Successful!';
  String get addTip          => isSw ? 'Ongeza Tip' : 'Add a Tip';
  String get tipQuestion     => isSw ? 'Je, unataka kumpa tip Winga wako?' : 'Want to tip your Winga?';
  String get wallet          => isSw ? 'Pochi' : 'Wallet';

  // ── Rating ───────────────────────────────────────────────────────────────
  String get rateService     => isSw ? 'Pima Huduma' : 'Rate Service';
  String get goodService     => isSw ? 'Huduma Nzuri' : 'Good Service';
  String get badService      => isSw ? 'Huduma Mbaya' : 'Bad Service';
  String get onePoint        => isSw ? '+1 pointi' : '+1 point';
  String get zeroPoints      => isSw ? '0 pointi' : '0 points';
  String get rateComment     => isSw ? 'Ongeza maoni (hiari)' : 'Add a comment (optional)';
  String get badRateComment  => isSw ? 'Kwa nini? (hiari)' : 'Why? (optional)';
  String get skipForNow      => isSw ? 'Ruka kwa sasa' : 'Skip for now';
  String get thankYou        => isSw ? 'Asante!' : 'Thank you!';
  String get provisionalRank => isSw ? 'Winga Mpya — anaanza' : 'New Winga — getting started';

  // ── Referral ─────────────────────────────────────────────────────────────
  String get referFriends    => isSw ? 'Alika Marafiki' : 'Refer Friends';
  String get referTitle      => isSw ? 'Alika Rafiki, Pata Tuzo!' : 'Refer a Friend, Get Rewards!';
  String get referSub        => isSw ? 'Rafiki yako anapata punguzo la 20%\nWewe unapata TZS 2,000 kwenye pochi yako' : 'Your friend gets 20% off\nYou get TZS 2,000 in your wallet';
  String get myCode          => isSw ? 'Code Yako ya Kualiika' : 'Your Invite Code';
  String get haveCode        => isSw ? 'Una Code ya Rafiki?' : 'Have a friend\'s code?';
  String get applyCode       => isSw ? 'Tumia' : 'Apply';
  String get myWallet        => isSw ? 'Pochi Yangu' : 'My Wallet';
  String get referred        => isSw ? 'Waliojiunga' : 'Referred';

  // ── Earnings ─────────────────────────────────────────────────────────────
  String get earnings        => isSw ? 'Mapato' : 'Earnings';
  String get today           => isSw ? 'Leo' : 'Today';
  String get thisWeek        => isSw ? 'Wiki hii' : 'This week';
  String get thisMonth       => isSw ? 'Mwezi huu' : 'This month';
  String get totalEarnings   => isSw ? 'Mapato Yote' : 'Total Earnings';
  String get transactions    => isSw ? 'Miamala' : 'Transactions';
  String get tips            => isSw ? 'Tips' : 'Tips';
  String get payout          => isSw ? 'Malipo Yangu' : 'My Payout';

  // ── Profile ───────────────────────────────────────────────────────────────
  String get profile         => isSw ? 'Wasifu' : 'Profile';
  String get editProfile     => isSw ? 'Hariri Wasifu' : 'Edit Profile';
  String get name            => isSw ? 'Jina' : 'Name';
  String get email           => isSw ? 'Barua Pepe' : 'Email';
  String get phone           => isSw ? 'Simu' : 'Phone';
  String get specialty       => isSw ? 'Utaalamu' : 'Specialty';
  String get location        => isSw ? 'Mahali' : 'Location';
  String get verified        => isSw ? 'Imeidhinishwa' : 'Verified';
  String get notVerified     => isSw ? 'Haijadhiniishwa' : 'Not Verified';
  String get myRequests      => isSw ? 'Maombi Yangu' : 'My Requests';
  String get shoppingListTab => isSw ? 'Orodha' : 'Lists';
  String get settings        => isSw ? 'Mipangilio' : 'Settings';

  // ── Settings ─────────────────────────────────────────────────────────────
  String get settingsTitle   => isSw ? 'Mipangilio' : 'Settings';
  String get appearance      => isSw ? 'Muonekano' : 'Appearance';
  String get darkMode        => isSw ? 'Hali ya Giza' : 'Dark Mode';
  String get lightMode       => isSw ? 'Hali ya Mwanga' : 'Light Mode';
  String get systemTheme     => isSw ? 'Mfumo wa Simu' : 'Follow System';
  String get language        => isSw ? 'Lugha' : 'Language';
  String get swahili         => isSw ? 'Kiswahili' : 'Swahili';
  String get english         => isSw ? 'Kiingereza' : 'English';
  String get notifications   => isSw ? 'Arifa' : 'Notifications';
  String get pushNotifs      => isSw ? 'Arifa za Kusukuma' : 'Push Notifications';
  String get chatNotifs      => isSw ? 'Arifa za Mazungumzo' : 'Chat Notifications';
  String get account         => isSw ? 'Akaunti' : 'Account';
  String get privacy         => isSw ? 'Faragha' : 'Privacy';
  String get help            => isSw ? 'Msaada' : 'Help & Support';
  String get about           => isSw ? 'Kuhusu Winga' : 'About Winga';
  String get version         => isSw ? 'Toleo' : 'Version';

  // ── Availability ─────────────────────────────────────────────────────────
  String get mySchedule      => isSw ? 'Ratiba ya Kazi' : 'My Schedule';
  String get available       => isSw ? 'Ninapatikana' : 'Available';
  String get unavailable     => isSw ? 'Sipatikani' : 'Unavailable';
  String get startTime       => isSw ? 'Kuanza' : 'Start';
  String get endTime         => isSw ? 'Kumaliza' : 'End';
  String get saveSchedule    => isSw ? 'Hifadhi Ratiba' : 'Save Schedule';
  String get sunday          => isSw ? 'Jumapili' : 'Sunday';
  String get monday          => isSw ? 'Jumatatu' : 'Monday';
  String get tuesday         => isSw ? 'Jumanne' : 'Tuesday';
  String get wednesday       => isSw ? 'Jumatano' : 'Wednesday';
  String get thursday        => isSw ? 'Alhamisi' : 'Thursday';
  String get friday          => isSw ? 'Ijumaa' : 'Friday';
  String get saturday        => isSw ? 'Jumamosi' : 'Saturday';

  // ── Disputes ─────────────────────────────────────────────────────────────
  String get dispute         => isSw ? 'Toa Malalamiko' : 'Report Issue';
  String get disputeCategory => isSw ? 'Aina ya Tatizo *' : 'Issue Type *';
  String get disputeDesc     => isSw ? 'Maelezo *' : 'Description *';
  String get disputeAmount   => isSw ? 'Kiasi kilichoathiriwa (TZS)' : 'Amount Affected (TZS)';
  String get submitDispute   => isSw ? 'Wasilisha Malalamiko' : 'Submit Report';
  String get disputeHint     => isSw ? 'Malalamiko yatashughulikiwa ndani ya masaa 24.' : 'Issues are reviewed within 24 hours.';

  // ── Verification ─────────────────────────────────────────────────────────
  String get starter         => isSw ? 'Mwanzo' : 'Starter';
  String get mid             => isSw ? 'Kati' : 'Mid';
  String get verifiedBadge   => isSw ? 'Imeidhinishwa' : 'Verified';
  String get payFee          => isSw ? 'Lipa Ada ya Uthibitisho' : 'Pay Verification Fee';
  String get perMonth        => isSw ? '/mwezi' : '/month';

  // ── Errors / States ──────────────────────────────────────────────────────
  String get error           => isSw ? 'Hitilafu Imetokea' : 'An Error Occurred';
  String get retry           => isSw ? 'Jaribu Tena' : 'Try Again';
  String get loading         => isSw ? 'Inapakia...' : 'Loading...';
  String get noData          => isSw ? 'Hakuna Data' : 'No Data';
  String get save            => isSw ? 'Hifadhi' : 'Save';
  String get done            => isSw ? 'Imekamilika' : 'Done';
  String get close           => isSw ? 'Funga' : 'Close';
  String get confirm         => isSw ? 'Thibitisha' : 'Confirm';
  String get delete          => isSw ? 'Futa' : 'Delete';
  String get edit            => isSw ? 'Hariri' : 'Edit';
  String get search          => isSw ? 'Tafuta' : 'Search';
  String get filter          => isSw ? 'Chuja' : 'Filter';
  String get share           => isSw ? 'Shiriki' : 'Share';
  String get copy            => isSw ? 'Nakili' : 'Copy';
  String get copied          => isSw ? 'Imenakiliwa!' : 'Copied!';
  String get optional        => isSw ? 'hiari' : 'optional';
  String get required        => isSw ? 'lazima' : 'required';
}

// ── Extension for easy access from BuildContext ──────────────────────────────
// Import the provider, watch it, pass langCode to WingaStrings
WingaStrings stringsOf(String langCode) => WingaStrings(langCode);
