import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/user/user_dependency_injection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/serial_communication/i_serial_communication_service.dart';
import 'core/services/serial_communication/serial_communication_service.dart';

import 'features/active_ingredient/di/active_ingredient_di.dart';
import 'features/authentication/di/authentication_dependency_injection.dart';
import 'features/branch/di/branch_dependency_injection.dart';
import 'features/cabin/di/cabin_dependency_injection.dart';
import 'features/cabin_assignment/di/cabin_assignment_dependency_injection.dart';
import 'features/cabin_fault/di/cabin_fault_dependency_injection.dart';
import 'features/cabin_stock/di/cabin_stock_di.dart';
import 'features/cabin_temperature/di/cabin_temperature_di.dart';
import 'features/dashboard/di/dashboard_dependency_injection.dart';
import 'features/directed_orders/di/directed_orders_di.dart';
import 'features/dosage_form/di/dosage_form_di.dart';
import 'features/drug_class/di/drug_class_di.dart';
import 'features/drug_type/di/drug_type_di.dart';
import 'features/favorite/favorite_dependency_injection.dart';
import 'features/filling_list/di/filling_list_di.dart';
import 'features/firm/di/firm_dependency_injection.dart';
import 'features/home/notifier/home_notifier.dart';
import 'features/hospitalization/di/hospitalization_dependency_injection.dart';
import 'features/inconsistency/di/inconsistency_di.dart';
import 'features/kit/di/kit_di.dart';
import 'features/kit_content/di/kit_content_di.dart';
import 'features/mail_preference/di/mail_preference_di.dart';
import 'features/material_type/di/material_type_di.dart';
import 'features/medicine/domain/di/medicine_di.dart';
import 'features/medicine_management/di/medicine_management_di.dart';
import 'features/medicine_refill/di/medicine_refill_di.dart';
import 'features/medicine_refund/di/medicine_refund_di.dart';
import 'features/medicine_unload/di/medicine_unload_di.dart';
import 'features/medicine_withdraw/domain/di/medicine_withdraw_di.dart';
import 'features/menu/menu_dependency_injection.dart';
import 'features/patient/di/patient_dependency_injection.dart';
import 'features/prescription/di/prescription_dependency_injection.dart';
import 'features/role/di/role_dependency_injection.dart';
import 'features/service/di/service_dependency_injection.dart';
import 'features/settings/di/settings_di.dart';
import 'features/station/di/station_dependency_injection.dart';
import 'features/stock_transaction/di/stock_transaction_di.dart';
import 'features/unit/di/unit_di.dart';
import 'features/warehouse/di/warehouse_dependency_injection.dart';
import 'features/warning/di/warning_di.dart';
import 'main.dart';

Future<void> start(SharedPreferences prefs) async {
  bool isDev = false;
  runApp(
    MultiProvider(
      providers: [
        Provider<ISerialCommunicationService>(
          create: (context) => SerialCommunicationService(),
          dispose: (context, service) => service.disconnect(),
        ),

        // Network
        Provider<Dio>(create: (_) => Dio()),

        // Settings
        ...SettingsProviders.providers(prefs),

        // Common
        ...FavoriteProviders.providers,
        //...AuthProviders.providers,

        // Features
        ...MenuProviders.providers(isDev: isDev),
        ...UserProviders.providers,
        ...StationProviders.providers(prefs, isDev: isDev),
        ...CabinFaultProviders.providers(isDev: isDev),
        ...CabinProviders.providers(isDev: isDev),
        ...CabinAssignmentProviders.providers(isDev: isDev),
        ...DashboardProviders.providers(isDev: isDev),
        ...FirmProviders.providers(isDev: isDev),
        ...MedicineProviders.providers(isDev: isDev),
        ...RoleProviders.providers,
        ...ServiceProviders.providers(isDev: isDev),
        ...WarehouseProviders.providers(isDev: isDev),
        ...HospitalizationProviders.providers(isDev: isDev),
        ...PatientProviders.providers(isDev: isDev),
        ...PrescriptionProviders.providers(isDev: isDev),
        ...StockTransactionProviders.providers(isDev: isDev),
        ...BranchProviders.providers(isDev: isDev),
        ...CabinStockProviders.providers(isDev: isDev),
        ...MedicineManagementProviders.providers(isDev: isDev),
        ...MedicineRefillProviders.providers(isDev: isDev),
        ...MedicineUnloadProviders.providers(isDev: isDev),
        ...MedicineRefundProviders.providers(isDev: isDev),
        ...DosageFormProviders.providers(isDev: isDev),
        ...MedicineWithdrawProviders.providers(isDev: isDev),
        ...ActiveIngredientProviders.providers(isDev: isDev),
        ...DrugClassProviders.providers(isDev: isDev),
        ...DrugTypeProviders.providers(isDev: isDev),
        ...KitProviders.providers(isDev: isDev),
        ...KitContentProviders.providers(isDev: isDev),
        ...UnitProviders.providers(isDev: isDev),
        ...MaterialTypeProviders.providers(isDev: isDev),
        ...WarningProviders.providers(isDev: isDev),
        ...AuthenticationProviders.providers(isDev: isDev),
        ...CabinTemperatureProviders.providers(isDev: isDev),
        ...FillingListProviders.providers(isDev: isDev),
        ...InconsistencyProviders.providers(isDev: isDev),
        ...MailPreferenceProviders.providers(isDev: isDev),
        ...DirectedOrderProviders.providers(isDev: true),

        ChangeNotifierProvider(
          create: (context) =>
              HomeNotifier(getFilteredMenusUseCase: context.read(), authStorageNotifier: context.read()),
        ),
      ],
      child: MyApp(),
    ),
  );
}
