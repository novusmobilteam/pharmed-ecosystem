import 'package:flutter/material.dart';
import '../../filling_list/presentation/view/filling_list_view.dart';
import '../../urgent_patient/presentation/view/urgent_patient_view.dart';
import '../../medicine_refill/presentation/view/medicine_refill_view.dart';

import '../../../core/core.dart';
import '../../cabin_assignment/presentation/view/cabin_assignment_dialog.dart';
import '../../cabin_design/view/cabin_design_view.dart';
import '../../cabin_fault/presentation/view/cabin_fault_view.dart';
import '../../cabin_stock/presentation/view/cabin_stock_dialog.dart';
import '../../medicine_count/view/medicine_count_view.dart';
import '../../medicine_disposal/presentation/view/medicine_disposal_view.dart';
import '../../medicine_unload/presentation/view/medicine_unload_view.dart';
import '../../my_patients/view/my_patients_view.dart';
import '../../patient_order_review/presentation/view/patient_order_review_view.dart';
import '../../stock_operations/stock_operations_view.dart';
import '../../change_password/widgets/change_password_view.dart';
import '../../medicine_management/presentation/view/medicine_management_view.dart';
import '../data/model/menu_dto.dart';
import '../domain/entity/menu_item.dart';

class MenuLocalMeta {
  final AppRoute? route;
  final Widget Function(BuildContext context)? dialogBuilder;
  final Color? color;
  const MenuLocalMeta({this.route, this.dialogBuilder, this.color});
}

final Map<String, MenuLocalMeta> kMenuMetaBySlug = {
  // Kat Stokları
  'stationStock': MenuLocalMeta(route: AppRoute.stationStock),
  'unappliedPrescriptions': MenuLocalMeta(route: AppRoute.unappliedPrescriptions),
  'refundDrawer': MenuLocalMeta(route: AppRoute.refundDrawer),
  'inconsistency': MenuLocalMeta(route: AppRoute.inconsistency),
  'refill': MenuLocalMeta(route: AppRoute.refill),
  'tray': MenuLocalMeta(route: AppRoute.stationCabinStock),

  // Hastane Veri İşlemleri
  'patientRegistration': MenuLocalMeta(route: AppRoute.hospitalization),
  'refund': MenuLocalMeta(route: AppRoute.refundPharmacy),
  'prescription': MenuLocalMeta(route: AppRoute.prescription),
  'unReadQrCode': MenuLocalMeta(route: AppRoute.unReadQrCode),
  '-emergency-patient-end-manager': MenuLocalMeta(dialogBuilder: (context) => UrgentPatientView()),

  // Kullanıcı İşlemleri
  'role': MenuLocalMeta(route: AppRoute.role),
  'user': MenuLocalMeta(route: AppRoute.user),
  'changePassword': MenuLocalMeta(
    dialogBuilder: (context) => ChangePasswordView(),
  ),
  'authorization': MenuLocalMeta(route: AppRoute.authorization),

  // Transfer
  'mailPreference': MenuLocalMeta(route: AppRoute.mailPreference),

  // Tanımlamalar
  'drugType': MenuLocalMeta(route: AppRoute.drugType),
  'branch': MenuLocalMeta(route: AppRoute.branch),
  'drugClass': MenuLocalMeta(route: AppRoute.drugClass),
  'activeIngredient': MenuLocalMeta(route: AppRoute.activeIngredient),
  'unit': MenuLocalMeta(route: AppRoute.unit),
  'materialType': MenuLocalMeta(route: AppRoute.materialType),
  'drug': MenuLocalMeta(route: AppRoute.medicine),
  'firm': MenuLocalMeta(route: AppRoute.firm),
  'warning': MenuLocalMeta(route: AppRoute.warning),
  'kit': MenuLocalMeta(route: AppRoute.kit),
  'heatControl': MenuLocalMeta(route: AppRoute.heatControl),
  'station': MenuLocalMeta(route: AppRoute.station),

  // Eczane
  'stock_transaction': MenuLocalMeta(route: AppRoute.stockTransactions),
  'cabin_design': MenuLocalMeta(dialogBuilder: (context) => CabinDesignView()),
  'cabinDrawerStock': MenuLocalMeta(dialogBuilder: (context) => CabinAssignmentDialog()),
  'cabin_loading': MenuLocalMeta(dialogBuilder: (context) => MedicineRefillView()),
  'inventory': MenuLocalMeta(route: AppRoute.inventory),
  'material-refill': MenuLocalMeta(dialogBuilder: (context) => FillingListView()),
  'census-quantity': MenuLocalMeta(dialogBuilder: (context) => MedicineCountView()),
  'stock_operations': MenuLocalMeta(dialogBuilder: (context) => StockOperationsView()),
  'cabin-stock': MenuLocalMeta(dialogBuilder: (context) => CabinStockDialog()),
  'medicine-unload': MenuLocalMeta(dialogBuilder: (context) => MedicineUnloadView()),

  // Tedavi
  'destruction': MenuLocalMeta(dialogBuilder: (context) => MedicineDisposalView()),
  'directed-orders': MenuLocalMeta(route: AppRoute.directedOrders),
  'medicine-management': MenuLocalMeta(dialogBuilder: (context) => MedicineManagementView()),
  'drawer-malfunction': MenuLocalMeta(dialogBuilder: (context) => CabinFaultView()),
  'emergency-patient-end': MenuLocalMeta(dialogBuilder: (context) => UrgentPatientView()),
  'expiring-materials': MenuLocalMeta(route: AppRoute.expiringStocks),
  'job-list': MenuLocalMeta(route: AppRoute.jobList),
  'my-patients': MenuLocalMeta(dialogBuilder: (context) => MyPatientsView()),
  'patient-medicine-receipt': MenuLocalMeta(route: AppRoute.patientMedicineReceipt),
  'patient-request-review': MenuLocalMeta(dialogBuilder: (context) => PatientOrderReviewView()),
  'return': MenuLocalMeta(route: AppRoute.ret),
  'station-inventory': MenuLocalMeta(route: AppRoute.stationInventory),
  'unscanned-barcodes': MenuLocalMeta(route: AppRoute.unscannedBarcodes),
  'medicine-activity': MenuLocalMeta(route: AppRoute.medicineActivity),

  // Raporlar
  'expiring-materials-report': MenuLocalMeta(route: AppRoute.expiredStocks),
  'cabin-transaction-report': MenuLocalMeta(route: AppRoute.cabinTransactionReport)
};

class MenuTreeMapper {
  final Map<String, MenuLocalMeta> _metaBySlug;

  MenuTreeMapper() : _metaBySlug = kMenuMetaBySlug;

  MenuItem mapDtoToMenuItem(
    MenuDTO dto, {
    Map<String, Widget Function(BuildContext context)>? builderOverrides,
  }) {
    final slug = dto.slug;
    final meta = (slug != null && slug.isNotEmpty) ? _metaBySlug[slug] : null;

    // Route belirleme
    final String? routeName = meta?.route?.name ?? _routeNameIfValid(slug);

    // Builder (Dialog) belirleme
    Widget Function(BuildContext)? selectedBuilder;
    if (slug != null && builderOverrides != null && builderOverrides.containsKey(slug)) {
      selectedBuilder = builderOverrides[slug];
    } else {
      selectedBuilder = meta?.dialogBuilder;
    }

    String formattedLabel = dto.appName?.replaceAll('/n', '\n') ?? '';

    return MenuItem(
      id: dto.id,
      parentId: dto.parentId,
      name: dto.name,
      label: dto.parentId == null ? dto.name : formattedLabel.trim(),
      slug: slug,
      icon: iconDataFromUnicode(dto.unicode),
      route: routeName,
      isManager: dto.isManager,
      builder: selectedBuilder,
      orderNo: dto.orderNo,
      description: dto.description,
      children: const [],
    );
  }

  /// Tüm listeyi tekil MenuItem'lara çevirir.
  List<MenuItem> mapDtosToFlatList(List<MenuDTO> dtos) {
    return dtos.where((d) => d.isActive != false).map((dto) => mapDtoToMenuItem(dto)).toList()
      ..sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
  }

  String? _routeNameIfValid(String? slug) {
    if (slug == null || slug.isEmpty) return null;
    try {
      return AppRoute.values.byName(slug).name;
    } catch (_) {
      return null;
    }
  }
}
