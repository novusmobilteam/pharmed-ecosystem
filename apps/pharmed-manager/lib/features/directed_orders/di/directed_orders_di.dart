import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/directed_order_datasource.dart';
import '../data/datasource/directed_order_local_datasource.dart';
import '../data/datasource/directed_order_remote_datasource.dart';
import '../data/repository/directed_order_repository_impl.dart';

class DirectedOrderProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<DirectedOrderDataSource>(
        create: (context) {
          if (isDev) {
            return DirectedOrderLocalDataSource(assetPath: 'assets/mocks/directed_order.json');
          } else {
            return DirectedOrderRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      Provider<DirectedOrderRepository>(
        create: (context) {
          if (isDev) {
            return DirectedOrderRepository.dev(local: context.read());
          } else {
            return DirectedOrderRepository.prod(remote: context.read());
          }
        },
      ),
    ];
  }
}
