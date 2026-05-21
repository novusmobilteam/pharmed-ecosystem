// SWREQ-WASTE-02

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../waste.dart';

final mobileWasteNotifierProvider = NotifierProvider<MobileWasteNotifier, MobileWasteState>(MobileWasteNotifier.new);

class MobileWasteNotifier extends Notifier<MobileWasteState> {
  GetHospitalizationsUseCase get _getHospitalizations => ref.read(getHospitalizationsUseCaseProvider);
  GetMobileDisposablesUseCase get _getDisposables => ref.read(getMobileDisposablesUseCaseProvider);
  MobileWastageUseCase get _wastage => ref.read(mobileWastageUseCaseProvider);
  MobileDestructionUseCase get _destruction => ref.read(mobileDestructionUseCaseProvider);
  AuthCacheDataSource get _auth => ref.read(authCacheProvider);

  @override
  MobileWasteState build() => const MobileWasteUninitialized();

  Future<void> init() async {
    if (state is! MobileWasteUninitialized) return;

    MedLogger.info(unit: 'MobileWasteNotifier', swreq: 'SWREQ-WASTE-02', message: 'init — hasta listesi yükleniyor');

    state = const MobileWasteLoading();

    final result = await _getHospitalizations.call(GetHospitalizationsParams());

    state = result.when(
      ok: (response) => MobileWasteIdle(patients: response.data ?? const []),
      error: (e) => MobileWasteError(
        message: e.message,
        previousState: const MobileWasteIdle(patients: []),
      ),
    );
  }

  void onSearchChanged(String query) {
    final current = state;
    state = switch (current) {
      MobileWasteIdle() => current.copyWith(search: query),
      MobileWastePatientSelected() => current.copyWith(search: query),
      MobileWasteDrugSelected() => MobileWastePatientSelected(
        patients: current.patients,
        selectedPatient: current.selectedPatient,
        disposables: current.disposables,
        search: query,
      ),
      _ => current,
    };
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final currentPatientId = state.selectedPatient?.id;

    // Aynı hasta tekrar tıklandıysa — seçimi kaldır
    if (currentPatientId == hospitalization.id) {
      state = MobileWasteIdle(patients: state.patients, search: state.search);
      return;
    }

    MedLogger.info(
      unit: 'MobileWasteNotifier',
      swreq: 'SWREQ-WASTE-02',
      message: 'onPatientTap — hospitalizationId=${hospitalization.id}',
    );

    state = MobileWastePatientLoading(patients: state.patients, selectedPatient: hospitalization, search: state.search);

    final result = await _getDisposables.call(hospitalization.id ?? 0);

    state = result.when(
      ok: (items) => MobileWastePatientSelected(
        patients: state.patients,
        selectedPatient: hospitalization,
        disposables: items,
        search: state.search,
      ),
      error: (e) => MobileWasteError(
        message: e.message,
        previousState: MobileWasteIdle(patients: state.patients, search: state.search),
      ),
    );
  }

  void onDrugTap(PrescriptionItem item) {
    final current = state;

    switch (current) {
      case MobileWastePatientSelected():
        // Yeni seçim — varsayılan miktar: 1
        state = MobileWasteDrugSelected(
          patients: current.patients,
          selectedPatient: current.selectedPatient,
          disposables: current.disposables,
          selectedItem: item,
          quantity: 1,
          search: current.search,
        );

      case MobileWasteDrugSelected():
        if (current.selectedItem.id == item.id) {
          // Aynı ilaç — seçimi kaldır
          state = MobileWastePatientSelected(
            patients: current.patients,
            selectedPatient: current.selectedPatient,
            disposables: current.disposables,
            search: current.search,
          );
        } else {
          // Farklı ilaç — yeni seçim
          state = MobileWasteDrugSelected(
            patients: current.patients,
            selectedPatient: current.selectedPatient,
            disposables: current.disposables,
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
    if (current is! MobileWasteDrugSelected) return;

    final maxQty = _maxDisposableQuantity(current.selectedItem);
    final clamped = quantity.clamp(0.0, maxQty);

    state = current.copyWith(quantity: clamped);
  }

  /// Fire işlemi — MobileWastageUseCase çağırır.
  Future<void> wastage() async {
    final current = state;
    if (current is! MobileWasteDrugSelected) return;
    if (current.quantity <= 0) return;
    final user = await _auth.readUser();

    MedLogger.info(
      unit: 'MobileWasteNotifier',
      swreq: 'SWREQ-WASTE-03',
      message: 'wastage — prescriptionItemId=${current.selectedItem.id}, qty=${current.quantity}',
    );

    state = MobileWasteSaving(
      patients: current.patients,
      selectedPatient: current.selectedPatient,
      disposables: current.disposables,
      selectedItem: current.selectedItem,
      quantity: current.quantity,
      search: current.search,
    );

    final result = await _wastage.call(
      WasteParams(prescriptionItemId: current.selectedItem.id ?? 0, quantity: current.quantity, witnessId: user?.id),
    );

    await result.when(
      ok: (_) => _refreshAfterAction(
        patients: current.patients,
        selectedPatient: current.selectedPatient,
        search: current.search,
        message: 'Fire işlemi başarıyla tamamlandı.',
      ),
      error: (e) async {
        MedLogger.error(
          unit: 'MobileWasteNotifier',
          swreq: 'SWREQ-WASTE-03',
          message: 'wastage başarısız: ${e.message}',
        );
        state = MobileWasteError(message: e.message, previousState: current);
      },
    );
  }

  /// İmha işlemi — MobileDestructionUseCase çağırır.
  Future<void> destruction() async {
    final current = state;
    if (current is! MobileWasteDrugSelected) return;
    if (current.quantity <= 0) return;
    final user = await _auth.readUser();

    MedLogger.info(
      unit: 'MobileWasteNotifier',
      swreq: 'SWREQ-WASTE-03',
      message: 'destruction — prescriptionItemId=${current.selectedItem.id}, qty=${current.quantity}',
    );

    state = MobileWasteSaving(
      patients: current.patients,
      selectedPatient: current.selectedPatient,
      disposables: current.disposables,
      selectedItem: current.selectedItem,
      quantity: current.quantity,
      search: current.search,
    );

    final result = await _destruction.call(
      WasteParams(prescriptionItemId: current.selectedItem.id ?? 0, quantity: current.quantity, witnessId: user?.id),
    );

    await result.when(
      ok: (_) => _refreshAfterAction(
        patients: current.patients,
        selectedPatient: current.selectedPatient,
        search: current.search,
        message: 'İmha işlemi başarıyla tamamlandı.',
      ),
      error: (e) async {
        MedLogger.error(
          unit: 'MobileWasteNotifier',
          swreq: 'SWREQ-WASTE-03',
          message: 'destruction başarısız: ${e.message}',
        );
        state = MobileWasteError(message: e.message, previousState: current);
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MobileWasteError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileWasteSuccess) return;
    // Başarı sonrası aynı hasta seçili kalır; MobileWastePatientSelected'a dön
    state = MobileWastePatientSelected(
      patients: current.patients,
      selectedPatient: current.selectedPatient,
      disposables: current.disposables,
      search: current.search,
    );
  }

  void clearSelection() {
    final current = state;
    switch (current) {
      case MobileWasteDrugSelected():
        state = MobileWastePatientSelected(
          patients: current.patients,
          selectedPatient: current.selectedPatient,
          disposables: current.disposables,
          search: current.search,
        );
      case MobileWastePatientSelected():
        state = MobileWasteIdle(patients: current.patients, search: current.search);
      default:
        break;
    }
  }

  Future<void> _refreshAfterAction({
    required List<Hospitalization> patients,
    required Hospitalization selectedPatient,
    required String search,
    required String message,
  }) async {
    final result = await _getDisposables.call(selectedPatient.id ?? 0);

    state = result.when(
      ok: (items) => MobileWasteSuccess(
        patients: patients,
        selectedPatient: selectedPatient,
        disposables: items,
        message: message,
        search: search,
      ),
      error: (e) => MobileWasteError(
        message: e.message,
        previousState: MobileWastePatientSelected(
          patients: patients,
          selectedPatient: selectedPatient,
          disposables: const [],
          search: search,
        ),
      ),
    );
  }

  double _maxDisposableQuantity(PrescriptionItem item) {
    return (item.dosePiece ?? 0).toDouble();
  }
}
