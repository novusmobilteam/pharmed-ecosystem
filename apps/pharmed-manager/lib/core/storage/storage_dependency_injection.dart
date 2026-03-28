import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/auth.dart';

class StorageProviders {
  static List<SingleChildWidget> providers(SharedPreferences prefs) {
    return [
      Provider<AuthPersistence>(
        create: (_) => LocalStorageAuthPersistence(prefs)..clearAuth(),
      ),
      ChangeNotifierProvider<AuthStorageNotifier>(
        create: (context) => AuthStorageNotifier(
          store: context.read<AuthPersistence>(),
        ),
      ),
    ];
  }
}
