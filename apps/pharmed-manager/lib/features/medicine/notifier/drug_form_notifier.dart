import 'package:flutter/material.dart';

import '../../../core/core.dart';

class DrugFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateMedicineUseCase _createMedicineUseCase;
  final UpdateMedicineUseCase _updateMedicineUseCase;
  final GetDrugUseCase _getDrugUseCase;
  final GetActiveIngredientsUseCase _getActiveIngredientsUseCase;
  final SaveIndependentServicesUseCase _saveIndependentServicesUseCase;
  final GetServicesUseCase _getServicesUseCase;

  static const _swreq = 'SWREQ-MGR-MEDICINE-001';

  DrugFormNotifier({
    required CreateMedicineUseCase createMedicineUseCase,
    required UpdateMedicineUseCase updateMedicineUseCase,
    required GetDrugUseCase getDrugUseCase,
    required GetActiveIngredientsUseCase getActiveIngredientsUseCase,
    required SaveIndependentServicesUseCase saveIndependentServicesUseCase,
    required GetServicesUseCase getServicesUseCase,
    required IUserManager userRepository,
    required IStationRepository stationRepository,
    Drug? drug,
  }) : _createMedicineUseCase = createMedicineUseCase,
       _updateMedicineUseCase = updateMedicineUseCase,
       _getDrugUseCase = getDrugUseCase,
       _getActiveIngredientsUseCase = getActiveIngredientsUseCase,
       _saveIndependentServicesUseCase = saveIndependentServicesUseCase,
       _getServicesUseCase = getServicesUseCase,
       _drug = drug ?? Drug(returnType: ReturnType.toOrigin, isCameraRecording: true) {
    _initialize();
  }

  Drug _drug;
  Drug get drug => _drug;

  List<ActiveIngredient> _activeIngredients = [];
  List<ActiveIngredient> get activeIngredients => _activeIngredients;

  /// Serbest ilaç için formda seçili servisler. Backend'deki kayıtlar
  /// (`_drug.independentServices`) kayıt başarılı olana kadar değiştirilmez;
  /// PUT gövdesi bu iki liste karşılaştırılarak üretilir.
  List<HospitalService> _independentServices = [];
  List<HospitalService> get independentServices => _independentServices;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.custom('submit');

  bool get isCreate => _drug.id == null;
  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  String? get statusMessage => message(submitOp);

  // İlgili ilaca ait 'Etken Maddeler', 'Kullanıcılar' ve 'İstasyonlar' bilgilerini
  // gösterebilmek için servisten getiriyoruz ve gelen verileri ilgili
  // değerlere atıyoruz.
  Future<void> _initialize() async {
    if (!isCreate) {
      await execute(
        fetchOp,
        operation: () => _getDrugUseCase.call(_drug.id ?? 0),
        onData: (data) async {
          if (data != null) {
            _drug = data;
            _independentServices = _drug.independentServices
                .map((s) => HospitalService(id: s.serviceId, name: s.serviceName))
                .toList();

            notifyListeners();
            await Future.wait([_getActiveIngredients(), _resolveIndependentServiceNames()]);
          }
        },
      );
    }
  }

  Future<void> _getActiveIngredients() async {
    final res = await _getActiveIngredientsUseCase.call(PagedQueryParams());

    res.when(
      ok: (response) {
        if (response.data != null) {
          _activeIngredients = response.data!.where((a) => _drug.activeIngredientIds.contains(a.id)).toList();
          notifyListeners();
        }
      },
      error: (_) {},
    );
  }

  /// `GET /Material/{id}` servis adını dönmezse seçili servislerin adlarını
  /// servis listesinden tamamlar. Hata olursa id ile gösterime devam edilir.
  Future<void> _resolveIndependentServiceNames() async {
    if (_independentServices.every((s) => s.name != null)) return;

    final res = await _getServicesUseCase.call(PagedQueryParams());
    res.when(
      ok: (response) {
        final byId = {for (final s in response.data ?? <HospitalService>[]) s.id: s};
        _independentServices = _independentServices.map((s) => byId[s.id] ?? s).toList();
        notifyListeners();
      },
      error: (_) {},
    );
  }

  /// İlacın servis kayıtlarının senkronize edilmesi gerekiyor mu?
  /// - Serbest ilaçsa: her zaman (eklenen/çıkarılan servisler).
  /// - Serbest değilse: yalnızca backend'de kalan servis varsa (temizlemek için).
  bool get _needsIndependentServiceSync => _drug.isIndependentMaterial || _drug.independentServices.isNotEmpty;

  /// PUT /Material/independentServices gövdesindeki `services` listesi.
  /// Mevcut kaydı olan servis id'siyle (güncelle), yeni servis id'siz (ekle) gönderilir;
  /// listede olmayan kayıtlar backend tarafından silinir.
  List<IndependentMaterialService> _buildIndependentServicePayload() {
    if (!_drug.isIndependentMaterial) return const [];

    final persisted = {for (final s in _drug.independentServices) s.serviceId: s};
    return _independentServices
        .where((s) => s.id != null)
        .map((s) => IndependentMaterialService(id: persisted[s.id]?.id, serviceId: s.id!, serviceName: s.name))
        .toList();
  }

  /// [SWREQ-MGR-MEDICINE-001] İlaç kaydı + serbest ilaç servisleri.
  ///
  /// Sıra: 1) ilaç oluştur/güncelle → 2) gerekiyorsa servisleri kaydet.
  /// 2. adım 1. adımın döndüğü id'ye bağlıdır; 1. adım başarısızsa 2. adım
  /// çalıştırılmaz. 2. adım başarısız olursa ilaç kayıtlı kalır ve notifier
  /// düzenleme moduna geçer — tekrar kaydet ilacı yeniden OLUŞTURMAZ, günceller.
  Future<void> submit() async {
    final wasCreate = isCreate;
    setLoading(submitOp);
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: _swreq, message: 'DrugFormNotifier.submit başlatıldı (create: $wasCreate)');

    // ── 1. İlaç kaydı ────────────────────────────────────────────
    AppException? saveError;
    int? savedId = _drug.id;
    if (wasCreate) {
      final res = await _createMedicineUseCase.call(_drug);
      res.when(ok: (created) => savedId = created?.id, error: (e) => saveError = e);
    } else {
      final res = await _updateMedicineUseCase.call(_drug);
      res.when(ok: (_) {}, error: (e) => saveError = e);
    }

    final drugError = saveError;
    if (drugError != null) {
      _logSubmitError('İlaç kaydı başarısız', drugError);
      setFailed(submitOp, message: drugError.userMessage);
      return;
    }

    final materialId = savedId;
    if (materialId != null && wasCreate) {
      _drug = _drug.copyWith(id: materialId);
    }

    // ── 2. Serbest ilaç servisleri ───────────────────────────────
    if (_needsIndependentServiceSync) {
      if (materialId == null) {
        // Backend oluşturulan ilacı dönmedi — servisler bağlanamaz. [HAZ-004]
        MedLogger.error(
          unit: 'SW-UNIT-UI',
          swreq: _swreq,
          message: 'Oluşturulan ilacın id\'si dönmedi, serbest ilaç servisleri kaydedilemedi',
        );
        setFailed(
          submitOp,
          message: contextlessL10n().medicine_independentServicesSaveError(contextlessL10n().common_genericErrorMessage),
        );
        return;
      }

      final payload = _buildIndependentServicePayload();
      final res = await _saveIndependentServicesUseCase.call(materialId: materialId, services: payload);
      AppException? serviceError;
      res.when(ok: (_) {}, error: (e) => serviceError = e);

      final syncError = serviceError;
      if (syncError != null) {
        _logSubmitError('Serbest ilaç servisleri kaydedilemedi', syncError, materialId: materialId);
        setFailed(submitOp, message: contextlessL10n().medicine_independentServicesSaveError(syncError.userMessage));
        return;
      }

      MedLogger.info(
        unit: 'SW-UNIT-UI',
        swreq: _swreq,
        message: 'Serbest ilaç servisleri kaydedildi',
        context: {'materialId': materialId, 'serviceIds': payload.map((s) => s.serviceId).toList()},
      );
    }

    setSuccess(
      submitOp,
      message: wasCreate ? contextlessL10n().medicine_successCreated : contextlessL10n().medicine_successUpdated,
    );
  }

  void _logSubmitError(String message, AppException error, {int? materialId}) {
    // [HAZ-004] Hata her zaman loglanır, sessiz geçmez
    MedLogger.error(
      unit: 'SW-UNIT-UI',
      swreq: _swreq,
      message: 'DrugFormNotifier.submit: $message',
      context: {
        if (materialId != null) 'materialId': materialId,
        'errorType': error.runtimeType.toString(),
        'message': error.message,
      },
      error: error,
    );
  }

  void updateDefinitionName(String? value) {
    _drug = _drug.copyWith(definition: value);
    notifyListeners();
  }

  void updateBarcode(String? value) {
    _drug = _drug.copyWith(barcode: value);
    notifyListeners();
  }

  void updateName(String? value) {
    _drug = _drug.copyWith(name: value);
    notifyListeners();
  }

  void updateCode(String? value) {
    _drug = _drug.copyWith(code: value);
    notifyListeners();
  }

  void updatePrescriptionType(PrescriptionType? value) {
    _drug = _drug.copyWith(prescriptionType: value);
    notifyListeners();
  }

  void updateDose(String? value) {
    _drug = _drug.copyWith(dose: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateDoseUnit(Unit? value) {
    _drug = _drug.copyWith(doseUnit: value, unitMeasure: value);
    notifyListeners();
  }

  void updateFirm(Firm? value) {
    _drug = _drug.copyWith(firm: value);
    notifyListeners();
  }

  void updateDailyUsage(String? value) {
    final usage = int.tryParse(value ?? '');
    _drug = _drug.copyWith(dailyMaxUsage: usage, clearDailyMaxUsage: usage == null);
    notifyListeners();
  }

  void updateDrugType(DrugType? value) {
    _drug = _drug.copyWith(drugType: value);
    notifyListeners();
  }

  void updateReturnType(ReturnType? value) {
    bool maxValue = value == ReturnType.toOrigin ? _drug.isNotSerumCabinetMaxValue : false;
    _drug = _drug.copyWith(returnType: value, isNotSerumCabinetMaxValue: maxValue, isNotCubicDrawrMaxValue: maxValue);
    notifyListeners();
  }

  void toggleQr() {
    _drug = _drug.copyWith(isQrCode: !_drug.isQrCode, piece: 0);
    notifyListeners();
  }

  void updatePiece(int? value) {
    _drug = _drug.copyWith(piece: value);
    notifyListeners();
  }

  void updateDrugClass(DrugClass? value) {
    _drug = _drug.copyWith(drugClass: value);
    notifyListeners();
  }

  /// "Order'lı" seçildiğinde order'sız alım personeli alanı kilitlenir ve temizlenir.
  void updatePurchaseType(PurchaseType? value) {
    _drug = _drug.copyWith(
      purchaseType: value,
      materialOrderlessTakingUsers: value == PurchaseType.ordered ? [] : null,
    );
    notifyListeners();
  }

  void toggleMeasurement() {
    _drug = _drug.copyWith(isMeasureUnit: !_drug.isMeasureUnit, unitMeasure: null, doseMeasureUnit: null);
    notifyListeners();
  }

  void updateMeasurementDose(String? value) {
    _drug = _drug.copyWith(doseMeasureUnit: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateVolume(String? value) {
    _drug = _drug.copyWith(volume: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateVolumeUnit(Unit? value) {
    _drug = _drug.copyWith(volumeUnit: value);
    notifyListeners();
  }

  void updateDosageForm(DosageForm? value) {
    _drug = _drug.copyWith(dosageForm: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _drug = _drug.copyWith(isActive: value?.isActive);
    notifyListeners();
  }

  void updateCountType(CountType? value) {
    _drug = _drug.copyWith(countType: value);
    notifyListeners();
  }

  void updateAtcCode(String? value) {
    _drug = _drug.copyWith(atcCode: value);
    notifyListeners();
  }

  void updateEquivalentCode(String? value) {
    _drug = _drug.copyWith(equivalentCode: value);
    notifyListeners();
  }

  void toggleWitnessedPurchase() {
    _drug = _drug.copyWith(
      isWitnessedPurchase: !_drug.isWitnessedPurchase,
      witnessedPurchaseStations: [],
      witnessedPurchaseUsers: [],
    );
    notifyListeners();
  }

  void updateWitnessedPurchaseUsers(List<User>? users) {
    _drug = _drug.copyWith(witnessedPurchaseUsers: users);
    notifyListeners();
  }

  void updateWitnessedPurchaseStations(List<Station>? stations) {
    _drug = _drug.copyWith(witnessedPurchaseStations: stations);
    notifyListeners();
  }

  void toggleWastageWitnessedPurchase() {
    _drug = _drug.copyWith(
      isWastageWitnessedPurchase: !_drug.isWastageWitnessedPurchase,
      wastageWitnessedPurchaseStations: [],
      wastageWitnessedPurchaseUsers: [],
    );
    notifyListeners();
  }

  void updateWastageWitnessedPurchaseUsers(List<User>? users) {
    _drug = _drug.copyWith(wastageWitnessedPurchaseUsers: users);
    notifyListeners();
  }

  void updateWastageWitnessedPurchaseStations(List<Station>? stations) {
    _drug = _drug.copyWith(wastageWitnessedPurchaseStations: stations);
    notifyListeners();
  }

  void updateOrderlessUsers(List<User>? users) {
    _drug = _drug.copyWith(materialOrderlessTakingUsers: users);
    notifyListeners();
  }

  void toggleIsDestroyable() {
    _drug = _drug.copyWith(isDestroyable: !_drug.isDestroyable, destroyableUsers: []);
    notifyListeners();
  }

  void updateDestroyableUsers(List<User>? users) {
    _drug = _drug.copyWith(destroyableUsers: users);
    notifyListeners();
  }

  void updateActiveIngredients(List<ActiveIngredient>? value) {
    _activeIngredients = value ?? [];
    _drug = _drug.copyWith(activeIngredientIds: _activeIngredients.map((a) => a.id ?? 0).toList());
    notifyListeners();
  }

  void updateCollectNote(String? value) {
    _drug = _drug.copyWith(collectNote: value);
    notifyListeners();
  }

  void updateReturnNote(String? value) {
    _drug = _drug.copyWith(returnNote: value);
    notifyListeners();
  }

  void updateDestructionNote(String? value) {
    _drug = _drug.copyWith(destructionNote: value);
    notifyListeners();
  }

  void toggleMultiPatientAccess() {
    _drug = _drug.copyWith(isMultiplePatientAccess: !_drug.isMultiplePatientAccess);
    notifyListeners();
  }

  void toggleSingleUse() {
    _drug = _drug.copyWith(isSingleUse: !_drug.isSingleUse);
    notifyListeners();
  }

  void toggleCameraRecording() {
    _drug = _drug.copyWith(isCameraRecording: !_drug.isCameraRecording);
    notifyListeners();
  }

  /// Kapatıldığında seçili servisler temizlenir; kayıtta backend'e boş liste
  /// gönderilerek mevcut servisler kaldırılır.
  void toggleIndependentMaterial() {
    _drug = _drug.copyWith(isIndependentMaterial: !_drug.isIndependentMaterial);
    if (!_drug.isIndependentMaterial) _independentServices = [];
    notifyListeners();
  }

  void updateIndependentServices(List<HospitalService>? services) {
    _independentServices = services ?? [];
    notifyListeners();
  }

  void toggleLowerDose() {
    _drug = _drug.copyWith(isCanLowerDose: !_drug.isCanLowerDose);

    notifyListeners();
  }

  void toggleWastagePharmacyApproval() {
    _drug = _drug.copyWith(isWastagePharmacyApproval: !_drug.isWastagePharmacyApproval);
    notifyListeners();
  }

  void toggleWastageOrderRenewed() {
    _drug = _drug.copyWith(isWastageOrderRenewed: !_drug.isWastageOrderRenewed);
    notifyListeners();
  }

  void toggleSerumMaxValue() {
    _drug = _drug.copyWith(isNotSerumCabinetMaxValue: !_drug.isNotSerumCabinetMaxValue);
    notifyListeners();
  }

  void toggleCubicMaxValue() {
    _drug = _drug.copyWith(isNotCubicDrawrMaxValue: !_drug.isNotCubicDrawrMaxValue);
    notifyListeners();
  }

  void toggleRfid() {
    _drug = _drug.copyWith(isRfidEnable: !_drug.isRfidEnable);
    notifyListeners();
  }

  void toggleTakeGiveButton() {
    _drug = _drug.copyWith(isTakeGiveButtonActive: !_drug.isTakeGiveButtonActive);
    notifyListeners();
  }
}
