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

  bool get _isComplete => _ctrls.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                color: WingaColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.phone_android_rounded,
                      size: 50, color: WingaColors.primary),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: WingaColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '***',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 10,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: WingaColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              'Enter the 6-digit code',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: WingaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "We've sent a 6-digit verification code to",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: WingaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+255 ${widget.phone}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: WingaColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (i) => _OtpBox(
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
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Code expires in ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: WingaColors.textSecondary,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              '00:$_seconds',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: WingaColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            // Safety notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: WingaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usalama wako ni muhimu',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WingaColors.primary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Winga App itahakikisha namba yako iko salama na haitashirikishwa.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WingaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Resend
            GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Text(
                    'Hukupokea code?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: WingaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tuma tena code',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            WingaButton(
              label: 'Thibitisha na Endelea',
              trailing: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
              isLoading: _isLoading,
              onPressed: _isComplete ? _verify : null,
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: WingaColors.textLight),
                const SizedBox(width: 6),
                Text(
                  'Hitaji msaada? ',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: WingaColors.textLight),
                ),
                const Text(
                  'Wasiliana nasi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WingaColors.primary,
                  ),
                ),
              ],
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

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: WingaColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
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
            borderSide: const BorderSide(color: WingaColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
