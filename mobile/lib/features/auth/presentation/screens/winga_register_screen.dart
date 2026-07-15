import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class WingaRegisterScreen extends StatefulWidget {
  const WingaRegisterScreen({super.key});
  @override State<WingaRegisterScreen> createState() => _State();
}

class _State extends State<WingaRegisterScreen> {
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _nidaCtrl       = TextEditingController();
  final _specialtyCtrl  = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  String? _error;
  int _step = 1;

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _phoneCtrl, _emailCtrl,
      _nidaCtrl, _specialtyCtrl, _locationCtrl, _passwordCtrl, _confirmCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  String get _cleanPhone => _phoneCtrl.text
      .trim().replaceAll(' ', '').replaceAll('-', '')
      .replaceAll(RegExp(r'^\+?255'), '')
      .replaceAll(RegExp(r'^0'), '');

  bool get _step1Valid =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      _cleanPhone.length >= 9;

  bool get _step2Valid =>
      _specialtyCtrl.text.trim().isNotEmpty &&
      _locationCtrl.text.trim().isNotEmpty;

  bool get _passwordsMatch =>
      _passwordCtrl.text == _confirmCtrl.text &&
      _passwordCtrl.text.length >= 6;

  Future<void> _submit() async {
    if (!_step1Valid || !_step2Valid || !_passwordsMatch) return;
    setState(() { _loading = true; _error = null; });

    try {
      final fullName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';
      final phone = '+255$_cleanPhone';

      // 1. Call Edge Function to create user + winga records
      final res = await Supabase.instance.client.functions.invoke(
        'register-winga',
        body: {
          'phone': _cleanPhone,
          'name': fullName,
          'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          'specialty': _specialtyCtrl.text.trim(),
          'home_location': _locationCtrl.text.trim(),
          'national_id': _nidaCtrl.text.trim().isEmpty ? null : _nidaCtrl.text.trim(),
          'password': _passwordCtrl.text,
        },
      );

      final data = res.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Registration failed');
      }

      if (!mounted) return;

      // 2. Send OTP for phone verification
      await Supabase.instance.client.auth.signInWithOtp(phone: phone);

      // 3. Go to OTP screen — on verify they'll be routed to /winga-home
      context.pushReplacement('/otp?phone=$_cleanPhone');
    } on FunctionException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.details?.toString() ?? 'Edge Function error');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20,
              color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Jiunge kama Winga'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Msaada',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  color: WingaColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WingaStepIndicator(
              totalSteps: 2,
              currentStep: _step,
              labels: const ['Taarifa Zako', 'Kazi & Usalama'],
            ),
            const SizedBox(height: 20),

            // Error
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WingaColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
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

            if (_step == 1) ...[
              // ── STEP 1: Personal Info ───────────────────────────────
              WingaCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Taarifa za Kibinafsi',
                    style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  const Text('Kumbuka: taarifa hizi zitatumika kuthibitisha utambulisho wako.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: WingaColors.textSecondary)),
                ],
              )),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Field('Jina la Kwanza *', 'Mfano: Ahmed',
                    _firstNameCtrl, Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _Field('Jina la Mwisho *', 'Mfano: Juma',
                    _lastNameCtrl, Icons.person_outline_rounded)),
              ]),
              const SizedBox(height: 12),
              _Field('Namba ya Simu *', '712 345 678',
                  _phoneCtrl, Icons.phone_outlined,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _Field('Barua Pepe (hiari)', 'ahmed@example.com',
                  _emailCtrl, Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field('Namba ya NIDA (hiari)', '19900101-12345-00001-00',
                  _nidaCtrl, Icons.badge_outlined),
              const SizedBox(height: 24),
              WingaButton(
                label: 'Endelea →',
                onPressed: _step1Valid
                    ? () => setState(() { _step = 2; _error = null; })
                    : null,
              ),
            ] else ...[
              // ── STEP 2: Specialty, Location, Password ───────────────
              WingaCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Huduma na Usalama', style: WingaTextStyles.headingSmall),
                  SizedBox(height: 4),
                  Text('Sema zaidi kuhusu jinsi unavyoweza kusaidia wateja.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: WingaColors.textSecondary)),
                ],
              )),
              const SizedBox(height: 16),
              _Field('Utaalamu Wako *', 'Mfano: Elektroniki, Mavazi, Vifaa...',
                  _specialtyCtrl, Icons.star_outline_rounded),
              const SizedBox(height: 12),
              _Field('Eneo Unalofanya Kazi *', 'Mfano: Kariakoo, Mwenge, Arusha...',
                  _locationCtrl, Icons.location_on_outlined),
              const SizedBox(height: 20),
              const Text('Usalama wa Akaunti', style: WingaTextStyles.headingSmall),
              const SizedBox(height: 12),
              _Field('Nywila *', 'Angalau tarakimu 6',
                  _passwordCtrl, Icons.lock_outline_rounded,
                  isPassword: true, showPassword: _showPassword,
                  onTogglePassword: () =>
                      setState(() => _showPassword = !_showPassword)),
              const SizedBox(height: 12),
              _Field('Thibitisha Nywila *', 'Rudia nywila yako',
                  _confirmCtrl, Icons.lock_outline_rounded,
                  isPassword: !_showPassword),
              if (_confirmCtrl.text.isNotEmpty && !_passwordsMatch)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Nywila hazifanani.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: WingaColors.error)),
                ),
              const SizedBox(height: 16),
              SafetyBanner(
                message: 'Akaunti zote za Winga zinathihirishwa. Tutawasiliana nawe baada ya kuwasilisha.',
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 1),
                    child: const Text('← Rudi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: WingaButton(
                    label: 'Wasilisha Maombi',
                    isLoading: _loading,
                    onPressed: _step2Valid && _passwordsMatch ? _submit : null,
                  ),
                ),
              ]),
            ],

            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => context.go('/login'),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                        color: WingaColors.textSecondary),
                    children: [
                      TextSpan(text: 'Una akaunti tayari? '),
                      TextSpan(text: 'Ingia hapa',
                        style: TextStyle(color: WingaColors.primary,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType keyboard;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;

  const _Field(this.label, this.hint, this.ctrl, this.icon, {
    this.keyboard = TextInputType.text,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
              fontWeight: FontWeight.w500, color: WingaColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: isPassword && !showPassword,
          onChanged: (_) {},
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: WingaColors.textLight),
            suffixIcon: isPassword && onTogglePassword != null
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: WingaColors.textLight,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
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
              borderSide: const BorderSide(color: WingaColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: WingaColors.white,
          ),
        ),
      ],
    );
  }
}
