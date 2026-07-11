import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/customer_home_screen.dart';
import '../../features/home/presentation/screens/winga_home_screen.dart';
import '../../features/booking/presentation/screens/choose_service_screen.dart';
import '../../features/booking/presentation/screens/booking_details_screen.dart';
import '../../features/booking/presentation/screens/booking_preferences_screen.dart';
import '../../features/booking/presentation/screens/find_winga_screen.dart';
import '../../features/booking/presentation/screens/request_confirm_screen.dart';
import '../../features/booking/presentation/screens/delivery_method_screen.dart';
import '../../features/booking/presentation/screens/request_sent_screen.dart';
import '../../features/tracking/presentation/screens/winga_on_the_way_screen.dart';
import '../../features/tracking/presentation/screens/winga_shopping_screen.dart';
import '../../features/payment/presentation/screens/final_payment_screen.dart';
import '../../features/requests/presentation/screens/my_requests_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/winga_register_screen.dart';
import '../widgets/customer_shell.dart';
// winga_shell in customer_shell.dart

final _rootKey = GlobalKey<NavigatorState>();
final _customerShellKey = GlobalKey<NavigatorState>();
final _wingaShellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // ── Splash & Auth ──────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (ctx, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/winga-register',
        builder: (ctx, state) => const WingaRegisterScreen(),
      ),

      // ── Customer Shell ─────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _customerShellKey,
        builder: (ctx, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (ctx, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/requests',
            builder: (ctx, state) => const MyRequestsScreen(),
          ),
          GoRoute(
            path: '/earnings',
            builder: (ctx, state) => const EarningsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Winga Partner Shell ────────────────────────────────────────
      ShellRoute(
        navigatorKey: _wingaShellKey,
        builder: (ctx, state, child) => WingaShell(child: child),
        routes: [
          GoRoute(
            path: '/winga-home',
            builder: (ctx, state) => const WingaHomeScreen(),
          ),
          GoRoute(
            path: '/winga-requests',
            builder: (ctx, state) => const MyRequestsScreen(),
          ),
          GoRoute(
            path: '/winga-earnings',
            builder: (ctx, state) => const EarningsScreen(),
          ),
          GoRoute(
            path: '/winga-profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Booking Flow (no shell) ────────────────────────────────────
      GoRoute(
        path: '/book/service',
        builder: (ctx, state) => const ChooseServiceScreen(),
      ),
      GoRoute(
        path: '/book/details',
        builder: (ctx, state) => const BookingDetailsScreen(),
      ),
      GoRoute(
        path: '/book/preferences',
        builder: (ctx, state) => const BookingPreferencesScreen(),
      ),
      GoRoute(
        path: '/book/find-winga',
        builder: (ctx, state) => const FindWingaScreen(),
      ),
      GoRoute(
        path: '/book/request',
        builder: (ctx, state) => const RequestConfirmScreen(),
      ),
      GoRoute(
        path: '/book/delivery',
        builder: (ctx, state) => const DeliveryMethodScreen(),
      ),
      GoRoute(
        path: '/book/sent',
        builder: (ctx, state) => const RequestSentScreen(),
      ),

      // ── Tracking ──────────────────────────────────────────────────
      GoRoute(
        path: '/tracking/on-the-way',
        builder: (ctx, state) => const WingaOnTheWayScreen(),
      ),
      GoRoute(
        path: '/tracking/shopping',
        builder: (ctx, state) => const WingaShoppingScreen(),
      ),

      // ── Payment ───────────────────────────────────────────────────
      GoRoute(
        path: '/payment/final',
        builder: (ctx, state) => const FinalPaymentScreen(),
      ),
    ],
  );
});
