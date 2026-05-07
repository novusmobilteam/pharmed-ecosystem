import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class RepositoryProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      /// Active Ingredient
      Provider<IActiveIngredientRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => ActiveIngredientRepositoryImpl(
            dataSource: context.read(),
            mapper: ActiveIngredientMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => ActiveIngredientRepositoryImpl(
            dataSource: context.read(),
            mapper: ActiveIngredientMapper(),
          ),
        },
      ),

      /// Branch
      Provider<IBranchRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => BranchRepositoryImpl(dataSource: context.read(), mapper: BranchMapper()),
          AppFlavor.dev || AppFlavor.prod => BranchRepositoryImpl(dataSource: context.read(), mapper: BranchMapper()),
        },
      ),

      /// Role Authorization
      Provider<IRoleAuthorizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RoleAuthorizationRepositoryImpl(
            dataSource: context.read(),
            menuMapper: RoleMenuAuthorizationMapper(),
            drugMapper: RoleDrugAuthorizationMapper(),
            consumableMapper: RoleMedicalConsumableAuthorizationMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => RoleAuthorizationRepositoryImpl(
            dataSource: context.read(),
            menuMapper: RoleMenuAuthorizationMapper(),
            drugMapper: RoleDrugAuthorizationMapper(),
            consumableMapper: RoleMedicalConsumableAuthorizationMapper(),
          ),
        },
      ),

      /// User Authorization
      Provider<IUserAuthorizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => UserAuthorizationRepositoryImpl(
            dataSource: context.read(),
            mapper: UserMenuAuthorizationMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => UserAuthorizationRepositoryImpl(
            dataSource: context.read(),
            mapper: UserMenuAuthorizationMapper(),
          ),
        },
      ),

      /// Dosage Form
      Provider<IDosageFormRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DosageFormRepositoryImpl(dataSource: context.read(), mapper: DosageFormMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => DosageFormRepositoryImpl(dataSource: context.read(), mapper: DosageFormMapper()),
        },
      ),

      /// Drug Class
      Provider<IDrugClassRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DrugClassRepositoryImpl(dataSource: context.read(), mapper: DrugClassMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => DrugClassRepositoryImpl(dataSource: context.read(), mapper: DrugClassMapper()),
        },
      ),

      /// Drug Type
      Provider<IDrugTypeRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DrugTypeRepositoryImpl(dataSource: context.read(), mapper: DrugTypeMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => DrugTypeRepositoryImpl(dataSource: context.read(), mapper: DrugTypeMapper()),
        },
      ),

      /// Firm
      Provider<IFirmRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => FirmRepositoryImpl(dataSource: context.read(), mapper: FirmMapper()),
          AppFlavor.dev || AppFlavor.prod => FirmRepositoryImpl(dataSource: context.read(), mapper: FirmMapper()),
        },
      ),

      /// Hospitalization
      Provider<IHospitalizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => HospitalizationRepositoryImpl(dataSource: context.read(), mapper: HospitalizationMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => HospitalizationRepositoryImpl(dataSource: context.read(), mapper: HospitalizationMapper()),
        },
      ),

      /// Inconsistency
      Provider<IInconsistencyRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => InconsistencyRepositoryImpl(dataSource: context.read(), mapper: InconsistencyMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => InconsistencyRepositoryImpl(dataSource: context.read(), mapper: InconsistencyMapper()),
        },
      ),

      /// KitContent
      Provider<IKitContentRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => KitContentRepositoryImpl(dataSource: context.read(), mapper: KitContentMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => KitContentRepositoryImpl(dataSource: context.read(), mapper: KitContentMapper()),
        },
      ),

      /// Kit
      Provider<IKitRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => KitRepositoryImpl(dataSource: context.read(), mapper: KitMapper()),
          AppFlavor.dev || AppFlavor.prod => KitRepositoryImpl(dataSource: context.read(), mapper: KitMapper()),
        },
      ),

      /// MaterialType
      Provider<IMaterialTypeRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MaterialTypeRepositoryImpl(dataSource: context.read(), mapper: MaterialTypeMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => MaterialTypeRepositoryImpl(dataSource: context.read(), mapper: MaterialTypeMapper()),
        },
      ),

      /// Medicine
      Provider<IMedicineRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MedicineRepositoryImpl(
            dataSource: context.read(),
            mapper: MedicineMapper(),
            drugMapper: DrugMapper(),
            mcMapper: MedicalConsumableMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => MedicineRepositoryImpl(
            dataSource: context.read(),
            mapper: MedicineMapper(),
            drugMapper: DrugMapper(),
            mcMapper: MedicalConsumableMapper(),
          ),
        },
      ),

      /// Dashboard
      Provider<IDashboardRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MockDashboardRepository(),
          AppFlavor.dev || AppFlavor.prod => DashboardRepositoryImpl(
            dataSource: context.read(),
            cabinStockMapper: CabinStockMapper(),
            prescriptionItemMapper: PrescriptionItemMapper(),
            prescriptionMapper: PrescriptionMapper(),
            refundMapper: RefundMapper(),
            menuMapper: MenuTreeMapper(),
          ),
        },
      ),

      /// Patient
      Provider<IPatientRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => PatientRepository(
            dataSource: context.read(),
            patientMapper: PatientMapper(),
            myPatientMapper: MyPatientMapper(),
            urgentPatientMapper: UrgentPatientMapper(),
            hospitalizationMapper: HospitalizationMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => PatientRepository(
            dataSource: context.read(),
            patientMapper: PatientMapper(),
            myPatientMapper: MyPatientMapper(),
            urgentPatientMapper: UrgentPatientMapper(),
            hospitalizationMapper: HospitalizationMapper(),
          ),
        },
      ),

      Provider<IPrescriptionRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => PrescriptionRepositoryImpl(
            dataSource: context.read(),
            prescriptionMapper: PrescriptionMapper(),
            prescriptionItemMapper: PrescriptionItemMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => PrescriptionRepositoryImpl(
            dataSource: context.read(),
            prescriptionMapper: PrescriptionMapper(),
            prescriptionItemMapper: PrescriptionItemMapper(),
          ),
        },
      ),

      /// Refund
      Provider<IRefundRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RefundRepositoryImpl(
            dataSource: context.read(),
            refundMapper: RefundMapper(),
            withdrawItemMapper: MedicineWithdrawItemMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => RefundRepositoryImpl(
            dataSource: context.read(),
            refundMapper: RefundMapper(),
            withdrawItemMapper: MedicineWithdrawItemMapper(),
          ),
        },
      ),

      /// Role
      Provider<IRoleRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RoleRepositoryImpl(dataSource: context.read(), mapper: RoleMapper()),
          AppFlavor.dev || AppFlavor.prod => RoleRepositoryImpl(dataSource: context.read(), mapper: RoleMapper()),
        },
      ),

      /// Service
      Provider<IServiceRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => ServiceRepositoryImpl(
            dataSource: context.read(),
            mapper: ServiceMapper(),
            roomMapper: RoomMapper(),
            bedMapper: BedMapper(),
          ),
          AppFlavor.dev || AppFlavor.prod => ServiceRepositoryImpl(
            dataSource: context.read(),
            mapper: ServiceMapper(),
            roomMapper: RoomMapper(),
            bedMapper: BedMapper(),
          ),
        },
      ),

      /// Station
      Provider<IStationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MockStationRepository(),
          AppFlavor.dev || AppFlavor.prod => StationRepositoryImpl(dataSource: context.read(), mapper: StationMapper()),
        },
      ),

      /// Cabin Stock
      Provider<ICabinStockRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MockCabinStockRepository(),
          AppFlavor.dev || AppFlavor.prod => CabinStockRepositoryImpl(
            dataSource: context.read(),
            localDataSource: context.read(),
            cabinMapper: CabinStockMapper(),
            stationMapper: StationStockMapper(),
          ),
        },
      ),

      /// Unit
      Provider<IUnitRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => UnitRepositoryImpl(dataSource: context.read(), mapper: UnitMapper()),
          AppFlavor.dev || AppFlavor.prod => UnitRepositoryImpl(dataSource: context.read(), mapper: UnitMapper()),
        },
      ),

      /// User
      Provider<IUserManager>(
        create: (context) => UserRepositoryImpl(dataSource: context.read(), mapper: UserMapper()),
      ),

      /// Warehouse
      Provider<IWarehouseRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => WarehouseRepositoryImpl(dataSource: context.read(), mapper: WarehouseMapper()),
          AppFlavor.dev ||
          AppFlavor.prod => WarehouseRepositoryImpl(dataSource: context.read(), mapper: WarehouseMapper()),
        },
      ),

      /// Warning
      Provider<IWarningRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => WarningRepositoryImpl(dataSource: context.read(), mapper: WarningMapper()),
          AppFlavor.dev || AppFlavor.prod => WarningRepositoryImpl(dataSource: context.read(), mapper: WarningMapper()),
        },
      ),
    ];
  }
}
