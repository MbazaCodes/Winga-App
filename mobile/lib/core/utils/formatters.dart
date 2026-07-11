import 'package:intl/intl.dart';

class WingaFormatters {
  static String currency(int amount) {
    final f = NumberFormat('#,###', 'en_US');
    return 'TZS ${f.format(amount)}';
  }

  static String shortCurrency(int amount) {
    if (amount >= 1000000) return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
    return currency(amount);
  }

  static String date(DateTime dt) =>
      DateFormat('dd MMM yyyy').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy • hh:mm a').format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }

  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 1).toUpperCase();
  }

  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255') && digits.length == 12) {
      return '+${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
    }
    return raw;
  }
}
