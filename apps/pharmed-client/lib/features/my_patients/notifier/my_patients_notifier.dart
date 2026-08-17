// [SWREQ-UI-MYPATIENTS-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../auth/notifier/auth_notifier.dart';

class MyPatientsNotifier extends ChangeNotifier with ApiRequestMixin {
  MyPatientsNotifier({
    required GetBedAssignmentsUseCase getBedAssignments,
    required GetActiveHospitalizationsUseCase getHospitalizations,
    required GetMyPatientsUseCase getMyPatients,
    required AddPatientUseCase addPatient,
    required RemovePatientsUseCase removePatients,
    required AuthNotifier authNotifier,
    // GEÇİCİ — DeviceMode henüz Riverpod'dan taşınmadı. Bu köprü, DeviceMode
    // ChangeNotifier'a geçince kaldırılacak (bkz. proje TODO).
    required Future<CabinType?> Function() getDeviceMode,
  }) : _getBedAssignments = getBedAssignments,
       _getHospitalizations = getHospitalizations,
       _getMyPatients = getMyPatients,
       _addPatient = addPatient,
       _removePatients = removePatients,
       _authNotifier = authNotifier,
       _getDeviceMode = getDeviceMode;

  final GetBedAssignmentsUseCase _getBedAssignments;
  final GetActiveHospitalizationsUseCase _getHospitalizations;
  final GetMyPatientsUseCase _getMyPatients;
  final AddPatientUseCase _addPatient;
  final RemovePatientsUseCase _removePatients;
  final AuthNotifier _authNotifier;
  final Future<CabinType?> Function() _getDeviceMode;

  final OperationKey initOp = OperationKey.custom('init');
  final OperationKey addOp = OperationKey.custom('add-patient');
  final OperationKey removeOp = OperationKey.custom('remove-patient');

  /// Oturum açmış kullanıcının ID'si.
  int get _currentUserId => _authNotifier.currentUser?.id ?? 0;

  // ── State ────────────────────────────────────────────────────────

  int? _cabinId;
  int? get cabinId => _cabinId;

  List<Hospitalization> _allPatients = const [];
  List<Hospitalization> get allPatients => _allPatients;

  List<MyPatient> _myPatients = const [];
  List<MyPatient> get myPatients => _myPatients;

  String _search = '';
  String get search => _search;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Ekleme/kaldırma sürerken spinner gösterilecek hospitalizationId'ler.
  Set<int> _pendingIds = const {};

  bool get isInitialized => _cabinId != null;
  bool get isInitialLoading => isLoading(initOp) && !isInitialized;

  Set<int> get myPatientHospitalizationIds => _myPatients.map((p) => p.hospitalization?.id).whereType<int>().toSet();

  bool isPending(int hospitalizationId) => _pendingIds.contains(hospitalizationId);

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(int cabinId) async {
    await execute(
      initOp,
      operation: () async {
        final cabinType = await _getDeviceMode();
        final isMobile = cabinType == CabinType.mobile;

        final Future<dynamic> patientsFuture = isMobile
            ? _getBedAssignments.call(cabinId)
            : _getHospitalizations.call(const PagedQueryParams());

        final results = await Future.wait([patientsFuture, _getMyPatients.call()]);

        final myResult = results[1] as Result<List<MyPatient>>;

        late final Result<List<Hospitalization>> patientsResult;

        if (isMobile) {
          final bedResult = results[0] as Result<List<BedAssignment>>;
          patientsResult = bedResult is Error
              ? Result.error((bedResult as Error).error)
              : Result.ok(_toHospitalizations((bedResult as Ok<List<BedAssignment>>).data ?? []));
        } else {
          final hospResult = results[0] as Result<ApiResponse<List<Hospitalization>>>;
          patientsResult = hospResult is Error
              ? Result.error((hospResult as Error).error)
              : Result.ok((hospResult as Ok<ApiResponse<List<Hospitalization>>>).data?.data ?? const []);
        }

        if (patientsResult is Error) {
          return Result<({List<Hospitalization> patients, List<MyPatient> mine})>.error(
            (patientsResult as Error).error,
          );
        }
        if (myResult is Error) {
          return Result<({List<Hospitalization> patients, List<MyPatient> mine})>.error((myResult as Error).error);
        }

        final allPatients = (patientsResult as Ok<List<Hospitalization>>).data ?? [];
        final mine = (myResult as Ok<List<MyPatient>>).data ?? [];
        return Result.ok((patients: allPatients, mine: mine));
      },
      onData: (data) {
        _cabinId = cabinId;
        _allPatients = data.patients;
        _myPatients = data.mine;
        notifyListeners();
      },
      onFailed: (e) {
        _cabinId = cabinId;
        _allPatients = const [];
        _myPatients = const [];
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  // ── Aksiyonlar ───────────────────────────────────────────────────

  Future<void> addPatient(Hospitalization hospitalization) async {
    final hospId = hospitalization.id;
    if (hospId == null || !isInitialized) return;

    // Zaten bende varsa işlem yapma.
    if (myPatientHospitalizationIds.contains(hospId)) return;

    _pendingIds = {..._pendingIds, hospId};
    notifyListeners();

    await executeVoid(
      addOp,
      operation: () => _addPatient.call(AddPatientParams(userId: _currentUserId, hospitalizationId: hospId)),
      onSuccess: () async {
        _pendingIds = {..._pendingIds}..remove(hospId);

        final refreshResult = await _getMyPatients.call();
        refreshResult.when(
          ok: (patients) => _myPatients = patients,
          error: (_) {}, // Refresh hata verse bile pending'i kaldır, mevcut listeyle devam et
        );
        notifyListeners();
      },
      onFailed: (e) {
        _pendingIds = {..._pendingIds}..remove(hospId);
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<void> removePatient(MyPatient patient) async {
    final myPatientId = patient.id;
    final hospId = patient.hospitalization?.id;
    if (myPatientId == null || hospId == null || !isInitialized) return;

    _pendingIds = {..._pendingIds, hospId};
    notifyListeners();

    await executeVoid(
      removeOp,
      operation: () => _removePatients.call([myPatientId]),
      onSuccess: () {
        _pendingIds = {..._pendingIds}..remove(hospId);
        _myPatients = _myPatients.where((p) => p.id != myPatientId).toList();
        notifyListeners();
      },
      onFailed: (e) {
        _pendingIds = {..._pendingIds}..remove(hospId);
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

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
