// lib/core/cache/hive_cache.dart
//
// [SWREQ-CORE-002] [HAZ-007]
// Generic Hive cache wrapper.
// Her entry timestamp ile saklanır.
// Repository, yaşa bakarak stale/fresh kararını verir.
//
// Sınıf: Class B — stale data kararı [HAZ-007] ile ilişkili

import 'package:hive_flutter/hive_flutter.dart';
import '../flavor/app_flavor.dart';
import '../logging/med_logger.dart';

// ─────────────────────────────────────────────────────────────────
// CachedEntry<T> — Hive'a yazılan sarmalayıcı model
// ─────────────────────────────────────────────────────────────────

class CachedEntry<T> {
  const CachedEntry({required this.data, required this.savedAt});

  final T data;
  final DateTime savedAt;

  /// [HAZ-007] maxAgeMinutes geçtiyse stale sayılır
  bool isStale(int maxAgeMinutes) {
    final age = DateTime.now().difference(savedAt).inMinutes;
    return age > maxAgeMinutes;
  }

  Map<String, dynamic> toJson(Object? Function(T) dataSerializer) => {
    'data': dataSerializer(data),
    'savedAt': savedAt.toIso8601String(),
  };

  static CachedEntry<T> fromJson<T>(Map<dynamic, dynamic> json, T Function(dynamic) dataDeserializer) =>
      CachedEntry<T>(data: dataDeserializer(json['data']), savedAt: DateTime.parse(json['savedAt'] as String));
}

// ─────────────────────────────────────────────────────────────────
// HiveCache<T> — tip güvenli generic cache
// ─────────────────────────────────────────────────────────────────

class HiveCache<T> {
  HiveCache({required this.boxName, required this.serialize, required this.deserialize});

  final String boxName;
  final Object? Function(T) serialize;
  final T Function(dynamic) deserialize;

  Box? _box;

  Future<void> open() async {
    if (!(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> write(String key, T data) async {
    // mock flavor'da cache yazılmaz
    if (FlavorConfig.instance.isMock) return;

    await open();
    final entry = CachedEntry<T>(data: data, savedAt: DateTime.now());
    await _box!.put(key, entry.toJson(serialize));

    MedLogger.info(
      unit: 'HIVE-CACHE',
      swreq: 'SWREQ-CORE-002',
      message: 'Cache yazıldı',
      context: {'box': boxName, 'key': key},
    );
  }

  Future<CachedEntry<T>?> read(String key) async {
    if (FlavorConfig.instance.isMock) return null;

    await open();
    final raw = _box!.get(key);
    if (raw == null) return null;

    try {
      return CachedEntry.fromJson<T>(raw as Map<dynamic, dynamic>, deserialize);
    } catch (e) {
      // Bozuk cache → sil, null dön
      MedLogger.warn(
        unit: 'HIVE-CACHE',
        swreq: 'SWREQ-CORE-002',
        message: 'Cache parse hatası, siliniyor',
        context: {'box': boxName, 'key': key, 'error': e.toString()},
      );
      await _box!.delete(key);
      return null;
    }
  }

  Future<void> invalidate(String key) async {
    await open();
    await _box!.delete(key);
  }

  Future<void> clear() async {
    await open();
    await _box!.clear();
  }
}

// ─────────────────────────────────────────────────────────────────
// AppBootstrap — Hive'ı başlatır, tüm box'ları kaydeder
// ─────────────────────────────────────────────────────────────────

class AppBootstrap {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapter kayıtları buraya eklenir
    // Hive.registerAdapter(CabinStockDTOAdapter());
  }
}
