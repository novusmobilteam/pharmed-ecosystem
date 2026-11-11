// [SWREQ-CORE-CABINOP-014] [IEC 62304 §5.5]
//
// Kabin işlemi seçim ekranlarının (dolum/sayım/boşaltma/imha) ortak seçim
// kümesi. Normal gözdeki atama göz (cabinDrawerId) ile seçilir; serum
// avadanlığındaki atama ise avadanlık (cabinDrawerDetailId) ile — aynı rafın
// (DrawerUnit) birden fazla avadanlığı olduğundan raf kimliği ayırt etmez.
//
// Seçilebilirlik kuralları (stok, yetki, kilitli mod) çağıranda kalır; bu
// sınıf yalnızca kümeyi tutar.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class AssignmentSelection {
  final Set<int> _unitIds = {};

  /// Serum ataması id → avadanlık (cabinDrawerDetailId). Serumda seçim ATAMA
  /// bazındadır: normal avadanlıkta tek atama olduğu için avadanlık seçmekle
  /// aynıdır; Açık Raf'ta ise aynı avadanlıkta birden çok ilaç bulunur ve
  /// her biri ayrı seçilir.
  final Map<int, int> _serumAssignmentCells = {};

  /// Id'siz serum ataması (beklenmez) — avadanlık bazında tutulur.
  final Set<int> _serumCellIdsWithoutId = {};

  /// Seçili normal göz kimlikleri (cabinDrawerId).
  Set<int> get unitIds => Set.unmodifiable(_unitIds);

  /// En az bir ataması seçili serum avadanlığı kimlikleri (cabinDrawerDetailId)
  /// — kabin görselinde vurgulama için.
  Set<int> get serumCellIds => Set.unmodifiable({..._serumAssignmentCells.values, ..._serumCellIdsWithoutId});

  bool get isEmpty => _unitIds.isEmpty && _serumAssignmentCells.isEmpty && _serumCellIdsWithoutId.isEmpty;
  bool get isNotEmpty => !isEmpty;

  bool contains(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) {
      final id = a.id;
      return id != null ? _serumAssignmentCells.containsKey(id) : _serumCellIdsWithoutId.contains(cellId);
    }
    final unitId = a.cabinDrawerId;
    return unitId != null && _unitIds.contains(unitId);
  }

  void add(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) {
      final id = a.id;
      if (id != null) {
        _serumAssignmentCells[id] = cellId;
      } else {
        _serumCellIdsWithoutId.add(cellId);
      }
      return;
    }
    final unitId = a.cabinDrawerId;
    if (unitId != null) _unitIds.add(unitId);
  }

  /// true → atama seçimdeydi ve çıkarıldı.
  bool remove(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) {
      final id = a.id;
      return id != null ? _serumAssignmentCells.remove(id) != null : _serumCellIdsWithoutId.remove(cellId);
    }
    final unitId = a.cabinDrawerId;
    return unitId != null && _unitIds.remove(unitId);
  }

  void toggle(MedicineAssignment a) {
    if (!remove(a)) add(a);
  }

  void addAll(Iterable<MedicineAssignment> items) => items.forEach(add);

  void removeAll(Iterable<MedicineAssignment> items) => items.forEach(remove);

  /// Hepsi seçiliyse hepsini kaldırır, değilse hepsini ekler. Boşsa false.
  bool toggleAll(Iterable<MedicineAssignment> items) {
    final list = items.toList();
    if (list.isEmpty) return false;
    list.every(contains) ? removeAll(list) : addAll(list);
    return true;
  }

  void clear() {
    _unitIds.clear();
    _serumAssignmentCells.clear();
    _serumCellIdsWithoutId.clear();
  }

  /// Bu seçimin içerdiği atamalar ([all] sırasıyla).
  List<MedicineAssignment> selectedFrom(Iterable<MedicineAssignment> all) => all.where(contains).toList();

  /// [group] çekmecesindeki atamalar — serumda avadanlıklara, diğerlerinde
  /// gözlere bağlı olanlar.
  static Iterable<MedicineAssignment> inGroup(DrawerGroup group, Iterable<MedicineAssignment> all) {
    if (group.isSerum) {
      final trayIds = group.serumTrayIds;
      return all.where((a) => a.cabinDrawerDetailId != null && trayIds.contains(a.cabinDrawerDetailId));
    }
    final unitIds = group.units.map((u) => u.id).whereType<int>().toSet();
    return all.where((a) => a.cabinDrawerDetailId == null && unitIds.contains(a.cabinDrawerId));
  }

  /// [cellId]'li serum avadanlığının ataması. Açık Raf'ta birden çok atama
  /// olabilir — orada [serumAssignments] kullanılmalı.
  static MedicineAssignment? serumAssignment(int cellId, Iterable<MedicineAssignment> all) {
    for (final a in all) {
      if (a.cabinDrawerDetailId == cellId) return a;
    }
    return null;
  }

  /// [cellId]'li serum avadanlığının TÜM atamaları (Açık Raf'ta birden çok).
  static List<MedicineAssignment> serumAssignments(int cellId, Iterable<MedicineAssignment> all) =>
      all.where((a) => a.cabinDrawerDetailId == cellId).toList();

  /// [unitId]'li normal gözün ataması (serum avadanlıkları hariç).
  static MedicineAssignment? unitAssignment(int unitId, Iterable<MedicineAssignment> all) {
    for (final a in all) {
      if (a.cabinDrawerDetailId == null && a.cabinDrawerId == unitId) return a;
    }
    return null;
  }
}
