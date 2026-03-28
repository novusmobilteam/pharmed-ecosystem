import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/mail_preference_datasource.dart';
import '../data/datasource/mail_preference_local_datasource.dart';
import '../data/datasource/mail_preference_remote_datasource.dart';
import '../data/repository/mail_preference_repository_impl.dart';

class MailPreferenceProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<MailPreferenceDataSource>(
        create: (context) {
          if (isDev) {
            return MailPreferenceLocalDataSource(assetPath: 'assets/mocks/mail_preference.json');
          } else {
            return MailPreferenceRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      Provider<MailPreferenceRepository>(
        create: (context) {
          if (isDev) {
            return MailPreferenceRepository.dev(local: context.read());
          } else {
            return MailPreferenceRepository.prod(remote: context.read());
          }
        },
      ),
    ];
  }
}
