// [SWREQ-MGR-RX-FORM-003] Reçete oluşturma — geçmiş reçete kaynağı.
import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class PrescriptionHistoryNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetPatientPrescriptionHistoryUseCase _useCase;

  PrescriptionHistoryNotifier({required GetPatientPrescriptionHistoryUseCase useCase}) : _useCase = useCase;

  final OperationKey fetchOp = OperationKey.fetch();

  int? _patientId;

  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  String? _searchQuery;

  String? get searchQuery => _searchQuery;

  bool get isFetching => isLoading(fetchOp);

  /// Hasta değişince listeyi sıfırla ve yeniden fetch et.
  void setPatient(int? patientId) {
    if (_patientId == patientId) return;
    _patientId = patientId;
    _items = [];
    notifyListeners();
    if (patientId != null) fetch();
  }

  Future<void> fetch() async {
    if (_patientId == null) return;

    await execute(
      fetchOp,
      operation: () => _useCase.call(_patientId!),
      onData: (data) {
        _items = data;
        notifyListeners();
      },
    );
  }
}
