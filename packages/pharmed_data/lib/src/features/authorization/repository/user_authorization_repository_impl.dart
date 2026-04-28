import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UserAuthorizationRepositoryImpl implements IUserAuthorizationRepository {
  final UserAuthorizationRemoteDataSource _dataSource;
  final UserMenuAuthorizationMapper _mapper;

  UserAuthorizationRepositoryImpl({
    required UserAuthorizationRemoteDataSource dataSource,
    required UserMenuAuthorizationMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  @override
  Future<Result<UserMenuAuthorization>> getAuthorization(User user) async {
    final res = await _dataSource.getAuthentication(user.id!);
    return res.when(
      ok: (dto) => Result.ok(_mapper.toEntity(dto, user: user)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> saveAuthorization(UserMenuAuthorization auth) async {
    final dto = _mapper.toDto(auth);

    if (auth.id != null) {
      return _dataSource.updateAuthentication(dto);
    } else {
      return _dataSource.createAuthentication(dto);
    }
  }
}
