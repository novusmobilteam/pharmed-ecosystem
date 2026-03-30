import 'package:flutter/material.dart';

import '../../../core/core.dart';

class CabinDesignFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateCabinUseCase _createCabinUseCase;
  final UpdateCabinUseCase _updateCabinUseCase;
  final Cabin? _initial;

  CabinDesignFormNotifier({
    required CreateCabinUseCase createCabinUseCase,
    required UpdateCabinUseCase updateCabinUseCase,
    Cabin? initial,
  }) : _createCabinUseCase = createCabinUseCase,
       _updateCabinUseCase = updateCabinUseCase,
       _initial = initial {
    if (_initial != null) {
      _cabin = _initial;
    } else {
      _cabin = Cabin(
        type: CabinType.master,
        baudRate: BaudRate.baud9600,
        stopBit: StopBit.stop1,
        parityBit: ParityBit.none,
        dataBit: DataBit.data1,
        status: Status.active,
        comPort: ComPort.com3,
      );
    }
  }

  // Operation Keys
  static const submitOp = OperationKey.custom('submit');

  // Variables
  Cabin? _cabin;

  // Getters
  Cabin? get cabin => _cabin;
  bool get isSubmitting => isLoading(submitOp);
  bool get isCreate => _initial == null;

  // Bu kabin tipleri dışındaki kabin tiplerinde ayarlar yapılabiliyor
  bool get showDeviceSettings => _cabin?.type != CabinType.openCabin && _cabin?.type != CabinType.returnCabin;

  // // Şimdilik bu kullanılıyor - MultiSelectionDialog için
  // Future<Result<ApiResponse<List<CabinCardType>>>> getCardTypes() async {
  //   return Result.ok(ApiResponse(data: CabinCardType.values));
  // }

  // Functions
  Future<bool> submitForm() async {
    bool success = false;

    await executeVoid(
      submitOp,
      operation: () async {
        final result = _initial != null
            ? await _updateCabinUseCase.call(_cabin!)
            : await _createCabinUseCase.call(_cabin!);
        return result;
      },
      successMessage: isCreate ? 'Kabin oluşturuldu' : 'Kabin güncellendi',
    );

    return success;
  }

  void updateStation(Station? value) {
    _cabin = _cabin?.copyWith(station: value);
    notifyListeners();
  }

  void updateName(String? value) {
    _cabin = _cabin?.copyWith(name: value);
    notifyListeners();
  }

  void updateType(CabinType? value) {
    _cabin = _cabin?.copyWith(type: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _cabin = _cabin?.copyWith(status: value);
    notifyListeners();
  }

  // void updateCardTypes(List<CabinCardType>? value) {
  //   _cabin = _cabin?.copyWith(cardTypes: value);
  //   notifyListeners();
  // }

  void updatePort(ComPort? value) {
    _cabin = _cabin?.copyWith(comPort: value);
    notifyListeners();
  }

  void updateBaudRate(BaudRate? value) {
    _cabin = _cabin?.copyWith(baudRate: value);
    notifyListeners();
  }

  void updateStopBit(StopBit? value) {
    _cabin = _cabin?.copyWith(stopBit: value);
    notifyListeners();
  }

  void updateDataBit(DataBit? value) {
    _cabin = _cabin?.copyWith(dataBit: value);
    notifyListeners();
  }

  void updateParityBit(ParityBit? value) {
    _cabin = _cabin?.copyWith(parityBit: value);
    notifyListeners();
  }

  void updateColor(CabinColor? value) {
    _cabin = _cabin?.copyWith(color: value);
    notifyListeners();
  }

  void updateCameraNo(String? value) {
    _cabin = _cabin?.copyWith(cameraNo: int.tryParse(value ?? ""));
    notifyListeners();
  }

  void updateSequence(int? value) {
    _cabin = _cabin?.copyWith(sequenceNo: value);
    notifyListeners();
  }

  void updateDvrIp(String? value) {
    _cabin = _cabin?.copyWith(dvrIp: value);
    notifyListeners();
  }
}
