import 'package:pharmed_core/pharmed_core.dart';

class GetMasterDisposablesUseCase {
  final IWasteRepository _repository;
  final IMedicineRepository _medicineRepository;

  GetMasterDisposablesUseCase(this._repository, this._medicineRepository);

  Future<Result<List<DisposableItem>>> call(int hospitalizationId) async {
    final result = await _repository.getMasterDisposables(hospitalizationId: hospitalizationId);

    return result.when(
      ok: (items) async {
        final List<DisposableItem> mapped = [];

        for (final item in items) {
          final witnessContext = await _fetchWitnessContext(item);
          mapped.add(
            DisposableItem(
              id: item.id ?? 0,
              medicine: item.medicine,
              dosePiece: item.dosePiece ?? 0,
              hospitalization: item.hospitalization,
              lastMovement: item.lastMovement,
              witnessContext: witnessContext,
            ),
          );
        }

        return Result.ok(mapped);
      },
      error: Result.error,
    );
  }

  /// İlacın şahitli imha gerektirip gerektirmediğini kontrol eder.
  /// Gerektiriyorsa şahit kullanıcı ve istasyon listesini çeker.
  Future<WitnessContext> _fetchWitnessContext(PrescriptionItem item) async {
    final medicine = item.medicine;
    if (medicine == null || medicine is! Drug) return const WitnessContext();

    final drug = medicine;
    if (!drug.isWastageWitnessedPurchase) return const WitnessContext();

    List<User> witnesses = [];
    List<Station> stations = [];

    final res = await _medicineRepository.getDrug(medicine.id ?? 0);
    res.when(
      error: (_) {},
      ok: (data) {
        witnesses = data?.wastageWitnessedPurchaseUsers ?? [];
        stations = data?.witnessedPurchaseStations ?? [];
      },
    );

    return WitnessContext(witnesses: witnesses, stations: stations);
  }
}
