import '../../../../core/core.dart';
import '../model/inconsistency_dto.dart';
import 'inconsistency_datasource.dart';

class _InconsistencyStore extends BaseLocalDataSource<InconsistencyDTO, int> {
  _InconsistencyStore({required super.filePath})
      : super(
          fromJson: (m) => InconsistencyDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

/// Tutarsızlık işlemleri için yerel (Mock) veri kaynağı.
class InconsistencyLocalDataSource implements InconsistencyDataSource {
  final _InconsistencyStore _incStore;

  InconsistencyLocalDataSource({
    required String inconsistenciesPath,
  }) : _incStore = _InconsistencyStore(filePath: inconsistenciesPath);

  @override
  Future<Result<ApiResponse<List<InconsistencyDTO>>>> getInconsistencies({
    int? skip,
    int? take,
    String? search,
  }) {
    return _incStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'drugName',
    );
  }
}
