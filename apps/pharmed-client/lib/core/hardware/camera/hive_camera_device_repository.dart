import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// Kamera tanımlarının lokal deposu. Şifre BURADA YOKTUR (bkz. ICameraSecretStore).
class HiveCameraDeviceRepository implements ICameraDeviceRepository {
  HiveCameraDeviceRepository({this.boxName = 'camera_devices'});

  final String boxName;
  Box<String>? _box;
  final _changes = StreamController<void>.broadcast();

  Future<Box<String>> _open() async => _box ??= await Hive.openBox<String>(boxName);

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<Result<List<CameraDevice>>> getAll() async {
    try {
      final box = await _open();
      final list = box.values.map((raw) => _fromJson(jsonDecode(raw) as Map<String, Object?>)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Result.ok(list);
    } catch (e) {
      return Result.error(CacheException(message: 'Kamera tanımları okunamadı', boxName: boxName, cause: e));
    }
  }

  @override
  Future<Result<void>> save(CameraDevice d) async {
    try {
      await (await _open()).put(d.id, jsonEncode(_toJson(d)));
      _changes.add(null);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(CacheException(message: 'Kamera kaydedilemedi', boxName: boxName, key: d.id, cause: e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await (await _open()).delete(id);
      _changes.add(null);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(CacheException(message: 'Kamera silinemedi', boxName: boxName, key: id, cause: e));
    }
  }

  static Map<String, Object?> _toJson(CameraDevice d) => {
    'id': d.id,
    'name': d.name,
    'host': d.host,
    'username': d.username,
    'cabinIds': d.cabinIds.toList()..sort(),
    'rtspPort': d.rtspPort,
    'channel': d.channel,
    'enabled': d.enabled,
  };

  static CameraDevice _fromJson(Map<String, Object?> j) => CameraDevice(
    id: j['id']! as String,
    name: j['name']! as String,
    host: j['host']! as String,
    username: j['username']! as String,
    cabinIds: (j['cabinIds'] as List<Object?>? ?? const []).cast<int>().toSet(),
    rtspPort: (j['rtspPort'] as int?) ?? 554,
    channel: (j['channel'] as int?) ?? 101,
    enabled: (j['enabled'] as bool?) ?? true,
  );
}
