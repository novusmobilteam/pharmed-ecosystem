import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../service_selection.dart';

/// [SWREQ-CORE-0XX] Madde 72 — aktif istasyon+servis bilgisinin dashboard'da
/// her zaman görünür olması. Madde 75 — aynı kart üzerinden servis değiştirme.
/// "Değiştir" butonu `changeService()` çağırır; bu, `activeServiceNotifierProvider`'ı
/// izleyen `ActiveServiceGate`'i tetikleyip `ServiceSelectionScreen`'e döner —
/// dashboard tarafında ayrı bir navigasyon mantığı gerekmez.
class ActiveStationServiceCard extends ConsumerWidget {
  const ActiveStationServiceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeService = ref.watch(activeServiceNotifierProvider);
    final station = activeService.station;
    final service = activeService.activeService;

    if (station == null || service == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 6.0),
      width: double.infinity,
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.dashboard_activeStationLabel(station.name ?? ''), style: MedTextStyles.monoMd()),
                Text(l10n.dashboard_activeServiceLabel(service.name ?? ''), style: MedTextStyles.monoMd()),
                SizedBox(height: MedSpacing.xs),
                Divider(thickness: 1, color: MedColors.border2),
                if (activeService.availableServices.length > 1)
                  GestureDetector(
                    onTap: () => ref.read(activeServiceNotifierProvider).changeService(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.dashboard_changeServiceButton,
                          style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.bold),
                        ),
                        Icon(PhosphorIcons.arrowRight(), color: MedColors.blue, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
