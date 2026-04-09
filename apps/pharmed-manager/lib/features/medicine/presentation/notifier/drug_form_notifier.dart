import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class DrugFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateMedicineUseCase _createMedicineUseCase;
  final UpdateMedicineUseCase _updateMedicineUseCase;
  final GetDrugUseCase _getDrugUseCase;
  final GetActiveIngredientsUseCase _getActiveIngredientsUseCase;

  DrugFormNotifier({
    required CreateMedicineUseCase createMedicineUseCase,
    required UpdateMedicineUseCase updateMedicineUseCase,
    required GetDrugUseCase getDrugUseCase,
    required GetActiveIngredientsUseCase getActiveIngredientsUseCase,
    required IUserManager userRepository,
    required IStationRepository stationRepository,
    Drug? drug,
  }) : _createMedicineUseCase = createMedicineUseCase,
       _updateMedicineUseCase = updateMedicineUseCase,
       _getDrugUseCase = getDrugUseCase,
       _getActiveIngredientsUseCase = getActiveIngredientsUseCase,
       _drug = drug ?? Drug(returnType: ReturnType.toOrigin, isCameraRecording: true) {
    _initialize();
  }

  Drug _drug;
  Drug get drug => _drug;

  List<ActiveIngredient> _activeIngredients = [];
  List<ActiveIngredient> get activeIngredients => _activeIngredients;

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

            notifyListeners();
            await _getActiveIngredients();
          }
        },
      );
    }
  }

  Future<void> _getActiveIngredients() async {
    final res = await _getActiveIngredientsUseCase.call(GetActiveIngredientsParams());

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

  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    await executeVoid(
      submitOp,
      operation: () async {
        final result = isCreate ? await _createMedicineUseCase.call(_drug) : await _updateMedicineUseCase.call(_drug);
        return result;
      },
      onSuccess: () {
        final msg = isCreate ? 'İlaç oluşturuldu' : 'İlaç güncellendi';
        onSuccess?.call(msg);
      },
      onFailed: (error) => onFailed?.call(error.message),
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
    var usage = int.tryParse(value ?? '0');
    _drug = _drug.copyWith(dailyMaxUsage: usage);
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

  void updatePurchaseType(PurchaseType? value) {
    _drug = _drug.copyWith(purchaseType: value);
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
    _drug = _drug.copyWith(atcCode: int.tryParse(value ?? ''));
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

  void toggleIndependentMaterial() {
    _drug = _drug.copyWith(isIndependentMaterial: !_drug.isIndependentMaterial);
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
}
