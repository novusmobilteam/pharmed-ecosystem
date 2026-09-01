import 'package:pharmed_core/pharmed_core.dart';

class EquivalentIntakeParams {
  final int prescriptionDetailId;
  final int materialId;
  final double? censusQuantity;

  EquivalentIntakeParams({required this.prescriptionDetailId, required this.materialId, this.censusQuantity});

  Map<String, dynamic> toJson() => {
    "prescriptionDetailId": prescriptionDetailId,
    "materialId": materialId,
    "censusQuantity": censusQuantity,
  };
}

class GetEquivalentIntakesUseCase {
  const GetEquivalentIntakesUseCase(this._repository, this._medicineRepository);

  final IIntakeRepository _repository;
  final IMedicineRepository _medicineRepository;

  Future<Result<List<EquivalentMedicine>>> call(int prescriptionDetailId) async {
    final result = await _repository.getEquivalentMedicines(prescriptionDetailId: prescriptionDetailId);

    return result.when(
      ok: (list) async => Result.ok(await Future.wait(list.map(_withWitnessContext))),
      error: Result.error,
    );
  }

  Future<EquivalentMedicine> _withWitnessContext(EquivalentMedicine equivalent) async {
    final medicine = equivalent.medicine;

    //if (medicine is! Drug || !medicine.isWitnessedPurchase) return equivalent;

    final res = await _medicineRepository.getDrug(medicine?.id ?? 0);
    return res.when(
      ok: (data) => equivalent.copyWith(
        witnessContext: WitnessContext(
          witnesses: data?.witnessedPurchaseUsers ?? [],
          stations: data?.witnessedPurchaseStations ?? [],
        ),
      ),
      error: (_) => equivalent,
    );
  }
}

class CheckEquivalentIntakeUseCase {
  const CheckEquivalentIntakeUseCase(this._repository);
  final IIntakeRepository _repository;

  Future<Result<void>> call(EquivalentIntakeParams params) => _repository.checkEquivalentIntake(params.toJson());
}

class CompleteEquivalentIntakeUseCase {
  const CompleteEquivalentIntakeUseCase(this._repository);
  final IIntakeRepository _repository;

  Future<Result<void>> call(EquivalentIntakeParams params) => _repository.completeEquivalentIntake(params.toJson());
}
