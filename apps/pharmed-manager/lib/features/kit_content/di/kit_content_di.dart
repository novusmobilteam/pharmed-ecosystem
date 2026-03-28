import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/kit_content_datasource.dart';
import '../data/datasource/kit_content_local_datasource.dart';
import '../data/datasource/kit_content_remote_datasource.dart';
import '../data/repository/kit_content_repository.dart';
import '../domain/repository/i_kit_content_repository.dart';
import '../domain/usecase/create_kit_content_usecase.dart';
import '../domain/usecase/delete_kit_content_usecase.dart';
import '../domain/usecase/get_kit_content_usecase.dart';
import '../domain/usecase/update_kit_content_usecase.dart';

class KitContentProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<KitContentDataSource>(
        create: (context) {
          if (isDev) {
            return KitContentLocalDataSource(assetPath: 'assets/mocks/kit_content.json');
          } else {
            return KitContentRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IKitContentRepository>(
        create: (context) => KitContentRepository(
          context.read<KitContentDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetKitContentUseCase>(
        create: (context) => GetKitContentUseCase(context.read()),
      ),
      Provider<DeleteKitContentUseCase>(
        create: (context) => DeleteKitContentUseCase(context.read()),
      ),
      Provider<CreateKitContentUseCase>(
        create: (context) => CreateKitContentUseCase(context.read()),
      ),
      Provider<UpdateKitContentUseCase>(
        create: (context) => UpdateKitContentUseCase(context.read()),
      ),
    ];
  }
}
