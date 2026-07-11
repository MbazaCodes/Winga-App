import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../data/rating_repository.dart';

final ratingRepositoryProvider = Provider((_) => RatingRepository());

/// Shown after a trip completes. The customer gives the Winga one point for
/// good service, or zero for bad. Deliberately binary — no 5-star scale — so
/// the signal stays unambiguous and hard to game.
class RateTripScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String wingaName;

  const RateTripScreen({
    super.key,
    required this.requestId,
    required this.wingaName,
  });

  @override
  ConsumerState<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends ConsumerState<RateTripScreen> {
  bool? _good; // null = nothing chosen yet
  final _reasonCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_good == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(ratingRepositoryProvider).rate(
            requestId: widget.requestId,
            good: _good!,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_good!
              ? 'Asante! Umempa ${widget.wingaName} pointi 1.'
              : 'Asante kwa maoni yako. Tutafuatilia.'),
          backgroundColor: WingaColors.primary,
        ),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.white,
      appBar: AppBar(
        title: const Text('Pima Huduma'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: WingaColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 38, color: WingaColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.wingaName,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Je, huduma ilikuwa nzuri?',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: WingaColors.textSecondary),
            ),
            const SizedBox(height: 28),

            // The binary choice
            Row(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    emoji: '👍',
                    title: 'Huduma Nzuri',
                    subtitle: '+1 pointi',
                    selected: _good == true,
                    accent: WingaColors.primary,
                    onTap: () => setState(() => _good = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceCard(
                    emoji: '👎',
                    title: 'Huduma Mbaya',
                    subtitle: '0 pointi',
                    selected: _good == false,
                    accent: WingaColors.error,
                    onTap: () => setState(() => _good = false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Optional note — required in spirit for a bad rating, so the Winga
            // learns something instead of just losing a point.
            if (_good != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _good! ? 'Ongeza maoni (hiari)' : 'Kwa nini? (hiari)',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: _good!
                      ? 'Alinisaidia vizuri sana...'
                      : 'Alichelewa, hakuwa msaada...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: WingaColors.border),
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WingaColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: WingaColors.error),
                ),
              ),
            ],

            const Spacer(),

            WingaButton(
              label: 'Tuma',
              isLoading: _submitting,
              onPressed: _good == null ? null : _submit,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _submitting ? null : () => context.go('/home'),
              child: const Text(
                'Ruka kwa sasa',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: WingaColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.08) : WingaColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : WingaColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? accent : WingaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: WingaColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
