import 'package:pharmed_core/pharmed_core.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class CabinAssignmentProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<CabinAssignmentDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return CabinAssignmentLocalDataSource(assetPath: 'assets/mocks/cabin_drawer_quantity.json');
      //     } else {
      //       return CabinAssignmentRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),

      // // 2. Repository
      // Provider<ICabinAssignmentRepository>(
      //   create: (context) => CabinAssignmentRepository(context.read()),
      // ),

      // 3. Use Cases
      Provider<CreateAssignmentUseCase>(create: (context) => CreateAssignmentUseCase(context.read())),
      Provider<DeleteAssignmentUseCase>(create: (context) => DeleteAssignmentUseCase(context.read())),
      Provider<GetAssignmentsUseCase>(create: (context) => GetAssignmentsUseCase(context.read())),
      Provider<UpdateAssignmentUseCase>(create: (context) => UpdateAssignmentUseCase(context.read())),
      Provider<GetCabinAssignmentsUseCase>(create: (context) => GetCabinAssignmentsUseCase(context.read())),

      Provider<GetCabinAssignmentsWithCabinUseCase>(
        create: (context) => GetCabinAssignmentsWithCabinUseCase(context.read()),
      ),
      Provider<GetIndependentMaterialsUseCase>(create: (context) => GetIndependentMaterialsUseCase(context.read())),
    ];
  }
}
