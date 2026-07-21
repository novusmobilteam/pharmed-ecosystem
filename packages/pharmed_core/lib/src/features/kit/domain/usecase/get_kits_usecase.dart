import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetKitsUseCase {
  final IKitRepository _repository;

  GetKitsUseCase(this._repository);

  Future<Result<ApiResponse<List<Kit>>>> call(PagedQueryParams params) {
    return _repository.getKits(skip: params.skip, take: params.take, search: params.searchQuery);
  }
}
