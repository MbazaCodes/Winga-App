import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../../../core/widgets/winga_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _seconds = 60;
  Timer? _timer;
  bool _canResend = false;
  String? _error;

  String get _otp => _ctrls.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() { _seconds = 60; _canResend = false; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        setState(() => _canResend = true);
        t.cancel();
      }
    });
  }

  Future<void> _resend() async {
    setState(() { _isResending = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: '+255${widget.phone}',
      );
      _startTimer();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Hitilafu. Jaribu tena.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verify() async {
    if (!_isComplete) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      debugPrint('Verifying OTP for phone: +255${widget.phone} with token: $_otp');
      final res = await Supabase.instance.client.auth.verifyOTP(
        phone: '+255${widget.phone}',
        token: _otp,
        type: OtpType.sms,
      );

      if (res.session == null) {
        setState(() => _error = 'Uthibitisho umeshindwa. Tafadhali jaribu login upya.');
        return;
      }

      final userId = res.session!.user.id;
      debugPrint('Auth successful. User ID: $userId');

      // Check our users table
      final userRow = await Supabase.instance.client
          .from('users')
          .select('id, user_type, name')
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (userRow == null) {
        debugPrint('User record not found in public.users. Creating one...');
        // New user — create customer record
        try {
          await Supabase.instance.client.from('users').insert({
            'id': userId,
            'phone': '+255${widget.phone}',
            'user_type': 'customer',
            'is_verified': true,
            'name': 'Mteja Mpya',
          });
          debugPrint('User record created successfully.');
        } catch (e) {
          debugPrint('Error creating user record: $e');
          setState(() => _error = 'Hatuwezi kutengeneza wasifu: $e');
          return;
        }
      }

      final typeStr = (userRow?['user_type'] ?? 'customer') as String;
      final type = typeStr == 'winga' ? UserType.winga : UserType.customer;

      await WingaSession.setSession(userId, type);
      debugPrint('Session saved. Routing to home...');

      if (mounted) {
        context.go(type == UserType.winga ? '/winga/home' : '/home');
      }
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      if (!mounted) return;
      setState(() {
        _error = e.message.contains('Invalid')
            ? 'Code si sahihi. Angalia na ujaribu tena.'
            : e.message;
      });
    } catch (e) {
      debugPrint('Generic Exception during verify: $e');
      if (mounted) setState(() => _error = 'Hitilafu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDigitChanged(String val, int i) {
    if (val.length > 1) {
      // Handle paste — distribute digits across boxes
      final digits = val.replaceAll(RegExp(r'\D'), '');
      for (int j = 0; j < digits.length && i + j < 6; j++) {
        _ctrls[i + j].text = digits[j];
      }
      final next = (i + digits.length).clamp(0, 5);
      _focusNodes[next].requestFocus();
    } else if (val.isNotEmpty) {
      if (i < 5) _focusNodes[i + 1].requestFocus();
    } else if (val.isEmpty) {
      if (i > 0) _focusNodes[i - 1].requestFocus();
    }
    setState(() => _error = null);
    if (_isComplete) _verify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Thibitisha Namba'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Icon
              Container(
                width: 88, height: 88,
                decoration: const BoxDecoration(
                  color: WingaColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.sms_outlined,
                    size: 44, color: WingaColors.primary),
              ),
              const SizedBox(height: 24),

              const Text('Ingiza Code ya OTP',
                style: TextStyle(fontFamily: 'Inter', fontSize: 22,
                    fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                      color: WingaColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Tumetuma SMS kwenda '),
                    TextSpan(
                      text: '+255 ${widget.phone}',
                      style: const TextStyle(fontWeight: FontWeight.w600,
                          color: WingaColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) => _onDigitChanged(v, i),
                  hasError: _error != null,
                )),
              ),

              const SizedBox(height: 16),

              // Error
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WingaColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 16, color: WingaColors.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                          color: WingaColors.error))),
                  ]),
                ),

              const SizedBox(height: 16),

              // Countdown / Resend
              if (_canResend)
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: _isResending
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: WingaColors.primary))
                      : const Text('Tuma Code Tena',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                              fontWeight: FontWeight.w600, color: WingaColors.primary)),
                )
              else
                Text(
                  'Tuma tena baada ya 00:${_seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: WingaColors.textSecondary),
                ),

              const SizedBox(height: 16),

              // Security note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WingaColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline_rounded, size: 15, color: WingaColors.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'Usalama wako ni muhimu. Kamwe usishirikishe code hii na mtu yeyote.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: WingaColors.primary),
                  )),
                ]),
              ),

              const SizedBox(height: 40),

              WingaButton(
                label: 'Thibitisha na Endelea',
                isLoading: _isLoading,
                onPressed: _isComplete && !_isLoading ? _verify : null,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44, height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(fontFamily: 'Inter', fontSize: 22,
            fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: controller.text.isNotEmpty
              ? WingaColors.primarySurface
              : WingaColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? WingaColors.error : WingaColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? WingaColors.error : WingaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? WingaColors.error : WingaColors.primary,
              width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
