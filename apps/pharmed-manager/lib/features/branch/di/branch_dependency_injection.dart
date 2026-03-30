import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BranchProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 3. Use Cases
      Provider<GetBranchesUseCase>(create: (context) => GetBranchesUseCase(context.read())),
      Provider<CreateBranchUseCase>(create: (context) => CreateBranchUseCase(context.read())),
      Provider<UpdateBranchUseCase>(create: (context) => UpdateBranchUseCase(context.read())),
      Provider<DeleteBranchUseCase>(create: (context) => DeleteBranchUseCase(context.read())),
    ];
  }
}
