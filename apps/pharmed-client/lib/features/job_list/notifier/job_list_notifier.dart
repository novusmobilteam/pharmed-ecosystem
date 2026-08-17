import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class JobListNotifier extends ChangeNotifier with ApiRequestMixin {
  JobListNotifier({required GetMyPatientsUseCase getMyPatients, required GetDailyJobListUseCase getJobList})
    : _getMyPatients = getMyPatients,
      _getJobList = getJobList;

  final GetMyPatientsUseCase _getMyPatients;
  final GetDailyJobListUseCase _getJobList;

  final OperationKey initOp = OperationKey.custom('init');
  final OperationKey jobListOp = OperationKey.custom('load-job-list');

  // ── State ────────────────────────────────────────────────────────

  int? _cabinId;
  int? get cabinId => _cabinId;

  List<Hospitalization> _allPatients = const [];
  List<Hospitalization> get allPatients => _allPatients;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<PrescriptionItem> _jobList = const [];
  List<PrescriptionItem> get jobList => _jobList;

  String _search = '';
  String get search => _search;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch sürerken kullanıcı başka bir hastaya tıklarsa, eski isteğin
  /// sonucu görmezden gelinir — sadece bu id'ye ait sonuç uygulanır.
  int? _pendingHospitalizationId;

  bool get isInitialized => _cabinId != null;
  bool get isInitialLoading => isLoading(initOp) && !isInitialized;
  bool get isJobListLoading => isLoading(jobListOp);

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(int cabinId) async {
    if (_cabinId == cabinId && isInitialized) return;

    await execute(
      initOp,
      operation: () => _getMyPatients.call(),
      onData: (myPatients) async {
        _cabinId = cabinId;
        _allPatients = _toHospitalizations(myPatients);
        _selectedHospitalization = null;
        _jobList = const [];
        notifyListeners();

        // Liste boş değilse ilk eleman otomatik seçilir.
        if (_allPatients.isNotEmpty) {
          await selectPatient(_allPatients.first);
        }
      },
      onFailed: (e) {
        _cabinId = cabinId;
        _allPatients = const [];
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<void> selectPatient(Hospitalization hospitalization) async {
    final hospId = hospitalization.id;
    if (hospId == null) return;
    if (!isInitialized) return;

    _selectedHospitalization = hospitalization;
    _pendingHospitalizationId = hospId;
    notifyListeners();

    await execute(
      jobListOp,
      operation: () => _getJobList.call(hospId),
      onData: (jobList) {
        // Fetch sürerken kullanıcı başka bir hastaya tıkladıysa, eski
        // sonucu uygulama.
        if (_pendingHospitalizationId != hospId) return;
        _jobList = jobList;
        notifyListeners();
      },
      onFailed: (e) {
        if (_pendingHospitalizationId != hospId) return;
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    if (!isInitialized) return;
    _search = value;
    notifyListeners();
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  List<Hospitalization> _toHospitalizations(List<MyPatient> patients) {
    return patients.map((p) => p.hospitalization).whereType<Hospitalization>().toList();
  }
}
