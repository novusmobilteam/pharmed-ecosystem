import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../patient/domain/entity/patient.dart';

import '../../../prescription/domain/entity/prescription_item.dart';

import '../../domain/usecase/get_hospitalized_and_recent_exits_usecase.dart';
import '../../domain/usecase/get_patient_prescription_history_usecase.dart';

class PatientOrderReviewNotifier extends ChangeNotifier with SearchMixin<Patient>, ApiRequestMixin {
  final GetHospitalizedAndRecentExitsUseCase _getHospitalizedAndRecentExitsUseCase;
  final GetPatientPrescriptionHistoryUseCase _getPatientPrescriptionHistoryUseCase;

  PatientOrderReviewNotifier({
    required GetHospitalizedAndRecentExitsUseCase getHospitalizedAndRecentExitsUseCase,
    required GetPatientPrescriptionHistoryUseCase getPatientPrescriptionHistoryUseCase,
  }) : _getHospitalizedAndRecentExitsUseCase = getHospitalizedAndRecentExitsUseCase,
       _getPatientPrescriptionHistoryUseCase = getPatientPrescriptionHistoryUseCase;

  OperationKey fetchPatientOp = OperationKey.custom('fetch_patients');
  OperationKey fetchPrescriptionsOp = OperationKey.custom('fetch_prescriptions');

  bool get isFetchingPatients => isLoading(fetchPatientOp);
  bool get isFetchingPrescriptions => isLoading(fetchPrescriptionsOp);

  List<PrescriptionItem> _prescriptionItems = [];
  List<PrescriptionItem> get prescriptionItems => _prescriptionItems;

  Map<int, List<PrescriptionItem>> _groupedPrescriptions = {};
  Map<int, List<PrescriptionItem>> get groupedPrescriptions => _groupedPrescriptions;

  String _prescriptionSearchQuery = '';

  void setPrescriptionSearchQuery(String query) {
    _prescriptionSearchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Filtrelenmiş ve gruplanmış reçeteleri dönen getter
  Map<int, List<PrescriptionItem>> get filteredGroupedPrescriptions {
    if (_prescriptionSearchQuery.isEmpty) return _groupedPrescriptions;

    final Map<int, List<PrescriptionItem>> filteredMap = {};

    _groupedPrescriptions.forEach((id, items) {
      final bool matchesId = id.toString().contains(_prescriptionSearchQuery);

      final filteredItems = items.where((item) {
        final medicineName = item.medicine?.name?.toLowerCase() ?? '';
        final barcode = item.medicine?.barcode?.toLowerCase() ?? '';
        final doctor = item.doctor?.fullName.toLowerCase() ?? '';
        return medicineName.contains(_prescriptionSearchQuery) ||
            barcode.contains(_prescriptionSearchQuery) ||
            doctor.contains(_prescriptionSearchQuery);
      }).toList();

      // Eğer ID eşleşiyorsa tüm grubu al, yoksa sadece isimle eşleşen kalemleri al
      if (matchesId) {
        filteredMap[id] = items;
      } else if (filteredItems.isNotEmpty) {
        filteredMap[id] = filteredItems;
      }
    });

    return filteredMap;
  }

  Future<void> getPatients() async {
    await execute(
      fetchPatientOp,
      operation: () => _getHospitalizedAndRecentExitsUseCase.call(),
      onData: (response) => allItems = response,
      loadingMessage: 'Hastalar yükleniyor...',
    );
  }

  Future<void> getPrescriptions(
    int patientId, {
    Function(String? msg)? onLoading,
    Function(String? msg)? onFailed,
    Function()? onSuccess,
  }) async {
    _prescriptionSearchQuery = '';
    onLoading?.call('Reçeteler yükleniyor..');
    await execute(
      fetchPrescriptionsOp,
      operation: () => _getPatientPrescriptionHistoryUseCase.call(patientId),
      onData: (data) {
        _prescriptionItems = data;
        _groupedPrescriptions = _groupItemsById(data);
        onSuccess?.call();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  // Gruplama yardımcı fonksiyonu
  Map<int, List<PrescriptionItem>> _groupItemsById(List<PrescriptionItem> items) {
    final Map<int, List<PrescriptionItem>> groups = {};
    for (var item in items) {
      final id = item.prescriptionId;
      if (id != null) {
        groups.putIfAbsent(id, () => []).add(item);
      }
    }
    return groups;
  }
}
