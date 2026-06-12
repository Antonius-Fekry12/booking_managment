// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatCurrency(double amount, {String symbol = 'ج.م'}) {
    final formatted = NumberFormat('#,##0.00', 'ar').format(amount);
    return '$formatted $symbol';
  }

  static String formatCurrencyCompact(double amount, {String symbol = 'ج.م'}) {
    final formatted = NumberFormat('#,##0', 'ar').format(amount);
    return '$formatted\n$symbol';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ar').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$minute $period';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} - ${formatTime(date)}';
  }
}

class AppConstants {
  AppConstants._();

  static const List<Map<String, String>> eventTypes = [
    {'key': 'wedding', 'label': 'حفل زفاف'},
    {'key': 'engagement', 'label': 'خطوبة'},
    {'key': 'henna', 'label': 'حنة'},
    {'key': 'photography', 'label': 'جلسة تصوير'},
    {'key': 'portrait', 'label': 'بورتريه'},
    {'key': 'products', 'label': 'منتجات'},
    {'key': 'commercial', 'label': 'تصوير معماري'},
    {'key': 'newborn', 'label': 'أطفال'},
    {'key': 'family', 'label': 'عائلي'},
  ];

  static const List<Map<String, String>> serviceTypes = [
    {'key': 'photography', 'label': 'تصوير فوتوغرافي'},
    {'key': 'videography', 'label': 'تصوير فيديو'},
    {'key': 'drone', 'label': 'تصوير درون'},
    {'key': 'album', 'label': 'ألبوم صور'},
    {'key': 'editing', 'label': 'مونتاج احترافي'},
    {'key': '4k', 'label': 'تصوير فيديو 4K'},
    {'key': 'color_grading', 'label': 'تعديل ألوان سينمائي'},
  ];

  static const List<Map<String, String>> paymentMethods = [
    {'key': 'cash', 'label': 'نقدي'},
    {'key': 'network', 'label': 'شبكة'},
    {'key': 'transfer', 'label': 'تحويل'},
  ];

  static const List<Map<String, String>> statusTypes = [
    {'key': 'confirmed', 'label': 'مؤكد'},
    {'key': 'pending', 'label': 'قيد الانتظار'},
    {'key': 'cancelled', 'label': 'ملغي'},
  ];

  static String getEventLabel(String key) {
    return eventTypes.firstWhere(
      (e) => e['key'] == key,
      orElse: () => {'label': key},
    )['label']!;
  }

  static String getServiceLabel(String key) {
    return serviceTypes.firstWhere(
      (e) => e['key'] == key,
      orElse: () => {'label': key},
    )['label']!;
  }

  static String getStatusLabel(String key) {
    return statusTypes.firstWhere(
      (e) => e['key'] == key,
      orElse: () => {'label': key},
    )['label']!;
  }

  static String getPaymentMethodLabel(String key) {
    return paymentMethods.firstWhere(
      (e) => e['key'] == key,
      orElse: () => {'label': key},
    )['label']!;
  }
}
