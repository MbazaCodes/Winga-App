import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _seconds = 45;
  Timer? _timer;
  bool _canResend = false;

  bool get _isComplete => _ctrls.every((c) => c.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() { _seconds = 45; _canResend = false; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _verify() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/home');
      }
    });
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
        title: const Text('Verify your number'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: WingaColors.primarySurface, shape: BoxShape.circle),
              child: const Icon(Icons.phone_android_rounded,
                  size: 50, color: WingaColors.primary),
            ),
            const SizedBox(height: 28),
            const Text('Enter the 6-digit code',
                style: TextStyle(fontFamily: 'Inter', fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Sent to +255 ${widget.phone}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                    color: WingaColors.textSecondary)),
            const SizedBox(height: 32),
            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) => _OtpBox(
                controller: _ctrls[i],
                focusNode: _focusNodes[i],
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (v.isEmpty && i > 0) {
                    _focusNodes[i - 1].requestFocus();
                  }
                  setState(() {});
                },
              )),
            ),
            const SizedBox(height: 20),
            // Countdown
            _canResend
                ? TextButton(
                    onPressed: _startTimer,
                    child: const Text('Resend Code',
                        style: TextStyle(fontFamily: 'Inter',
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: WingaColors.primary)),
                  )
                : Text(
                    'Resend code in 00:${_seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                        color: WingaColors.textSecondary),
                  ),
            // Safety notice
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: WingaColors.primary),
                SizedBox(width: 12),
                Expanded(child: Text(
                  'Usalama wako ni muhimu. Kamwe usishirikishe code hii na mtu yeyote.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                      color: WingaColors.textSecondary))),
              ]),
            ),
            const Spacer(),
            WingaButton(
              label: 'Thibitisha na Endelea',
              isLoading: _isLoading,
              onPressed: _isComplete ? _verify : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, height: 56,
      child: TextField(
        controller: controller, focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WingaColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WingaColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WingaColors.primary, width: 2)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
