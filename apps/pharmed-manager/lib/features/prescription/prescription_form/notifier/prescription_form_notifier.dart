import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../auth/notifier/auth_notifier.dart';

class PrescriptionFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreatePrescriptionUseCase _useCase;
  final AuthNotifier _authNotifier;

  PrescriptionFormNotifier({
    required CreatePrescriptionUseCase useCase,
    Hospitalization? hospitalization,
    required AuthNotifier authNotifier,
  }) : _useCase = useCase,
       _authNotifier = authNotifier {
    _hospitalization = hospitalization;
    _isPatientSelectionEnabled = hospitalization == null;
    _doctor = _authNotifier.currentUser?.toUser();
  }

  final OperationKey submitOp = OperationKey.submit();

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
  String? get statusMessage => message(submitOp);

  bool get canSave => _items.isNotEmpty && _hospitalization != null && _doctor != null;

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

    // 1. Backend her ilaç-saatini ayrı kalem olarak döndürdüğü için,
    //    aynı reçete + aynı ilaç + aynı doz/flag setine sahip kalemlerin
    //    saatlerini tek bir form kalemine topla.
    final grouped = _groupBySharedAttributes(source);

    // 2. Her grup → tek bir draft kalem + birleştirilmiş ve bugüne kaydırılmış times.
    for (final group in grouped) {
      final sourceTimes = group.map((it) => it.time).whereType<DateTime>().toList()..sort();

      final remapped = _remapTimesToToday(sourceTimes);

      final draft = group.first.asDraft().copyWith(doctor: _doctor, doctorId: _doctor?.id, times: remapped);

      _items.add(draft);
    }

    _selectedIndex = _items.length - grouped.length;
    notifyListeners();
  }

  /// Backend'in kalem-per-saat formatını, form'un kalem-per-times formatına çevirmek için
  /// kalemleri ortak özelliklerine göre grupla.
  List<List<PrescriptionItem>> _groupBySharedAttributes(List<PrescriptionItem> source) {
    final groups = <String, List<PrescriptionItem>>{};
    for (final item in source) {
      final key = [
        item.prescriptionId,
        item.medicine?.id ?? item.medicineId,
        item.dosePiece,
        item.requestType?.id,
        item.firstDoseEmergency ?? false,
        item.askDoctor ?? false,
        item.inCaseOfNecessity ?? false,
        (item.description ?? '').trim(),
      ].join('|');
      groups.putIfAbsent(key, () => []).add(item);
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

  void updateTemplateName(String value) {
    _templateName = value;
    notifyListeners();
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
      onSuccess: () {
        // TODO(template): _saveAsTemplate true ise CreateTemplateUseCase çağrılacak.
        onSuccess?.call('Reçete başarıyla kaydedildi.');
      },
      loadingMessage: 'Reçete oluşturuluyor. Lütfen bekleyiniz..',
    );
  }
}
