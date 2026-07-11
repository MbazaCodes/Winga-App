import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class WingaRegisterScreen extends StatefulWidget {
  const WingaRegisterScreen({super.key});
  @override State<WingaRegisterScreen> createState() => _State();
}
class _State extends State<WingaRegisterScreen> {
  int _step = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WingaColors.primary), onPressed: () => context.pop()),
        title: const Text('Winga Registration'),
        actions: [Row(children: const [Icon(Icons.headset_mic_outlined, size: 16, color: WingaColors.primary), SizedBox(width: 4), Text('Help', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.primary, fontWeight: FontWeight.w600)), SizedBox(width: 16)])],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          WingaStepIndicator(totalSteps: 5, currentStep: _step, labels: const ['Basic Info','Documents','Verification','Vehicle\n(Optional)','Review']),
          const SizedBox(height: 20),
          WingaCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Join the Winga Community', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: WingaColors.primary)),
              const SizedBox(height: 6),
              const Text('Create your Winga account and start earning by helping people in your community.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textSecondary)),
            ])),
            const SizedBox(width: 12),
            Container(width: 70, height: 70, decoration: BoxDecoration(color: WingaColors.primarySurface, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, size: 40, color: WingaColors.primary)),
          ])),
          const SizedBox(height: 20),
          const Text('Personal Information', style: WingaTextStyles.headingSmall),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: _Field(label: 'First Name', hint: 'Enter your first name', icon: Icons.person_outline_rounded)), const SizedBox(width: 12), Expanded(child: _Field(label: 'Last Name', hint: 'Enter your last name', icon: Icons.person_outline_rounded))]),
          const SizedBox(height: 12),
          _Field(label: 'Phone Number', hint: '07X XXX XXXX', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _Field(label: 'Email Address', hint: 'Enter your email address', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _Field(label: 'National ID (NIDA)', hint: 'Enter your NIDA number', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: WingaColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: WingaColors.border), boxShadow: WingaShadows.card), child: Row(children: [const Icon(Icons.calendar_today_outlined, size: 18, color: WingaColors.textLight), const SizedBox(width: 12), const Expanded(child: Text('Select your date of birth', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textLight))), const Icon(Icons.keyboard_arrow_down_rounded, color: WingaColors.textLight)])),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: WingaColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: WingaColors.border), boxShadow: WingaShadows.card), child: Row(children: [const Icon(Icons.person_outline_rounded, size: 18, color: WingaColors.textLight), const SizedBox(width: 12), const Expanded(child: Text('Select your gender', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textLight))), const Icon(Icons.keyboard_arrow_down_rounded, color: WingaColors.textLight)])),
          const SizedBox(height: 20),
          const Text('Account Security', style: WingaTextStyles.headingSmall),
          const SizedBox(height: 14),
          _Field(label: 'Create Password', hint: 'Create a strong password', icon: Icons.lock_outline_rounded, isPassword: true),
          const SizedBox(height: 12),
          _Field(label: 'Confirm Password', hint: 'Confirm your password', icon: Icons.lock_outline_rounded, isPassword: true),
          const SizedBox(height: 16),
          SafetyBanner(message: 'Your safety matters\nAll Winga accounts are verified and background-checked to ensure a safe community.'),
          const SizedBox(height: 20),
          WingaButton(
              label: 'Continue',
              trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              onPressed: () async {
                // TODO: Validate all fields
                // Call register-winga Edge Function
                try {
                  final supabase = Supabase.instance.client;
                  // Registration handled via Edge Function
                  // supabase.functions.invoke('register-winga', body: {...})
                  context.go('/winga-home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: \$e')));
                }
              }),
          const SizedBox(height: 14),
          Center(child: GestureDetector(onTap: () => context.go('/login'), child: RichText(text: const TextSpan(style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary), children: [TextSpan(text: 'Already have an account? '), TextSpan(text: 'Login', style: TextStyle(color: WingaColors.primary, fontWeight: FontWeight.w600))])))),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
class _Field extends StatefulWidget {
  final String label, hint; final IconData icon; final bool isPassword; final TextInputType? keyboard;
  const _Field({required this.label, required this.hint, required this.icon, this.isPassword = false, this.keyboard});
  @override State<_Field> createState() => _FieldState();
}
class _FieldState extends State<_Field> {
  bool _show = false;
  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: WingaColors.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(
        obscureText: widget.isPassword && !_show,
        keyboardType: widget.keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, size: 18, color: WingaColors.textLight),
          hintText: widget.hint,
          suffixIcon: widget.isPassword ? GestureDetector(onTap: () => setState(() => _show = !_show), child: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: WingaColors.textLight)) : null,
        ),
      ),
    ]);
  }
}
