import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

mixin DateFilterMixin<T extends TableData> on ChangeNotifier {
  DateTime? _startDate;
  DateTime? _endDate;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get hasDateRange => _startDate != null || _endDate != null;

  void setStartDate(DateTime? date) {
    _startDate = date;
    if (_endDate != null && date != null && date.isAfter(_endDate!)) {
      _endDate = null;
    }
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    if (_startDate != null && date != null && date.isBefore(_startDate!)) {
      _startDate = null;
    }
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearDateFilters() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Abstract method - Tarih alanını belirlemek için implemente edilecek
  DateTime? getDateField(T item);

  /// Tarih Filtreleme
  List<T> applyDateFilter(List<T> items) {
    if (!hasDateRange) return items;

    // Başlangıç ve bitiş tarihlerinin sadece gün kısmını alıyoruz
    final start = _startDate != null ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day) : null;
    final end = _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day) : null;

    return items.where((item) {
      final DateTime? rawDate = getDateField(item);
      if (rawDate == null) return false;

      // Karşılaştırılacak tarihin de sadece gününü alıyoruz
      final itemDate = DateTime(rawDate.year, rawDate.month, rawDate.day);

      // .isBefore ve .isAfter kullanımı + Manuel eşitlik kontrolü
      bool afterStart = start == null || itemDate.isAtSameMomentAs(start) || itemDate.isAfter(start);

      bool beforeEnd = end == null || itemDate.isAtSameMomentAs(end) || itemDate.isBefore(end);

      return afterStart && beforeEnd;
    }).toList();
  }

  /// Çoklu tarih alanına göre filtreleme (opsiyonel)
  List<T> applyDateFilterWithMultipleFields(List<T> items, {required List<DateTime? Function(T item)> dateFields}) {
    if (!hasDateRange) return items;

    return items.where((item) {
      for (final dateField in dateFields) {
        final DateTime? itemDate = dateField(item);
        if (itemDate != null && _isDateInRange(itemDate)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  bool _isDateInRange(DateTime date) {
    bool afterStart = startDate == null || date.isAtSameMomentAs(startDate!) || date.isAfter(startDate!);

    bool beforeEnd = endDate == null || date.isAtSameMomentAs(endDate!) || date.isBefore(endDate!);

    return afterStart && beforeEnd;
  }

  /// Tarih aralığı metnini döndürür
  String get dateRangeText {
    if (startDate == null && endDate == null) return 'Tüm Tarihler';
    if (startDate == null) return '→ ${_formatDate(endDate!)}';
    if (endDate == null) return '${_formatDate(startDate!)} →';
    return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
