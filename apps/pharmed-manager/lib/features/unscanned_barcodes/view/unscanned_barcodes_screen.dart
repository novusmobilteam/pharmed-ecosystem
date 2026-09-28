import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/unscanned_barcodes_notifier.dart';

part 'delete_description_view.dart';
part 'table_view.dart';

class UnscannedBarcodesScreen extends StatelessWidget {
  const UnscannedBarcodesScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnscannedBarcodesNotifier(
        deleteUnscannedBarcodeUseCase: context.read(),
        getUnscannedBarcodesUseCase: context.read(),
        scanQrCodeUseCase: context.read(),
        toggleBarcodeWarningUseCase: context.read(),
        getScannedBarcodesUseCase: context.read(),
        getDeletedBarcodesUseCase: context.read(),
        getStationsUseCase: context.read(),
      )..getStations(),
      child: Consumer<UnscannedBarcodesNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              actions: [
                if (notifier.canOpenWarning)
                  MedButton(
                    label: 'Uyarı Aç/Kapa',
                    onPressed: () => notifier.toggleWarning(
                      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      onSuccess: (msg) =>
                          MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
                    ),
                  ),
                // IconButton(
                //   onPressed: notifier.toggleWarning,
                //   tooltip: 'Uyarı Aç/Kapa',
                //   icon: Icon(PhosphorIcons.warning()),
                // ),
              ],

              child: _TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}
