import '../../../../core/core.dart';

import '../../user.dart';

class GetUsersParams {
  final UserType? type;
  final int? skip;
  final int? take;
  final String? search;
  final List<String> searchFields;

  GetUsersParams({this.type, this.skip, this.take, this.search, this.searchFields = const ['name', 'surname']});
}

class GetUsersUseCase implements UseCase<ApiResponse<List<User>>, GetUsersParams> {
  final IUserRepository _repository;
  GetUsersUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<User>>>> call(GetUsersParams params) {
    return _repository.getUsers(
      type: params.type,
      skip: params.skip,
      take: params.take,
      search: params.search,
      searchFields: const ['name', 'surname', 'registrationNumber'],
    );
  }
}
