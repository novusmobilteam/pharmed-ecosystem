// lib/feature/dashboard/presentation/notifier/dashboard_notifier.dart
//
// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi.
// UI'dan gelen aksiyonları karşılar, UiState'i günceller.
// Repository'yi bilir, Dio/Hive'ı bilmez.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../domain/model/dasboard_data.dart';
import '../state/dashboard_ui_state.dart';
import '../../data/mock/dashboard_mock_repository.dart';

// ─────────────────────────────────────────────────────────────────
// Provider tanımı
// ─────────────────────────────────────────────────────────────────

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardUiState>(DashboardNotifier.new);

// ─────────────────────────────────────────────────────────────────
// DashboardNotifier
// ─────────────────────────────────────────────────────────────────

class DashboardNotifier extends Notifier<DashboardUiState> {
  // Flavor'a göre gerçek veya mock repository inject edilir
  // Şimdilik mock — DI kurulunca değişecek
  // final _repository = DashboardMockRepository();

  @override
  DashboardUiState build() {
    // Notifier oluştuğunda veriyi yükle
    _load();
    return const DashboardLoading();
  }

  // ── Yükleme ──────────────────────────────────────────────────

  // [SWREQ-UI-DASH-003]
  Future<void> _load() async {
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard yükleniyor');

    state = const DashboardLoading();

    // final result = await _repository.getDashboardData();

    // result.when(
    //   ok: (data) {
    //     MedLogger.info(
    //       unit: 'SW-UNIT-UI',
    //       swreq: 'SWREQ-UI-DASH-003',
    //       message: 'Dashboard yüklendi',
    //       context: {'treatments': data.treatments.length, 'sktItems': data.skt.allItems.length},
    //     );
    //     state = DashboardLoaded(data);
    //   },
    //   error: (error) {
    //     (error) {
    //       MedLogger.error(
    //         unit: 'SW-UNIT-UI',
    //         swreq: 'SWREQ-UI-DASH-003',
    //         message: 'Dashboard yükleme hatası',
    //         error: error,
    //       );
    //       final appError = error is AppException ? error : null;
    //       state = DashboardError(
    //         message: appError?.userMessage ?? 'Veriler yüklenemedi.',
    //         isRetryable: appError?.isRetryable ?? true,
    //       );
    //     };
    //   },
    // );
  }

  // ── Public aksiyonlar ─────────────────────────────────────────

  /// Yeniden yükle — retry butonu ve pull-to-refresh için
  Future<void> refresh() => _load();

  /// [HAZ-009] Kabin açma — onay dialog'u UI'da gösterilmeli,
  /// onay alındıktan sonra bu metod çağrılmalı
  Future<void> openCabin() async {
    final currentData = _currentData;
    if (currentData == null) return;

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-DASH-003',
      message: 'Kabin açma isteği',
      context: {'cabinId': currentData.cabin.cabinId},
    );

    // TODO: CabinRepository.openCabin() çağrısı
    // Başarılıysa state'i güncelle
    _refresh();
  }

  /// [HAZ-009] Kabin kilitleme — onay sonrası çağrılır
  Future<void> lockCabin() async {
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Kabin kilitleme isteği');
    // TODO: CabinRepository.lockCabin()
    _refresh();
  }

  /// [HAZ-009] İlaç atama — onay sonrası çağrılır
  Future<void> assignMedicine() async {
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'İlaç atama isteği');
    // TODO: Navigation to assign screen
  }

  /// [HAZ-009] Yeni tedavi atama — onay sonrası çağrılır
  Future<void> assignNewTreatment() async {
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Yeni tedavi atama isteği');
    // TODO: Navigation to treatment assign screen
  }

  // ── Yardımcı ─────────────────────────────────────────────────

  DashboardData? get _currentData => switch (state) {
    DashboardLoaded(:final data) => data,
    DashboardStale(:final data) => data,
    DashboardPartial(:final data) => data,
    _ => null,
  };

  void _refresh() {
    Future.microtask(_load);
  }
}
