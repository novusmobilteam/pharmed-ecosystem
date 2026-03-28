import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/filling_list_datasource.dart';
import '../data/datasource/filling_list_local_datasource.dart';
import '../data/datasource/filling_list_remote_datasource.dart';
import '../data/repository/filling_list_repository.dart';
import '../domain/repository/i_filling_list_repository.dart';
import '../domain/useacase/cancel_filling_list_usecase.dart';
import '../domain/useacase/create_filling_list_usecase.dart';
import '../domain/useacase/filling_list_refill_usecase.dart';
import '../domain/useacase/get_current_station_filling_lists_usecase.dart';
import '../domain/useacase/get_filling_list_detail_usecase.dart';
import '../domain/useacase/get_filling_lists_usecase.dart';
import '../domain/useacase/get_refill_candidates_usecase.dart';
import '../domain/useacase/update_filling_list_status_usecase.dart';
import '../domain/useacase/update_filling_list_usecase.dart';

class FillingListProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<FillingListDataSource>(
        create: (context) {
          if (isDev) {
            return FillingListLocalDataSource(
              recordsPath: 'assets/mocks/filling_record.json',
              detailsPath: 'assets/mocks/filling_detail.json',
            );
          } else {
            return FillingListRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      Provider<IFillingListRepository>(
        create: (context) {
          return FillingListRepository(context.read());
        },
      ),

      // Use Cases
      Provider<GetFillingListsUseCase>(
        create: (context) {
          return GetFillingListsUseCase(context.read());
        },
      ),
      Provider<UpdateFillingListStatusUseCase>(
        create: (context) {
          return UpdateFillingListStatusUseCase(context.read());
        },
      ),
      Provider<CancelFillingListUseCase>(
        create: (context) {
          return CancelFillingListUseCase(context.read());
        },
      ),
      Provider<CreateFillingListUseCase>(
        create: (context) {
          return CreateFillingListUseCase(context.read());
        },
      ),
      Provider<GetRefillCandidatesUseCase>(
        create: (context) {
          return GetRefillCandidatesUseCase(context.read());
        },
      ),
      Provider<GetFillingListDetailUseCase>(
        create: (context) {
          return GetFillingListDetailUseCase(context.read());
        },
      ),
      Provider<UpdateFillingListUseCase>(
        create: (context) {
          return UpdateFillingListUseCase(context.read());
        },
      ),
      Provider<GetCurrentStationFillingListsUseCase>(
        create: (context) {
          return GetCurrentStationFillingListsUseCase(context.read());
        },
      ),
      Provider<FillingListRefillUseCase>(
        create: (context) {
          return FillingListRefillUseCase(context.read());
        },
      ),
    ];
  }
}
