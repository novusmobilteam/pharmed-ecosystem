import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IServiceRepository {
  Future<Result<ApiResponse<List<HospitalService>>>> getServices({int? skip, int? take, String? search});
  Future<Result<HospitalService?>> getService(int serviceId);
  Future<Result<void>> createService(HospitalService service);
  Future<Result<void>> updateService(HospitalService service);
  Future<Result<void>> deleteService(HospitalService service);
  Future<Result<List<Room>?>> getRooms(int serviceId);
  Future<Result<List<Bed>?>> getBeds(int roomId);
  Future<Result<void>> deleteRoom(int roomId);
  Future<Result<void>> deleteBed(int bedId);
}
