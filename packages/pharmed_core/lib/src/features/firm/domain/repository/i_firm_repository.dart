import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IFirmRepository {
  Future<Result<ApiResponse<List<Firm>>>> getFirms({int? skip, int? take, String? search});
  Future<Result<void>> createFirm(Firm entity);
  Future<Result<void>> updateFirm(Firm entity);
  Future<Result<void>> deleteFirm(Firm entity);
}
