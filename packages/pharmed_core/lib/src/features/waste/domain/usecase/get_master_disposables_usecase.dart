import 'package:pharmed_core/pharmed_core.dart';

class GetMasterDisposablesUseCase {
  final IWasteRepository _repository;
  final IMedicineRepository _medicineRepository;

  GetMasterDisposablesUseCase(this._repository, this._medicineRepository);

  Future<Result<List<DisposableItem>>> call(int hospitalizationId) async {
    final result = await _repository.getMasterDisposables(hospitalizationId: hospitalizationId);

    return result.when(
      ok: (items) async {
        // Aynı ilaç birden fazla reçete kaleminde tekrar edebiliyor (örn.
        // farklı zamanlarda alınmış aynı ilaç) — her tekrar için ayrı ayrı
        // getDrug() çağırmak yerine, ilaç id'si bazında BİR KEZ çekip
        // sonucu tüm eşleşen item'lar arasında paylaşıyoruz.
        final witnessCache = <int, WitnessContext>{};
        final List<DisposableItem> mapped = [];

        for (final item in items) {
          final witnessContext = await _resolveWitnessContext(item, witnessCache);
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

  /// [witnessCache]'i ilaç id'si bazında doldurur/okur — aynı çağrı
  /// (call()) içindeki tüm item'lar arasında paylaşılır, her item için
  /// yeniden network isteği atılmaz.
  Future<WitnessContext> _resolveWitnessContext(PrescriptionItem item, Map<int, WitnessContext> witnessCache) async {
    final medicine = item.medicine;
    if (medicine == null || medicine is! Drug) return const WitnessContext();

    final drug = medicine;
    if (!drug.isWastageWitnessedPurchase) return const WitnessContext();

    final medicineId = medicine.id;
    if (medicineId == null) return _fetchWitnessContext(drug);

    final cached = witnessCache[medicineId];
    if (cached != null) return cached;

    final fetched = await _fetchWitnessContext(drug);
    witnessCache[medicineId] = fetched;
    return fetched;
  }

  /// İlacın şahitli imha gerektirip gerektirmediğini kontrol eder.
  /// Gerektiriyorsa şahit kullanıcı ve istasyon listesini çeker.
  Future<WitnessContext> _fetchWitnessContext(Drug drug) async {
    List<User> witnesses = [];
    List<Station> stations = [];

    final res = await _medicineRepository.getDrug(drug.id ?? 0);
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
