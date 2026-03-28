import 'package:dio/dio.dart';

import '../../../core/storage/auth/auth.dart';
import '../data/datasource/auth_remote_data_source.dart';
import '../data/repository/auth_repository.dart';
import '../domain/repository/i_auth_repository.dart';
import '../domain/usecase/login_usecase.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
// Gerekli importları ekleyin

class AuthProviders {
  static List<SingleChildWidget> providers = [
    // 1. Data Source
    Provider<AuthRemoteDataSource>(
      create: (context) => AuthRemoteDataSource(
        dio: context.read<Dio>(),
      ),
    ),

    // 2. Repository
    Provider<IAuthRepository>(
      create: (context) => AuthRepository(
        remoteDataSource: context.read<AuthRemoteDataSource>(),
      ),
    ),

    // 3. UseCase
    Provider<LoginUseCase>(
      create: (context) => LoginUseCase(
        context.read<IAuthRepository>(),
        context.read<AuthStorageNotifier>(),
      ),
    ),
  ];
}
