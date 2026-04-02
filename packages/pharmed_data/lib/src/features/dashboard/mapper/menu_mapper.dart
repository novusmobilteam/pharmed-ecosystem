import 'package:pharmed_core/pharmed_core.dart';

/// Rota çözümleme stratejisi için arayüz.
abstract class MenuRouteResolver {
  String? resolve(String? slug);
}

class MenuTreeMapper {
  final MenuRouteResolver? routeResolver;

  // routeResolver opsiyonel; verilmezse sadece slug'ı rota olarak döner.
  MenuTreeMapper({this.routeResolver});

  MenuItem toEntity(MenuDTO dto) {
    final slug = dto.slug;

    // Rota çözümleme işini uygulamaya devrediyoruz
    final String? routeName = routeResolver?.resolve(slug) ?? slug;

    final String formattedLabel = (dto.appName ?? dto.name ?? '').replaceAll('/n', '\n').trim();

    return MenuItem(
      id: dto.id,
      parentId: dto.parentId,
      orderNo: dto.orderNo,
      name: dto.name,
      label: formattedLabel,
      slug: slug,
      unicode: dto.unicode,
      route: routeName,
      isManager: dto.isManager ?? false,
      description: dto.description,
      children: [],
    );
  }

  List<MenuItem> toTreeList(List<MenuDTO> dtos) {
    final activeDtos = dtos.where((d) => d.isActive != false).toList();
    final Map<int, MenuItem> itemMap = {};
    final List<MenuItem> rootItems = [];

    for (var dto in activeDtos) {
      if (dto.id != null) itemMap[dto.id!] = toEntity(dto);
    }

    for (var dto in activeDtos) {
      final currentItem = itemMap[dto.id];
      if (currentItem == null) continue;

      if (dto.parentId == null || dto.parentId == 0) {
        rootItems.add(currentItem);
      } else {
        final parent = itemMap[dto.parentId];
        if (parent != null) {
          parent.children.add(currentItem);
        } else {
          rootItems.add(currentItem);
        }
      }
    }

    _sortMenu(rootItems);
    return rootItems;
  }

  void _sortMenu(List<MenuItem> items) {
    items.sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
    for (var item in items) {
      _sortMenu(item.children);
    }
  }
}



// class AppMenuRouteResolver implements MenuRouteResolver {
//   @override
//   String? resolve(String? slug) {
//     if (slug == null) return null;
    
//     // 1. Önce meta map'ten bak (Eski meta map'ini buraya taşıyabilirsin)
//     final meta = kMenuMetaBySlug[slug];
//     if (meta != null) return meta.route?.name;

//     // 2. Yoksa enum içinde ara (AppRoute bu uygulamaya özeldir)
//     try {
//       return AppRoute.values.byName(slug).name;
//     } catch (_) {
//       return slug; // En kötü ihtimalle slug'ı rota olarak kullan
//     }
//   }
// }

// // Mapper'ı başlatırken:
// final mapper = MenuTreeMapper(routeResolver: AppMenuRouteResolver());


// final Map<String, String> kMenuMetaBySlug = {
//   // Kat Stokları
//   'stationStock': MenuLocalMeta(route: AppRoute.stationStock),
//   'unappliedPrescriptions': MenuLocalMeta(route: AppRoute.unappliedPrescriptions),
//   'refundDrawer': MenuLocalMeta(route: AppRoute.refundDrawer),
//   'inconsistency': MenuLocalMeta(route: AppRoute.inconsistency),
//   'refill': MenuLocalMeta(route: AppRoute.refill),
//   'tray': MenuLocalMeta(route: AppRoute.stationCabinStock),

//   // Hastane Veri İşlemleri
//   'patientRegistration': MenuLocalMeta(route: AppRoute.hospitalization),
//   'refund': MenuLocalMeta(route: AppRoute.refundPharmacy),
//   'prescription': MenuLocalMeta(route: AppRoute.prescription),
//   'unReadQrCode': MenuLocalMeta(route: AppRoute.unReadQrCode),
//   '-emergency-patient-end-manager': MenuLocalMeta(dialogBuilder: (context) => UrgentPatientView()),

//   // Kullanıcı İşlemleri
//   'role': MenuLocalMeta(route: AppRoute.role),
//   'user': MenuLocalMeta(route: AppRoute.user),
//   'changePassword': MenuLocalMeta(
//     dialogBuilder: (context) => ChangePasswordView(),
//   ),
//   'authorization': MenuLocalMeta(route: AppRoute.authorization),

//   // Transfer
//   'mailPreference': MenuLocalMeta(route: AppRoute.mailPreference),

//   // Tanımlamalar
//   'drugType': MenuLocalMeta(route: AppRoute.drugType),
//   'branch': MenuLocalMeta(route: AppRoute.branch),
//   'drugClass': MenuLocalMeta(route: AppRoute.drugClass),
//   'activeIngredient': MenuLocalMeta(route: AppRoute.activeIngredient),
//   'unit': MenuLocalMeta(route: AppRoute.unit),
//   'materialType': MenuLocalMeta(route: AppRoute.materialType),
//   'drug': MenuLocalMeta(route: AppRoute.medicine),
//   'firm': MenuLocalMeta(route: AppRoute.firm),
//   'warning': MenuLocalMeta(route: AppRoute.warning),
//   'kit': MenuLocalMeta(route: AppRoute.kit),
//   'heatControl': MenuLocalMeta(route: AppRoute.heatControl),
//   'station': MenuLocalMeta(route: AppRoute.station),

//   // Eczane
//   'stock_transaction': MenuLocalMeta(route: AppRoute.stockTransactions),
//   'cabin_design': MenuLocalMeta(dialogBuilder: (context) => CabinDesignView()),
//   'cabinDrawerStock': MenuLocalMeta(dialogBuilder: (context) => CabinAssignmentDialog()),
//   'cabin_loading': MenuLocalMeta(dialogBuilder: (context) => MedicineRefillView()),
//   'inventory': MenuLocalMeta(route: AppRoute.inventory),
//   'material-refill': MenuLocalMeta(dialogBuilder: (context) => FillingListView()),
//   'census-quantity': MenuLocalMeta(dialogBuilder: (context) => MedicineCountView()),
//   'stock_operations': MenuLocalMeta(dialogBuilder: (context) => StockOperationsView()),
//   'cabin-stock': MenuLocalMeta(dialogBuilder: (context) => CabinStockDialog()),
//   'medicine-unload': MenuLocalMeta(dialogBuilder: (context) => MedicineUnloadView()),

//   // Tedavi
//   'destruction': MenuLocalMeta(dialogBuilder: (context) => MedicineDisposalView()),
//   'directed-orders': MenuLocalMeta(route: AppRoute.directedOrders),
//   'medicine-management': MenuLocalMeta(dialogBuilder: (context) => MedicineManagementView()),
//   'drawer-malfunction': MenuLocalMeta(dialogBuilder: (context) => CabinFaultView()),
//   'emergency-patient-end': MenuLocalMeta(dialogBuilder: (context) => UrgentPatientView()),
//   'expiring-materials': MenuLocalMeta(route: AppRoute.expiringStocks),
//   'job-list': MenuLocalMeta(route: AppRoute.jobList),
//   'my-patients': MenuLocalMeta(dialogBuilder: (context) => MyPatientsView()),
//   'patient-medicine-receipt': MenuLocalMeta(route: AppRoute.patientMedicineReceipt),
//   'patient-request-review': MenuLocalMeta(dialogBuilder: (context) => PatientOrderReviewView()),
//   'return': MenuLocalMeta(route: AppRoute.ret),
//   'station-inventory': MenuLocalMeta(route: AppRoute.stationInventory),
//   'unscanned-barcodes': MenuLocalMeta(route: AppRoute.unscannedBarcodes),
//   'medicine-activity': MenuLocalMeta(route: AppRoute.medicineActivity),

//   // Raporlar
//   'expiring-materials-report': MenuLocalMeta(route: AppRoute.expiredStocks),
//   'cabin-transaction-report': MenuLocalMeta(route: AppRoute.cabinTransactionReport)
// };