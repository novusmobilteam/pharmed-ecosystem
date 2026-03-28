import '../data/datasource/remote/settings_data_source.dart';
import '../data/datasource/remote/settings_remote_data_source.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasource/persistence/app_settings_persistence.dart';
import '../data/datasource/persistence/local_storage_app_settings_persistence.dart';
import '../data/repository/settings_repository.dart';
import '../domain/repository/i_settings_repository.dart';
import '../presentation/notifier/settings_notifier.dart';

class SettingsProviders {
  static List<SingleChildWidget> providers(SharedPreferences prefs) {
    return [
      // 1. Data Source
      Provider<SettingsDataSource>(
        create: (context) {
          return SettingsRemoteDataSource(apiManager: context.read());
        },
      ),

      Provider<AppSettingsPersistence>(
        create: (_) => LocalStorageAppSettingsPersistence(prefs),
      ),

      // 3. Repository
      Provider<ISettingsRepository>(
        create: (context) => SettingsRepository(
          remoteDataSource: context.read(),
          localPersistence: context.read(),
        ),
      ),

      // 4. Use Cases
      ChangeNotifierProvider<SettingsNotifier>(
        create: (context) => SettingsNotifier(
          repository: context.read(),
        )..getSettings(),
      ),
    ];
  }
}
