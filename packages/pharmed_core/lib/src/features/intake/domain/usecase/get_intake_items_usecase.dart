import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

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
            return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
          }

          var (witnesses, stations) = await _fetchWitnesses(d.medicine!);
          items.add(
            IntakeItem(
              id: d.id ?? 0,
              type: IntakeType.orderless,
              assignment: d,
              medicine: d.medicine!,
              witnesses: witnesses,
              stations: stations,
            ),
          );
        }
        return Result.ok(_groupByMedicine(items));
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
            return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
          }

          var (witnesses, stations) = await _fetchWitnesses(d.medicine!);

          items.add(
            IntakeItem(
              id: d.id ?? 0,
              type: IntakeType.free,
              assignment: d,
              medicine: d.medicine!,
              witnesses: witnesses,
              stations: stations,
            ),
          );
        }
        return Result.ok(_groupByMedicine(items));
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
      return Result.error(CustomException(message: "Bir hata oluştu."));
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

    final tasksResult = results[0] as Result<List<MedicineIntakeItem>>;
    final assignmentsResult = results[1] as Result<List<MedicineAssignment>>;

    if (tasksResult is! Ok || assignmentsResult is! Ok) {
      return Result.error(CustomException(message: "Bir hata oluştu."));
    }

    final allTasks = (tasksResult as Ok).value;
    final List<MedicineAssignment> allAssignments = (assignmentsResult as Ok).value;

    for (MedicineIntakeItem task in allTasks) {
      final assignment = allAssignments.firstWhereOrNull((a) => a.cabinDrawerId == task.cabinAssignment.cabinDrawerId);

      if (task.medicine == null) {
        return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
      }

      var (witnesses, stations) = await _fetchWitnesses(task.medicine!);

      items.add(
        IntakeItem(
          id: task.id,
          type: IntakeType.ordered,
          assignment: assignment, // null olsa bile ekliyoruz
          medicine: assignment?.medicine ?? task.medicine, // Fallback mekanizması
          dosePiece: task.dosePiece.toDouble(),
          prescriptionDose: task.dosePiece.toDouble(),
          witnesses: witnesses,
          stations: stations,
          prescriptionItem: task.lastMovement?.prescriptionItem,
          lastMovement: task.lastMovement,
        ),
      );
    }

    return Result.ok(items);
  }

  Future<(List<User>, List<Station>)> _fetchWitnesses(Medicine medicine) async {
    List<User> witnesses = [];
    List<Station> stations = [];

    if (medicine.isDrug) {
      final drug = medicine as Drug?;
      if (drug?.isWitnessedPurchase ?? false) {
        final res = await _medicineRepository.getDrug(medicine.id ?? 0);
        res.when(
          error: Result.error,
          ok: (data) {
            witnesses = data?.witnessedPurchaseUsers ?? [];
            stations = data?.witnessedPurchaseStations ?? [];
          },
        );
      }
    } else {
      witnesses = [];
    }

    return (witnesses, stations);
  }

  List<IntakeItem> _groupByMedicine(List<IntakeItem> items) {
    final Map<int, IntakeItem> grouped = {};

    for (final item in items) {
      final medicineId = item.medicine?.id ?? item.id;

      if (grouped.containsKey(medicineId)) {
        final existing = grouped[medicineId]!;
        grouped[medicineId] = existing.copyWith(dosePiece: (existing.dosePiece ?? 0) + (item.dosePiece ?? 0));
      } else {
        grouped[medicineId] = item;
      }
    }

    return grouped.values.toList();
  }
}
