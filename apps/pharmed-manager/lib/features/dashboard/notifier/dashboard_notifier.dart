import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'dashboard_section.dart';

// [SWREQ-MGR-DASH-004]
// Manager dashboard state yönetimi.
// Sınıf: Class B

class DashboardNotifier extends ChangeNotifier {
  DashboardNotifier({
    required GetDashboardCabinsUseCase getCabins,
    required GetMissingStocksUseCase getMissingStocks,
    required ApproveMissingStockUseCase approveMissingStock,
    required RejectMissingStockUseCase rejectMissingStock,
    required GetDashboardUnappliedPrescriptionsUseCase getUnappliedPrescriptions,
    required GetUpcomingTreatmentsUseCase getUpcomingTreatments,
    required GetDrugActivitiesUseCase getDrugActivities,
  }) : _getCabins = getCabins,
       _getMissingStocks = getMissingStocks,
       _approveMissingStock = approveMissingStock,
       _rejectMissingStock = rejectMissingStock,
       _getUnappliedPrescriptions = getUnappliedPrescriptions,
       _getUpcomingTreatments = getUpcomingTreatments,
       _getDrugActivities = getDrugActivities;

  final GetDashboardCabinsUseCase _getCabins;
  final GetMissingStocksUseCase _getMissingStocks;
  final ApproveMissingStockUseCase _approveMissingStock;
  final RejectMissingStockUseCase _rejectMissingStock;
  final GetDashboardUnappliedPrescriptionsUseCase _getUnappliedPrescriptions;
  final GetUpcomingTreatmentsUseCase _getUpcomingTreatments;
  final GetDrugActivitiesUseCase _getDrugActivities;

  bool _disposed = false;

  List<Cabin> _cabins = const [];
  List<Cabin> get cabins => _cabins;

  int? _selectedCabinId;
  int? get selectedCabinId => _selectedCabinId;

  Cabin? get selectedCabin => _cabins.where((c) => c.id == _selectedCabinId).firstOrNull;
  bool get isMobileSelected => selectedCabin?.type?.isMobile ?? false;

  bool _cabinsLoading = false;
  bool get cabinsLoading => _cabinsLoading;

  String? _cabinsError;
  String? get cabinsError => _cabinsError;

  bool _cabinsStale = false;
  bool get cabinsStale => _cabinsStale;

  bool get showFullScreenError => _cabins.isEmpty && _cabinsError != null;
  bool get isInitialLoading => _cabins.isEmpty && _cabinsLoading;

  DashboardSection<List<PrescriptionItem>> _shortage = const DashboardSection();
  DashboardSection<List<PrescriptionItem>> get shortage => _shortage;

  DashboardSection<List<PrescriptionItem>> _unappliedPrescriptions = const DashboardSection();
  DashboardSection<List<PrescriptionItem>> get unappliedPrescriptions => _unappliedPrescriptions;

  DashboardSection<List<PrescriptionItem>> _upcomingTreatments = const DashboardSection();
  DashboardSection<List<PrescriptionItem>> get upcomingTreatments => _upcomingTreatments;

  DashboardSection<List<PrescriptionItemMovement>> _drugActivities = const DashboardSection();
  DashboardSection<List<PrescriptionItemMovement>> get drugActivities => _drugActivities;

  // ── Onay/red işlem id'leri (item bazlı loading) ──
  final Set<int> _processingIds = {};
  bool isProcessing(int itemId) => _processingIds.contains(itemId);

  // ── Otomatik döngü ──
  static const _rotateInterval = Duration(minutes: 4);
  Timer? _rotateTimer;

  /// Dispose sonrası gelen async cevaplar notify etmesin.
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> init() async {
    await fetchCabins();
    _startRotation();
  }

  Future<void> fetchCabins() async {
    _cabinsLoading = true;
    _cabinsError = null;
    _safeNotify();

    final result = await _getCabins.call();
    if (_disposed) return;

    result.when(
      ok: (value) => _applyCabins(value, stale: false),
      error: (error) {
        _cabinsLoading = false;
        _cabinsError = error.message;
        _safeNotify();
        MedLogger.error(
          unit: 'DashboardNotifier',
          swreq: 'SWREQ-MGR-DASH-004',
          message: 'Kabin listesi çekilemedi',
          context: {'error': error.message},
        );
      },
    );
  }

  void _applyCabins(List<Cabin> data, {required bool stale}) {
    _cabins = data;
    _cabinsLoading = false;
    _cabinsError = null;
    _cabinsStale = stale;

    final stillExists = data.any((c) => c.id == _selectedCabinId);
    if (!stillExists) {
      _selectedCabinId = data.isNotEmpty ? data.first.id : null;
    }

    _safeNotify();
    _loadSelectedCabinData(silent: false);
  }

  void selectCabin(int cabinId) {
    if (cabinId == _selectedCabinId) return;
    _selectedCabinId = cabinId;
    _safeNotify();

    _restartRotation();
    _loadSelectedCabinData(silent: false);
  }

  /// Seçili kabinin tüm bölüm verilerini çeker.
  /// Uygulanmamış reçete global; eksik stok yalnızca mobil; yaklaşan tedavi mac'e bağlı.
  Future<void> _loadSelectedCabinData({required bool silent}) async {
    final cabin = selectedCabin;
    if (cabin == null) return;

    // Uygulanmamış reçete global — mac'ten bağımsız, her turda çek
    _loadUnapplied(silent: silent);

    final mac = cabin.station?.macAddress;

    // Mac yoksa mac'e bağlı bölümler çekilemez
    if (mac == null || mac.isEmpty) {
      _shortage = const DashboardSection(data: []);
      _upcomingTreatments = const DashboardSection(data: []);
      _drugActivities = const DashboardSection(data: []);
      _safeNotify();
      MedLogger.error(
        unit: 'DashboardNotifier',
        swreq: 'SWREQ-MGR-DASH-004',
        message: 'Seçili kabinin mac adresi yok, mac bağlı veriler çekilemedi',
        context: {'cabinId': cabin.id},
      );
      return;
    }

    // Eksik stok yalnızca mobil; değilse temizle (sonraki tur: SKT/kritik)
    if (cabin.type?.isMobile ?? false) {
      _loadMissingStocks(mac, silent: silent);
    } else {
      _shortage = const DashboardSection();
      _safeNotify();
    }

    _loadUpcoming(mac, silent: silent);
    _loadDrugActivities(mac, silent: silent);
  }

  Future<void> _loadMissingStocks(String mac, {required bool silent}) async {
    _shortage = _shortage.copyWith(isLoading: true, error: null);
    _safeNotify();

    final result = await _getMissingStocks.call(mac: mac);
    if (_disposed) return;

    result.when(
      ok: (data) {
        // Listede olmayan processing id'leri temizle
        final liveIds = data.map((e) => e.id).whereType<int>().toSet();
        _processingIds.removeWhere((id) => !liveIds.contains(id));
        _shortage = DashboardSection(data: data, isLoading: false);
      },
      error: (e) {
        if (silent) {
          // Otomatik tur: eski veriyi koru, panel-içi hata gösterme
          _shortage = _shortage.copyWith(isLoading: false);
          MedLogger.error(
            unit: 'DashboardNotifier',
            swreq: 'SWREQ-MGR-DASH-004',
            message: 'Otomatik turda eksik stok yenilenemedi (sessiz)',
            context: {'error': e.message},
          );
        } else {
          _shortage = _shortage.copyWith(isLoading: false, error: e.message);
        }
      },
    );
    _safeNotify();
  }

  Future<void> _loadUnapplied({required bool silent}) async {
    _unappliedPrescriptions = _unappliedPrescriptions.copyWith(isLoading: true, error: null);
    _safeNotify();

    final result = await _getUnappliedPrescriptions.call();
    if (_disposed) return;

    result.when(
      ok: (data) {
        _unappliedPrescriptions = DashboardSection(data: data, isLoading: false);
      },
      error: (e) {
        if (silent) {
          _unappliedPrescriptions = _unappliedPrescriptions.copyWith(isLoading: false);
          MedLogger.error(
            unit: 'DashboardNotifier',
            swreq: 'SWREQ-MGR-DASH-004',
            message: 'Otomatik turda uygulanmamış reçete yenilenemedi (sessiz)',
            context: {'error': e.message},
          );
        } else {
          _unappliedPrescriptions = _unappliedPrescriptions.copyWith(isLoading: false, error: e.message);
        }
      },
    );
    _safeNotify();
  }

  Future<void> _loadUpcoming(String mac, {required bool silent}) async {
    _upcomingTreatments = _upcomingTreatments.copyWith(isLoading: true, error: null);
    _safeNotify();

    final result = await _getUpcomingTreatments.call(mac: mac);
    if (_disposed) return;

    result.when(
      ok: (data) {
        _upcomingTreatments = DashboardSection(data: data, isLoading: false);
      },
      error: (e) {
        if (silent) {
          _upcomingTreatments = _upcomingTreatments.copyWith(isLoading: false);
          MedLogger.error(
            unit: 'DashboardNotifier',
            swreq: 'SWREQ-MGR-DASH-004',
            message: 'Otomatik turda yaklaşan tedavi yenilenemedi (sessiz)',
            context: {'error': e.message},
          );
        } else {
          _upcomingTreatments = _upcomingTreatments.copyWith(isLoading: false, error: e.message);
        }
      },
    );
    _safeNotify();
  }

  Future<void> _loadDrugActivities(String mac, {required bool silent}) async {
    _drugActivities = _drugActivities.copyWith(isLoading: true, error: null);
    _safeNotify();

    final result = await _getDrugActivities.call(mac: mac);
    if (_disposed) return;

    result.when(
      ok: (data) {
        _drugActivities = DashboardSection(data: data ?? const [], isLoading: false);
      },
      error: (e) {
        if (silent) {
          _drugActivities = _drugActivities.copyWith(isLoading: false);
          MedLogger.error(
            unit: 'DashboardNotifier',
            swreq: 'SWREQ-MGR-DASH-004',
            message: 'Otomatik turda ilaç hareketleri yenilenemedi (sessiz)',
            context: {'error': e.message},
          );
        } else {
          _drugActivities = _drugActivities.copyWith(isLoading: false, error: e.message);
        }
      },
    );
    _safeNotify();
  }

  // ── Retry'lar (panel-içi) ──
  Future<void> retryShortage() async {
    final mac = selectedCabin?.station?.macAddress;
    if (mac != null && mac.isNotEmpty) await _loadMissingStocks(mac, silent: false);
  }

  Future<void> retryUnapplied() => _loadUnapplied(silent: false);

  Future<void> retryUpcoming() async {
    final mac = selectedCabin?.station?.macAddress;
    if (mac != null && mac.isNotEmpty) await _loadUpcoming(mac, silent: false);
  }

  Future<void> retryDrugActivities() async {
    final mac = selectedCabin?.station?.macAddress;
    if (mac != null && mac.isNotEmpty) await _loadDrugActivities(mac, silent: false);
  }

  Future<void> approveMissingStock(int id) => _runMovementAction(id, _approveMissingStock.call, 'onaylandı');

  Future<void> rejectMissingStock(int id) => _runMovementAction(id, _rejectMissingStock.call, 'reddedildi');

  Future<void> _runMovementAction(int itemId, Future<Result<void>> Function(int id) action, String actionLabel) async {
    if (_processingIds.contains(itemId)) return;

    _processingIds.add(itemId);
    _safeNotify();

    final result = await action(itemId);
    if (_disposed) return;

    await result.when(
      ok: (_) async {
        MedLogger.info(
          unit: 'DashboardNotifier',
          swreq: 'SWREQ-MGR-DASH-005',
          message: 'Eksik stok bildirimi $actionLabel',
          context: {'prescriptionDetailId': itemId},
        );
        _processingIds.remove(itemId);
        final mac = selectedCabin?.station?.macAddress;
        if (mac != null && mac.isNotEmpty && (selectedCabin?.type?.isMobile ?? false)) {
          await _loadMissingStocks(mac, silent: false);
        } else {
          _safeNotify();
        }
      },
      error: (e) {
        _processingIds.remove(itemId);
        _shortage = _shortage.copyWith(error: e.message);
        _safeNotify();
        MedLogger.error(
          unit: 'DashboardNotifier',
          swreq: 'SWREQ-MGR-DASH-005',
          message: 'Eksik stok bildirimi işlemi başarısız',
          context: {'prescriptionDetailId': itemId, 'error': e.message},
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Otomatik döngü
  // ─────────────────────────────────────────────────────────────

  void _startRotation() {
    _rotateTimer?.cancel();
    _rotateTimer = Timer.periodic(_rotateInterval, (_) => _rotateToNextCabin());
  }

  void _restartRotation() => _startRotation();

  void _rotateToNextCabin() {
    // Döngü kabin LİSTESİNİ yenilemez — yalnızca seçili kabini değiştirir.
    if (_cabins.length < 2) {
      _loadSelectedCabinData(silent: true);
      return;
    }
    final currentIndex = _cabins.indexWhere((c) => c.id == _selectedCabinId);
    final nextIndex = (currentIndex + 1) % _cabins.length;
    _selectedCabinId = _cabins[nextIndex].id;
    _safeNotify();
    _loadSelectedCabinData(silent: true);
  }

  @override
  void dispose() {
    _disposed = true;
    _rotateTimer?.cancel();
    super.dispose();
  }
}
