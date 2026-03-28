import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/core.dart';
import '../data/datasource/persistence/local_storage_station_persistence.dart';
import '../data/datasource/persistence/station_persistence.dart';
import '../data/datasource/remote/station_data_source.dart';
import '../data/datasource/remote/station_local_data_source.dart';
import '../data/datasource/remote/station_remote_data_source.dart';
import '../data/repository/station_repository.dart';
import '../domain/repository/i_station_repository.dart';
import '../domain/usecase/create_station_usecase.dart';
import '../domain/usecase/delete_station_usecase.dart';
import '../domain/usecase/get_current_station_usecase.dart';
import '../domain/usecase/get_station_usecase.dart';
import '../domain/usecase/get_stations_usecase.dart';
import '../domain/usecase/update_station_mac_address_usecase.dart';
import '../domain/usecase/update_station_usecase.dart';

class StationProviders {
  static List<SingleChildWidget> providers(SharedPreferences prefs, {bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<StationDataSource>(
        create: (context) {
          if (isDev) {
            return StationLocalDataSource(assetPath: 'assets/mocks/station.json');
          } else {
            return StationRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      Provider<StationPersistence>(
        create: (_) => LocalStorageStationPersistence(prefs),
      ),

      // 2. Repository
      Provider<IStationRepository>(
        create: (context) => StationRepository(
          context.read<StationDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetStationsUseCase>(
        create: (context) => GetStationsUseCase(context.read()),
      ),
      Provider<GetStationUseCase>(
        create: (context) => GetStationUseCase(context.read()),
      ),
      Provider<GetCurrentStationUseCase>(
        create: (context) => GetCurrentStationUseCase(context.read()),
      ),
      Provider<CreateStationUseCase>(
        create: (context) => CreateStationUseCase(context.read()),
      ),
      Provider<UpdateStationUseCase>(
        create: (context) => UpdateStationUseCase(context.read()),
      ),
      Provider<DeleteStationUseCase>(
        create: (context) => DeleteStationUseCase(context.read()),
      ),
      Provider<UpdateStationMacAddressUseCase>(
        create: (context) => UpdateStationMacAddressUseCase(context.read()),
      ),
    ];
  }
}
