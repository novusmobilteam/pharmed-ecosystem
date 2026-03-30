import '../../../prescription/domain/entity/prescription_item.dart';

import '../../../../core/core.dart';

import '../entity/medicine_withdraw_item.dart';
import '../entity/withdraw_item.dart';
import '../repository/i_medicine_withdraw_repository.dart';
import 'package:collection/collection.dart';

class GetWithdrawItemsParams {
  final WithdrawType type;
  final int? hospitalizationId;
  // Orderlı alımda birbirine yakın saatlerde aynı iki ilacı almaya çalıştığımız
  // senaryoda ilk alım işleminden sonra kabin stokları yenilenmediği için
  // ikinci alımda stokların eksildiği görünmüyor ve bundan dolayı alımı ilk alım yaptığı
  // gözlerden almaya çalışıyor. Bu da stokların eksiye düşmesine sebep oluyor.
  final bool refreshAssignments;

  GetWithdrawItemsParams({required this.type, this.hospitalizationId, required this.refreshAssignments});
}

class GetWithdrawItemsUseCase implements UseCase<List<WithdrawItem>, GetWithdrawItemsParams> {
  final IMedicineWithdrawRepository _withdrawRepository;
  final ICabinAssignmentRepository _assignmentRepository;
  final IMedicineRepository _medicineRepository;
  List<WithdrawItem> _cachedItems = [];

  GetWithdrawItemsUseCase({
    required IMedicineWithdrawRepository withdrawRepository,
    required ICabinAssignmentRepository assignmentRepository,
    required IMedicineRepository medicineRepository,
  }) : _withdrawRepository = withdrawRepository,
       _assignmentRepository = assignmentRepository,
       _medicineRepository = medicineRepository;

  @override
  Future<Result<List<WithdrawItem>>> call(GetWithdrawItemsParams params) async {
    final type = params.type;
    final refreshAssignments = params.refreshAssignments;
    final hospitalizationId = params.hospitalizationId ?? 0;

    switch (type) {
      case WithdrawType.ordered:
        return await _getOrdered(hospitalizationId, refreshAssignments);
      case WithdrawType.orderless:
      case WithdrawType.urgent:
        return await _getOrderless();
      case WithdrawType.free:
        return await _getFree();
    }
  }

  Future<Result<List<WithdrawItem>>> _getOrderless() async {
    List<WithdrawItem> items = [];
    final result = await _assignmentRepository.getOrderlessCabinAssignments();
    return result.when(
      ok: (data) async {
        for (var d in data) {
          if (d.medicine == null) {
            return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
          }

          var (witnesses, stations) = await _fetchWitnesses(d.medicine!);
          items.add(
            WithdrawItem(
              id: d.id ?? 0,
              type: WithdrawType.orderless,
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

  Future<Result<List<WithdrawItem>>> _getFree() async {
    List<WithdrawItem> items = [];
    final result = await _assignmentRepository.getIndependentMaterials();
    return result.when(
      ok: (data) async {
        for (var d in data) {
          if (d.medicine == null) {
            return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
          }

          var (witnesses, stations) = await _fetchWitnesses(d.medicine!);

          items.add(
            WithdrawItem(
              id: d.id ?? 0,
              type: WithdrawType.free,
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

  Future<Result<List<WithdrawItem>>> _getOrdered(int hospitalizationId, bool refreshAssignments) async {
    // İlk yükleme: her iki istek paralel çalışır
    if (!refreshAssignments) {
      final result = await _fetchOrdered(hospitalizationId);
      // İlk yüklemede cache'i doldur
      if (result is Ok) {
        _cachedItems = (result as Ok<List<WithdrawItem>>).value;
      }
      return result;
    }

    // Sonraki alımlar: sadece assignment güncellenir, tasks tekrar çekilmez
    final assignmentsResult = await _assignmentRepository.getCabinAssignments();
    if (assignmentsResult is! Ok) {
      return Result.error(CustomException(message: "Bir hata oluştu."));
    }

    final List<CabinAssignment> freshAssignments = (assignmentsResult as Ok).value;

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

  Future<Result<List<WithdrawItem>>> _fetchOrdered(int hospitalizationId) async {
    List<WithdrawItem> items = [];

    final results = await Future.wait([
      _withdrawRepository.getWithdrawItems(hospitalizationId: hospitalizationId),
      _assignmentRepository.getCabinAssignments(),
    ]);

    final tasksResult = results[0] as Result<List<MedicineWithdrawItem>>;
    final assignmentsResult = results[1] as Result<List<CabinAssignment>>;

    if (tasksResult is! Ok || assignmentsResult is! Ok) {
      return Result.error(CustomException(message: "Bir hata oluştu."));
    }

    final allTasks = (tasksResult as Ok).value;
    final List<CabinAssignment> allAssignments = (assignmentsResult as Ok).value;

    for (MedicineWithdrawItem task in allTasks) {
      final assignment = allAssignments.firstWhereOrNull((a) => a.cabinDrawerId == task.cabinAssignment.cabinDrawerId);

      if (task.medicine == null) {
        return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'));
      }

      var (witnesses, stations) = await _fetchWitnesses(task.medicine!);

      items.add(
        WithdrawItem(
          id: task.id,
          type: WithdrawType.ordered,
          assignment: assignment, // null olsa bile ekliyoruz
          medicine: assignment?.medicine ?? task.medicine, // Fallback mekanizması
          dosePiece: task.dosePiece.toDouble(),
          prescriptionDose: task.dosePiece.toDouble(),
          witnesses: witnesses,
          stations: stations,
          prescriptionItem: PrescriptionItem(
            id: task.id,
            time: task.time,
            firstDoseEmergency: task.firstDoseEmergency,
            askDoctor: task.askDoctor,
            inCaseOfNecessity: task.inCaseOfNecessity,
            dosePiece: task.dosePiece.toDouble(),
          ),
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

  List<WithdrawItem> _groupByMedicine(List<WithdrawItem> items) {
    final Map<int, WithdrawItem> grouped = {};

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
