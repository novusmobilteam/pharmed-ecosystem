// SWREQ-REFUND-02
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../refund.dart';

final refundNotifierProvider = NotifierProvider<RefundNotifier, MobileRefundState>(RefundNotifier.new);

class RefundNotifier extends Notifier<MobileRefundState> {
  GetHospitalizationsUseCase get _getHospitalizations => ref.read(getHospitalizationsUseCaseProvider);
  GetMobileRefundablesUseCase get _getRefundables => ref.read(getMobileRefundablesUseCaseProvider);
  CheckMobileRefundStatusUseCase get _checkStatus => ref.read(checkMobileRefundStatusUseCaseProvider);
  CompleteMobileRefundUseCase get _completeRefund => ref.read(completeMobileRefundUseCaseProvider);

  @override
  MobileRefundState build() => const MobileRefundUninitialized();

  Future<void> init() async {
    if (state is! MobileRefundUninitialized) return;

    MedLogger.info(unit: 'RefundNotifier', swreq: 'SWREQ-REFUND-02', message: 'init — hasta listesi yükleniyor');

    state = const MobileRefundLoading();

    final result = await _getHospitalizations.call(GetHospitalizationsParams());

    state = result.when(
      ok: (response) => MobileRefundIdle(patients: response.data ?? const []),
      error: (e) => MobileRefundError(
        message: e.message,
        previousState: const MobileRefundIdle(patients: []),
      ),
    );
  }

  void onSearchChanged(String query) {
    final current = state;
    state = switch (current) {
      MobileRefundIdle() => current.copyWith(search: query),
      MobileRefundPatientSelected() => current.copyWith(search: query),
      MobileRefundDrugSelected() => MobileRefundPatientSelected(
        patients: current.patients,
        selectedPatient: current.selectedPatient,
        refundables: current.refundables,
        search: query,
      ),
      _ => current,
    };
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final currentPatientId = state.selectedPatient?.id;

    // Aynı hasta tekrar tıklandıysa — seçimi kaldır
    if (currentPatientId == hospitalization.id) {
      state = MobileRefundIdle(patients: state.patients, search: state.search);
      return;
    }

    MedLogger.info(
      unit: 'RefundNotifier',
      swreq: 'SWREQ-REFUND-02',
      message: 'onPatientTap — hospitalizationId=${hospitalization.id}',
    );

    state = MobileRefundPatientLoading(
      patients: state.patients,
      selectedPatient: hospitalization,
      search: state.search,
    );

    final result = await _getRefundables.call(hospitalization.id ?? 0);

    state = result.when(
      ok: (items) => MobileRefundPatientSelected(
        patients: state.patients,
        selectedPatient: hospitalization,
        refundables: items,
        search: state.search,
      ),
      error: (e) => MobileRefundError(
        message: e.message,
        previousState: MobileRefundIdle(patients: state.patients, search: state.search),
      ),
    );
  }

  void onDrugTap(PrescriptionItem item) {
    final current = state;

    switch (current) {
      case MobileRefundPatientSelected():
        // Yeni seçim — varsayılan miktar: 1
        state = MobileRefundDrugSelected(
          patients: current.patients,
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
            patients: current.patients,
            selectedPatient: current.selectedPatient,
            refundables: current.refundables,
            search: current.search,
          );
        } else {
          // Farklı ilaç — yeni seçim
          state = MobileRefundDrugSelected(
            patients: current.patients,
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
      patients: current.patients,
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
      patients: current.patients,
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
        patients: current.patients,
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
      patients: current.patients,
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
          patients: current.patients,
          selectedPatient: current.selectedPatient,
          refundables: current.refundables,
          search: current.search,
        );
      case MobileRefundPatientSelected():
        state = MobileRefundIdle(patients: current.patients, search: current.search);
      default:
        break;
    }
  }

  Future<void> _refreshAfterRefund({
    required List<Hospitalization> patients,
    required Hospitalization selectedPatient,
    required String search,
  }) async {
    final result = await _getRefundables.call(selectedPatient.id ?? 0);

    state = result.when(
      ok: (items) => MobileRefundSuccess(
        patients: patients,
        selectedPatient: selectedPatient,
        refundables: items,
        message: 'İade başarıyla tamamlandı.',
        search: search,
      ),
      error: (e) => MobileRefundError(
        message: e.message,
        previousState: MobileRefundPatientSelected(
          patients: patients,
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
}
