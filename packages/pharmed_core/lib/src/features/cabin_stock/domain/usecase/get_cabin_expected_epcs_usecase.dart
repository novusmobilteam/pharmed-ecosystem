// [SWREQ-CABIN-RFID-001] [IEC 62304 §5.5]
// Bir kabinde şu an stokta olan tüm RFID etiketlerini (EPC) getirir.
//
// Mobil çekmece operasyonlarında (alım/dolum/boşaltma/sayım) çekmece
// açıldığında kabin baseline'ı ile karşılaştırma yapmak için kullanılır.
// "Expected vs Observed" reconciliation'ın "Expected" tarafıdır.
//
// Boş liste = kabinde RFID'li ilaç yok (geçerli senaryo, hata değil).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetCabinExpectedEpcsUseCase {
  GetCabinExpectedEpcsUseCase(this._repository);

  final ICabinStockRepository _repository;

  Future<Result<List<CabinExpectedEpc>>> call(int cabinId) {
    return _repository.getExpectedEpcs(cabinId);
  }
}
