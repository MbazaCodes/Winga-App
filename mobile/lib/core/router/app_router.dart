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
import '../../features/home/presentation/screens/explore_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/chat/presentation/screens/messages_screen.dart';
import '../../features/payment/presentation/screens/final_payment_screen.dart';
import '../../features/requests/presentation/screens/my_requests_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/tracking/presentation/screens/winga_on_the_way_screen.dart';
import '../../features/tracking/presentation/screens/winga_shopping_screen.dart';
import '../../features/auth/presentation/screens/winga_register_screen.dart';
import '../../features/rating/presentation/screens/rate_trip_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/substitution_proposal_screen.dart';
import '../../features/location/presentation/screens/city_picker_screen.dart';
import '../../features/shopping_list/presentation/screens/shopping_list_screen.dart';
import '../../features/referral/presentation/screens/referral_screen.dart';
import '../../features/availability/presentation/screens/winga_availability_screen.dart';
import '../../features/disputes/presentation/screens/dispute_screen.dart';

import '../widgets/customer_shell.dart';
import '../widgets/winga_shell.dart';

import '../../features/home/presentation/screens/categories_screen.dart';

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
      // ── New feature routes ──────────────────────────────────
      GoRoute(
        path: '/categories',
        builder: (ctx, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/chat/:requestId',
        builder: (ctx, state) => ChatScreen(
          requestId: state.pathParameters['requestId'] ?? '',
          wingaName: state.uri.queryParameters['winga'] ?? 'Winga',
          isWinga: state.uri.queryParameters['role'] == 'winga',
        ),
      ),
      GoRoute(
        path: '/chat/:requestId/substitution',
        builder: (ctx, state) => SubstitutionProposalScreen(
          requestId: state.pathParameters['requestId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/pick-city',
        builder: (ctx, state) => const CityPickerScreen(),
      ),
      GoRoute(
        path: '/shopping-list/:requestId',
        builder: (ctx, state) => ShoppingListScreen(
          requestId: state.pathParameters['requestId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/referral',
        builder: (ctx, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/availability/:wingaId',
        builder: (ctx, state) => WingaAvailabilityScreen(
          wingaId: state.pathParameters['wingaId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/dispute/:requestId',
        builder: (ctx, state) => DisputeScreen(
          requestId: state.pathParameters['requestId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/rate',
        builder: (ctx, state) {
          final requestId = state.uri.queryParameters['request'] ?? '';
          final wingaName = state.uri.queryParameters['winga'] ?? 'Winga';
          return RateTripScreen(requestId: requestId, wingaName: wingaName);
        },
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
            path: '/explore',
            builder: (ctx, state) => const NearbyWingasScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (ctx, state) => const MessagesScreen(),
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
            path: '/winga/home',
            builder: (ctx, state) => const WingaHomeScreen(),
          ),
          GoRoute(
            path: '/winga/requests',
            builder: (ctx, state) => const MyRequestsScreen(),
          ),
          GoRoute(
            path: '/winga/earnings',
            builder: (ctx, state) => const EarningsScreen(isWinga: true),
          ),
          GoRoute(
            path: '/winga/profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Booking Flow ──────────────────────────────────────────────
      GoRoute(
        path: '/book',
        builder: (ctx, state) {
          final cat = state.uri.queryParameters['category'];
          return BookingScreen(initialCategory: cat);
        },
      ),

      // ── Tracking ──────────────────────────────────────────────────
      GoRoute(
        path: '/tracking/on-the-way',
        builder: (ctx, state) => WingaOnTheWayScreen(),
      ),
      GoRoute(
        path: '/tracking/shopping',
        builder: (ctx, state) => WingaShoppingScreen(),
      ),

      // ── Payment ───────────────────────────────────────────────────
      GoRoute(
        path: '/payment/final',
        builder: (ctx, state) => FinalPaymentScreen(
          requestId: state.uri.queryParameters['request'] ?? '',
        ),
      ),
    ],
  );
});
