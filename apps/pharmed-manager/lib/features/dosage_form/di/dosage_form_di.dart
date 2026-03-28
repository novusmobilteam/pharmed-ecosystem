import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/dosage_form_datasource.dart';
import '../data/datasource/dosage_form_local_datasource.dart';
import '../data/datasource/dosage_form_remote_datasource.dart';
import '../data/repository/dosage_form_repository.dart';
import '../domain/repository/i_dosage_form_repository.dart';
import '../domain/usecase/create_dosage_form_usecase.dart';
import '../domain/usecase/delete_dosage_form_usecase.dart';
import '../domain/usecase/get_dosage_forms_usecase.dart';
import '../domain/usecase/update_dosage_form_usecase.dart';

class DosageFormProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<DosageFormDataSource>(
        create: (context) {
          if (isDev) {
            return DosageFormLocalDataSource(assetPath: 'assets/mocks/branch.json');
          } else {
            return DosageFormRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IDosageFormRepository>(
        create: (context) => DosageFormRepository(
          context.read<DosageFormDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetDosageFormsUseCase>(
        create: (context) => GetDosageFormsUseCase(context.read()),
      ),
      Provider<CreateDosageFormUseCase>(
        create: (context) => CreateDosageFormUseCase(context.read()),
      ),
      Provider<DeleteDosageFormUseCase>(
        create: (context) => DeleteDosageFormUseCase(context.read()),
      ),
      Provider<UpdateDosageFormUseCase>(
        create: (context) => UpdateDosageFormUseCase(context.read()),
      ),
    ];
  }
}
