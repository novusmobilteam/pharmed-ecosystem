// [SWREQ-SETUP-UC-002] [IEC 62304 §5.5]
// Kurulum yapılmamış istasyonları dönen use case.
//
// AMAÇ:
//   Kabin kurulum sihirbazının istasyon seçim adımında (Step 3) yalnızca
//   henüz bir kabine atanmamış istasyonların listelenmesini sağlar.
//   Bu sayede aynı istasyona birden fazla kabin kurulmasının önüne geçilir.
//
// KULLANIM BAĞLAMI:
//   Setup Wizard → Step 3 (ServiceScope)
//   Kabin tipi master veya mobile olduğunda çağrılır.
//   Daha önce kurulum yapılmış istasyonlar listede gösterilmez.
//
// FARK — GetAllStationsUseCase ile karşılaştırma:
//   GetAllStationsUseCase    → sistemdeki tüm istasyonları döner
//   GetUnassignedStationsUseCase → henüz kabine atanmamış istasyonları döner
//
// AKIŞ:
//   1. IStationRepository.getUnassignedStations() çağrılır
//   2. Servis tarafında filtreleme yapılır (client tarafında değil)
//   3. Result<List<Station>> olarak döner
//
// HATA DURUMLARI:
//   • Ağ bağlantısı yoksa → Result.error (NetworkException)
//   • Sunucu hatası → Result.error (ServerException)
//   • Boş liste → Result.ok([]) — hata değildir, tüm istasyonlar atanmış demektir
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getUnassignedStationsUseCaseProvider = Provider<GetUnassignedStationsUseCase>((ref) {
  return GetUnassignedStationsUseCase(ref.read(stationRepositoryProvider));
});

class GetUnassignedStationsUseCase {
  const GetUnassignedStationsUseCase(this._repository);

  final IStationRepository _repository;

  /// Henüz bir kabine atanmamış istasyonları döner.
  ///
  /// Returns:
  ///   [Result.ok] → atanmamış istasyon listesi (boş olabilir)
  ///   [Result.error] → ağ veya sunucu hatası
  Future<Result<List<Station>>> call() {
    return _repository.getUnassignedStations();
  }
}
