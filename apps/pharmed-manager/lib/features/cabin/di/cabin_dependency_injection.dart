import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';

import '../data/repository/mock_cabin_operation_service.dart';
import '../domain/repository/i_cabin_operation_service.dart';

import '../shared/cabin_process/notifier/cabin_status_notifier.dart';

class CabinProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<ICabinOperationService>(
        create: (context) {
          return MockCabinOperationService();
        },
      ),

      // TODO : Versiyon gönderirken düzelt..
      // Provider<ICabinOperationService>(
      //   create: (context) {
      //     if (isDev) {
      //       return MockCabinOperationService();
      //     } else {
      //       return CabinOperationService(
      //         serialCommunicationService: context.read(),
      //       );
      //     }
      //   },
      // ),

      // 3. Use Cases
      Provider<CreateCabinUseCase>(create: (context) => CreateCabinUseCase(context.read(), context.read())),
      Provider<DeleteCabinUseCase>(create: (context) => DeleteCabinUseCase(context.read())),
      Provider<GetCabinsUseCase>(create: (context) => GetCabinsUseCase(context.read())),
      Provider<GetCabinsByStationUseCase>(create: (context) => GetCabinsByStationUseCase(context.read())),
      Provider<UpdateCabinUseCase>(create: (context) => UpdateCabinUseCase(context.read())),

      Provider<GetCabinLayoutUseCase>(create: (context) => GetCabinLayoutUseCase(context.read(), context.read())),

      Provider<SaveCabinDesignUseCase>(create: (context) => SaveCabinDesignUseCase(cabinRepository: context.read())),

      Provider<HandleSensorStatusUseCase>(create: (context) => HandleSensorStatusUseCase(context.read())),

      Provider<OpenDrawerUseCase>(create: (context) => OpenDrawerUseCase(context.read())),

      Provider<GetSerumSlotsUseCase>(create: (context) => GetSerumSlotsUseCase(context.read())),

      Provider<ScanCabinUseCase>(
        create: (context) => ScanCabinUseCase(
          cabinOperationService: context.read(),
          serialService: context.read(),
          cabinRepository: context.read(),
        ),
      ),

      ChangeNotifierProvider<CabinStatusNotifier>(
        create: (context) => CabinStatusNotifier(
          cabinOperationService: context.read(),
          openDrawerUseCase: context.read(),
          handleSensorStatusUseCase: context.read(),
        ),
      ),
    ];
  }
}
