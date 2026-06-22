// SWREQ-REFUND-02
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../refund.dart';

final refundNotifierProvider = NotifierProvider<RefundNotifier, MobileRefundState>(RefundNotifier.new);

class RefundNotifier extends Notifier<MobileRefundState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetMobileRefundablesUseCase get _getRefundables => ref.read(getMobileRefundablesUseCaseProvider);
  CheckMobileRefundStatusUseCase get _checkStatus => ref.read(checkMobileRefundStatusUseCaseProvider);
  CompleteMobileRefundUseCase get _completeRefund => ref.read(completeMobileRefundUseCaseProvider);

  @override
  MobileRefundState build() => const MobileRefundUninitialized();

  Future<void> init(int cabinId) async {
    state = const MobileRefundLoading();
    final result = await _getBedAssignments.call(cabinId);

    await result.when(
      ok: (assignments) async {
        final hospitalizations = _toHospitalizations(assignments);
        state = MobileRefundIdle(hospitalizations: hospitalizations);
        if (hospitalizations.isEmpty) return;
        await onPatientTap(hospitalizations.first);
      },
      error: (error) {
        state = MobileRefundError(
          message: error.message,
          previousState: MobileRefundIdle(hospitalizations: const []),
        );
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    // Toggle — aynı hasta tekrar seçilirse Idle'a dön
    if (state.selectedPatient?.patient?.id == patientId) {
      state = MobileRefundIdle(hospitalizations: state.hospitalizations, search: state.search);
      return;
    }

    state = MobileRefundPatientSelected(
      hospitalizations: state.hospitalizations,
      selectedPatient: hospitalization,
      refundables: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getRefundables.call(hospitalization.id ?? 0);

    state = result.when(
      ok: (items) => MobileRefundPatientSelected(
        hospitalizations: state.hospitalizations,
        selectedPatient: hospitalization,
        refundables: items,
        search: state.search,
      ),
      error: (e) => MobileRefundError(
        message: e.message,
        previousState: MobileRefundIdle(hospitalizations: state.hospitalizations, search: state.search),
      ),
    );
  }

  void onDrugTap(PrescriptionItem item) {
    final current = state;

    switch (current) {
      case MobileRefundPatientSelected():
        // Yeni seçim — varsayılan miktar: 1
        state = MobileRefundDrugSelected(
          hospitalizations: current.hospitalizations,
          selectedPatient: current.selectedPatient,
          refundables: current.refundables,
          selectedItem: item,
          quantity: 1,
          search: current.search,
        );

      case MobileRefundDrugSelected():
        if (current.selectedItem.id == item.id) {
          // Aynı ilaç — seçimi kaldır
          state = MobileRefundPatientSelected(
            hospitalizations: current.hospitalizations,
            selectedPatient: current.selectedPatient,
            refundables: current.refundables,
            search: current.search,
          );
        } else {
          // Farklı ilaç — yeni seçim
          state = MobileRefundDrugSelected(
            hospitalizations: current.hospitalizations,
            selectedPatient: current.selectedPatient,
            refundables: current.refundables,
            selectedItem: item,
            quantity: 1,
            search: current.search,
          );
        }

      default:
        break;
    }
  }

  void onQuantityChanged(double quantity) {
    final current = state;
    if (current is! MobileRefundDrugSelected) return;

    final maxQty = _maxRefundableQuantity(current.selectedItem);
    final clamped = quantity.clamp(0.0, maxQty);

    state = current.copyWith(quantity: clamped);
  }

  Future<void> refund() async {
    final current = state;
    if (current is! MobileRefundDrugSelected) return;
    if (current.quantity <= 0) return;

    MedLogger.info(
      unit: 'RefundNotifier',
      swreq: 'SWREQ-REFUND-03',
      message: 'refund — prescriptionItemId=${current.selectedItem.id}, qty=${current.quantity}',
    );

    state = MobileRefundChecking(
      hospitalizations: current.hospitalizations,
      selectedPatient: current.selectedPatient,
      refundables: current.refundables,
      selectedItem: current.selectedItem,
      quantity: current.quantity,
      search: current.search,
    );

    final checkResult = await _checkStatus.call(
      prescriptionItemId: current.selectedItem.id ?? 0,
      quantity: current.quantity,
    );

    final checkError = checkResult.when(ok: (_) => null, error: (e) => e.message);

    if (checkError != null) {
      MedLogger.error(unit: 'RefundNotifier', swreq: 'SWREQ-REFUND-03', message: 'checkStatus başarısız: $checkError');
      state = MobileRefundError(message: checkError, previousState: current);
      return;
    }

    state = MobileRefundSaving(
      hospitalizations: current.hospitalizations,
      selectedPatient: current.selectedPatient,
      refundables: current.refundables,
      selectedItem: current.selectedItem,
      quantity: current.quantity,
      search: current.search,
    );

    final refundResult = await _completeRefund.call(
      prescriptionItemId: current.selectedItem.id ?? 0,
      quantity: current.quantity,
    );

    await refundResult.when(
      ok: (_) => _refreshAfterRefund(
        hospitalizations: current.hospitalizations,
        selectedPatient: current.selectedPatient,
        search: current.search,
      ),
      error: (e) async {
        state = MobileRefundError(message: e.message, previousState: current);
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MobileRefundError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileRefundSuccess) return;
    // Başarı sonrası aynı hasta seçili kalır; MobileRefundPatientSelected'a dön
    state = MobileRefundPatientSelected(
      hospitalizations: current.hospitalizations,
      selectedPatient: current.selectedPatient,
      refundables: current.refundables,
      search: current.search,
    );
  }

  void clearSelection() {
    final current = state;
    switch (current) {
      case MobileRefundDrugSelected():
        state = MobileRefundPatientSelected(
          hospitalizations: current.hospitalizations,
          selectedPatient: current.selectedPatient,
          refundables: current.refundables,
          search: current.search,
        );
      case MobileRefundPatientSelected():
        state = MobileRefundIdle(hospitalizations: current.hospitalizations, search: current.search);
      default:
        break;
    }
  }

  Future<void> _refreshAfterRefund({
    required List<Hospitalization> hospitalizations,
    required Hospitalization selectedPatient,
    required String search,
  }) async {
    final result = await _getRefundables.call(selectedPatient.id ?? 0);

    state = result.when(
      ok: (items) => MobileRefundSuccess(
        hospitalizations: hospitalizations,
        selectedPatient: selectedPatient,
        refundables: items,
        message: '',
        search: search,
      ),
      error: (e) => MobileRefundError(
        message: e.message,
        previousState: MobileRefundPatientSelected(
          hospitalizations: hospitalizations,
          selectedPatient: selectedPatient,
          refundables: const [],
          search: search,
        ),
      ),
    );
  }

  double _maxRefundableQuantity(PrescriptionItem item) {
    // PrescriptionItem'da refundableQuantity alanı varsa doğrudan kullan.
    // Yoksa prescribedQuantity - returnedQuantity gibi bir alan beklenir.
    // Burada alan adı projeye göre uyarlanmalıdır.
    return (item.dosePiece ?? 0).toDouble();
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }

  void onSearchChanged(String query) {
    final current = state;
    state = switch (current) {
      MobileRefundIdle() => current.copyWith(search: query),
      MobileRefundPatientSelected() => current.copyWith(search: query),
      MobileRefundDrugSelected() => MobileRefundPatientSelected(
        hospitalizations: current.hospitalizations,
        selectedPatient: current.selectedPatient,
        refundables: current.refundables,
        search: query,
      ),
      _ => current,
    };
  }
}
