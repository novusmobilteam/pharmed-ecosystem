import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class MedicineDefineNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetSerumSlotsUseCase _getSerumSlotsUseCase;
  final DefinePatientMedicineUseCase _definePatientMedicineUseCase;
  final Function(MedicineDefineNotifier notifier) onDefineMedicine;
  Hospitalization? _hospitalization;

  MedicineDefineNotifier({
    required GetSerumSlotsUseCase getSerumSlotsUseCase,
    required DefinePatientMedicineUseCase definePatientMedicineUseCase,
    required Hospitalization hospitalization,
    required this.onDefineMedicine,
  }) : _getSerumSlotsUseCase = getSerumSlotsUseCase,
       _definePatientMedicineUseCase = definePatientMedicineUseCase {
    _hospitalization = hospitalization;
  }

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.custom('submit');

  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _slots.isEmpty;

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  List<DrawerSlot> _slots = [];
  List<DrawerSlot> get slots => _slots;

  DrawerSlot? _selectedSlot;
  DrawerSlot? get selectedSlot => _selectedSlot;

  int? _compartmentNo;
  int? get compartmentNo => _compartmentNo;
  set compartmentNo(int? value) {
    _compartmentNo = value;
    notifyListeners();
  }

  String? medicineName;
  String? barcode;
  int? dosePiece;
  List<DateTime?> _selectedTimes = List<DateTime?>.filled(5, null);
  List<DateTime?> get selectedTimes => _selectedTimes;

  MedicineAssignment get assignment => MedicineAssignment(
    drawerUnit: DrawerUnit(drawerSlot: _selectedSlot, drawerSlotId: _selectedSlot?.id),
    cabin: _selectedSlot?.cabin,
  );

  String get saveButtonText => _activeIndex == 0 ? 'Devam Et' : 'Kaydet';

  void getSerumSlots() async {
    await execute(
      fetchOp,
      operation: () => _getSerumSlotsUseCase.call(),
      onData: (data) {
        _slots = data;
        notifyListeners();
      },
    );
  }

  void selectSlot(DrawerSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void onSave(BuildContext context) {
    if (_activeIndex == 0) {
      _activeIndex = 1;
      notifyListeners();
    } else if (_activeIndex == 1) {
      if (medicineName != null && barcode != null && dosePiece != null) {
        onDefineMedicine(this);
      }
    }
  }

  // Saat güncelleme (index'e göre)
  void updateSelectedTime(int index, TimeOfDay? time) {
    if (time != null) {
      final now = DateTime.now();
      _selectedTimes[index] = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } else {
      _selectedTimes[index] = null;
    }
    notifyListeners();
  }

  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    final data = {
      "patientHospitalizationId": _hospitalization?.id,
      "cabinDrawrId": _selectedSlot?.id,
      "compartmentNo": compartmentNo,
      "materialName": medicineName,
      "barcode": barcode,
      "dosePiece": dosePiece,
      "time": _selectedTimes.where((time) => time != null).map((time) => time!.toIso8601String()).toList(),
      "description": "",
    };

    await executeVoid(
      submitOp,
      operation: () => _definePatientMedicineUseCase.call(data),
      onSuccess: () => onSuccess?.call('Hasta ilacı tanımlama işlemi başarılı.'),
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}

// İlaç-saat-uyarı bilgisini tutan sınıf
class MedicineTime {
  final DateTime time;
  bool alertEnabled;

  MedicineTime({required this.time, required this.alertEnabled});

  String get formattedTime => '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineTime && other.time == time && other.alertEnabled == alertEnabled;
  }

  @override
  int get hashCode => time.hashCode ^ alertEnabled.hashCode;
}

// UI'da göstermek için yardımcı sınıf
class MedicineTimeEntry {
  final Medicine medicine;
  final MedicineTime medicineTime;

  MedicineTimeEntry({required this.medicine, required this.medicineTime});

  String get displayText {
    return '${medicine.name} - ${medicineTime.formattedTime}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineTimeEntry && other.medicine == medicine && other.medicineTime == medicineTime;
  }

  @override
  int get hashCode => medicine.hashCode ^ medicineTime.hashCode;
}
