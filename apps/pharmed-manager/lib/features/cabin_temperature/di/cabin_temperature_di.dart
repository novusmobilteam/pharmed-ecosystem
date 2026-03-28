import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/cabin_temperature_datasource.dart';
import '../data/datasource/cabin_temperature_local_datasource.dart';
import '../data/datasource/cabin_temperature_remote_datasource.dart';
import '../data/repository/cabin_temperature_repository_impl.dart';

class CabinTemperatureProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<CabinTemperatureDataSource>(
        create: (context) {
          if (isDev) {
            return CabinTemperatureLocalDataSource(
              cabinTemperaturePath: 'assets/mocks/cabin_temperature.json',
              cabinTemperatureDetailPath: 'assets/mocks/cabin_temperature_detail.json',
            );
          } else {
            return CabinTemperatureRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      Provider<CabinTemperatureRepository>(
        create: (context) {
          if (isDev) {
            return CabinTemperatureRepository.dev(local: context.read());
          } else {
            return CabinTemperatureRepository.prod(remote: context.read());
          }
        },
      ),
    ];
  }
}
