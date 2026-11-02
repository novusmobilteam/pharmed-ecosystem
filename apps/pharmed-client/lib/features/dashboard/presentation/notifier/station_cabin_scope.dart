// [SWREQ-CLI-STATIONSCOPE-001] [IEC 62304 §5.5]
//
// Kabin seçim adımı olmadan açılan istasyon geneli seçim ekranlarının
// (ilaç atama, dolum, sayım, boşaltma, iade kutusu boşaltma) ortak kabin
// kapsamı. Ekran istasyondaki TÜM işlem yapılabilir kabinlerin verisini
// görür; kullanıcı üstteki kabin şeridinden yalnızca hangi kabinin iç
// yerleşimini GÖRÜNTÜLEYECEĞİNİ seçer — seçim (göz/avadanlık) kabinler arası
// korunur ve kuyruk kabin sırasıyla kurulur.
//
// Atamanın hangi kabine ait olduğu, istasyon görsel verisindeki fiziksel
// çekmece (DrawerSlot.id) → kabin eşlemesinden çözülür; eşleşmezse atamanın
// kendi drawerSlot.cabinId'sine düşülür. Hiçbir kabine bağlanamayan atama
// istasyon listesinden düşürülür (görsel verisi olmayan / pasif kabin).
//
// Saf Dart — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'station_cabins_context.dart';

class StationCabinScope {
  StationCabinsContext? _context;
  Map<int, int> _slotToCabinId = const {};
  List<Cabin> _cabins = const [];

  int? _viewedCabinId;
  int? _cabinFilter;

  /// İşlem yapılabilir kabinler (pasif değil, kimliği ve görsel verisi var),
  /// istasyondaki sırasıyla.
  List<Cabin> get cabins => _cabins;

  /// Kuyruk sıralaması için kabin kimlikleri — şerit sırasıyla aynı.
  List<int> get cabinOrder => [for (final c in _cabins) ?c.id];

  /// İç yerleşimi gösterilen kabin.
  int? get viewedCabinId => _viewedCabinId;

  Cabin? get viewedCabin => _cabins.firstWhereOrNull((c) => c.id == _viewedCabinId);

  /// Sağ listenin kabin filtresi — null: tüm kabinler.
  int? get cabinFilter => _cabinFilter;

  bool get hasCabins => _cabins.isNotEmpty;

  /// İstasyondaki tüm işlem yapılabilir kabinlerin çekmece grupları — serum
  /// avadanlığı kilit adresleri gibi kabin bağımsız çözümlemeler için.
  List<DrawerGroup> get allGroups => [for (final id in cabinOrder) ...groupsOf(id)];

  List<DrawerGroup> groupsOf(int? cabinId) => _context?.dataFor(cabinId)?.groups ?? const <DrawerGroup>[];

  List<DrawerGroup> get viewedGroups => groupsOf(_viewedCabinId);

  /// [ctx] her route build'inde yeniden üretilebildiği için tekrar
  /// çağrılabilir — görüntülenen kabin hâlâ geçerliyse korunur.
  void attach(StationCabinsContext ctx) {
    _context = ctx;
    _cabins = [
      for (final c in ctx.cabins)
        if (c.id != null && c.status != Status.passive && ctx.dataFor(c.id) != null) c,
    ];
    _slotToCabinId = {
      for (final c in _cabins)
        for (final g in ctx.dataFor(c.id)?.groups ?? const <DrawerGroup>[])
          if (g.slot.id != null) g.slot.id!: c.id!,
    };

    final ids = cabinOrder;
    if (_viewedCabinId == null || !ids.contains(_viewedCabinId)) {
      final master = _cabins.firstWhereOrNull((c) => c.type == CabinType.master);
      _viewedCabinId = master?.id ?? ids.firstOrNull;
    }
    if (_cabinFilter != null && !ids.contains(_cabinFilter)) _cabinFilter = null;
  }

  /// true → görüntülenen kabin değişti.
  bool view(int? cabinId) {
    if (cabinId == null || cabinId == _viewedCabinId || !cabinOrder.contains(cabinId)) return false;
    _viewedCabinId = cabinId;
    return true;
  }

  /// true → filtre değişti.
  bool setFilter(int? cabinId) {
    final next = cabinId != null && cabinOrder.contains(cabinId) ? cabinId : null;
    if (next == _cabinFilter) return false;
    _cabinFilter = next;
    return true;
  }

  /// İlk görüntülenecek kabini belirler (ör. iade çekmecesi olan ilk kabin).
  void preferViewed(bool Function(int cabinId) test) {
    final current = _viewedCabinId;
    if (current != null && test(current)) return;
    final match = cabinOrder.firstWhereOrNull(test);
    if (match != null) _viewedCabinId = match;
  }

  int? cabinIdOfSlot(int? slotId) => slotId == null ? null : _slotToCabinId[slotId];

  int? cabinIdOf(MedicineAssignment a) {
    final slotId = a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;
    final fromSlot = cabinIdOfSlot(slotId);
    if (fromSlot != null) return fromSlot;
    final own = a.drawerUnit?.drawerSlot?.cabinId;
    return own != null && cabinOrder.contains(own) ? own : null;
  }

  String? cabinNameOf(MedicineAssignment a) {
    final id = cabinIdOf(a);
    return _cabins.firstWhereOrNull((c) => c.id == id)?.name;
  }

  /// Yalnızca işlem yapılabilir bir kabine bağlanabilen atamalar, kabin
  /// sırasıyla (aynı kabin içinde gelen sıra korunur).
  List<MedicineAssignment> stationAssignments(Iterable<MedicineAssignment> all) {
    final order = cabinOrder;
    final indexed = [
      for (final a in all)
        if (cabinIdOf(a) case final cabinId?) (order.indexOf(cabinId), a),
    ];
    return (indexed..sort((x, y) => x.$1.compareTo(y.$1))).map((e) => e.$2).toList();
  }

  /// [cabinFilter]'a göre süzülmüş liste.
  List<MedicineAssignment> filtered(Iterable<MedicineAssignment> items) {
    final filter = _cabinFilter;
    if (filter == null) return items.toList();
    return items.where((a) => cabinIdOf(a) == filter).toList();
  }

  List<MedicineAssignment> ofCabin(Iterable<MedicineAssignment> items, int? cabinId) =>
      items.where((a) => cabinId != null && cabinIdOf(a) == cabinId).toList();

  /// Kabin başına seçili atama sayısı — şerit rozetleri için.
  Map<int, int> countByCabin(Iterable<MedicineAssignment> items) {
    final counts = <int, int>{};
    for (final a in items) {
      final id = cabinIdOf(a);
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  /// Job'ın kabini, temsilci atamanın ilişkisel verisinden gelmediyse
  /// fiziksel çekmeceden çözülür — execution ekranı aktif kabini job.cabinId
  /// ile bulur, null kalırsa hiçbir şey gösteremez.
  List<CabinOperationDrawerJob> withCabinIds(List<CabinOperationDrawerJob> jobs) => [
    for (final job in jobs)
      job.cabinId != null
          ? job
          : CabinOperationDrawerJob(
              cabinDrawerId: job.cabinDrawerId,
              representativeAssignment: job.representativeAssignment,
              targets: job.targets,
              status: job.status,
              isReturnDrawer: job.isReturnDrawer,
              cabinId: cabinIdOfSlot(job.cabinDrawerId),
            ),
  ];
}
