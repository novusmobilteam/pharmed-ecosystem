import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/core.dart';
import '../../core/storage/auth/auth.dart';
import 'domain/usecase/save_user_usecase.dart';
import 'user.dart';

class UserProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<UserDataSource>(
        create: (context) {
          if (isDev) {
            return UserLocalDataSource(assetPath: 'assets/mocks/user.json');
          } else {
            return UserRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 2. Repository
      Provider<IUserRepository>(
        create: (context) => UserRepository(
          dataSource: context.read<UserDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetCurrentUserUseCase>(
        create: (context) => GetCurrentUserUseCase(
          context.read<IUserRepository>(),
          context.read<AuthStorageNotifier>(),
        ),
      ),
      Provider<GetUsersUseCase>(
        create: (context) => GetUsersUseCase(context.read<IUserRepository>()),
      ),
      Provider<CreateUserUseCase>(
        create: (context) => CreateUserUseCase(context.read<IUserRepository>()),
      ),
      Provider<UpdateUserUseCase>(
        create: (context) => UpdateUserUseCase(context.read<IUserRepository>()),
      ),
      Provider<SaveUserUseCase>(
        create: (context) => SaveUserUseCase(context.read<IUserRepository>()),
      ),
      Provider<DeleteUserUseCase>(
        create: (context) => DeleteUserUseCase(context.read<IUserRepository>()),
      ),
      Provider<BulkUpdateValidDateUseCase>(
        create: (context) => BulkUpdateValidDateUseCase(context.read<IUserRepository>()),
      ),
      Provider<ChangePasswordUseCase>(
        create: (context) => ChangePasswordUseCase(context.read<IUserRepository>()),
      ),
    ];
  }
}
