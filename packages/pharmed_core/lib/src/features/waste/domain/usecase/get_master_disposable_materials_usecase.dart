import 'package:pharmed_core/pharmed_core.dart';

class GetMasterDisposableMaterialsUseCase {
  final IWasteRepository _repository;
  final IMedicineRepository _medicineRepository;

  GetMasterDisposableMaterialsUseCase(this._repository, this._medicineRepository);

  Future<Result<List<MedicineAssignment>>> call() async {
    final result = await _repository.getMasterDisposableMaterials();

    // Result.when senkron: burada sadece dallara ayırıp değişkene alıyoruz,
    // asıl async zenginleştirme .when dışında yapılır.
    List<MedicineAssignment>? assignments;
    AppException? failure;

    result.when(ok: (data) => assignments = data, error: (e) => failure = e);

    if (failure != null) return Result.error(failure!);

    final list = assignments ?? [];
    if (list.isEmpty) return Result.ok(list);

    final enriched = await _enrichWithDrugs(list);
    return Result.ok(enriched);
  }

  /// Listedeki farklı medicine.id'ler için tek tek getDrug çağırır,
  /// dönen Drug'ı assignment.medicine ile değiştirir.
  /// Bir id için fetch başarısız olursa o assignment'ın mevcut medicine
  /// bilgisi KORUNUR — tek bir ilaç hatası tüm listeyi düşürmemeli (HAZ-004: sessiz geçmez, loglanır).
  Future<List<MedicineAssignment>> _enrichWithDrugs(List<MedicineAssignment> assignments) async {
    final distinctIds = assignments.map((a) => a.medicine?.id).whereType<int>().toSet();

    if (distinctIds.isEmpty) return assignments;

    final drugById = <int, Drug>{};

    await Future.wait(
      distinctIds.map((id) async {
        final drugResult = await _medicineRepository.getDrug(id);
        drugResult.when(
          ok: (drug) {
            if (drug != null) drugById[id] = drug;
          },
          error: (e) {},
        );
      }),
    );

    return assignments.map((a) {
      final id = a.medicine?.id;
      final drug = id != null ? drugById[id] : null;
      if (drug == null) return a;
      return a.copyWith(medicine: drug);
    }).toList();
  }
}
