import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_manager/features/medicine_disposal/domain/usecase/dispose_medicine_usecase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MedicineWithdrawProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<MedicineWithdrawDataSource>(
      //   create: (context) {
      //     return MedicineWithdrawRemoteDataSource(apiManager: context.read());
      //   },
      // ),

      // // 2. Repository
      // Provider<IMedicineWithdrawRepository>(create: (context) => MedicineWithdrawRepository(context.read())),

      // 3. Use Cases
      Provider<CheckIntakeUseCase>(create: (context) => CheckIntakeUseCase(context.read())),

      Provider<CompleteIntakeUseCase>(create: (context) => CompleteIntakeUseCase(context.read())),

      Provider<GetWithdrawItemsUseCase>(
        create: (context) => GetWithdrawItemsUseCase(
          withdrawRepository: context.read(),
          assignmentRepository: context.read(),
          medicineRepository: context.read(),
        ),
      ),
      Provider<WitnessUserLoginUseCase>(create: (context) => WitnessUserLoginUseCase(context.read())),
      Provider<DisposeMedicineUseCase>(create: (context) => DisposeMedicineUseCase(context.read())),
      Provider<GetPatientMedicinesUseCase>(create: (context) => GetPatientMedicinesUseCase(context.read())),
      Provider<DefinePatientMedicineUseCase>(create: (context) => DefinePatientMedicineUseCase(context.read())),
      Provider<IntakePatientMedicineUseCase>(create: (context) => IntakePatientMedicineUseCase(context.read())),
    ];
  }
}
