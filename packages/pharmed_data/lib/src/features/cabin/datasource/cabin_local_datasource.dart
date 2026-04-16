// [SWREQ-DATA-CABIN-003] [IEC 62304 §5.5]
// Kabin verilerini Hive'da saklar ve okur.
// Serializasyon için mevcut DTO'ların toJson/fromJson metodları kullanılır.
// TypeAdapter yazılmaz — Map<String, dynamic> olarak saklanır.
// Sınıf: Class B

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ICabinLocalDataSource {
  // ── Kabin ──────────────────────────────────────────────────────
  Future<void> saveCabins(List<CabinDTO> cabins);
  Future<List<CabinDTO>?> readCabins();
  Future<DateTime?> cabinsSavedAt();

  // ── Slot ───────────────────────────────────────────────────────
  Future<void> saveSlots(int cabinId, List<DrawerSlotDTO> slots);
  Future<List<DrawerSlotDTO>?> readSlots(int cabinId);
  Future<DateTime?> slotsSavedAt(int cabinId);

  // ── Unit ───────────────────────────────────────────────────────
  Future<void> saveUnits(int slotId, List<DrawerUnitDTO> units);
  Future<List<DrawerUnitDTO>?> readUnits(int slotId);
  Future<DateTime?> unitsSavedAt(int slotId);
  Future<void> clearUnits(int slotId);

  // ── Meta (DrawerConfig + DrawerType) ──────────────────────────
  Future<void> saveDrawerConfigs(List<DrawerConfigDTO> configs);
  Future<List<DrawerConfigDTO>?> readDrawerConfigs();
  Future<void> saveDrawerTypes(List<DrawerTypeDTO> types);
  Future<List<DrawerTypeDTO>?> readDrawerTypes();

  // ── Mobil Çekmece ──────────────────────────────────────────────
  Future<void> saveMobileDrawers(int cabinId, List<MobileDrawerSlotDTO> drawers);
  Future<List<MobileDrawerSlotDTO>?> readMobileDrawers(int cabinId);
  Future<DateTime?> mobileDrawersSavedAt(int cabinId);

  // ── Temizlik ───────────────────────────────────────────────────
  Future<void> clearCabins();
  Future<void> clearSlots(int cabinId);
  Future<void> clearAll();
  Future<void> clearMobileDrawers(int cabinId);
}

class CabinLocalDataSource implements ICabinLocalDataSource {
  // Box isimleri
  static const _cabinBoxName = 'cabin_cache';
  static const _slotBoxName = 'drawer_slot_cache';
  static const _unitBoxName = 'drawer_unit_cache';
  static const _metaBoxName = 'cabin_meta_cache';

  // Key'ler
  static const _cabinsKey = 'cabins';
  static const _cabinsSavedAtKey = 'cabins_saved_at';
  static const _drawerConfigsKey = 'drawer_configs';
  static const _drawerTypesKey = 'drawer_types';

  // Slot key'leri cabinId ile prefix'lenir
  static String _slotsKey(int cabinId) => 'slots_$cabinId';
  static String _slotsSavedAtKey(int cabinId) => 'slots_saved_at_$cabinId';
  static String _unitsKey(int slotId) => 'units_$slotId';
  static String _unitsSavedAtKey(int slotId) => 'units_saved_at_$slotId';
  static String _mobileDrawersKey(int cabinId) => 'mobile_drawers_$cabinId';
  static String _mobileDrawersSavedAtKey(int cabinId) => 'mobile_drawers_saved_at_$cabinId';

  // ── Box açma ──────────────────────────────────────────────────

  Future<Box> _cabinBox() => Hive.openBox(_cabinBoxName);
  Future<Box> _slotBox() => Hive.openBox(_slotBoxName);
  Future<Box> _metaBox() => Hive.openBox(_metaBoxName);
  Future<Box> _unitBox() => Hive.openBox(_unitBoxName);

  // ── Kabin ──────────────────────────────────────────────────────

  @override
  Future<void> saveCabins(List<CabinDTO> cabins) async {
    final box = await _cabinBox();
    final encoded = cabins.map((c) => c.toJson()).toList();
    await box.put(_cabinsKey, jsonEncode(encoded));
    await box.put(_cabinsSavedAtKey, DateTime.now().toIso8601String());
  }

  @override
  Future<List<CabinDTO>?> readCabins() async {
    final box = await _cabinBox();
    final raw = box.get(_cabinsKey) as String?;
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list.map((e) => CabinDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DateTime?> cabinsSavedAt() async {
    final box = await _cabinBox();
    final raw = box.get(_cabinsSavedAtKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> saveMobileDrawers(int cabinId, List<MobileDrawerSlotDTO> drawers) async {
    final box = await _slotBox();
    final encoded = drawers.map((d) => d.toJson()).toList();
    await box.put(_mobileDrawersKey(cabinId), jsonEncode(encoded));
    await box.put(_mobileDrawersSavedAtKey(cabinId), DateTime.now().toIso8601String());
  }

  @override
  Future<List<MobileDrawerSlotDTO>?> readMobileDrawers(int cabinId) async {
    final box = await _slotBox();
    final raw = box.get(_mobileDrawersKey(cabinId)) as String?;
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list.map((e) => MobileDrawerSlotDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DateTime?> mobileDrawersSavedAt(int cabinId) async {
    final box = await _slotBox();
    final raw = box.get(_mobileDrawersSavedAtKey(cabinId)) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── Slot ───────────────────────────────────────────────────────

  @override
  Future<void> saveSlots(int cabinId, List<DrawerSlotDTO> slots) async {
    final box = await _slotBox();
    final encoded = slots.map((s) => s.toJson()).toList();
    await box.put(_slotsKey(cabinId), jsonEncode(encoded));
    await box.put(_slotsSavedAtKey(cabinId), DateTime.now().toIso8601String());
  }

  @override
  Future<List<DrawerSlotDTO>?> readSlots(int cabinId) async {
    final box = await _slotBox();
    final raw = box.get(_slotsKey(cabinId)) as String?;
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list.map((e) => DrawerSlotDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DateTime?> slotsSavedAt(int cabinId) async {
    final box = await _slotBox();
    final raw = box.get(_slotsSavedAtKey(cabinId)) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── Unit ───────────────────────────────────────────────────────
  @override
  Future<void> saveUnits(int slotId, List<DrawerUnitDTO> units) async {
    final box = await _unitBox();
    final encoded = units.map((u) => u.toJson()).toList();
    await box.put(_unitsKey(slotId), jsonEncode(encoded));
    await box.put(_unitsSavedAtKey(slotId), DateTime.now().toIso8601String());
  }

  @override
  Future<List<DrawerUnitDTO>?> readUnits(int slotId) async {
    final box = await _unitBox();
    final raw = box.get(_unitsKey(slotId)) as String?;
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list.map((e) => DrawerUnitDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DateTime?> unitsSavedAt(int slotId) async {
    final box = await _unitBox();
    final raw = box.get(_unitsSavedAtKey(slotId)) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> clearUnits(int slotId) async {
    final box = await _unitBox();
    await box.delete(_unitsKey(slotId));
    await box.delete(_unitsSavedAtKey(slotId));
  }

  // ── Meta ───────────────────────────────────────────────────────

  @override
  Future<void> saveDrawerConfigs(List<DrawerConfigDTO> configs) async {
    final box = await _metaBox();
    final encoded = configs.map((c) => c.toJson()).toList();
    await box.put(_drawerConfigsKey, jsonEncode(encoded));
  }

  @override
  Future<List<DrawerConfigDTO>?> readDrawerConfigs() async {
    final box = await _metaBox();
    final raw = box.get(_drawerConfigsKey) as String?;
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list.map((e) => DrawerConfigDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<void> saveDrawerTypes(List<DrawerTypeDTO> types) async {
    final box = await _metaBox();
    final encoded = types.map((t) => t.toJson()).toList();
    await box.put(_drawerTypesKey, jsonEncode(encoded));
  }

  @override
  Future<List<DrawerTypeDTO>?> readDrawerTypes() async {
    final box = await _metaBox();
    final raw = box.get(_drawerTypesKey) as String?;
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list.map((e) => DrawerTypeDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  // ── Temizlik ───────────────────────────────────────────────────

  @override
  Future<void> clearCabins() async {
    final box = await _cabinBox();
    await box.delete(_cabinsKey);
    await box.delete(_cabinsSavedAtKey);
  }

  @override
  Future<void> clearSlots(int cabinId) async {
    final box = await _slotBox();
    await box.delete(_slotsKey(cabinId));
    await box.delete(_slotsSavedAtKey(cabinId));
    await box.delete(_mobileDrawersKey(cabinId));
    await box.delete(_mobileDrawersSavedAtKey(cabinId));
  }

  @override
  Future<void> clearMobileDrawers(int cabinId) async {
    final box = await _slotBox();
    await box.delete(_mobileDrawersKey(cabinId));
    await box.delete(_mobileDrawersSavedAtKey(cabinId));
  }

  @override
  Future<void> clearAll() async {
    final cabinBox = await _cabinBox();
    final slotBox = await _slotBox();
    final unitBox = await _unitBox();
    final metaBox = await _metaBox();

    await Future.wait([cabinBox.clear(), slotBox.clear(), unitBox.clear(), metaBox.clear()]);
  }
}
