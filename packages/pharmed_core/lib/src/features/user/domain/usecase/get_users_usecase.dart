// [SWREQ-CORE-USER-UC-004]
// Sadece pharmed_manager tarafından kullanılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUsersParams {
  const GetUsersParams({this.type, this.skip, this.take, this.search, this.searchFields});

  final UserType? type;
  final int? skip;
  final int? take;
  final String? search;
  final List<String>? searchFields;
}

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<ApiResponse<List<User>>>> call(GetUsersParams params) => _repository.getUsers(
    type: params.type,
    skip: params.skip,
    take: params.take,
    search: params.search,
    searchFields: params.searchFields,
  );
}
