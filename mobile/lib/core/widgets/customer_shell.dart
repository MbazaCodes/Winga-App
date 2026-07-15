import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  static const _tabs = ['/home', '/explore', '/book', '/messages', '/profile'];

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
          border: const Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(emoji: '🏠', label: 'Home', isActive: idx == 0, onTap: () => context.go('/home')),
                _NavItem(emoji: '🔍', label: 'Discover', isActive: idx == 1, onTap: () => context.go('/explore')),
                _NavFabItem(onTap: () => context.push('/book')),
                _NavItem(emoji: '💬', label: 'Messages', isActive: idx == 3, onTap: () => context.go('/messages')),
                _NavItem(emoji: '👤', label: 'Profile', isActive: idx == 4, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.emoji, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20, color: isActive ? null : Colors.grey)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? WingaColors.primary : const Color(0xFF9CA3AF))),
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
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: WingaColors.primary, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: WingaColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
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

  static const _tabs = ['/winga/home', '/winga/requests', '/book', '/winga/earnings', '/winga/profile'];

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
          border: const Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(emoji: '📊', label: 'Dashboard', isActive: idx == 0, onTap: () => context.go('/winga/home')),
                _NavItem(emoji: '📋', label: 'Requests', isActive: idx == 1, onTap: () => context.go('/winga/requests')),
                _NavFabItem(onTap: () => context.push('/book')),
                _NavItem(emoji: '💰', label: 'Earnings', isActive: idx == 3, onTap: () => context.go('/winga/earnings')),
                _NavItem(emoji: '👤', label: 'Profile', isActive: idx == 4, onTap: () => context.go('/winga/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
