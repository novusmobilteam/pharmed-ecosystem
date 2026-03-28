import '../../../../core/core.dart';

import '../entity/firm.dart';
import '../repository/i_firm_repository.dart';

class GetFirmsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetFirmsParams({this.skip, this.take, this.search});
}

class GetFirmsUseCase implements UseCase<ApiResponse<List<Firm>>, GetFirmsParams> {
  final IFirmRepository _repository;
  GetFirmsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Firm>>>> call(GetFirmsParams params) {
    return _repository.getFirms(skip: params.skip, take: params.take, search: params.search);
  }
}
