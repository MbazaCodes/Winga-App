import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // Strip any prefix so we always get bare digits e.g. "712345678"
  String get _cleanPhone => _phoneCtrl.text
      .trim()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll(RegExp(r'^\+?255'), '')
      .replaceAll(RegExp(r'^0'), '');

  Future<void> _continue() async {
    if (_cleanPhone.length < 9) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: '+255$_cleanPhone',
      );
      if (!mounted) return;
      context.push('/otp?phone=${_cleanPhone}');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Hitilafu imetokea. Jaribu tena.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green header ────────────────────────────────────────
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 56, color: WingaColors.white),
                          Positioned(
                            top: 10,
                            child: const Icon(Icons.person_rounded,
                                size: 24, color: WingaColors.gold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'WINGA',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: WingaColors.white, letterSpacing: 3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 22, height: 1, color: WingaColors.gold),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('APP',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: WingaColors.gold, letterSpacing: 4)),
                          ),
                          Container(width: 22, height: 1, color: WingaColors.gold),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mwongozo Wako wa Ununuzi Tanzania',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                            color: WingaColors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Karibu! 👋',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 26,
                      fontWeight: FontWeight.w700, color: WingaColors.primary)),
                  const SizedBox(height: 6),
                  const Text('Ingia kwa namba yako ya simu — tutakutumia code ya uthibitisho',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                        color: WingaColors.textSecondary)),
                  const SizedBox(height: 28),

                  // Error banner
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: WingaColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WingaColors.error.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 18, color: WingaColors.error),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                              color: WingaColors.error))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Phone field
                  const Text('Namba ya Simu',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w600, color: WingaColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Country code badge
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: WingaColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WingaColors.border),
                        ),
                        child: const Row(
                          children: [
                            Text('🇹🇿', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 6),
                            Text('+255',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                                  fontWeight: FontWeight.w600, color: WingaColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumberNational],
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 16,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: '712 345 678',
                            hintStyle: const TextStyle(fontFamily: 'Inter',
                                fontSize: 15, color: WingaColors.textLight),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: WingaColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: WingaColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: WingaColors.primary, width: 1.5),
                            ),
                          ),
                          onChanged: (_) => setState(() => _error = null),
                          onFieldSubmitted: (_) => _continue(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  WingaButton(
                    label: 'Pata Code ya OTP',
                    trailing: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                    isLoading: _isLoading,
                    onPressed: _cleanPhone.length >= 9 ? _continue : null,
                  ),

                  const SizedBox(height: 16),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WingaColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: WingaColors.primary),
                      SizedBox(width: 8),
                      Expanded(child: Text(
                        'Tutatumia SMS ya bure kwenye namba yako. Hakuna akaunti inahitajika awali.',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                            color: WingaColors.primary),
                      )),
                    ]),
                  ),

                  const SizedBox(height: 28),

                  // T&C
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                            color: WingaColors.textLight),
                        children: [
                          const TextSpan(text: 'Kwa kuendelea, unakubali '),
                          WidgetSpan(child: GestureDetector(
                            onTap: () {},
                            child: const Text('Sheria na Masharti',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                                  color: WingaColors.primary, fontWeight: FontWeight.w600)),
                          )),
                          const TextSpan(text: ' na '),
                          WidgetSpan(child: GestureDetector(
                            onTap: () {},
                            child: const Text('Sera ya Faragha',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                                  color: WingaColors.primary, fontWeight: FontWeight.w600)),
                          )),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register links
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/winga-register'),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                color: WingaColors.textSecondary),
                            children: [
                              TextSpan(text: 'Ungependa kuwa Winga? '),
                              TextSpan(text: 'Jiunge hapa →',
                                style: TextStyle(color: WingaColors.primary,
                                    fontWeight: FontWeight.w600)),
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
