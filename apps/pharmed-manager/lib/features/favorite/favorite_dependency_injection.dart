import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'data/datasource/favorite_remote_data_source.dart';
import 'favorite.dart';

class FavoriteProviders {
  static List<SingleChildWidget> providers = [
    // 1. Data Source
    Provider<FavoriteDataSource>(
      create: (context) => FavoriteRemoteDataSource(apiManager: context.read()),
    ),

    // 2. Repository
    Provider<IFavoriteRepository>(
      create: (context) => FavoriteRepository(
        context.read(),
      ),
    ),

    // 3. UseCases
    Provider<GetFavoriteItemsUseCase>(
      create: (context) => GetFavoriteItemsUseCase(
        context.read<IFavoriteRepository>(),
      ),
    ),
    Provider<UpdateFavoritesUseCase>(
      create: (context) => UpdateFavoritesUseCase(
        context.read<IFavoriteRepository>(),
      ),
    ),
  ];
}
