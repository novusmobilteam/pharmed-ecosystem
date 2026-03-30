import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DosageFormProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      // Provider<DosageFormDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return DosageFormLocalDataSource(assetPath: 'assets/mocks/branch.json');
      //     } else {
      //       return DosageFormRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),
      // // 2. Repository
      // Provider<IDosageFormRepository>(
      //   create: (context) => DosageFormRepository(
      //     context.read<DosageFormDataSource>(),
      //   ),
      // ),
      // 3. Use Cases
      Provider<GetDosageFormsUseCase>(create: (context) => GetDosageFormsUseCase(context.read())),
      Provider<CreateDosageFormUseCase>(create: (context) => CreateDosageFormUseCase(context.read())),
      Provider<DeleteDosageFormUseCase>(create: (context) => DeleteDosageFormUseCase(context.read())),
      Provider<UpdateDosageFormUseCase>(create: (context) => UpdateDosageFormUseCase(context.read())),
    ];
  }
}
