import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/branch_datasource.dart';
import '../data/datasource/branch_local_datasource.dart';
import '../data/datasource/branch_remote_datasource.dart';
import '../data/repository/branch_repository.dart';
import '../domain/repository/i_branch_repository.dart';
import '../domain/usecase/create_branch_usecase.dart';
import '../domain/usecase/delete_branch_usecase.dart';
import '../domain/usecase/get_branches_usecase.dart';
import '../domain/usecase/update_branch_usecase.dart';

class BranchProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<BranchDataSource>(
        create: (context) {
          if (isDev) {
            return BranchLocalDataSource(assetPath: 'assets/mocks/branch.json');
          } else {
            return BranchRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IBranchRepository>(
        create: (context) => BranchRepository(
          context.read<BranchDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetBranchesUseCase>(
        create: (context) => GetBranchesUseCase(context.read()),
      ),
      Provider<CreateBranchUseCase>(
        create: (context) => CreateBranchUseCase(context.read()),
      ),
      Provider<UpdateBranchUseCase>(
        create: (context) => UpdateBranchUseCase(context.read()),
      ),
      Provider<DeleteBranchUseCase>(
        create: (context) => DeleteBranchUseCase(context.read()),
      ),
    ];
  }
}
