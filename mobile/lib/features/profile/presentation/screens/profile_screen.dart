import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: WingaColors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, size: 26),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.settings_outlined,
                            size: 24, color: WingaColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Profile Hero Card ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WingaColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Top: avatar + name + edit
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Row(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: WingaColors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: WingaColors.white.withOpacity(0.3),
                                    width: 2),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 44, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: WingaColors.gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: WingaColors.primary, width: 2),
                                ),
                                child: const Icon(Icons.check,
                                    size: 12,
                                    color: WingaColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Ahmed Juma',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: WingaColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        size: 11, color: WingaColors.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Winga ID
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(
                                      text: 'WNGA12345'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Winga ID copied!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      'Winga ID: WNGA12345',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(Icons.copy_rounded,
                                        size: 13,
                                        color: Colors.white.withOpacity(0.6)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: WingaColors.gold),
                                  const SizedBox(width: 3),
                                  const Text(
                                    '4.9 (128 trips)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 1,
                                    height: 12,
                                    color: Colors.white30,
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.shield_outlined,
                                      size: 13, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Verified Winga',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Wallet + Earnings row
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        // Wallet
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Wallet Balance',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _balanceVisible = !_balanceVisible),
                                    child: Icon(
                                      _balanceVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _balanceVisible ? 'TZS 32,500' : 'TZS •••••',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'View Wallet →',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WingaColors.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                            width: 1,
                            height: 56,
                            color: Colors.white.withOpacity(0.2)),
                        const SizedBox(width: 16),
                        // Earnings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Earnings (After Tax)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'TZS 328,500',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/winga-earnings'),
                                child: Row(
                                  children: const [
                                    Icon(Icons.account_balance_wallet_outlined,
                                        size: 13, color: Colors.white38),
                                    const SizedBox(width: 4),
                                    Text(
                                      'View Earnings →',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: WingaColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Account Information ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Information',
                      style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  _SettingsCard(items: [
                    _SettingsItem(
                      icon: Icons.phone_android_outlined,
                      label: 'Phone Number',
                      value: '+255 7XX XXX XXX',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: 'ahmedjuma@gmail.com',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.location_on_outlined,
                      label: 'Home Address',
                      value: 'Kariakoo, Dar es Salaam, Tanzania',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.badge_outlined,
                      label: 'National ID',
                      value: '1990XXXXXXXXXX',
                      badge: 'Verified',
                      badgeColor: WingaColors.successText,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Member Since',
                      value: '12 March 2024',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 20),
                  const Text('Preferences', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  _SettingsCard(items: [
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: 'Manage your notification settings',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      value: 'English',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                        activeColor: WingaColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.shield_outlined,
                      label: 'Security',
                      value: 'Change password, PIN & security settings',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 20),
                  const Text('Other', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),

                  // 2-column other grid
                  Row(
                    children: [
                      Expanded(
                        child: _SettingsCard(items: [
                          _SettingsItem(
                            icon: Icons.headset_mic_outlined,
                            label: 'Help & Support',
                            value: 'Get help and support',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            label: 'Terms & Conditions',
                            value: 'Read our terms',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsCard(items: [
                          _SettingsItem(
                            icon: Icons.info_outline_rounded,
                            label: 'About Winga',
                            value: 'App version 1.0.0',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            value: 'Read our policy',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _SettingsCard(items: [
                    _SettingsItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      value: 'Sign out from your account',
                      iconColor: WingaColors.error,
                      labelColor: WingaColors.error,
                      onTap: () => _confirmLogout(context),
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WingaColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WingaColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: WingaColors.error, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Log Out?',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to log out of your Winga account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: WingaColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WingaColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log Out',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Settings Card ──────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: WingaShadows.card,
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => _SettingsRow(item: e.value))
            .toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final String? badge;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.badge,
    this.badgeColor,
    this.iconColor,
    this.labelColor,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItem item;
  const _SettingsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: item.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (item.iconColor ?? WingaColors.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon,
                      size: 18,
                      color: item.iconColor ?? WingaColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.labelColor ?? WingaColors.textPrimary,
                        ),
                      ),
                      if (item.value != null)
                        Text(
                          item.value!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WingaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (item.badgeColor ?? WingaColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.badgeColor ?? WingaColors.primary,
                      ),
                    ),
                  ),
                if (item.trailing != null) item.trailing!,
                if (item.trailing == null && item.onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: WingaColors.textLight),
              ],
            ),
          ),
        ),
        if (item.showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: WingaColors.borderLight),
          ),
      ],
    );
  }
}
