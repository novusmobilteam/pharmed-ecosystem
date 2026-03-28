import '../../../../core/core.dart';
import '../entity/firm.dart';

abstract class IFirmRepository {
  Future<Result<ApiResponse<List<Firm>>>> getFirms({int? skip, int? take, String? search});

  Future<Result<Firm>> createFirm(Firm entity);
  Future<Result<void>> updateFirm(Firm entity);
  Future<Result<void>> deleteFirm(int id);
}
