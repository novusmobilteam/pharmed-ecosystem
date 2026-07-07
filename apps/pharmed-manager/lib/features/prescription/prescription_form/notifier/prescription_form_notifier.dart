import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../auth/notifier/auth_notifier.dart';

class PrescriptionFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreatePrescriptionUseCase _useCase;
  final CreatePrescriptionTemplateUseCase _templateUseCase;

  PrescriptionFormNotifier({
    Hospitalization? hospitalization,
    required AuthNotifier authNotifier,
    required CreatePrescriptionUseCase useCase,
    required CreatePrescriptionTemplateUseCase templateUseCase,
  }) : _useCase = useCase,
       _templateUseCase = templateUseCase {
    _hospitalization = hospitalization;
    _isPatientSelectionEnabled = hospitalization == null;
    if (_hospitalization != null) {
      _doctor = _hospitalization?.doctor;
    }
  }

  final OperationKey submitOp = OperationKey.submit();
  final OperationKey templateOp = OperationKey.submit();

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  User? _doctor;
  User? get doctor => _doctor;

  bool _isPatientSelectionEnabled = false;
  bool get isPatientSelectionEnabled => _isPatientSelectionEnabled;

  bool get hasPatient => _hospitalization != null;

  final List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => List.unmodifiable(_items);

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  PrescriptionItem? get selectedItem =>
      _selectedIndex != null && _selectedIndex! < _items.length ? _items[_selectedIndex!] : null;

  bool _saveAsTemplate = false;
  bool get saveAsTemplate => _saveAsTemplate;

  String _templateName = '';
  String get templateName => _templateName;

  bool get isSubmitting => isLoading(submitOp);
  bool get isSavingTemplate => isLoading(templateOp);
  String? get statusMessage => message(submitOp) ?? message(templateOp);

  bool get canSave {
    final base = _items.isNotEmpty && _hospitalization != null && _doctor != null;
    if (!base) return false;
    // Şablon olarak da kaydedilecekse isim zorunlu.
    if (_saveAsTemplate && _templateName.trim().isEmpty) return false;
    return true;
  }

  bool isItemValid(PrescriptionItem item) {
    return item.medicine != null &&
        (item.dosePiece ?? 0) > 0 &&
        item.requestType != null &&
        (item.times?.isNotEmpty == true);
  }

  bool get areAllItemsValid => _items.every(isItemValid);

  void updatePatient(Hospitalization? h) {
    _hospitalization = h;
    notifyListeners();
  }

  void updateDoctor(User? d) {
    _doctor = d;
    notifyListeners();
  }

  void addEmptyItem() {
    final empty = PrescriptionItem(
      doctor: _doctor,
      doctorId: _doctor?.id,
      requestType: RequestType.normal,
      dosePiece: 1,
    );
    _items.add(empty);
    _selectedIndex = _items.length - 1;
    notifyListeners();
  }

  void selectItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);

    if (_items.isEmpty) {
      _selectedIndex = null;
    } else if (_selectedIndex == index) {
      _selectedIndex = index < _items.length ? index : _items.length - 1;
    } else if (_selectedIndex != null && _selectedIndex! > index) {
      _selectedIndex = _selectedIndex! - 1;
    }
    notifyListeners();
  }

  void _updateSelected(PrescriptionItem Function(PrescriptionItem) transform) {
    final i = _selectedIndex;
    if (i == null) return;
    _items[i] = transform(_items[i]);
    notifyListeners();
  }

  void updateMedicine(Medicine? medicine) => _updateSelected(
    (item) => item.copyWith(medicine: medicine, medicineId: medicine?.id, dosePiece: medicine?.operationStep ?? 1.0),
  );

  void updateDosePiece(double? value) => _updateSelected((item) => item.copyWith(dosePiece: value));

  void updateRequestType(RequestType? value) => _updateSelected((item) => item.copyWith(requestType: value));

  void updateDescription(String? value) => _updateSelected((item) => item.copyWith(description: value));

  void toggleFirstDoseEmergency() =>
      _updateSelected((item) => item.copyWith(firstDoseEmergency: !(item.firstDoseEmergency ?? false)));

  void toggleAskDoctor() => _updateSelected((item) => item.copyWith(askDoctor: !(item.askDoctor ?? false)));

  void toggleInCaseOfNecessity() =>
      _updateSelected((item) => item.copyWith(inCaseOfNecessity: !(item.inCaseOfNecessity ?? false)));

  void updateDoseHour(int index, TimeOfDay? value) {
    final i = _selectedIndex;
    if (i == null) return;
    final updated = _rebuildTimes(_items[i].times, index, value);
    _items[i] = _items[i].copyWith(times: updated.isEmpty ? null : updated);
    notifyListeners();
  }

  List<DateTime> _rebuildTimes(List<DateTime>? current, int index, TimeOfDay? value) {
    final tmp = List<DateTime?>.filled(6, null);
    final src = current ?? const [];
    for (var i = 0; i < src.length && i < 6; i++) {
      tmp[i] = src[i];
    }

    if (value != null) {
      final now = DateTime.now();
      tmp[index] = DateTime(now.year, now.month, now.day, value.hour, value.minute);
    } else {
      tmp[index] = null;
    }

    DateTime? last;
    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i] == null) continue;
      if (last != null) {
        final cH = tmp[i]!.hour, cM = tmp[i]!.minute;
        final lH = last.hour, lM = last.minute;
        if (cH < lH || (cH == lH && cM <= lM)) {
          tmp[i] = DateTime(last.year, last.month, last.day + 1, cH, cM);
        } else {
          tmp[i] = DateTime(last.year, last.month, last.day, cH, cM);
        }
      }
      last = tmp[i];
    }

    return tmp.whereType<DateTime>().toList();
  }

  void importItems(List<PrescriptionItem> source) {
    if (source.isEmpty) return;

    final grouped = _groupBySharedAttributes(source);
    int? firstNewIndex;

    for (final group in grouped) {
      final sourceTimes = group.map((it) => it.time).whereType<DateTime>().toList()..sort();
      final remapped = _remapTimesToToday(sourceTimes);

      final candidate = group.first.asDraft().copyWith(doctor: _doctor, doctorId: _doctor?.id, times: remapped);

      // Form'da aynı imzalı bir kalem var mı? Varsa times'ları birleştir.
      final candidateSig = _itemSignature(candidate);
      final existingIndex = _items.indexWhere((e) => _itemSignature(e) == candidateSig);

      if (existingIndex >= 0) {
        final merged = _mergeTimes(_items[existingIndex].times, candidate.times);
        _items[existingIndex] = _items[existingIndex].copyWith(times: merged);
      } else {
        _items.add(candidate);
        firstNewIndex ??= _items.length - 1;
      }
    }

    // En az bir yeni kalem eklendiyse ilkini seç; tamamı merge'lendiyse mevcut seçimi bozma.
    if (firstNewIndex != null) {
      _selectedIndex = firstNewIndex;
    }
    notifyListeners();
  }

  /// İki times listesini birleştirir, saat-dakika bazında dedupe eder, sıralar.
  List<DateTime>? _mergeTimes(List<DateTime>? a, List<DateTime>? b) {
    final all = <DateTime>[...?a, ...?b];
    if (all.isEmpty) return null;

    final seen = <String>{};
    final result = <DateTime>[];
    for (final dt in all..sort()) {
      final key = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      if (seen.add(key)) result.add(dt);
    }
    return result;
  }

  /// Backend'in kalem-per-saat formatını, form'un kalem-per-times formatına çevirmek için
  /// kalemleri ortak özelliklerine göre grupla.
  List<List<PrescriptionItem>> _groupBySharedAttributes(List<PrescriptionItem> source) {
    final groups = <String, List<PrescriptionItem>>{};
    for (final item in source) {
      groups.putIfAbsent(_itemSignature(item), () => []).add(item);
    }
    return groups.values.toList();
  }

  /// Source saatlerin date kısmını bugüne kaydırır, aralarındaki gün farkını korur.
  List<DateTime>? _remapTimesToToday(List<DateTime>? source) {
    if (source == null || source.isEmpty) return null;

    final now = DateTime.now();
    final firstSource = source.first;
    final firstSourceDay = DateTime(firstSource.year, firstSource.month, firstSource.day);
    final today = DateTime(now.year, now.month, now.day);
    final shift = today.difference(firstSourceDay).inDays;

    return source.map((dt) => dt.add(Duration(days: shift))).toList();
  }

  void toggleSaveAsTemplate() {
    _saveAsTemplate = !_saveAsTemplate;
    if (!_saveAsTemplate) _templateName = '';
    notifyListeners();
  }

  void updateTemplateName(String? value) {
    if (value != null) {
      _templateName = value;
      notifyListeners();
    }
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (!canSave) return;

    final prescription = Prescription(
      hospitalization: _hospitalization,
      hospitalizationId: _hospitalization?.id,
      prescriptionDate: DateTime.now(),
    );

    final itemsWithDoctor = _items.map((i) => i.copyWith(doctor: _doctor, doctorId: _doctor?.id)).toList();

    executeVoid(
      submitOp,
      operation: () => _useCase.call(prescription: prescription, items: itemsWithDoctor),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () async {
        // Reçete kaydı tamam. Şablon istendiyse onu da kaydetmeye çalış.
        if (_saveAsTemplate) {
          final ok = await _saveTemplate(itemsWithDoctor);
          if (ok) {
            onSuccess?.call('Reçete ve şablon başarıyla kaydedildi.');
          } else {
            // Reçete kaydedildi ama şablon kaydedilemedi — kullanıcıyı bilgilendir,
            // reçete başarısını geri alma.
            onSuccess?.call('Reçete kaydedildi ancak şablon kaydedilemedi.');
          }
        } else {
          onSuccess?.call('Reçete başarıyla kaydedildi.');
        }
      },
      loadingMessage: 'Reçete oluşturuluyor. Lütfen bekleyiniz..',
    );
  }

  /// Reçete başarıyla kaydedildikten sonra çağrılır.
  /// Şablon başarıyla kaydedildi mi onu döner; hata yönetimi içeride yapılır.
  Future<bool> _saveTemplate(List<PrescriptionItem> items) async {
    final template = PrescriptionTemplate(name: _templateName.trim());

    final templateItems = items.map((i) => i.toTemplateItem()).toList();

    var success = false;
    await execute<List<PrescriptionTemplateItem>>(
      templateOp,
      operation: () => _templateUseCase.call(template: template, items: templateItems),
      onData: (_) => success = true,
      loadingMessage: 'Şablon kaydediliyor..',
    );
    return success;
  }

  String _itemSignature(PrescriptionItem item) {
    return [
      item.medicine?.id ?? item.medicineId,
      item.dosePiece,
      item.requestType?.id,
      item.firstDoseEmergency ?? false,
      item.askDoctor ?? false,
      item.inCaseOfNecessity ?? false,
      (item.description ?? '').trim(),
    ].join('|');
  }
}
