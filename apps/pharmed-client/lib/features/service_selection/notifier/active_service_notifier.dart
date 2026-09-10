import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/mixins/api_request_mixin.dart';
import '../../../core/providers/providers.dart';

/// İstasyon-servis ilişkisinin client oturumu
/// boyunca tek kaynaktan yönetilmesi. Login sonrası initialize() edilir,
/// dashboard'dan bağımsız olarak GetCurrentStationUseCase'i kendi çağırır.
/// https://github.com/novusmobilteam/pharmed-ecosystem/issues/50#issue-5402109513

final activeServiceNotifierProvider = ChangeNotifierProvider<ActiveServiceNotifier>((ref) {
  return ActiveServiceNotifier(getCurrentStation: ref.read(getCurrentStationUseCaseProvider));
});

class ActiveServiceNotifier extends ChangeNotifier with ApiRequestMixin {
  ActiveServiceNotifier({required GetCurrentStationUseCase getCurrentStation}) : _getCurrentStation = getCurrentStation;

  final GetCurrentStationUseCase _getCurrentStation;

  final OperationKey _fetchStationOp = OperationKey.custom('fetch-active-service-station');

  Station? _station;
  Station? get station => _station;

  List<HospitalService> _availableServices = [];
  List<HospitalService> get availableServices => _availableServices;

  HospitalService? _activeService;
  HospitalService? get activeService => _activeService;

  bool get isLoadingServices => isLoading(_fetchStationOp);

  /// Birden fazla servis var ve henüz seçim yapılmadıysa true — bu true
  /// olduğu sürece gate ekranı (ServiceSelectionView) gösterilir.
  bool get requiresSelection => _availableServices.length > 1 && _activeService == null;

  bool get isResolved => _activeService != null;

  /// Login sonrası bir kez çağrılır. İstasyonu çeker; tek servisliyse
  /// otomatik seçer, çoklu servisliyse seçim beklenir (requiresSelection).
  Future<void> initialize() => execute(
    _fetchStationOp,
    operation: () => _getCurrentStation.call(),
    onData: (station) {
      _station = station;
      _availableServices = station?.services ?? [];
      _activeService = _availableServices.length == 1 ? _availableServices.first : null;
      notifyListeners();
    },
  );

  void selectService(HospitalService service) {
    if (!_availableServices.any((s) => s.id == service.id)) return;
    _activeService = service;
    notifyListeners();
  }

  /// Dashboard'daki "servis değiştir" alanından tetiklenir — seçim
  /// ekranına geri döner, mevcut liste (availableServices) korunur.
  void changeService() {
    _activeService = null;
    notifyListeners();
  }

  /// Logout'ta çağrılmalı — bir sonraki girişte servis yeniden sorulsun.
  void reset() {
    _station = null;
    _availableServices = [];
    _activeService = null;
    notifyListeners();
  }
}
