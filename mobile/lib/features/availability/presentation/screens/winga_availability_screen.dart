import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../../../core/widgets/winga_button.dart';

const _days = [
  'Jumapili', 'Jumatatu', 'Jumanne', 'Jumatano',
  'Alhamisi', 'Ijumaa', 'Jumamosi',
];

class AvailabilityEntry {
  final int dayOfWeek;
  bool isActive;
  TimeOfDay startTime;
  TimeOfDay endTime;

  AvailabilityEntry({
    required this.dayOfWeek,
    this.isActive = false,
    this.startTime = const TimeOfDay(hour: 8, minute: 0),
    this.endTime = const TimeOfDay(hour: 18, minute: 0),
  });
}

class WingaAvailabilityScreen extends ConsumerStatefulWidget {
  final String wingaId;
  const WingaAvailabilityScreen({super.key, required this.wingaId});

  @override
  ConsumerState<WingaAvailabilityScreen> createState() =>
      _WingaAvailabilityScreenState();
}

class _WingaAvailabilityScreenState
    extends ConsumerState<WingaAvailabilityScreen> {
  final List<AvailabilityEntry> _schedule = List.generate(
    7,
    (i) => AvailabilityEntry(
      dayOfWeek: i,
      isActive: i >= 1 && i <= 5, // Mon-Fri default
    ),
  );
  bool _loading = true;
  bool _saving = false;
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await _client
        .from('winga_availability')
        .select()
        .eq('winga_id', widget.wingaId)
        .order('day_of_week');

    if (rows is List && rows.isNotEmpty) {
      for (final row in rows) {
        final day = row['day_of_week'] as int;
        final parts = (row['start_time'] as String).split(':');
        final endParts = (row['end_time'] as String).split(':');
        _schedule[day]
          ..isActive = row['is_active'] as bool
          ..startTime = TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1]))
          ..endTime = TimeOfDay(
              hour: int.parse(endParts[0]),
              minute: int.parse(endParts[1]));
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      for (final e in _schedule) {
        final fmt = (TimeOfDay t) =>
            '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:00';

        await _client.from('winga_availability').upsert({
          'winga_id': widget.wingaId,
          'day_of_week': e.dayOfWeek,
          'start_time': fmt(e.startTime),
          'end_time': fmt(e.endTime),
          'is_active': e.isActive,
        }, onConflict: 'winga_id, day_of_week');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ratiba imehifadhiwa'),
          backgroundColor: WingaColors.primary));
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(AvailabilityEntry entry, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? entry.startTime : entry.endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: WingaColors.primary)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          entry.startTime = picked;
        } else {
          entry.endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ratiba ya Kazi'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: WingaColors.primary))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: WingaColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Weka saa unazofanya kazi. Wateja wataona "Mtoa huduma hapatikani" nje ya masaa haya.',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: WingaColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._schedule.map((e) => _DayRow(
                            entry: e,
                            onToggle: (v) =>
                                setState(() => e.isActive = v),
                            onPickStart: () => _pickTime(e, true),
                            onPickEnd: () => _pickTime(e, false),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20,
                      20 + MediaQuery.of(context).padding.bottom),
                  child: WingaButton(
                    label: 'Hifadhi Ratiba',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final AvailabilityEntry entry;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickStart, onPickEnd;

  const _DayRow({
    required this.entry,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  String _fmt(TimeOfDay t) =>
      '${t.hourOfPeriod}:${t.minute.toString().padLeft(2,'0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isActive
              ? WingaColors.primary.withOpacity(0.3)
              : WingaColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _days[entry.dayOfWeek],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: entry.isActive
                      ? WingaColors.textPrimary
                      : WingaColors.textSecondary,
                ),
              ),
              const Spacer(),
              Switch(
                value: entry.isActive,
                onChanged: onToggle,
                activeColor: WingaColors.primary,
              ),
            ],
          ),
          if (entry.isActive) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: 'Kuanza',
                    time: _fmt(entry.startTime),
                    onTap: onPickStart,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—',
                      style: TextStyle(color: WingaColors.textSecondary)),
                ),
                Expanded(
                  child: _TimeChip(
                    label: 'Kumaliza',
                    time: _fmt(entry.endTime),
                    onTap: onPickEnd,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimeChip(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: WingaColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: WingaColors.textSecondary)),
              Text(time,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary)),
            ],
          ),
        ),
      );
}
