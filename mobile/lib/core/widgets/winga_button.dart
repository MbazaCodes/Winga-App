import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum WingaButtonVariant { primary, secondary, outlined, ghost }

class WingaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final WingaButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final Widget? trailing;
  final double? height;
  final EdgeInsets? padding;

  const WingaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = WingaButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.trailing,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(WingaColors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    switch (variant) {
      case WingaButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: WingaColors.primary,
              foregroundColor: WingaColors.white,
              padding: padding,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );

      case WingaButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: WingaColors.primarySurface,
              foregroundColor: WingaColors.primary,
              padding: padding,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );

      case WingaButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: WingaColors.primary,
              side: const BorderSide(color: WingaColors.primary, width: 1.5),
              padding: padding,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );

      case WingaButtonVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 56,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: WingaColors.primary,
              padding: padding,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );
    }
  }
}
