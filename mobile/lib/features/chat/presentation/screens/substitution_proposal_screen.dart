import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../data/chat_repository.dart';
import 'chat_screen.dart';

class SubstitutionProposalScreen extends ConsumerStatefulWidget {
  final String requestId;
  const SubstitutionProposalScreen({super.key, required this.requestId});

  @override
  ConsumerState<SubstitutionProposalScreen> createState() =>
      _SubstitutionProposalScreenState();
}

class _SubstitutionProposalScreenState
    extends ConsumerState<SubstitutionProposalScreen> {
  final _originalCtrl = TextEditingController();
  final _suggestedCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _suggPriceCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _originalCtrl.dispose();
    _suggestedCtrl.dispose();
    _reasonCtrl.dispose();
    _origPriceCtrl.dispose();
    _suggPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_originalCtrl.text.trim().isEmpty ||
        _suggestedCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      final res =
          await ref.read(chatRepoProvider).proposeSubstitution(
                requestId: widget.requestId,
                originalItem: _originalCtrl.text.trim(),
                originalPrice: int.tryParse(_origPriceCtrl.text),
                suggestedItem: _suggestedCtrl.text.trim(),
                suggestedPrice: int.tryParse(_suggPriceCtrl.text),
                reason: _reasonCtrl.text.trim().isEmpty
                    ? null
                    : _reasonCtrl.text.trim(),
              );

      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ombi limetumwa kwa mteja'),
            backgroundColor: WingaColors.primary));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['error'] ?? 'Hitilafu')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        title: const Text('Pendekeza Mbadala'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Bidhaa isiyopatikana? Omba idhini ya mteja kabla ya kununua mbadala.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: WingaColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            _Field(
                ctrl: _originalCtrl,
                label: 'Bidhaa isiyopatikana *',
                hint: 'Mfano: Samsung A14 Nyeusi'),
            const SizedBox(height: 4),
            _Field(
                ctrl: _origPriceCtrl,
                label: 'Bei ya asili (TZS)',
                hint: '45000',
                keyboard: TextInputType.number),
            const SizedBox(height: 20),
            _Field(
                ctrl: _suggestedCtrl,
                label: 'Bidhaa mbadala unayopendekeza *',
                hint: 'Mfano: Samsung A14 Nyekundu'),
            const SizedBox(height: 4),
            _Field(
                ctrl: _suggPriceCtrl,
                label: 'Bei ya mbadala (TZS)',
                hint: '43000',
                keyboard: TextInputType.number),
            const SizedBox(height: 20),
            _Field(
                ctrl: _reasonCtrl,
                label: 'Sababu (hiari)',
                hint: 'Rangi nyekundu ndiyo pekee iliyobaki',
                maxLines: 3),
            const SizedBox(height: 32),
            WingaButton(
              label: 'Tuma kwa Mteja',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  final TextInputType keyboard;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboard,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontFamily: 'Inter', color: WingaColors.textLight),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: WingaColors.border)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      );
}
