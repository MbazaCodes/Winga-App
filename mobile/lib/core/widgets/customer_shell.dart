import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  static const _tabs = ['/home', '/requests', '/earnings', '/profile'];

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexWhere((t) => loc.startsWith(t));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _getIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WingaColors.white,
          border: const Border(top: BorderSide(color: WingaColors.borderLight, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                  label: 'Nyumbani', isActive: idx == 0, onTap: () => context.go('/home')),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded,
                  label: 'Safari', isActive: idx == 1, onTap: () => context.go('/requests')),
                _NavFabItem(onTap: () => context.push('/book/service')),
                _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Mapato', isActive: idx == 2, onTap: () => context.go('/earnings')),
                _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                  label: 'Wasifu', isActive: idx == 3, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, size: 24, color: isActive ? WingaColors.primary : WingaColors.textLight),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? WingaColors.primary : WingaColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _NavFabItem extends StatelessWidget {
  final VoidCallback onTap;
  const _NavFabItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: WingaColors.primary, shape: BoxShape.circle,
                boxShadow: WingaShadows.button),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class WingaShell extends StatelessWidget {
  final Widget child;
  const WingaShell({super.key, required this.child});

  static const _tabs = ['/winga-home', '/winga-requests', '/winga-earnings', '/winga-profile'];

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexWhere((t) => loc.startsWith(t));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _getIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WingaColors.white,
          border: const Border(top: BorderSide(color: WingaColors.borderLight, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard', isActive: idx == 0, onTap: () => context.go('/winga-home')),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded,
                  label: 'Maombi', isActive: idx == 1, onTap: () => context.go('/winga-requests')),
                _NavFabItem(onTap: () {}),
                _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Mapato', isActive: idx == 2, onTap: () => context.go('/winga-earnings')),
                _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                  label: 'Wasifu', isActive: idx == 3, onTap: () => context.go('/winga-profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
