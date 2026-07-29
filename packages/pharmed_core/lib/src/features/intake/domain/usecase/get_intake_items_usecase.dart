import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class GetIntakeItemsParams {
  final IntakeType type;
  final int? hospitalizationId;
  // Orderlı alımda birbirine yakın saatlerde aynı iki ilacı almaya çalıştığımız
  // senaryoda ilk alım işleminden sonra kabin stokları yenilenmediği için
  // ikinci alımda stokların eksildiği görünmüyor ve bundan dolayı alımı ilk alım yaptığı
  // gözlerden almaya çalışıyor. Bu da stokların eksiye düşmesine sebep oluyor.
  final bool refreshAssignments;

  GetIntakeItemsParams({required this.type, this.hospitalizationId, required this.refreshAssignments});
}

class GetIntakeItemsUseCase {
  final IIntakeRepository _intakeRepository;
  final IAssignmentRepository _assignmentRepository;
  final IMedicineRepository _medicineRepository;
  List<IntakeItem> _cachedItems = [];

  GetIntakeItemsUseCase({
    required IIntakeRepository intakeRepository,
    required IAssignmentRepository assignmentRepository,
    required IMedicineRepository medicineRepository,
  }) : _intakeRepository = intakeRepository,
       _assignmentRepository = assignmentRepository,
       _medicineRepository = medicineRepository;

  Future<Result<List<IntakeItem>>> call(GetIntakeItemsParams params) async {
    final type = params.type;
    final refreshAssignments = params.refreshAssignments;
    final hospitalizationId = params.hospitalizationId ?? 0;

    switch (type) {
      case IntakeType.ordered:
        return await _getOrdered(hospitalizationId, refreshAssignments);
      case IntakeType.orderless:
      case IntakeType.urgent:
        return await _getOrderless();
      case IntakeType.free:
        return await _getFree();
    }
  }

  Future<Result<List<IntakeItem>>> _getOrderless() async {
    List<IntakeItem> items = [];
    final result = await _assignmentRepository.getOrderlessCabinAssignments();
    return result.when(
      ok: (data) async {
        for (var d in data) {
          if (d.medicine == null) {
            return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
          }

          items.add(
            IntakeItem(
              id: d.id ?? 0,
              type: IntakeType.orderless,
              assignment: d,
              medicine: d.medicine!,
              witnessContext: await _fetchWitnessContext(d.medicine!),
            ),
          );
        }
        // _groupByMedicine KALDIRILDI — aynı ilacın farklı fiziksel çekmecelerdeki
        // karşılıkları artık ayrı kart olarak gösteriliyor. Gruplama, farklı
        // assignment'ların stoklarını tek karta sıkıştırıp birini kaybediyordu
        // (copyWith yalnızca dosePiece'i topluyor, ikinci assignment'ı atıyordu) —
        // bu da kısmi-açma hesabının (calculateAddressFromAssignment) yanlış
        // çekmece üzerinden yapılmasına yol açabilirdi. İlaç bazlı gruplama +
        // "hangi çekmeceden alınacağına biz karar verelim" (SKT öncelikli, FEFO)
        // ayrı bir iş kalemi — şimdilik kapsam dışı.
        return Result.ok(items);
      },
      error: Result.error,
    );
  }

  Future<Result<List<IntakeItem>>> _getFree() async {
    List<IntakeItem> items = [];
    final result = await _assignmentRepository.getIndependentMaterials();
    return result.when(
      ok: (data) async {
        for (var d in data) {
          if (d.medicine == null) {
            return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
          }

          items.add(
            IntakeItem(
              id: d.id ?? 0,
              type: IntakeType.free,
              assignment: d,
              medicine: d.medicine!,
              witnessContext: await _fetchWitnessContext(d.medicine!),
            ),
          );
        }
        // Aynı gerekçe — bkz. _getOrderless.
        return Result.ok(items);
      },
      error: Result.error,
    );
  }

  Future<Result<List<IntakeItem>>> _getOrdered(int hospitalizationId, bool refreshAssignments) async {
    // İlk yükleme: her iki istek paralel çalışır
    if (!refreshAssignments) {
      final result = await _fetchOrdered(hospitalizationId);
      // İlk yüklemede cache'i doldur
      if (result is Ok) {
        _cachedItems = (result as Ok<List<IntakeItem>>).value;
      }
      return result;
    }

    // Sonraki alımlar: sadece assignment güncellenir, tasks tekrar çekilmez
    final assignmentsResult = await _assignmentRepository.getCabinAssignments();
    if (assignmentsResult is! Ok) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorShortMessage));
    }

    final List<MedicineAssignment> freshAssignments = (assignmentsResult as Ok).value;

    // Mevcut item listesindeki assignmentları güncelle
    final updatedItems = _cachedItems.map((item) {
      final freshAssignment = freshAssignments.firstWhereOrNull(
        (a) => a.cabinDrawerId == item.assignment?.cabinDrawerId,
      );
      return item.copyWith(assignment: freshAssignment ?? item.assignment);
    }).toList();

    _cachedItems = updatedItems;

    return Result.ok(_cachedItems);
  }

  Future<Result<List<IntakeItem>>> _fetchOrdered(int hospitalizationId) async {
    List<IntakeItem> items = [];

    final results = await Future.wait([
      _intakeRepository.getIntakeItems(hospitalizationId: hospitalizationId),
      _assignmentRepository.getCabinAssignments(),
    ]);

    final tasksResult = results[0] as Result<List<CabinTargetedPrescriptionItem>>;
    final assignmentsResult = results[1] as Result<List<MedicineAssignment>>;

    if (tasksResult is! Ok || assignmentsResult is! Ok) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorShortMessage));
    }

    final allTasks = (tasksResult as Ok).value;
    final List<MedicineAssignment> allAssignments = (assignmentsResult as Ok).value;

    for (CabinTargetedPrescriptionItem task in allTasks) {
      final assignment = _resolveAssignment(task, allAssignments);

      if (task.medicine == null) {
        return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
      }

      items.add(
        IntakeItem(
          id: task.id,
          type: IntakeType.ordered,
          assignment: assignment, // null olsa bile ekliyoruz
          medicine: assignment?.medicine ?? task.medicine, // Fallback mekanizması
          dosePiece: task.dosePiece.toDouble(),
          prescriptionDose: task.dosePiece.toDouble(),
          witnessContext: await _fetchWitnessContext(task.medicine!),
          lastMovement: task.lastMovement,
          firstDoseEmergency: task.firstDoseEmergency,
          inCaseOfNecessity: task.inCaseOfNecessity,
          askDoctor: task.askDoctor,
          stock: task.stock,
        ),
      );
    }

    return Result.ok(items);
  }

  /// [task]'ı GÖZE ÖZEL doğru assignment'a eşler.
  ///
  /// task.cabinAssignment.cabinDrawerId, materyal+fiziksel-çekmece bazlı bir
  /// AGREGAT kimliktir (aynı çekmecedeki her göz için AYNI değeri taşır) — bu
  /// yüzden birden fazla göz aynı materyale sahipse yanlış (her zaman ilk) göze
  /// eşleşmeye sebep olur. Doğru anahtar task.stock.cabinDrawerDetailId
  /// (DrawerCell.id, göze özel) — allAssignments'taki her assignment'ın kendi
  /// cabinDrawerDetail listesinde bu id'yi arayarak GERÇEK gözü buluyoruz.
  MedicineAssignment? _resolveAssignment(CabinTargetedPrescriptionItem task, List<MedicineAssignment> allAssignments) {
    final targetDetailId = task.stock?.cabinDrawerDetailId;

    if (targetDetailId != null) {
      final byDetail = allAssignments.firstWhereOrNull(
        (a) => a.cabinDrawerDetail?.any((cell) => cell.id == targetDetailId) ?? false,
      );
      if (byDetail != null) return byDetail;
    }

    // Fallback: stok bilgisi yoksa (ör. noCount ilaç, tekil göz) eski davranış.
    return allAssignments.firstWhereOrNull((a) => a.cabinDrawerId == task.cabinAssignment.cabinDrawerId);
  }

  Future<WitnessContext> _fetchWitnessContext(Medicine medicine) async {
    if (!medicine.isDrug) return const WitnessContext();

    final drug = medicine as Drug?;
    if (!(drug?.isWitnessedPurchase ?? false)) return const WitnessContext();

    List<User> witnesses = [];
    List<Station> stations = [];

    final res = await _medicineRepository.getDrug(medicine.id ?? 0);
    res.when(
      error: Result.error,
      ok: (data) {
        witnesses = data?.witnessedPurchaseUsers ?? [];
        stations = data?.witnessedPurchaseStations ?? [];
      },
    );

    return WitnessContext(witnesses: witnesses, stations: stations);
  }
}
