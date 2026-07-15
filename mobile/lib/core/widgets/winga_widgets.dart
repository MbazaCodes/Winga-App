import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Winga Card ─────────────────────────────────────────────────────────────
class WingaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool hasBorder;

  const WingaCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? WingaSpacing.cardPadding,
        decoration: BoxDecoration(
          color: color ?? WingaColors.cardBg,
          borderRadius: borderRadius ?? WingaRadius.cardRadius,
          border: hasBorder
              ? Border.all(color: WingaColors.border, width: 1)
              : null,
          boxShadow: WingaShadows.card,
        ),
        child: child,
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (type) {
      case StatusType.completed:
        bg = WingaColors.successLight;
        text = WingaColors.successText;
        break;
      case StatusType.inProgress:
        bg = WingaColors.inProgressLight;
        text = WingaColors.inProgress;
        break;
      case StatusType.pending:
        bg = WingaColors.warningLight;
        text = WingaColors.goldDark;
        break;
      case StatusType.cancelled:
        bg = WingaColors.errorLight;
        text = WingaColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: WingaRadius.chipRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

enum StatusType { completed, inProgress, pending, cancelled }

// ── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: WingaTextStyles.headingSmall),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: WingaColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────
class WingaStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String>? labels;

  const WingaStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          final isActive = stepIndex < currentStep - 1;
          return Expanded(
            child: Container(
              height: 2,
              color: isActive ? WingaColors.primary : WingaColors.border,
            ),
          );
        }

        final stepIndex = i ~/ 2 + 1;
        final isDone = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isCurrent
                    ? WingaColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isDone || isCurrent
                      ? WingaColors.primary
                      : WingaColors.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '$stepIndex',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Colors.white
                              : WingaColors.textLight,
                        ),
                      ),
              ),
            ),
            if (labels != null && stepIndex <= labels!.length) ...[
              const SizedBox(height: 4),
              Text(
                labels![stepIndex - 1],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isCurrent
                      ? WingaColors.primary
                      : WingaColors.textLight,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

// ── Winga Avatar ───────────────────────────────────────────────────────────
class WingaAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showBadge;

  const WingaAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WingaColors.primarySurface,
            border: Border.all(color: WingaColors.white, width: 2),
          ),
          child: imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initials(),
                  ),
                )
              : _initials(),
        ),
        if (showBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: WingaColors.gold,
                shape: BoxShape.circle,
                border: Border.all(color: WingaColors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initials() {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, 1).toUpperCase();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: WingaColors.primary,
        ),
      ),
    );
  }
}

// ── Rating Stars ───────────────────────────────────────────────────────────
class RatingStars extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: WingaColors.gold),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: size - 2,
            fontWeight: FontWeight.w600,
            color: WingaColors.textPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size - 2,
              fontWeight: FontWeight.w400,
              color: WingaColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Safety Banner ──────────────────────────────────────────────────────────
class SafetyBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const SafetyBanner({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
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
              child: const Icon(
                Icons.shield_outlined,
                size: 16,
                color: WingaColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: WingaColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 18, color: WingaColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ───────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: WingaTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: WingaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 18, color: WingaColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
