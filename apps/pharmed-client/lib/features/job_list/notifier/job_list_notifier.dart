import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_core/pharmed_core.dart';

final jobListNotifierProvider = ChangeNotifierProvider<JobListNotifier>((ref) {
  return JobListNotifier(getJobList: ref.read(getDailyJobListUseCaseProvider));
});

class JobListNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetDailyJobListUseCase _getJobList;

  JobListNotifier({required GetDailyJobListUseCase getJobList}) : _getJobList = getJobList;

  final OperationKey fetchOp = OperationKey.fetch();

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  bool get isError => isFailed(fetchOp);

  void selectHospitalization(Hospitalization hosp) {
    if (_selectedHospitalization?.id == hosp.id) {
      _selectedHospitalization = null;
      _items.clear();
      notifyListeners();
      return;
    }
    _selectedHospitalization = hosp;
    notifyListeners();
    _fetch();
  }

  void clearSelection() {
    _selectedHospitalization = null;
    _items.clear();
    notifyListeners();
  }

  Future<void> _fetch() async {
    final patientId = _selectedHospitalization?.patient?.id;
    if (patientId == null) return;

    await execute(
      fetchOp,
      operation: () => _getJobList.call(patientId),
      onData: (data) {
        _items = data;
        notifyListeners();
      },
    );
  }
}
