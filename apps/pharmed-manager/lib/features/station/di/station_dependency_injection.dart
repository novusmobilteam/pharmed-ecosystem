import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/core.dart';

class StationProviders {
  static List<SingleChildWidget> providers(SharedPreferences prefs, {bool isDev = false}) {
    return [
      // 3. Use Cases
      Provider<GetStationsUseCase>(create: (context) => GetStationsUseCase(context.read())),
      Provider<GetStationUseCase>(create: (context) => GetStationUseCase(context.read())),
      Provider<GetCurrentStationUseCase>(create: (context) => GetCurrentStationUseCase(context.read())),
      Provider<CreateStationUseCase>(create: (context) => CreateStationUseCase(context.read())),
      Provider<UpdateStationUseCase>(create: (context) => UpdateStationUseCase(context.read())),
      Provider<DeleteStationUseCase>(create: (context) => DeleteStationUseCase(context.read())),
      Provider<UpdateStationMacAddressUseCase>(create: (context) => UpdateStationMacAddressUseCase(context.read())),
    ];
  }
}
