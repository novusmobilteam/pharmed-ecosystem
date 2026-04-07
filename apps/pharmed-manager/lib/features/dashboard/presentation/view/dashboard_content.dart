part of 'dashboard_screen.dart';

class DashboardContentFactory {
  static Widget buildContent(DashboardUiState state, DashboardNotifier notifier, bool isLoggedIn) {
    // Rota bilgisini güvenli bir şekilde state'den ayıklıyoruz
    final route = switch (state) {
      DashboardLoaded s => s.activeRoute,
      DashboardStale s => s.activeRoute,
      DashboardPartial s => s.activeRoute,
      _ => 'dashboard',
    };

    final cabinData = switch (state) {
      DashboardLoaded s => s.data.cabinVisualizerData,
      DashboardStale s => s.data.cabinVisualizerData,
      _ => null,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (route) {
        // Ana Sayfa (Mevcut _DashboardBody içeriğin buraya taşındı)
        'dashboard' => _buildMainDashboard(state, notifier, isLoggedIn),

        // Diğer Modüller
        'cabinDrawerStock' => Center(child: AssignmentView(data: cabinData)),
        'drawer-malfunction' => Center(child: FaultView(data: cabinData)),

        // Fallback
        _ => const Center(child: Text('Sayfa bulunamadı')),
      },
    );
  }

  static Widget _buildMainDashboard(DashboardUiState state, DashboardNotifier notifier, bool isLoggedIn) {
    return switch (state) {
      DashboardLoading() => const _LoadingView(),
      DashboardLoaded(:final data) => _DashboardBody(data: data, notifier: notifier, isLoggedIn: isLoggedIn),
      DashboardStale(:final data, :final canProceed) => _DashboardBody(
        data: data,
        notifier: notifier,
        isStale: true,
        canProceed: canProceed,
        isLoggedIn: isLoggedIn,
      ),
      DashboardPartial(:final data, :final failedSections) => _DashboardBody(
        data: data,
        notifier: notifier,
        failedSections: failedSections,
        isLoggedIn: isLoggedIn,
      ),
      DashboardError(:final message, :final isRetryable) => _ErrorView(
        message: message,
        isRetryable: isRetryable,
        onRetry: notifier.refresh,
      ),
    };
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.data,
    required this.notifier,
    required this.isLoggedIn,
    this.isStale = false,
    this.canProceed = true,
    this.failedSections = const [],
  });

  final DashboardData data;
  final DashboardNotifier notifier;
  final bool isLoggedIn;
  final bool isStale;
  final bool canProceed;
  final List<DashboardSection> failedSections;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: MedColors.blue,
      onRefresh: notifier.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            failedSections.contains(DashboardSection.kpi)
                ? const _SectionError(label: 'KPI verileri yüklenemedi')
                : KpiView(kpi: data.kpi, isStale: isStale),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol kolon: Kabin
                SizedBox(
                  width: 260,
                  child: data.hasCabinData
                      ? CabinView(
                          cabin: data.cabinVisualizerData!,
                          isStale: isStale,
                          canProceed: canProceed,
                          notifier: notifier,
                        )
                      : const _SectionError(label: 'Kabin verisi yüklenemedi'),
                ),
                const SizedBox(width: 14),

                // Orta kolon: Bekleyen Tedaviler
                Expanded(
                  child: failedSections.contains(DashboardSection.treatments)
                      ? const _SectionError(label: 'Tedavi listesi yüklenemedi')
                      : UpcomingTreatmentsView(
                          treatments: data.upcomingTreatments,
                          isStale: isStale,
                          notifier: notifier,
                        ),
                ),

                const SizedBox(width: 14),

                // Sağ kolon: Uyarılar + SKT + Hızlı + Aktivite
                SizedBox(
                  width: 256,
                  child: failedSections.contains(DashboardSection.skt)
                      ? const _SectionError(label: 'SKT verisi yüklenemedi')
                      : SktView(skt: data.expiringMaterials, isStale: isStale),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: MedColors.blue));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.isRetryable, required this.onRetry});

  final String message;
  final bool isRetryable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: MedColors.redLight, borderRadius: MedRadius.lgAll),
              child: const Icon(Icons.wifi_off_rounded, size: 28, color: MedColors.red),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: MedTextStyles.bodySm(color: MedColors.text2),
              textAlign: TextAlign.center,
            ),
            if (isRetryable) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
                  child: Text('Tekrar Dene', style: MedTextStyles.bodyMd(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
