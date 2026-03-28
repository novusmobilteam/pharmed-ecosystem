import 'package:dio/dio.dart';

import '../../../../core/core.dart';
import '../../domain/entity/token.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../datasource/auth_remote_data_source.dart';
import '../model/token_dto.dart';

class AuthRepository implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository({required AuthRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<Token>> login({required String email, required String password, String? macAddress}) async {
    try {
      final apiResponse = await _remoteDataSource.login(email: email, password: password, macAddress: macAddress!);

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        final dto = TokenDTO.fromJson(apiResponse.data!);
        return Result.ok(dto.toEntity());
      }
      return Result.error(ServiceException(message: 'Giriş başarısız', statusCode: 400));
    } catch (e) {
      // Hatayı parse etme mantığı
      String errorMessage = 'Bir hata oluştu';

      if (e is DioException) {
        try {
          final apiError = ApiError.fromJson(e.response!.data);
          errorMessage = apiError.error ?? errorMessage;
        } catch (_) {
          errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }

      return Result.error(ServiceException(message: errorMessage, statusCode: 400));
    }
  }
}
