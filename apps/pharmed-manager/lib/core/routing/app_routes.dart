enum AppRoute {
  home,
  platformSelection,
  cabinSetup,

  managerDashboard,
  clientDashboard,

  /// Tanımlamalar
  activeIngredient,
  station,
  branch,
  medicine,
  drugType,
  drugClass,
  unit,
  firm,
  kit,
  warning,
  materialType,
  heatControl,

  /// Kullanıcı İşlemleri
  role,
  user,
  changePassword,
  authorization,
  mailPreference,

  /// Hastane Veri İşlemleri
  hospitalization,
  prescription,
  unReadQrCode,
  refundPharmacy,

  /// Kat Stokları
  stationStock,
  unappliedPrescriptions,
  refundDrawer,
  inconsistency,
  refill,
  stationCabinStock,

  /// Eczane
  stockTransactions,
  cabinDesign,
  cabinLoading,
  inventory,
  medicineCount,

  /// Tedavi
  disposal,
  directedOrders,
  expiringStocks,
  jobList,
  patientMedicineReceipt,

  // return
  ret,
  stationInventory,
  unscannedBarcodes,
  withdraw,
  medicineActivity,

  /// Reports
  expiredStocks,
  cabinTransactionReport,
}

extension PathExtension on AppRoute {
  String get path {
    return '/$name';
  }
}
