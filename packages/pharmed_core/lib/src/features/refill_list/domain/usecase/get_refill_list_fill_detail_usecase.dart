// GetRefillListDetailUseCase (manager) ile KARIŞTIRILMAMALI — o, satırları
// medicineId bazında gruplayıp konum bilgisini kaybediyor (form/özet amaçlı).
// Bu use case, client fill akışı için HAM satırları (medicineId gruplaması
// YAPILMADAN) döndürür — aynı ilaç birden fazla fiziksel çekmeceye
// atanmış olabileceğinden, her satırın kendi cabinAssignment/cabinDrawer
// bilgisi korunmalıdır (bkz. RefillListJobMapper: fiziksel çekmece bazlı
// gruplama).

import 'package:pharmed_core/pharmed_core.dart';

class GetRefillListFillDetailUseCase {
  final IRefillListRepository _repository;

  GetRefillListFillDetailUseCase(this._repository);

  Future<Result<List<RefillListDetail>>> call(int fillingListId) {
    return _repository.getFillingListDetail(fillingListId);
  }
}
