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
  final Set<int> _serumCellIds = {};

  /// Seçili normal göz kimlikleri (cabinDrawerId).
  Set<int> get unitIds => Set.unmodifiable(_unitIds);

  /// Seçili serum avadanlığı kimlikleri (cabinDrawerDetailId).
  Set<int> get serumCellIds => Set.unmodifiable(_serumCellIds);

  bool get isEmpty => _unitIds.isEmpty && _serumCellIds.isEmpty;
  bool get isNotEmpty => !isEmpty;

  bool contains(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) return _serumCellIds.contains(cellId);
    final unitId = a.cabinDrawerId;
    return unitId != null && _unitIds.contains(unitId);
  }

  void add(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) {
      _serumCellIds.add(cellId);
      return;
    }
    final unitId = a.cabinDrawerId;
    if (unitId != null) _unitIds.add(unitId);
  }

  /// true → atama seçimdeydi ve çıkarıldı.
  bool remove(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) return _serumCellIds.remove(cellId);
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
    _serumCellIds.clear();
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

  /// [cellId]'li serum avadanlığının ataması.
  static MedicineAssignment? serumAssignment(int cellId, Iterable<MedicineAssignment> all) {
    for (final a in all) {
      if (a.cabinDrawerDetailId == cellId) return a;
    }
    return null;
  }

  /// [unitId]'li normal gözün ataması (serum avadanlıkları hariç).
  static MedicineAssignment? unitAssignment(int unitId, Iterable<MedicineAssignment> all) {
    for (final a in all) {
      if (a.cabinDrawerDetailId == null && a.cabinDrawerId == unitId) return a;
    }
    return null;
  }
}
