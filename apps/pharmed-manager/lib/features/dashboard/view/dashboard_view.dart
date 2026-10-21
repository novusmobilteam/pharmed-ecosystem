import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../../auth/notifier/auth_state.dart';
import '../dashboard.dart';

// [SWREQ-MGR-DASH-001]
// Manager anasayfa dashboard — kabin bazlı özet.
// Sınıf: Class A

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthNotifier>().state is AuthLoggedIn;

    return ChangeNotifierProvider(
      create: (BuildContext context) => DashboardNotifier(
        getCabins: context.read(),
        getMissingStocks: context.read(),
        approveMissingStock: context.read(),
        rejectMissingStock: context.read(),
        getUnappliedPrescriptions: context.read(),
        getUpcomingTreatments: context.read(),
        getDrugActivities: context.read(),
        getExpiredStocks: context.read(),
      )..init(),
      child: Consumer<DashboardNotifier>(
        builder: (context, notifier, _) {
          // İlk yükleme — hiç kabin yok + yükleniyor
          if (notifier.isInitialLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          // Tam ekran hata — gösterecek kabin yok
          if (notifier.showFullScreenError) {
            return _FullScreenError(
              message: notifier.cabinsError ?? context.l10n.dashboard_cabinsLoadErrorFallback,
              onRetry: () => context.read<DashboardNotifier>().fetchCabins(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCabinSelector(
                cabins: notifier.cabins,
                selectedId: notifier.selectedCabinId,
                onSelect: (id) => context.read<DashboardNotifier>().selectCabin(id),
                lastUpdatedLabel: notifier.cabinsStale ? context.l10n.dashboard_cabinListStaleLabel : context.read(),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Row(
                  spacing: 16.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: notifier.isMobileSelected
                          ? MissingStockPanel(isLoggedIn: isLoggedIn)
                          : ExpiredStockPanel(
                              section: notifier.expiredStocks,
                              onRetry: () => context.read<DashboardNotifier>().retryExpiredStocks(),
                            ),
                    ),

                    Expanded(
                      child: DrugActivityPanel(
                        section: notifier.drugActivities,
                        onRetry: () => context.read<DashboardNotifier>().retryDrugActivities(),
                      ),
                    ),
                    Expanded(child: UnappliedPrescriptionPanel(section: notifier.unappliedPrescriptions)),
                    // TODO : Düzelt
                    //Expanded(child: UpcomingTreatmentPanel(section: notifier.upcomingTreatments)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FullScreenError extends StatelessWidget {
  const _FullScreenError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 40, color: MedColors.text3),
          const SizedBox(height: 12),
          Text(
            message,
            style: MedTextStyles.bodyMd(color: MedColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            child: MedButton(
              label: context.l10n.common_retryButton,
              prefixIcon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class DrugActivityPanel extends StatelessWidget {
  const DrugActivityPanel({super.key, required this.section, this.onRetry});

  final DashboardSection<List<PrescriptionItemMovement>> section;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItemMovement>[];

    return MedDashboardPanel<List<PrescriptionItemMovement>>(
      title: context.l10n.dashboardDrugActivityPanelTitle,
      section: section,
      itemCount: items.length,
      onRetry: onRetry,
      itemBuilder: (context, index) => MedDrugActivityCard(movement: items[index]),
    );
  }
}

class MissingStockPanel extends StatelessWidget {
  const MissingStockPanel({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DashboardNotifier>();
    final section = notifier.shortage;
    final items = section.data ?? const <PrescriptionItem>[];

    return MedDashboardPanel<List<PrescriptionItem>>(
      title: context.l10n.dashboard_missingStockPanelTitle,
      section: section,
      itemCount: items.length,
      onRetry: () => context.read<DashboardNotifier>().retryShortage(),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item.id;
        return MedDashboardRxCard(
          item: item,
          showFlags: true,
          showStatusChip: true,
          tone: MedTone.error,
          infoLines: [
            DashboardRxInfoLine(
              context.l10n.assignment_patientLabel,
              item.prescription?.hospitalization?.patient?.fullName ?? '-',
            ),
            DashboardRxInfoLine(context.l10n.assignment_serviceLabel, item.physicalService?.name ?? '-'),
            DashboardRxInfoLine(context.l10n.movement_performedBy, item.activityUser?.fullName ?? '-'),
            DashboardRxInfoLine(
              context.l10n.dashboard_missingStockTimeLabel,
              item.activityDate?.formattedDateTime ?? '-',
            ),
          ],
          actionButtons: (isLoggedIn && item.status == PrescriptionMovementType.shortageReported)
              ? [
                  MedButton(
                    label: context.l10n.dashboard_missingStockApproveButton,
                    size: MedButtonSize.sm,
                    variant: MedButtonVariant.success,
                    fullWidth: true,
                    isLoading: id != null && notifier.isProcessing(id),
                    onPressed: (id == null || notifier.isProcessing(id))
                        ? null
                        : () => context.read<DashboardNotifier>().approveMissingStock(id),
                  ),
                  MedButton(
                    label: context.l10n.dashboard_missingStockRejectButton,
                    size: MedButtonSize.sm,
                    variant: MedButtonVariant.danger,
                    fullWidth: true,
                    onPressed: (id == null || notifier.isProcessing(id))
                        ? null
                        : () => context.read<DashboardNotifier>().rejectMissingStock(id),
                  ),
                ]
              : [],
        );
      },
    );
  }
}

// [SWREQ-MGR-DASH-010]
// Master kabin seçiliyken sol panel — SKT geçmiş malzemeler.
// Sınıf: Class B (SKT bilgisini temsil eder)
class ExpiredStockPanel extends StatelessWidget {
  const ExpiredStockPanel({super.key, required this.section, this.onRetry});

  final DashboardSection<List<CabinStock>> section;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <CabinStock>[];

    return MedDashboardPanel<List<CabinStock>>(
      key: const ValueKey('expired_stock_panel'),
      title: context.l10n.dashboard_expiredStockPanelTitle,
      section: section,
      itemCount: items.length,
      onRetry: onRetry,
      itemBuilder: (context, index) => _ExpiredStockCard(stock: items[index]),
    );
  }
}

class _ExpiredStockCard extends StatelessWidget {
  const _ExpiredStockCard({required this.stock});

  final CabinStock stock;

  @override
  Widget build(BuildContext context) {
    final unit = stock.medicine?.pieceUnitLabel ?? '';
    final location = [
      stock.assignment?.cabin?.name,
      [stock.shelfNo, stock.corpartmentNo].whereType<Object>().join('/'),
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.medicine?.name ?? '-',
                      style: MedTextStyles.titleSm(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stock.medicine?.barcode != null) ...[
                      const SizedBox(height: 2),
                      Text(stock.medicine!.barcode!, style: MedTextStyles.monoXs(color: MedColors.text3)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MedRemainingDayChip(days: stock.remainingDay ?? 0),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: MedColors.border2),
          const SizedBox(height: 12),
          MedInfoRow(
            label: context.l10n.dashboard_expiredStockLocationLabel,
            value: location.isEmpty ? '-' : location,
          ),
          const SizedBox(height: 6),
          MedInfoRow(
            label: context.l10n.dashboard_expiredStockQuantityLabel,
            value: '${stock.quantity.formatFractional} $unit'.trim(),
          ),
          const SizedBox(height: 6),
          MedInfoRow(
            label: context.l10n.dashboard_expiredStockExpiryDateLabel,
            value: stock.miadDate?.formattedDate ?? '-',
          ),
        ],
      ),
    );
  }
}

class UnappliedPrescriptionPanel extends StatelessWidget {
  const UnappliedPrescriptionPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItem>> section;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItem>[];

    return MedDashboardPanel<List<PrescriptionItem>>(
      key: const ValueKey('unapplied_panel'),
      title: context.l10n.dashboard_unappliedPrescriptionsPanelTitle,
      section: section,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MedDashboardRxCard(
          item: item,
          showFlags: true,
          showStatusChip: false,
          showTimeChip: true,
          tone: MedTone.warning,
          infoLines: [
            DashboardRxInfoLine(
              context.l10n.assignment_patientLabel,
              item.prescription?.hospitalization?.patient?.fullName ?? '-',
            ),
            DashboardRxInfoLine(context.l10n.dashboard_doctorLabel, item.doctor?.fullName ?? '-'),
            DashboardRxInfoLine(
              context.l10n.assignment_serviceLabel,
              item.prescription?.hospitalization?.physicalService?.name ?? '-',
            ), // TODO(l10n): no all-caps ARB key exists for this label yet; see migration report
            DashboardRxInfoLine(
              context.l10n.dashboard_roomBedLabel,
              [
                item.prescription?.hospitalization?.room?.name,
                item.prescription?.hospitalization?.bed?.name,
              ].whereType<String>().join(' / '),
            ),
          ],
        );
      },
    );
  }
}

// class UpcomingTreatmentPanel extends StatelessWidget {
//   const UpcomingTreatmentPanel({super.key, required this.section});

//   final DashboardSection<List<UpcomingTreatment>> section;

//   @override
//   Widget build(BuildContext context) {
//     final items = section.data ?? const <PrescriptionItem>[];

//     return MedDashboardPanel(
//       key: const ValueKey('upcoming_panel'),
//       title: context.l10n.dashboardUpcomingTreatmentsPanelTitle,
//       section: section,
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return MedDashboardRxCard(
//           item: item,
//           showFlags: true,
//           showStatusChip: true,
//           showTimeChip: true,
//           tone: MedTone.neutral,
//           infoLines: [
//             DashboardRxInfoLine(
//               context.l10n.assignment_patientLabel,
//               item.prescription?.hospitalization?.patient?.fullName ?? '-',
//             ),
//             DashboardRxInfoLine(
//               context.l10n.assignment_serviceLabel,
//               item.prescription?.hospitalization?.physicalService?.name ?? '-',
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
