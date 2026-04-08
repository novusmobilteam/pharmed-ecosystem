import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class UserProviders {
  static List<SingleChildWidget> providers() => [
    // 1. Mapper
    Provider<UserMapper>(create: (_) => const UserMapper()),

    // 2. DataSource
    Provider<UserRemoteDataSource>(create: (context) => UserRemoteDataSource(apiManager: context.read<APIManager>())),

    // 3. Repository — IUserManager olarak register
    Provider<IUserManager>(
      create: (context) =>
          UserRepositoryImpl(dataSource: context.read<UserRemoteDataSource>(), mapper: context.read<UserMapper>()),
    ),

    // IUserReader ayrıca register etmeye gerek yok —
    // IUserManager, IUserReader'ı extend eder.
    // context.read<IUserReader>() yerine context.read<IUserManager>() kullan.

    // 4. Use Cases
    Provider<GetCurrentUserUseCase>(create: (context) => GetCurrentUserUseCase(context.read<IUserManager>())),
    Provider<GetUsersUseCase>(create: (context) => GetUsersUseCase(context.read<IUserManager>())),
    Provider<CreateUserUseCase>(create: (context) => CreateUserUseCase(context.read<IUserManager>())),
    Provider<UpdateUserUseCase>(create: (context) => UpdateUserUseCase(context.read<IUserManager>())),
    Provider<DeleteUserUseCase>(create: (context) => DeleteUserUseCase(context.read<IUserManager>())),
    Provider<BulkUpdateValidDateUseCase>(create: (context) => BulkUpdateValidDateUseCase(context.read<IUserManager>())),
    Provider<ChangePasswordUseCase>(create: (context) => ChangePasswordUseCase(context.read<IUserManager>())),
  ];
}
