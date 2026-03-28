import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../medicine_disposal/domain/usecase/dispose_medicine_usecase.dart';
import '../../data/datasource/medicine_withdraw_datasource.dart';
import '../../data/datasource/medicine_withdraw_remote_datasource.dart';
import '../../data/repository/medicine_withdraw_repository.dart';
import '../repository/i_medicine_withdraw_repository.dart';
import '../usecase/check_withdraw_usecase.dart';
import '../usecase/complete_withdraw_usecase.dart';
import '../usecase/define_patient_medicine_usecase.dart';
import '../usecase/get_patient_medicines_usecase.dart';
import '../usecase/get_withdraw_items_usecase.dart';
import '../usecase/withdraw_patient_medicine_usecase.dart';
import '../usecase/witness_user_login_usecase.dart';

class MedicineWithdrawProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<MedicineWithdrawDataSource>(
        create: (context) {
          return MedicineWithdrawRemoteDataSource(apiManager: context.read());
        },
      ),

      // 2. Repository
      Provider<IMedicineWithdrawRepository>(
        create: (context) => MedicineWithdrawRepository(context.read()),
      ),

      // 3. Use Cases

      Provider<CheckWithdrawUseCase>(
        create: (context) => CheckWithdrawUseCase(context.read()),
      ),

      Provider<CompleteWithdrawUseCase>(
        create: (context) => CompleteWithdrawUseCase(context.read()),
      ),

      Provider<GetWithdrawItemsUseCase>(
        create: (context) => GetWithdrawItemsUseCase(
          withdrawRepository: context.read(),
          assignmentRepository: context.read(),
          medicineRepository: context.read(),
        ),
      ),
      Provider<WitnessUserLoginUseCase>(
        create: (context) => WitnessUserLoginUseCase(context.read()),
      ),
      Provider<DisposeMedicineUseCase>(
        create: (context) => DisposeMedicineUseCase(context.read()),
      ),
      Provider<GetPatientMedicinesUseCase>(
        create: (context) => GetPatientMedicinesUseCase(context.read()),
      ),
      Provider<DefinePatientMedicineUseCase>(
        create: (context) => DefinePatientMedicineUseCase(context.read()),
      ),
      Provider<WithdrawPatientMedicineUseCase>(
        create: (context) => WithdrawPatientMedicineUseCase(context.read()),
      ),
    ];
  }
}
