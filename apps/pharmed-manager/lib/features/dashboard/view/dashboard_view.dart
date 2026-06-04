import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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
              message: notifier.cabinsError ?? 'Kabinler yüklenemedi',
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
                lastUpdatedLabel: notifier.cabinsStale ? 'Kabin listesi güncel değil' : context.read(),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Row(
                  spacing: 16.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: notifier.isMobileSelected
                          ? MissingStockPanel(isLoggedIn: isLoggedIn)
                          : OtherCabinPlaceholder(),
                    ),

                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Expanded(child: UnappliedPrescriptionPanel(section: notifier.unappliedPrescriptions)),
                          const SizedBox(height: 12),
                          Expanded(child: UpcomingTreatmentPanel(section: notifier.upcomingTreatments)),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 4,
                      child: DrugActivityPanel(
                        section: notifier.drugActivities,
                        onRetry: () => context.read<DashboardNotifier>().retryDrugActivities(),
                      ),
                    ),
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
              label: 'Tekrar Dene',
              prefixIcon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
