import 'package:pharmed_core/pharmed_core.dart';

class RefillMasterCabinUseCase {
  final ICabinStockRepository _cabinStockRepository;

  RefillMasterCabinUseCase(this._cabinStockRepository);

  Future<Result<void>> call(List<CabinOperationMedicineParams> params) {
    return _cabinStockRepository.refillMasterCabin(params);
  }
}
