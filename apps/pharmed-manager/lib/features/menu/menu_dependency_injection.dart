import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/core.dart';

import 'data/datasource/menu_data_source.dart';
import 'data/datasource/menu_local_data_source.dart';
import 'data/datasource/menu_remote_data_source.dart';
import 'data/repository/menu_repository.dart';
import 'domain/repository/i_menu_repository.dart';
import 'domain/usecase/get_filtered_menus_usecase.dart';
import 'utils/menu_tree_mapper.dart';

class MenuProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Mapper
      Provider<MenuTreeMapper>(
        create: (_) => MenuTreeMapper(),
      ),

      // 2. Data Source
      Provider<MenuDataSource>(
        create: (context) {
          if (isDev) {
            return MenuLocalDataSource(assetPath: 'assets/mocks/menu.json');
          } else {
            return MenuRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 3. Repository
      Provider<IMenuRepository>(
        create: (context) => MenuRepository(
          dataSource: context.read<MenuDataSource>(),
          mapper: context.read<MenuTreeMapper>(),
        ),
      ),

      // 4. Use Cases
      Provider<GetFilteredMenusUseCase>(
        create: (context) => GetFilteredMenusUseCase(
          context.read<IMenuRepository>(),
        ),
      ),
    ];
  }
}
