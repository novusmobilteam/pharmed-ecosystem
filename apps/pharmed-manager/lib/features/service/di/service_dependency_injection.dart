import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';

class ServiceProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 3. Use Cases
      Provider<GetServicesUseCase>(create: (context) => GetServicesUseCase(context.read())),
      Provider<CreateServiceUseCase>(create: (context) => CreateServiceUseCase(context.read())),
      Provider<UpdateServiceUseCase>(create: (context) => UpdateServiceUseCase(context.read())),
      Provider<DeleteServiceUseCase>(create: (context) => DeleteServiceUseCase(context.read())),
    ];
  }
}
