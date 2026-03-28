// lib/core/di/datasource_injector.dart
//
// [SWREQ-CORE-005]
// Flavor'a göre doğru datasource + repository oluşturur.
// Üst katmanlar (domain, UI) flavor'ı bilmez.
// Tüm bağımlılık kurulumu burada.

import '../../features/cabin_stock/data/datasource/cabin_stock_datasource.dart';
import '../../features/cabin_stock/data/datasource/cabin_stock_mock_datasource.dart';
import '../../features/cabin_stock/data/datasource/cabin_stock_remote_datasource.dart';
import '../../features/cabin_stock/data/repository/cabin_stock_repository_impl.dart';
import '../../features/cabin_stock/domain/mapper/cabin_stock_mapper.dart';
import '../../features/setup_wizard/data/datasource/setup_wizard_datasource.dart';
import '../../features/setup_wizard/data/datasource/setup_wizard_mock_datasource.dart';
import '../../features/setup_wizard/data/repository/setup_wizard_repository_impl.dart';
import '../cache/cabin_stock_cache.dart';
import '../flavor/app_flavor.dart';
import '../hardware/serial_communication/i_serial_communication_service.dart';
import '../hardware/serial_communication/mock_serial_communication_service.dart';
import '../hardware/serial_communication/serial_communication_service.dart';

abstract final class DI {
  static ISerialCommunicationService serialCommunicationService() {
    final config = FlavorConfig.instance;

    return switch (config.flavor) {
      AppFlavor.mock => MockSerialCommunicationService(),
      AppFlavor.dev || AppFlavor.prod => SerialCommunicationService(),
    };
  }

  // ── CabinStock ──────────────────────────────────────────────

  // static CabinStockDataSource cabinStockDataSource({
  //   bool forceError = false, // Test: error state görmek için
  // }) {
  //   final config = FlavorConfig.instance;

  //   return switch (config.flavor) {
  //     // mock → sahte veri, forceError ile hata senaryosu
  //     AppFlavor.mock => forceError ? CabinStockMockErrorDataSource() : CabinStockMockDataSource(),

  //     // dev / prod → gerçek servis
  //     AppFlavor.dev || AppFlavor.prod => CabinStockRemoteDataSource(
  //       networkManager: NetworkManager(
  //         baseUrl: config.baseUrl,
  //         connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
  //         receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
  //       ),
  //     ),
  //   };
  // }

  // static CabinStockRepositoryImpl cabinStockRepository({bool forceError = false}) {
  //   return CabinStockRepositoryImpl(
  //     dataSource: cabinStockDataSource(forceError: forceError),
  //     listCache: CabinStockListCache(),
  //     singleCache: CabinStockSingleCache(),
  //     mapper: const CabinStockMapper(),
  //   );
  // }

  // ── SetupWizard ─────────────────────────────────────────────

  static SetupWizardDataSource setupWizardDataSource({bool forceError = false}) {
    final config = FlavorConfig.instance;

    return switch (config.flavor) {
      AppFlavor.mock => forceError ? SetupWizardMockErrorDataSource() : SetupWizardMockDataSource(),
      AppFlavor.dev || AppFlavor.prod =>
        // TODO: SetupWizardRemoteDataSource ile değiştir
        forceError ? SetupWizardMockErrorDataSource() : SetupWizardMockDataSource(),
    };
  }

  static SetupWizardRepositoryImpl setupWizardRepository({bool forceError = false}) {
    return SetupWizardRepositoryImpl(dataSource: setupWizardDataSource(forceError: forceError));
  }
}
