import '../../../../core/core.dart';

import '../entity/warehouse.dart';
import '../repository/i_warehouse_repository.dart';

class GetWarehousesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetWarehousesParams({this.skip, this.take, this.search});
}

class GetWarehousesUseCase implements UseCase<ApiResponse<List<Warehouse>>, GetWarehousesParams> {
  final IWarehouseRepository _repository;

  GetWarehousesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Warehouse>>>> call(GetWarehousesParams params) {
    return _repository.getWarehouses(skip: params.skip, take: params.take, search: params.search);
  }
}
