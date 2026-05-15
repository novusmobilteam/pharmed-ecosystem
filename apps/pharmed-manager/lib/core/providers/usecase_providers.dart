import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class UsecaseProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      /// ActiveIngredient
      Provider(create: (context) => GetActiveIngredientsUseCase(context.read())),
      Provider(create: (context) => CreateActiveIngredientUseCase(context.read())),
      Provider(create: (context) => UpdateActiveIngredientUseCase(context.read())),
      Provider(create: (context) => DeleteActiveIngredientUseCase(context.read())),

      /// Authorization
      Provider(create: (context) => GetUserMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveUserMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => GetRoleMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveRoleMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => GetRoleMcAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveRoleMcAuthorizationUseCase(context.read())),
      Provider(
        create: (context) =>
            GetRoleDrugAuthorizationUseCase(authRepository: context.read(), medicineRepository: context.read()),
      ),
      Provider(create: (context) => SaveRoleDrugAuthorizationUseCase(context.read())),

      /// Branch
      Provider(create: (context) => GetBranchesUseCase(context.read())),
      Provider(create: (context) => CreateBranchUseCase(context.read())),
      Provider(create: (context) => UpdateBranchUseCase(context.read())),
      Provider(create: (context) => DeleteBranchUseCase(context.read())),

      /// Dosage Form
      Provider(create: (context) => GetDosageFormsUseCase(context.read())),
      Provider(create: (context) => CreateDosageFormUseCase(context.read())),
      Provider(create: (context) => DeleteDosageFormUseCase(context.read())),
      Provider(create: (context) => UpdateDosageFormUseCase(context.read())),

      /// Drug Class
      Provider(create: (context) => GetDrugClassUseCase(context.read())),
      Provider(create: (context) => CreateDrugClassUseCase(context.read())),
      Provider(create: (context) => UpdateDrugClassUseCase(context.read())),
      Provider(create: (context) => DeleteDrugClassUseCase(context.read())),

      /// Drug Type
      Provider(create: (context) => GetDrugTypesUseCase(context.read())),
      Provider(create: (context) => DeleteDrugTypeUseCase(context.read())),
      Provider(create: (context) => CreateDrugTypeUseCase(context.read())),
      Provider(create: (context) => UpdateDrugTypeUseCase(context.read())),

      /// Firm
      Provider(create: (context) => GetFirmsUseCase(context.read<IFirmRepository>())),
      Provider(create: (context) => CreateFirmUseCase(context.read<IFirmRepository>())),
      Provider(create: (context) => UpdateFirmUseCase(context.read<IFirmRepository>())),
      Provider(create: (context) => DeleteFirmUseCase(context.read<IFirmRepository>())),

      /// Hospitalization
      Provider(create: (context) => CreateHospitalizationUseCase(context.read())),
      Provider(create: (context) => DeleteHospitalizationUseCase(context.read())),
      Provider(create: (context) => GetFilteredHospitalizationsUseCase(context.read())),
      Provider(create: (context) => GetHospitalizationsUseCase(context.read())),
      Provider(create: (context) => GetHospitalizationsWithPrescriptionUseCase(context.read())),
      Provider(create: (context) => GetPatientsWithActivePrescriptionUseCase(context.read())),
      Provider(create: (context) => UpdateHospitalizationUseCase(context.read())),
      Provider(create: (context) => GetHospitalizationsByServiceUseCase(context.read())),

      /// Inconsistency
      Provider(create: (context) => GetInconsistenciesUseCase(context.read())),

      /// Kit Content
      Provider(create: (context) => GetKitContentUseCase(context.read())),
      Provider(create: (context) => DeleteKitContentUseCase(context.read())),
      Provider(create: (context) => CreateKitContentUseCase(context.read())),
      Provider(create: (context) => UpdateKitContentUseCase(context.read())),

      /// Kit
      Provider(create: (context) => GetKitsUseCase(context.read())),
      Provider(create: (context) => DeleteKitUseCase(context.read())),
      Provider(create: (context) => CreateKitUseCase(context.read())),
      Provider(create: (context) => UpdateKitUseCase(context.read())),

      /// Material Type
      Provider(create: (context) => GetMaterialTypesUseCase(context.read())),
      Provider(create: (context) => CreateMaterialTypeUseCase(context.read())),
      Provider(create: (context) => UpdateMaterialTypeUseCase(context.read())),
      Provider(create: (context) => DeleteMaterialTypeUseCase(context.read())),

      /// Medicine
      Provider(create: (context) => CreateMedicineUseCase(context.read())),
      Provider(create: (context) => DeleteMedicineUseCase(context.read())),
      Provider(create: (context) => GetDrugsUseCase(context.read())),
      Provider(create: (context) => GetMedicalConsumablesUseCase(context.read())),
      Provider(create: (context) => GetMedicinesUseCase(context.read())),
      Provider(create: (context) => UpdateMedicineUseCase(context.read())),
      Provider(create: (context) => GetDrugUseCase(context.read())),

      /// Menu
      Provider(create: (context) => GetFilteredMenusUseCase(context.read(), isManager: true)),
      Provider(create: (context) => GetAllMenusUseCase(context.read())),

      /// Patient
      Provider(create: (context) => AddPatientUseCase(context.read())),
      Provider(create: (context) => CreatePatientUseCase(context.read())),
      Provider(create: (context) => DeletePatientUseCase(context.read())),
      Provider(create: (context) => GetMyPatientsUseCase(context.read())),
      Provider(create: (context) => GetPatientsUseCase(context.read())),
      Provider(create: (context) => RemovePatientsUseCase(context.read())),
      Provider(create: (context) => UpdatePatientUseCase(context.read())),
      Provider(create: (context) => EndEmergencyPatientUseCase(context.read())),
      Provider(create: (context) => GetHospitalizedAndRecentExitsUseCase(context.read())),
      Provider(create: (context) => GetUrgentPatientsUseCase(context.read())),
      Provider(create: (context) => CreateUrgentPatientUseCase(context.read())),

      /// Prescription
      Provider(create: (context) => GetPatientPrescriptionsUseCase(context.read())),
      Provider(create: (context) => GetPrescriptionDetailUseCase(context.read())),
      Provider(create: (context) => SubmitPrescriptionActionUseCase(context.read())),
      Provider(create: (context) => UpdatePrescriptionItemUseCase(context.read())),
      Provider(create: (context) => GetPatientPrescriptionHistoryUseCase(context.read())),
      Provider(create: (context) => DeleteUnscannedBarcodeUseCase(context.read())),
      Provider(create: (context) => GetUnscannedBarcodesUseCase(context.read())),
      Provider(create: (context) => ScanBarcodeUseCase(context.read())),
      Provider(create: (context) => ToggleBarcodeWarningUseCase(context.read())),
      Provider(create: (context) => GetScannedBarcodesUseCase(context.read())),
      Provider(create: (context) => GetDeletedBarcodesUseCase(context.read())),
      Provider(create: (context) => GetUnappliedPrescriptionsUseCase(context.read())),
      Provider(create: (context) => GetUnappliedPrescriptionDetailUseCase(context.read())),
      Provider(create: (context) => AssignRfidTagUseCase(context.read(), context.read())),
      Provider(create: (context) => DeleteRfidTagUseCase(context.read())),
      Provider(create: (context) => CheckAndApprovePrescriptionUseCase(context.read())),
      Provider(create: (context) => CreatePrescriptionUseCase(prescriptionRepository: context.read())),

      /// Refund
      Provider(create: (context) => GetMasterRefundablesUseCase(context.read())),
      Provider(create: (context) => CompleteRefundUseCase(context.read())),
      Provider(create: (context) => CompletePharmacyRefundUseCase(context.read())),
      Provider(create: (context) => GetCompletedPharmacyRefundsUseCase(context.read())),
      Provider(create: (context) => GetPharmacyRefundsUseCase(context.read())),
      Provider(create: (context) => GetDrawerRefundsUseCase(context.read())),
      Provider(create: (context) => DeletePharmacyRefundUseCase(context.read())),
      Provider(
        create: (context) =>
            CheckMasterRefundStatusUseCase(refundRepository: context.read(), cabinRepository: context.read()),
      ),

      /// Role
      Provider(create: (context) => GetRolesUseCase(context.read<IRoleRepository>())),
      Provider(create: (context) => CreateRoleUseCase(context.read<IRoleRepository>())),
      Provider(create: (context) => UpdateRoleUseCase(context.read<IRoleRepository>())),
      Provider(create: (context) => DeleteRoleUseCase(context.read<IRoleRepository>())),

      /// Service
      Provider(create: (context) => GetServicesUseCase(context.read())),
      Provider(create: (context) => CreateServiceUseCase(context.read())),
      Provider(create: (context) => UpdateServiceUseCase(context.read())),
      Provider(create: (context) => DeleteServiceUseCase(context.read())),
      Provider(create: (context) => DeleteRoomUseCase(context.read())),
      Provider(create: (context) => DeleteBedUseCase(context.read())),
      Provider(create: (context) => GetRoomsUseCase(context.read())),
      Provider(create: (context) => GetBedsUseCase(context.read())),

      /// Station
      Provider(create: (context) => GetStationsUseCase(context.read())),
      Provider(create: (context) => GetStationUseCase(context.read())),
      Provider(create: (context) => GetCurrentStationUseCase(context.read())),
      Provider(create: (context) => CreateStationUseCase(context.read())),
      Provider(create: (context) => UpdateStationUseCase(context.read())),
      Provider(create: (context) => DeleteStationUseCase(context.read())),
      Provider(create: (context) => UpdateStationMacAddressUseCase(context.read())),

      /// Stock
      Provider(create: (context) => GetCurrentCabinStockUseCase(context.read())),
      Provider(create: (context) => GetCabinStockUseCase(context.read())),
      Provider(create: (context) => GetExpiredStocksUseCase(context.read())),
      Provider(create: (context) => GetExpiringStocksUseCase(context.read())),
      Provider(create: (context) => GetStationStocksUseCase(context.read())),
      Provider(create: (context) => CountMedicineUseCase(context.read())),

      /// Unit
      Provider(create: (context) => GetUnitsUseCase(context.read())),
      Provider(create: (context) => CreateUnitUseCase(context.read())),
      Provider(create: (context) => UpdateUnitUseCase(context.read())),
      Provider(create: (context) => DeleteUnitUseCase(context.read())),

      /// User
      Provider(create: (context) => GetCurrentUserUseCase(context.read<IUserManager>())),
      Provider(create: (context) => GetUsersUseCase(context.read<IUserManager>())),
      Provider(create: (context) => CreateUserUseCase(context.read<IUserManager>())),
      Provider(create: (context) => UpdateUserUseCase(context.read<IUserManager>())),
      Provider(create: (context) => DeleteUserUseCase(context.read<IUserManager>())),
      Provider(create: (context) => BulkUpdateValidDateUseCase(context.read<IUserManager>())),
      Provider(create: (context) => ChangePasswordUseCase(context.read<IUserManager>())),

      /// Warehouse
      Provider(create: (context) => GetWarehousesUseCase(context.read())),
      Provider(create: (context) => CreateWarehouseUseCase(context.read())),
      Provider(create: (context) => UpdateWarehouseUseCase(context.read())),
      Provider(create: (context) => DeleteWarehouseUseCase(context.read())),

      /// Warning
      Provider(create: (context) => GetWarningsUseCase(context.read())),
      Provider(create: (context) => CreateWarningUseCase(context.read())),
      Provider(create: (context) => UpdateWarningUseCase(context.read())),
      Provider(create: (context) => DeleteWarningUseCase(context.read())),

      /// Stock Transaction
      Provider(create: (context) => CreateStockTransactionUseCase(context.read())),
      Provider(create: (context) => DeleteStockTransactionUseCase(context.read())),
      Provider(create: (context) => GetStockTransactionsUseCase(context.read())),
      Provider(create: (context) => GetCabinStockTransactionsUseCase(context.read())),
    ];
  }
}
