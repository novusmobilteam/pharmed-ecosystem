import 'package:pharmed_core/pharmed_core.dart';

abstract class IRefillListRepository {
  /// Dolum listelerini getiren servis
  Future<Result<List<RefillList>>> getFillingLists(int stationId);

  /// Dolum listesi durumunu güncelleyen servis
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId);

  /// Dolum listesini iptal eden servis
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId);

  /// Dolum listesi oluşturan servis
  Future<Result<void>> createFillingList(List<Map<String, dynamic>> data, {required int stationId});

  /// Dolum listesini güncelleyen servis
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  });

  /// Dolum listesi oluşturulabilecek malzemeleri getirir
  Future<Result<List<CabinStock>>> getRefillCandidates({required RefillType type, required int stationId});

  // Oluşturulan dolum kaydının detayını getiren istek
  Future<Result<List<RefillListDetail>>> getFillingListDetail(int fillingListId);

  // İşlem yapılan kabine ait oluşturulan dolum listelerini getirir
  Future<Result<List<RefillList>>> getCurrentStationFillingLists();

  Future<Result<void>> fill(List<CabinRefillParams> data);
}
