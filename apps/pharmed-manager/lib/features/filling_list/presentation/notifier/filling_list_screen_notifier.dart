import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../station/domain/usecase/get_stations_usecase.dart';
import '../../domain/entity/filling_list.dart';
import '../../../station/domain/entity/station.dart';
import '../../domain/useacase/cancel_filling_list_usecase.dart';
import '../../domain/useacase/get_filling_lists_usecase.dart';
import '../../domain/useacase/update_filling_list_status_usecase.dart';

class FillingListScreenNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<FillingList>, DateFilterMixin<FillingList> {
  final GetFillingListsUseCase _getFillingRecordsUseCase;
  final UpdateFillingListStatusUseCase _updateFillingRecordUseCase;
  final CancelFillingListUseCase _cancelFillingRecordUseCase;
  final GetStationsUseCase _getStationsUseCase;

  FillingListScreenNotifier({
    required GetStationsUseCase getStationsUseCase,
    required GetFillingListsUseCase getFillingRecordsUseCase,
    required UpdateFillingListStatusUseCase updateFillingRecordUseCase,
    required CancelFillingListUseCase cancelFillingRecordUseCase,
  }) : _getStationsUseCase = getStationsUseCase,
       _getFillingRecordsUseCase = getFillingRecordsUseCase,
       _updateFillingRecordUseCase = updateFillingRecordUseCase,
       _cancelFillingRecordUseCase = cancelFillingRecordUseCase;

  @override
  DateTime? getDateField(FillingList item) => item.date;

  // Operation Keys
  OperationKey fetchStationsOp = OperationKey.custom('fetch-stations');
  OperationKey fetchRecordsOp = OperationKey.custom('fetch-records');
  OperationKey updateOp = OperationKey.update();
  OperationKey cancelOp = OperationKey.custom('cancel');

  bool get isTableLoading => isLoading(fetchStationsOp) || isLoading(fetchRecordsOp);

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  // Station
  Station? _selectedStation;
  Station? get selectedStation => _selectedStation;
  String get selectedStationId => _selectedStation?.id.toString() ?? '-1';

  List<TableSideCategory> get tableCategories => [
    ...stations.map((s) => TableSideCategory(id: s.id.toString(), label: s.name ?? '-')),
  ];

  void getStations() async {
    await execute(
      fetchStationsOp,
      operation: () => _getStationsUseCase.call(GetStationsParams()),
      onData: (response) {
        if (response.data != null) {
          _stations = response.data!;
          selectStation(_stations.first);
          notifyListeners();
        }
      },
    );
  }

  // Dolum listelerini getirme işlemi
  Future<void> getFillingLists() async {
    final stationId = _selectedStation?.id ?? 0;
    await execute(
      fetchRecordsOp,
      operation: () => _getFillingRecordsUseCase.call(stationId),
      onData: (data) => allItems = data,
    );
  }

  // Dolum listesi iptal etme işlemi
  Future<void> cancelFillingList(
    FillingList record, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      cancelOp,
      operation: () => _cancelFillingRecordUseCase.call(record),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getFillingLists();
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
      },
    );
  }

  // Kayıt durumunu güncelleyen servis (Toplandı/toplanacak/gönderildi vb.)
  Future<void> updateFillingListStatus(
    FillingList record, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      updateOp,
      operation: () => _updateFillingRecordUseCase.call(record),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        getFillingLists();
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
      },
    );
  }

  void selectStation(Station? station) {
    _selectedStation = station;
    getFillingLists();
    notifyListeners();
  }
}
