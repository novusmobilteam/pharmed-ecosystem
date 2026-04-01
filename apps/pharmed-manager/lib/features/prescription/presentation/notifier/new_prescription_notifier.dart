import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class NewPrescriptionNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreatePrescriptionWithProductsUseCase _useCase;

  NewPrescriptionNotifier({required CreatePrescriptionWithProductsUseCase useCase, Hospitalization? hospitalization})
    : _useCase = useCase {
    _hospitalization = hospitalization;
    _isPatientSelectionEnabled = hospitalization == null;
    _currentItem = PrescriptionItem(requestType: RequestType.normal, dosePiece: 1);
  }

  OperationKey submitOp = OperationKey.submit();

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  late PrescriptionItem _currentItem;
  PrescriptionItem get currentItem => _currentItem;

  List<PrescriptionItem> _prescriptionItems = [];
  List<PrescriptionItem> get prescriptionItems => _prescriptionItems;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  bool get hasPatient => _hospitalization != null;

  bool _isPatientSelectionEnabled = false;
  bool get isPatientSelectionEnabled => _isPatientSelectionEnabled;

  bool get isButtonActive {
    return _currentItem.medicine != null &&
        _currentItem.doctor != null &&
        (_currentItem.dosePiece ?? 0) > 0 &&
        _currentItem.requestType != null &&
        (_currentItem.times?.isNotEmpty == true);
  }

  bool _isCurrentItemValid() {
    return _currentItem.medicine != null &&
        _currentItem.doctor != null &&
        (_currentItem.dosePiece ?? 0) > 0 &&
        (_currentItem.times?.isNotEmpty == true);
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final hospitalizationId = _hospitalization?.id;
    final prescription = Prescription(
      hospitalization: _hospitalization,
      hospitalizationId: hospitalizationId,
      prescriptionDate: DateTime.now(),
    );

    executeVoid(
      submitOp,
      operation: () => _useCase.call(prescription: prescription, items: _prescriptionItems),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı..'),
      loadingMessage: 'Reçete oluşturuluyor. Lütfen bekleyiniz..',
    );
  }

  void updateDoctor(User? doctor) {
    _currentItem = _currentItem.copyWith(doctor: doctor);
    notifyListeners();
  }

  void updateMaterial(Medicine? medicine) {
    _currentItem = _currentItem.copyWith(medicine: medicine, medicineId: medicine?.id, dosePiece: 0);
    notifyListeners();
  }

  void updateDosePiece(double? value) {
    _currentItem = _currentItem.copyWith(dosePiece: value);
    notifyListeners();
  }

  void updatePatient(Hospitalization? hospitalization) {
    _hospitalization = hospitalization;
    notifyListeners();
  }

  void updateRequestType(RequestType? value) {
    _currentItem = _currentItem.copyWith(requestType: value);
    notifyListeners();
  }

  void updateDoseHour(int index, TimeOfDay? value) {
    // 1. Mevcut listeyi hazırla (6 slotluk geçici liste)
    final tmp = List<DateTime?>.filled(6, null);
    final current = _currentItem.times ?? [];
    for (var i = 0; i < current.length && i < 6; i++) {
      tmp[i] = current[i];
    }

    // 2. Değer güncelleme (null ise sil, değilse ata)
    if (value != null) {
      final now = DateTime.now();
      // Başlangıç olarak bugünün tarihini veriyoruz
      tmp[index] = DateTime(now.year, now.month, now.day, value.hour, value.minute);
    } else {
      tmp[index] = null;
    }

    // 3. Tarihleri sırayla kontrol et ve "Sonraki Gün" mantığını uygula
    // Sadece dolu olanları (null olmayanları) filtrelemeden önce tarihleri kaydırmalıyız
    DateTime? lastDateTime;
    for (int i = 0; i < tmp.length; i++) {
      if (tmp[i] == null) continue;

      if (lastDateTime != null) {
        // Mevcut saati bir öncekiyle karşılaştır
        final currentHour = tmp[i]!.hour;
        final currentMinute = tmp[i]!.minute;
        final lastHour = lastDateTime.hour;
        final lastMinute = lastDateTime.minute;

        // Eğer şu anki saat, önceki saatten küçükse (veya eşitse, tercihe bağlı) günü bir artır
        // Kriter: (Saat küçükse) VEYA (Saatler eşit ama dakika küçükse)
        if (currentHour < lastHour || (currentHour == lastHour && currentMinute <= lastMinute)) {
          // Bir önceki tarihin üzerine 1 gün ekleyerek yeni tarihi setle
          tmp[i] = DateTime(lastDateTime.year, lastDateTime.month, lastDateTime.day + 1, currentHour, currentMinute);
        } else {
          // Saat ileri bir saatse, öncekiyle aynı gün kalabilir
          tmp[i] = DateTime(lastDateTime.year, lastDateTime.month, lastDateTime.day, currentHour, currentMinute);
        }
      }
      lastDateTime = tmp[i];
    }

    // 4. Listeyi filtrele ve state'i güncelle
    final filtered = tmp.whereType<DateTime>().toList();
    _currentItem = _currentItem.copyWith(times: filtered.isEmpty ? null : filtered);

    notifyListeners();
  }

  void toggleFirstDoseEmergency() {
    _currentItem = _currentItem.copyWith(firstDoseEmergency: !(_currentItem.firstDoseEmergency ?? false));
    notifyListeners();
  }

  void toggleAskDoctor() {
    _currentItem = _currentItem.copyWith(askDoctor: !(_currentItem.askDoctor ?? false));
    notifyListeners();
  }

  void toggleInCaseOfNecessity() {
    _currentItem = _currentItem.copyWith(inCaseOfNecessity: !(_currentItem.inCaseOfNecessity ?? false));
    notifyListeners();
  }

  void updateDescription(String? value) {
    _currentItem = _currentItem.copyWith(description: value);
    notifyListeners();
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < _prescriptionItems.length) {
      _prescriptionItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    if (_prescriptionItems.isEmpty) return;
    _prescriptionItems.clear();
    notifyListeners();
  }

  void addCurrentItem() {
    if (!_isCurrentItemValid()) return;

    _prescriptionItems.add(_currentItem);
    _resetCurrentItem();
    notifyListeners();
  }

  void _resetCurrentItem() {
    final currentDoctor = _currentItem.doctor;
    final currentDoctorId = _currentItem.doctorId;

    _currentItem = PrescriptionItem(
      doctor: currentDoctor,
      doctorId: currentDoctorId,
      requestType: RequestType.normal,
      description: null,
    );
  }

  // UI'dan çağrılacak reset metodu
  void resetForm() {
    _resetCurrentItem();
    notifyListeners();
  }
}
