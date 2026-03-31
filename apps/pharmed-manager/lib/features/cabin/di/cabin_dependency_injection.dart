import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';

class CabinProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // Provider<ICabinOperationService>(
      //   create: (context) {
      //     return MockCabinOperationService();
      //   },
      // ),

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
      Provider<GetCabinsUseCase>(create: (context) => GetCabinsUseCase(context.read())),
      Provider<GetCabinsByStationUseCase>(create: (context) => GetCabinsByStationUseCase(context.read())),

      Provider<GetSerumSlotsUseCase>(create: (context) => GetSerumSlotsUseCase(context.read())),

      // Provider<ScanCabinUseCase>(
      //   create: (context) => ScanCabinUseCase(
      //     cabinOperationService: context.read(),
      //     serialService: context.read(),
      //     cabinRepository: context.read(),
      //   ),
      // ),
      // ChangeNotifierProvider<CabinStatusNotifier>(
      //   create: (context) => CabinStatusNotifier(
      //     cabinOperationService: context.read(),
      //     openDrawerUseCase: context.read(),
      //     handleSensorStatusUseCase: context.read(),
      //   ),
      // ),
    ];
  }
}
