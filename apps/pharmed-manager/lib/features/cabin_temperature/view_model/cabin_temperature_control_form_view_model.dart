import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../data/repository/cabin_temperature_repository_impl.dart';
import '../domain/entity/cabin_temperature.dart';
import '../domain/entity/cabin_temperature_detail.dart';

class CabinTemperatureControlFormViewModel extends ChangeNotifier {
  final CabinTemperatureRepository _cabinTemperatureRepository;
  // BuildContext'e erişimi olmayan bu ViewModel yerine, oluşturulduğu view
  // katmanından (l10n ile) çözülen mesajlar için enjekte edilir.
  final AppLocalizations _l10n;

  CabinTemperatureControlFormViewModel({
    required CabinTemperatureRepository cabinTemperatureRepository,
    required AppLocalizations l10n,
    CabinTemperatureDetail? initial,
  }) : _cabinTemperatureRepository = cabinTemperatureRepository,
       _l10n = l10n {
    init(initial);
  }

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  APIRequestStatus _submitStatus = APIRequestStatus.initial;
  APIRequestStatus get submitStatus => _submitStatus;

  CabinTemperatureDetail? _form;
  CabinTemperatureDetail? get form => _form;

  bool get isUpdate => _form?.id != null; // Yeni: update mi create mi?

  void init(CabinTemperatureDetail? initial) {
    if (initial != null) {
      _form = initial;
    } else {
      _form = CabinTemperatureDetail();
    }
    notifyListeners();
  }

  void setStation(Station? station) {
    _form = _form?.copyWith(station: station);
    notifyListeners();
  }

  void setCabin(Cabin? cabin) {
    _form = _form?.copyWith(cabin: cabin);
    notifyListeners();
  }

  void setInsideBottomTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(bottomTemperatureInside: temp);
    notifyListeners();
  }

  void setInsideTopTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(topTemperatureInside: temp);
    notifyListeners();
  }

  void setOutsideBottomTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(bottomTemperatureOutside: temp);
    notifyListeners();
  }

  void setOutsideTopTemp(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(topTemperatureOutside: temp);
    notifyListeners();
  }

  void setBottomHumidity(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(bottomLimitHumidity: temp);
    notifyListeners();
  }

  void setTopHumidity(String? value) {
    var temp = int.tryParse(value ?? "");
    _form = _form?.copyWith(topLimitHumidity: temp);
    notifyListeners();
  }

  Future<void> submit() async {
    if (_form == null) return;

    _submitStatus = APIRequestStatus.loading;
    notifyListeners();

    try {
      if (isUpdate) {
        // UPDATE işlemi
        await _updateCabinTemperature();
      } else {
        // CREATE işlemi
        await _createCabinTemperature();
      }
    } catch (e) {
      _submitStatus = APIRequestStatus.failed;
      _statusMessage = _l10n.cabinTemperatureGenericErrorMessage(e.toString());
      notifyListeners();
    }
  }

  Future<void> _createCabinTemperature() async {
    final cabinTemperature = CabinTemperature(station: _form?.station);

    if (cabinTemperature.station == null) {
      _submitStatus = APIRequestStatus.failed;
      _statusMessage = _l10n.cabinTemperatureStationNotSelectedError;
      notifyListeners();
      return;
    }

    final res = await _cabinTemperatureRepository.createCabinTemperature(cabinTemperature);
    res.when(
      ok: (data) async {
        final res = await _cabinTemperatureRepository.createCabinTemperatureDetail(
          _form!.copyWith(station: _form?.station!.copyWith(id: data.id)),
        );
        res.when(
          ok: (_) {
            _submitStatus = APIRequestStatus.success;
            _statusMessage = _l10n.cabinTemperatureCreateSuccess;
            notifyListeners();
          },
          error: (error) {
            _submitStatus = APIRequestStatus.failed;
            _statusMessage = error.message;
            notifyListeners();
          },
        );
      },
      error: (error) {
        _submitStatus = APIRequestStatus.failed;
        _statusMessage = error.message;
        notifyListeners();
      },
    );
  }

  Future<void> _updateCabinTemperature() async {
    if (_form?.id == null) {
      _submitStatus = APIRequestStatus.failed;
      _statusMessage = _l10n.cabinTemperatureUpdateRecordNotFoundError;
      notifyListeners();
      return;
    }

    final res = await _cabinTemperatureRepository.updateCabinTemperatureDetail(_form!);
    res.when(
      ok: (_) {
        _submitStatus = APIRequestStatus.success;
        _statusMessage = _l10n.cabinTemperatureUpdateSuccess;
        notifyListeners();
      },
      error: (error) {
        _submitStatus = APIRequestStatus.failed;
        _statusMessage = error.message;
        notifyListeners();
      },
    );
  }
}
