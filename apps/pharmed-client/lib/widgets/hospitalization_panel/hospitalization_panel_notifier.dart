import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers/providers.dart';
import '../../features/service_selection/service_selection.dart';

final hospitalizationNotifierProvider = ChangeNotifierProvider<HospitalizationPanelNotifier>((ref) {
  return HospitalizationPanelNotifier(
    getHospitalizationsByServiceUseCase: ref.read(getHospitalizationsByServiceUseCaseProvider),
    activeServiceNotifier: ref.read(activeServiceNotifierProvider),
    getBedAssignmentsUseCase: ref.read(getBedAssignmentsUseCaseProvider),
  );
});

enum HospitalizationType { all, myPatients }

class HospitalizationPanelNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetHospitalizationsByServiceUseCase _getHospitalizationsByServiceUseCase;
  final GetBedAssignmentsUseCase _getBedAssignmentsUseCase;
  final ActiveServiceNotifier _activeServiceNotifier;

  HospitalizationPanelNotifier({
    required GetHospitalizationsByServiceUseCase getHospitalizationsByServiceUseCase,
    required GetBedAssignmentsUseCase getBedAssignmentsUseCase,
    required ActiveServiceNotifier activeServiceNotifier,
  }) : _getHospitalizationsByServiceUseCase = getHospitalizationsByServiceUseCase,
       _getBedAssignmentsUseCase = getBedAssignmentsUseCase,
       _activeServiceNotifier = activeServiceNotifier;

  int get _activeServiceId => _activeServiceNotifier.activeService?.id ?? 0;

  final OperationKey fetchHospitalizationsOp = OperationKey.custom('fetch-hospitalizations');

  List<Hospitalization> _hospitalizations = [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  HospitalizationType _type = HospitalizationType.all;
  HospitalizationType get type => _type;

  int get selectedIndex => HospitalizationType.values.indexOf(_type);

  List<Hospitalization> get filteredHospitalizations {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return _hospitalizations;
    return _hospitalizations.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  void init({bool isMobileCabin = false, required bool showTypeSelector}) {
    if (!showTypeSelector) {
      _type = HospitalizationType.all;
      notifyListeners();
    }
    if (isMobileCabin) {
      _getBedAssignments();
      return;
    } else {
      _getHospitalizations();
      return;
    }
  }

  void selectType(HospitalizationType type) {
    _type = type;
    notifyListeners();
    _getHospitalizations();
  }

  Future<void> _getHospitalizations() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () => _getHospitalizationsByServiceUseCase.call(
        serviceId: _activeServiceId,
        filter: PatientFilterType.all,
        myPatients: _type == HospitalizationType.myPatients,
      ),
      onData: (hospitalizations) {
        _hospitalizations = hospitalizations.where((h) => !h.isRedirected && !h.isUrgent).toList();
        notifyListeners();
      },
    );
  }

  Future<void> _getBedAssignments() async {
    await execute(
      fetchHospitalizationsOp,
      operation: () => _getBedAssignmentsUseCase.call(),
      onData: (assignments) {
        _hospitalizations = _toHospitalizations(assignments);
        notifyListeners();
      },
    );
  }

  void selectHospitalization(Hospitalization hosp) {
    if (_selectedHospitalization?.id == hosp.id) {
      _selectedHospitalization = null;
      notifyListeners();
      return;
    }
    _selectedHospitalization = hosp;
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
