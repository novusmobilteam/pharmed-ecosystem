import '../../../../core/core.dart';
import '../../../cabin/domain/entity/cabin_filling_request.dart';
import '../../../cabin_stock/data/model/cabin_stock_dto.dart';
import '../model/filling_list_dto.dart';
import '../model/filling_detail_dto.dart';

/// Dolum Listesi (Filling List) işlemleri için veri kaynağı arayüzü.
abstract class FillingListDataSource {
  /// Dolum listelerini getiren servis
  Future<Result<List<FillingListDTO>>> getFillingLists(int stationId);

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
  Future<Result<List<CabinStockDTO>>> getRefillCandidates({
    required FillingType type,
    required int stationId,
  });

  /// Oluşturulan dolum kaydının detayını getiren istek.
  Future<Result<List<FillingDetailDTO>>> getFillingListDetail(int fillingListId);

  /// İşlem yapılan istasyona ait dolum listelerini getirir
  Future<Result<List<FillingListDTO>>> getCurrentStationFillingLists();

  // Dolum listesi oluşturma işlemi iki aşamalı. Önce bu istek atılıyor, buradan gelen
  // verinin id'si ile createFillingList isteği atılıyor

  Future<Result<void>> fill(List<CabinFillingRequest> data);
}
