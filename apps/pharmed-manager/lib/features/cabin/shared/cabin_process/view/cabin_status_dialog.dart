import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/core.dart';
import '../notifier/cabin_status_notifier.dart';

class CabinStatusDialog extends StatelessWidget {
  const CabinStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Consumer<CabinStatusNotifier>(
        builder: (context, notifier, _) {
          IconData icon = PhosphorIcons.hourglass();
          String title = "Lütfen Bekleyiniz";

          switch (notifier.stage) {
            case DrawerStage.connecting:
              icon = PhosphorIcons.gear();
              title = "Bağlantı kuruluyor";
              break;
            case DrawerStage.unlockingMaster:
              icon = PhosphorIcons.lock();
              title = "Çekmece açılıyor";
              break;
            case DrawerStage.waitingForPull:
              icon = PhosphorIcons.dresser();
              title = "Lütfen çekmeceyi açınız";
              break;
            case DrawerStage.openingLid:
              icon = PhosphorIcons.gridFour();
              title = "Kapak açılıyor";
              break;
            case DrawerStage.error:
              icon = PhosphorIcons.warning();
              title = 'İşlem sırasında bir hatayla karşılaşıldı. İşleminizi sonlandırıyoruz.';
            case DrawerStage.waitingForClose:
              icon = PhosphorIcons.dresser();
              title = "Lütfen çekmeceyi kapatınız";
            default:
              break;
          }

          return Dialog(
            backgroundColor: context.colorScheme.primary.withAlpha(130),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              width: 350,
              height: 350,
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 60,
                    color: context.colorScheme.onPrimary,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  LinearProgressIndicator(
                    color: context.colorScheme.primary,
                    backgroundColor: context.colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
