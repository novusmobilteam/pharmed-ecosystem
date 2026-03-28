import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/inconsistency_datasource.dart';
import '../data/datasource/inconsistency_local_datasource.dart';
import '../data/datasource/inconsistency_remote_datasource.dart';
import '../data/repository/inconsitency_repository_impl.dart';

class InconsistencyProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<InconsistencyDataSource>(
        create: (context) {
          if (isDev) {
            return InconsistencyLocalDataSource(
              inconsistenciesPath: 'assets/mocks/inconsistency.json',
            );
          } else {
            return InconsistencyRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      Provider<InconsistencyRepository>(
        create: (context) {
          if (isDev) {
            return InconsistencyRepository.dev(local: context.read());
          } else {
            return InconsistencyRepository.prod(remote: context.read());
          }
        },
      ),
    ];
  }
}
