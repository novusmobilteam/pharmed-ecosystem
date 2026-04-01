import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class HospitalizationNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Hospitalization>, DateFilterMixin<Hospitalization> {
  final IHospitalizationRepository _hospitalizationRepository;

  HospitalizationNotifier({required IHospitalizationRepository hospitalizationRepository})
    : _hospitalizationRepository = hospitalizationRepository {
    // Varsayılan tarih aralığı: son 4 gün
    setStartDate(DateTime.now().subtract(const Duration(days: 4)));
    setEndDate(DateTime.now());
  }

  static const fetch = OperationKey.fetch();

  // State
  Hospitalization? _selectedHospitalization;

  bool get isFetching => isLoading(fetch);

  /// Seçili yatış kaydı
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  /// Seçili hastanın bilgileri
  Patient? get patient => _selectedHospitalization?.patient;

  /// Seçili yatış bilgisi (selectedHospitalization ile aynı)
  Hospitalization? get hospitalization => _selectedHospitalization;

  /// Hasta seçili mi kontrolü
  bool get hasPatient => _selectedHospitalization != null;

  /// Filtrelenmiş yatış listesi.
  /// Önce arama filtresini (SearchMixin default), sonra tarih filtresini uygular.
  @override
  List<Hospitalization> get filteredItems {
    // SearchMixin'in default araması searchQuery varsa çalışır
    if (searchQuery.isNotEmpty) {
      return applyDateFilter(super.filteredItems);
    }
    return applyDateFilter(allItems);
  }

  void selectHospitalization(Hospitalization? data) {
    _selectedHospitalization = data;
    notifyListeners();
  }

  /// Yatan hasta listesini API'den çeker.
  Future<void> getHospitalizations() async {
    _selectedHospitalization = null;
    await execute(
      fetch,
      operation: () => _hospitalizationRepository.getHospitalizations(),
      onData: (response) => allItems = response?.data ?? [],
    );
  }

  /// Tarih alanını belirler (DateFilterMixin için gerekli).
  /// Yatış tarihi (admissionDate) üzerinden filtreleme yapar.
  @override
  DateTime? getDateField(Hospitalization item) => item.admissionDate;
}
