// [SWREQ-CORE-WAREHOUSE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetWarehousesUseCase {
  const GetWarehousesUseCase(this._repository);

  final IWarehouseRepository _repository;

  Future<Result<ApiResponse<List<Warehouse>>>> call(PagedQueryParams params) =>
      _repository.getWarehouses(skip: params.skip, take: params.take, searchQuery: params.searchQuery);
}
