import '../../../../core/core.dart';
import '../model/firm_dto.dart';

abstract class FirmDataSource {
  Future<Result<ApiResponse<List<FirmDTO>>>> getFirms({int? skip, int? take, String? search});
  Future<Result<FirmDTO?>> createFirm(FirmDTO firm);
  Future<Result<void>> updateFirm(FirmDTO firm);
  Future<Result<void>> deleteFirm(int id);
}
