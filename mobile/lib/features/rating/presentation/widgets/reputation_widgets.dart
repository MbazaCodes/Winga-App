import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/winga_reputation.dart';

/// The "⭐ Top Rated" badge. Only shown for Wingas the backend has actually
/// marked as top-rated (active + verified + >=10 rated trips + top decile),
/// so it can never appear on a Winga with 3/3 lucky points.
class TopRatedBadge extends StatelessWidget {
  final bool compact;
  const TopRatedBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WingaColors.gold, Color(0xFFF57F17)],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: compact ? 11 : 13, color: Colors.white),
          SizedBox(width: compact ? 2 : 4),
          Text(
            'Top Rated',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Points chip: "42 pointi · 95%". Shows a "Mpya" state while the Winga is
/// still provisional, rather than a misleading 100% off 2 trips.
class PointsChip extends StatelessWidget {
  final WingaReputation rep;
  const PointsChip({super.key, required this.rep});

  @override
  Widget build(BuildContext context) {
    if (rep.ratedTrips == 0) {
      return _chip(
        icon: Icons.fiber_new_rounded,
        label: 'Winga Mpya',
        color: WingaColors.textSecondary,
      );
    }

    if (rep.isProvisional) {
      return _chip(
        icon: Icons.trending_up_rounded,
        label: '${rep.totalPoints} pointi · anaanza',
        color: WingaColors.textSecondary,
      );
    }

    final good = rep.pointRate >= 80;
    return _chip(
      icon: Icons.thumb_up_rounded,
      label: '${rep.totalPoints} pointi · ${rep.pointRate.toStringAsFixed(0)}%',
      color: good ? WingaColors.primary : WingaColors.textSecondary,
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal "Wingas Bora" row for the customer Home screen.
class FeaturedWingasRow extends StatelessWidget {
  final List<Map<String, dynamic>> wingas;
  final void Function(Map<String, dynamic> winga) onTap;

  const FeaturedWingasRow({
    super.key,
    required this.wingas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (wingas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 18, color: WingaColors.gold),
              const SizedBox(width: 6),
              const Text(
                'Wingas Bora',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Text(
                'wanaopendekezwa',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: WingaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: wingas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final w = wingas[i];
              final rep = WingaReputation.fromJson(w);
              return GestureDetector(
                onTap: () => onTap(w),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WingaColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WingaColors.gold.withOpacity(0.35)),
                    boxShadow: WingaShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: WingaColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded,
                                size: 28, color: WingaColors.primary),
                          ),
                          if (w['is_online'] == true)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (w['name'] as String?) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        (w['specialty'] as String?) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: WingaColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      const TopRatedBadge(compact: true),
                      const SizedBox(height: 6),
                      PointsChip(rep: rep),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
