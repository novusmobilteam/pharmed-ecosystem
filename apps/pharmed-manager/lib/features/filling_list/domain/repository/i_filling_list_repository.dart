import '../../../../core/core.dart';
import '../entity/filling_list.dart';
import '../entity/filling_detail.dart';
import '../../../cabin/domain/entity/cabin_filling_request.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';

abstract class IFillingListRepository {
  /// Dolum listelerini getiren servis
  Future<Result<List<FillingList>>> getFillingLists(int stationId);

  /// Dolum listesi durumunu güncelleyen servis
  Future<Result<void>> updateFillingListStatus(int fillingListId, int stationId);

  /// Dolum listesini iptal eden servis
  Future<Result<void>> cancelFillingList(int fillingListId, int stationId);

  /// Dolum listesi oluşturan servis
  Future<Result<void>> createFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
  });

  /// Dolum listesini güncelleyen servis
  Future<Result<void>> updateFillingList(
    List<Map<String, dynamic>> data, {
    required int stationId,
    required int fillingListId,
  });

  /// Dolum listesi oluşturulabilecek malzemeleri getirir
  Future<Result<List<CabinStock>>> getRefillCandidates({
    required FillingType type,
    required int stationId,
  });

  // Oluşturulan dolum kaydının detayını getiren istek
  Future<Result<List<FillingDetail>>> getFillingListDetail(int fillingListId);

  // İşlem yapılan kabine ait oluşturulan dolum listelerini getirir
  Future<Result<List<FillingList>>> getCurrentStationFillingLists();

  Future<Result<void>> fill(List<CabinFillingRequest> data);
}
