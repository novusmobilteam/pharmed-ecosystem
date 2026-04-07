// pharmed_data/src/cache/hive_cache.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_data/src/cache/cached_entry.dart';

class HiveCache<T> {
  HiveCache({required this.boxName, required this.serialize, required this.deserialize, required this.isMock});

  final String boxName;
  final Object? Function(T) serialize;
  final T Function(dynamic) deserialize;
  final bool isMock;

  Box? _box;

  Future<void> open() async {
    if (!(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> write(String key, T data) async {
    if (isMock) return;
    await open();
    final entry = CachedEntry<T>(data: data, savedAt: DateTime.now());
    await _box!.put(key, entry.toJson(serialize));
  }

  Future<CachedEntry<T>?> read(String key) async {
    if (isMock) return null;
    await open();
    final raw = _box!.get(key);
    if (raw == null) return null;
    try {
      return CachedEntry.fromJson<T>(raw as Map<dynamic, dynamic>, deserialize);
    } catch (_) {
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
