import 'package:intl/intl.dart';

class Formatters {
  static String currency(
    double amount, {
    String symbol = 'Rp',
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$symbol ',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Compact currency format (e.g., Rp 1.5M, Rp 500K)
  static String compactCurrency(double amount, {String symbol = 'Rp'}) {
    if (amount >= 1000000000) {
      return '$symbol ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol ${amount.toStringAsFixed(0)}';
    }
  }

  static String number(num value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }

  static String date(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format, 'id_ID').format(date);
  }

  static String dateTime(
    DateTime date, {
    String format = 'dd MMM yyyy, HH:mm',
  }) {
    return DateFormat(format, 'id_ID').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  static String discountPercentage(double originalPrice, double discountPrice) {
    final discount =
        ((originalPrice - discountPrice) / originalPrice * 100).round();
    return '$discount%';
  }

  // Alias methods for compatibility
  static String formatCurrency(double amount) => currency(amount);
  static String formatDate(DateTime date) => Formatters.date(date);
  static String formatTimeAgo(DateTime date) => timeAgo(date);
}
