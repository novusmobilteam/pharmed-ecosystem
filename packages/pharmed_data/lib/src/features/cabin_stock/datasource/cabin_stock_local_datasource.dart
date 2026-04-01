import 'dart:convert';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

abstract interface class ICabinStockLocalDataSource {
  Future<void> saveCurrentStock(List<CabinStockDTO> stocks);
  Future<List<CabinStockDTO>?> readCurrentStock();
  Future<DateTime?> currentStockSavedAt();
  Future<void> clearCurrentStock();
}

class CabinStockLocalDataSource implements ICabinStockLocalDataSource {
  static const _boxName = 'cabin_stock_cache';
  static const _stocksKey = 'current_stock';
  static const _savedAtKey = 'current_stock_saved_at';

  Box? _box;

  Future<Box> _open() async {
    if (!(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(_boxName);
    }
    return _box!;
  }

  @override
  Future<void> saveCurrentStock(List<CabinStockDTO> stocks) async {
    final box = await _open();
    final encoded = stocks.map((s) => s.toJson()).toList();
    await box.put(_stocksKey, jsonEncode(encoded));
    await box.put(_savedAtKey, DateTime.now().toIso8601String());

    MedLogger.info(
      unit: 'SW-UNIT-DATA',
      swreq: 'SWREQ-DATA-STOCK-001',
      message: 'Kabin stok verisi cache\'e yazıldı',
      context: {'count': stocks.length},
    );
  }

  @override
  Future<List<CabinStockDTO>?> readCurrentStock() async {
    final box = await _open();
    final raw = box.get(_stocksKey) as String?;
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list.map((e) => CabinStockDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DateTime?> currentStockSavedAt() async {
    final box = await _open();
    final raw = box.get(_savedAtKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> clearCurrentStock() async {
    final box = await _open();
    await box.delete(_stocksKey);
    await box.delete(_savedAtKey);

    MedLogger.info(unit: 'SW-UNIT-DATA', swreq: 'SWREQ-DATA-STOCK-001', message: 'Kabin stok cache temizlendi');
  }
}
