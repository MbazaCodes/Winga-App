import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';

const _categories = [
  ('wrong_items', '📦', 'Bidhaa Mbaya', 'Zilizonunuliwa si sahihi'),
  ('missing_items', '❓', 'Bidhaa Zinaokosekana', 'Baadhi ya bidhaa hazikununuliwa'),
  ('overcharged', '💸', 'Bei Kubwa', 'Nililipa zaidi ya makubaliano'),
  ('late_delivery', '⏰', 'Kuchelewa', 'Winga alichelewa sana'),
  ('winga_no_show', '🚫', 'Winga Hakuja', 'Winga hakutokea kabisa'),
  ('quality', '⭐', 'Ubora Mbaya', 'Bidhaa haikuwa ya ubora uliohitajika'),
  ('misconduct', '⚠️', 'Tabia Mbaya', 'Winga alifanya vibaya'),
  ('other', '📝', 'Nyingine', 'Tatizo lingine'),
];

class DisputeScreen extends ConsumerStatefulWidget {
  final String requestId;
  const DisputeScreen({super.key, required this.requestId});

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> {
  String? _category;
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category == null || _descCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);

    try {
      final res =
          await Supabase.instance.client.rpc('raise_dispute', params: {
        'p_request_id': widget.requestId,
        'p_category': _category,
        'p_description': _descCtrl.text.trim(),
        'p_amount_disputed': int.tryParse(_amountCtrl.text),
      });

      final map = Map<String, dynamic>.from(res as Map);
      if (!mounted) return;

      if (map['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Malalamiko yako yamepokelewa. Tutayashughulikia hivi karibuni.'),
            backgroundColor: WingaColors.primary));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(map['error'] ?? 'Hitilafu')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
        title: const Text('Toa Malalamiko'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFF57F17), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Malalamiko yatashughulikiwa ndani ya masaa 24. Tunakusimamia.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFFF57F17)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Aina ya Tatizo *',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: _categories.map((cat) {
                final selected = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? WingaColors.primarySurface
                          : WingaColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? WingaColors.primary
                            : WingaColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(cat.$2,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cat.$3,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? WingaColors.primary
                                  : WingaColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Maelezo *',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Elezea tatizo kwa undani ili tuweze kukusaidia haraka...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kiasi kilichoathiriwa (TZS) — hiari',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '15000',
                prefixText: 'TZS ',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            WingaButton(
              label: 'Wasilisha Malalamiko',
              isLoading: _submitting,
              onPressed: _category != null &&
                      _descCtrl.text.trim().isNotEmpty
                  ? _submit
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
