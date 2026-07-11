import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  void _continue() {
    if (_phoneCtrl.text.length < 9) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        final raw = _phoneCtrl.text
            .replaceAll(RegExp(r'^(\+?255|0)'), '');
        context.push('/otp?phone=$raw');
      }
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Green Header ─────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: WingaColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                  child: Column(
                    children: [
                      // Logo row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 50,
                                color: WingaColors.white,
                              ),
                              Positioned(
                                top: 8,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 22,
                                  color: WingaColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'WINGA',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: WingaColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 22, height: 1, color: WingaColors.gold),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'APP',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: WingaColors.gold,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          Container(width: 22, height: 1, color: WingaColors.gold),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Trusted Guide\nIn ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: WingaColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Karibu! 👋',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: WingaColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingia au jiunge na Winga App',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: WingaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Social buttons
                  _SocialButton(
                    icon: Icons.apple,
                    label: 'Endelea na Apple',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Endelea na Google',
                    isGoogle: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    icon: Icons.facebook_rounded,
                    label: 'Endelea na Facebook',
                    isFacebook: true,
                    onTap: () {},
                  ),

                  // Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: WingaColors.borderLight)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'AU',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: WingaColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: WingaColors.borderLight)),
                      ],
                    ),
                  ),

                  // Phone field
                  const Text(
                    'Ingia kwa namba ya simu',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Country picker
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: WingaColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WingaColors.border),
                        ),
                        child: Row(
                          children: [
                            // TZ Flag emoji
                            const Text('🇹🇿', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 6),
                            const Text(
                              '+255',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Namba ya simu',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: WingaColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: WingaColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: WingaColors.primary, width: 1.5),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  WingaButton(
                    label: 'Endelea',
                    trailing: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                    isLoading: _isLoading,
                    onPressed: _phoneCtrl.text.length >= 9 ? _continue : null,
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: WingaColors.textLight,
                        ),
                        children: [
                          const TextSpan(text: 'Kwa kuendelea, unakubali\n'),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Sheria na Masharti',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: WingaColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Sera ya Faragha',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: WingaColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/winga-register'),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary),
                            children: [
                              TextSpan(text: 'Ungependa kuwa Winga? '),
                              TextSpan(text: 'Jiunge hapa', style: TextStyle(color: WingaColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary),
                            children: [
                              TextSpan(text: 'Mteja mpya? '),
                              TextSpan(text: 'Jisajili hapa', style: TextStyle(color: WingaColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isGoogle;
  final bool isFacebook;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isGoogle = false,
    this.isFacebook = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: WingaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WingaColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.red))
            else if (isFacebook)
              Icon(Icons.facebook_rounded, size: 24, color: const Color(0xFF1877F2))
            else
              Icon(icon, size: 24, color: WingaColors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: WingaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
