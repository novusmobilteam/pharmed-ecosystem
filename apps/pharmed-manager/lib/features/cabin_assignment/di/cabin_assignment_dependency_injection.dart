import '../data/datasource/cabin_assignment_local_datasource.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/cabin_assignment_datasource.dart';
import '../data/datasource/cabin_assignment_remote_datasource.dart';
import '../data/repository/cabin_assignment_repository.dart';
import '../domain/repository/i_cabin_assignment_repository.dart';
import '../domain/usecase/create_assignment_usecase.dart';
import '../domain/usecase/delete_assignment_usecase.dart';
import '../domain/usecase/get_assignments_usecase.dart';
import '../domain/usecase/get_cabin_assignments_usecase.dart';
import '../domain/usecase/get_independent_materials_usecase.dart';
import '../domain/usecase/update_assignment_usecase.dart';

class CabinAssignmentProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<CabinAssignmentDataSource>(
        create: (context) {
          if (isDev) {
            return CabinAssignmentLocalDataSource(assetPath: 'assets/mocks/cabin_drawer_quantity.json');
          } else {
            return CabinAssignmentRemoteDataSource(apiManager: context.read());
          }
        },
      ),

      // 2. Repository
      Provider<ICabinAssignmentRepository>(
        create: (context) => CabinAssignmentRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<CreateAssignmentUseCase>(
        create: (context) => CreateAssignmentUseCase(context.read()),
      ),
      Provider<DeleteAssignmentUseCase>(
        create: (context) => DeleteAssignmentUseCase(context.read()),
      ),
      Provider<GetAssignmentsUseCase>(
        create: (context) => GetAssignmentsUseCase(context.read()),
      ),
      Provider<UpdateAssignmentUseCase>(
        create: (context) => UpdateAssignmentUseCase(context.read()),
      ),
      Provider<GetCabinAssignmentsUseCase>(
        create: (context) => GetCabinAssignmentsUseCase(context.read()),
      ),

      Provider<GetCabinAssignmentsWithCabinUseCase>(
        create: (context) => GetCabinAssignmentsWithCabinUseCase(context.read()),
      ),
      Provider<GetIndependentMaterialsUseCase>(
        create: (context) => GetIndependentMaterialsUseCase(context.read()),
      ),
    ];
  }
}
