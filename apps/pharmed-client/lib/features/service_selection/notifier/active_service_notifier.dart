import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/mixins/api_request_mixin.dart';
import '../../../core/providers/providers.dart';

/// İstasyon-servis ilişkisinin client oturumu
/// boyunca tek kaynaktan yönetilmesi. Login sonrası initialize() edilir,
/// dashboard'dan bağımsız olarak GetCurrentStationUseCase'i kendi çağırır.
/// https://github.com/novusmobilteam/pharmed-ecosystem/issues/50#issue-5402109513
///
/// [SWREQ-CORE-AUTH-002] İstasyon yetki kontrolü — kullanıcının `stationIds`
/// listesinde güncel istasyonun id'si yoksa hiçbir işleme izin verilmez,
/// servis seçim ekranı dahi gösterilmez.
/// Fail-safe: yetki doğrulanamayan her durum (istasyon null, liste boş,
/// istek hatası) "izin yok" olarak ele alınır; dashboard'a asla geçilmez.

final activeServiceNotifierProvider = ChangeNotifierProvider<ActiveServiceNotifier>((ref) {
  return ActiveServiceNotifier(getCurrentStation: ref.read(getCurrentStationUseCaseProvider));
});

/// Kullanıcının güncel istasyondaki yetki durumu.
enum StationAccessStatus {
  /// Henüz doğrulanmadı (ilk açılış, istek sürüyor veya hata aldı).
  unknown,

  /// Kullanıcının stationIds listesi güncel istasyonu içeriyor.
  granted,

  /// Kullanıcının bu istasyonda yetkisi yok — tüm akış kilitli.
  denied,
}

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

  StationAccessStatus _accessStatus = StationAccessStatus.unknown;
  StationAccessStatus get accessStatus => _accessStatus;

  /// Yetki kontrolünün hangi kullanıcı için başlatıldığı. Gate, oturumdaki
  /// kullanıcı bununla eşleşmiyorsa kontrolü yeniden başlatır — kilitli
  /// dashboard'dan farklı bir kullanıcı girdiğinde önceki kullanıcının
  /// yetkisi asla devralınmaz.
  int? _checkedUserId;
  int? get checkedUserId => _checkedUserId;

  bool get isLoadingServices => isLoading(_fetchStationOp);
  bool get hasLoadError => hasError(_fetchStationOp);

  bool get isAccessGranted => _accessStatus == StationAccessStatus.granted;
  bool get isAccessDenied => _accessStatus == StationAccessStatus.denied;

  /// Birden fazla servis var ve henüz seçim yapılmadıysa true — bu true
  /// olduğu sürece gate ekranı (ServiceSelectionView) gösterilir.
  /// Yetkisiz kullanıcı için asla true dönmez.
  bool get requiresSelection => isAccessGranted && _availableServices.length > 1 && _activeService == null;

  bool get isResolved => isAccessGranted && _activeService != null;

  /// Login sonrası çağrılır. İstasyonu çeker, önce kullanıcının bu istasyonda
  /// yetkisi olup olmadığını doğrular; yetki varsa tek servisliyse otomatik
  /// seçer, çoklu servisliyse seçim beklenir (requiresSelection).
  Future<void> initialize(AppUser user) {
    _checkedUserId = user.id;
    _accessStatus = StationAccessStatus.unknown;
    _availableServices = [];
    _activeService = null;

    return execute(
      _fetchStationOp,
      swreq: 'SWREQ-CORE-AUTH-002',
      operation: () => _getCurrentStation.call(),
      onData: (station) {
        // Yanıt gelene kadar logout/başka kullanıcı girişi olduysa sonuç bayattır.
        if (_checkedUserId != user.id) return;
        _station = station;
        MedLogger.setSessionValue('stationId', station?.id);

        if (!user.hasAccessToStation(station?.id)) {
          _accessStatus = StationAccessStatus.denied;
          // [HAZ-004] Yetkisiz erişim denemesi sessiz geçmez — denetim izi.
          MedLogger.warn(
            unit: 'SW-UNIT-UI',
            swreq: 'SWREQ-CORE-AUTH-002',
            message: 'Station access denied',
            context: {'userId': user.id, 'stationId': station?.id, 'userStationIds': user.stationIds},
          );
          notifyListeners();
          return;
        }

        _accessStatus = StationAccessStatus.granted;
        _availableServices = station?.services ?? [];
        _activeService = _availableServices.length == 1 ? _availableServices.first : null;
        MedLogger.setSessionValue('serviceId', _activeService?.id);
        notifyListeners();
      },
    );
  }

  void selectService(HospitalService service) {
    // Savunma katmanı: yetkisiz kullanıcı servis seçemez.
    if (!isAccessGranted) return;
    if (!_availableServices.any((s) => s.id == service.id)) return;
    _activeService = service;
    MedLogger.setSessionValue('serviceId', service.id);
    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-CORE-LOG-003',
      message: 'Servis seçildi',
      context: {'serviceId': service.id, 'stationId': _station?.id},
    );
    notifyListeners();
  }

  /// Dashboard'daki "servis değiştir" alanından tetiklenir — seçim
  /// ekranına geri döner, mevcut liste (availableServices) korunur.
  void changeService() {
    if (!isAccessGranted) return;
    _activeService = null;
    notifyListeners();
  }

  /// Logout / 401'de çağrılır — bir sonraki girişte yetki ve servis
  /// yeniden doğrulansın (farklı kullanıcı aynı kiosk'a girebilir).
  void reset() {
    _station = null;
    _availableServices = [];
    _activeService = null;
    _accessStatus = StationAccessStatus.unknown;
    _checkedUserId = null;
    clearOperation(_fetchStationOp);
  }
}
