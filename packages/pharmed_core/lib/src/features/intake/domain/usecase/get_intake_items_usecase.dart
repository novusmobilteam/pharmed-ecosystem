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

  final PatientFilterType filter;

  GetIntakeItemsParams({
    required this.type,
    this.hospitalizationId,
    this.filter = PatientFilterType.ordersDue,
    required this.refreshAssignments,
  });
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
        return await _getOrdered(hospitalizationId, refreshAssignments, params.filter);
      case IntakeType.orderless:
        return await _getOrderless();
      case IntakeType.urgent:
        return await _getUrgent();
      case IntakeType.free:
        return await _getFree();
    }
  }

  Future<Result<List<IntakeItem>>> _getOrderless() async {
    final result = await _assignmentRepository.getOrderlessCabinAssignments();
    return result.when(
      ok: (data) async {
        if (data.any((d) => d.medicine == null)) {
          return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
        }

        final witnessMap = await _resolveWitnessContexts(data.map<Medicine?>((d) => d.medicine));

        final items = data
            .map(
              (d) => IntakeItem(
                id: d.id ?? 0,
                type: IntakeType.orderless,
                assignment: d,
                medicine: d.medicine!,
                witnessContext: _witnessContextFor(d.medicine, witnessMap),
              ),
            )
            .toList();

        return Result.ok(items);
      },
      error: Result.error,
    );
  }

  Future<Result<List<IntakeItem>>> _getFree() async {
    final result = await _assignmentRepository.getIndependentMaterials();
    return result.when(
      ok: (data) async {
        if (data.any((d) => d.medicine == null)) {
          return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
        }

        final witnessMap = await _resolveWitnessContexts(data.map<Medicine?>((d) => d.medicine));

        final items = data
            .map(
              (d) => IntakeItem(
                id: d.id ?? 0,
                type: IntakeType.free,
                assignment: d,
                medicine: d.medicine!,
                witnessContext: _witnessContextFor(d.medicine, witnessMap),
              ),
            )
            .toList();

        return Result.ok(items);
      },
      error: Result.error,
    );
  }

  Future<Result<List<IntakeItem>>> _getOrdered(
    int hospitalizationId,
    bool refreshAssignments,
    PatientFilterType type,
  ) async {
    // İlk yükleme: her iki istek paralel çalışır
    if (!refreshAssignments) {
      final result = await _fetchOrdered(hospitalizationId, type);
      // İlk yüklemede cache'i doldur
      if (result is Ok) {
        _cachedItems = (result as Ok<List<IntakeItem>>).value;
      }
      return result;
    }

    // Sonraki alımlar: sadece assignment güncellenir, tasks tekrar çekilmez
    final assignmentsResult = await _assignmentRepository.getOrderlessCabinAssignments();
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

  Future<Result<List<IntakeItem>>> _getUrgent() async {
    final result = await _assignmentRepository.getStationAssignments();
    return result.when(
      ok: (data) async {
        if (data.any((d) => d.medicine == null)) {
          return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
        }

        final witnessMap = await _resolveWitnessContexts(data.map<Medicine?>((d) => d.medicine));

        final items = data
            .map(
              (d) => IntakeItem(
                id: d.id ?? 0,
                type: IntakeType.urgent,
                assignment: d,
                medicine: d.medicine!,
                witnessContext: _witnessContextFor(d.medicine, witnessMap),
              ),
            )
            .toList();

        return Result.ok(items);
      },
      error: Result.error,
    );
  }

  Future<Result<List<IntakeItem>>> _fetchOrdered(int hospitalizationId, PatientFilterType type) async {
    final results = await Future.wait([
      _intakeRepository.getIntakeItems(hospitalizationId: hospitalizationId, type: type),
      _assignmentRepository.getStationAssignments(),
    ]);

    final tasksResult = results[0] as Result<List<CabinTargetedPrescriptionItem>>;
    final assignmentsResult = results[1] as Result<List<MedicineAssignment>>;

    if (tasksResult is! Ok<List<CabinTargetedPrescriptionItem>> || assignmentsResult is! Ok<List<MedicineAssignment>>) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorShortMessage));
    }

    final List<CabinTargetedPrescriptionItem> allTasks = tasksResult.value;
    final List<MedicineAssignment> allAssignments = assignmentsResult.value;

    if (allTasks.any((t) => t.medicine == null)) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
    }

    final witnessMap = await _resolveWitnessContexts(allTasks.map<Medicine?>((t) => t.medicine));

    final items = allTasks.map((task) {
      final assignment = _resolveAssignment(task, allAssignments);
      return IntakeItem(
        id: task.id,
        type: IntakeType.ordered,
        assignment: assignment,
        medicine: assignment?.medicine ?? task.medicine,
        dosePiece: task.dosePiece.toDouble(),
        prescriptionDose: task.dosePiece.toDouble(),
        witnessContext: _witnessContextFor(task.medicine, witnessMap),
        lastMovement: task.lastMovement,
        firstDoseEmergency: task.firstDoseEmergency,
        inCaseOfNecessity: task.inCaseOfNecessity,
        askDoctor: task.askDoctor,
        stock: task.stock,
        time: task.time,
      );
    }).toList();

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
    final targetDetailId = task.cabinAssignment.cabinDrawerId;

    if (targetDetailId != null) {
      final byDetail = allAssignments.firstWhereOrNull(
        (a) => a.cabinDrawerDetail?.any((cell) => cell.id == targetDetailId) ?? false,
      );
      if (byDetail != null) return byDetail;
    }

    // Fallback: stok bilgisi yoksa (ör. noCount ilaç, tekil göz) eski davranış.
    return allAssignments.firstWhereOrNull((a) => a.cabinDrawerId == task.cabinAssignment.cabinDrawerId);
  }

  /// [medicines] içindeki BENZERSİZ, isWitnessedPurchase=true olan Drug'lar
  /// için PARALEL ve TEK SEFERLİK getDrug isteği atar. Aynı ilaç birden fazla
  /// kalemde geçse bile (örn. aynı ilaç farklı saatlerde) tek istek yeterli.
  Future<Map<int, WitnessContext>> _resolveWitnessContexts(Iterable<Medicine?> medicines) async {
    final uniqueDrugIds = medicines
        .whereType<Drug>()
        .where((d) => d.isWitnessedPurchase)
        .map((d) => d.id)
        .whereType<int>()
        .toSet();

    if (uniqueDrugIds.isEmpty) return {};

    final entries = await Future.wait(
      uniqueDrugIds.map((id) async {
        final res = await _medicineRepository.getDrug(id);
        return res.when(
          ok: (data) => MapEntry(
            id,
            WitnessContext(
              witnesses: data?.witnessedPurchaseUsers ?? [],
              stations: data?.witnessedPurchaseStations ?? [],
            ),
          ),
          error: (_) => MapEntry(id, const WitnessContext()),
        );
      }),
    );

    return Map.fromEntries(entries);
  }

  WitnessContext _witnessContextFor(Medicine? medicine, Map<int, WitnessContext> resolved) {
    if (medicine is! Drug || !medicine.isWitnessedPurchase) return const WitnessContext();
    return resolved[medicine.id] ?? const WitnessContext();
  }
}
