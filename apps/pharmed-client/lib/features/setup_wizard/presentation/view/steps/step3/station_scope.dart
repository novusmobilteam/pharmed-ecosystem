part of 'step3_station_scope.dart';

class _StationScopeBody extends StatelessWidget {
  const _StationScopeBody({
    required this.stationsLoadState,
    required this.stations,
    required this.stationsError,
    required this.selectedStation,
    required this.onStationSelected,
    required this.onRetry,
  });

  final StationsLoadState stationsLoadState;
  final List<Station> stations;
  final String? stationsError;
  final Station? selectedStation;
  final ValueChanged<Station> onStationSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (stationsLoadState) {
      StationsLoadState.idle || StationsLoadState.loading => const _StationsLoading(),
      StationsLoadState.error => _StationsError(message: stationsError, onRetry: onRetry),
      StationsLoadState.loaded => _StationList(
        stations: stations,
        selectedStation: selectedStation,
        onSelected: onStationSelected,
        onRetry: onRetry,
      ),
    };
  }
}

class _StationsLoading extends StatelessWidget {
  const _StationsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(MedColors.blue), strokeWidth: 2.5),
            SizedBox(height: 14),
            Text(
              'İstasyonlar yükleniyor…',
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationsError extends StatelessWidget {
  const _StationsError({this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: MedColors.redLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.wifi_off_rounded, color: MedColors.red, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'İstasyonlar yüklenemedi.',
              style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            MedButton(
              label: context.l10n.common_retryButton,
              variant: MedButtonVariant.secondary,
              size: MedButtonSize.sm,
              prefixIcon: const Icon(Icons.refresh_rounded, size: 15),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({
    required this.stations,
    required this.selectedStation,
    required this.onSelected,
    required this.onRetry,
  });

  final List<Station> stations;
  final Station? selectedStation;
  final ValueChanged<Station> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            children: [
              Text(
                'Kayıtlı istasyon bulunamadı.',
                style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
              ),
              MedButton(
                label: context.l10n.common_retryButton,
                variant: MedButtonVariant.secondary,
                size: MedButtonSize.sm,
                prefixIcon: Icon(Icons.refresh_rounded, size: 15),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final station in stations)
          _StationTile(
            station: station,
            isSelected: station.id == selectedStation?.id,
            onTap: () => onSelected(station),
          ),
      ],
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({required this.station, required this.isSelected, required this.onTap});

  final Station station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? MedColors.blue : Colors.transparent,
                border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                station.name ?? '—',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? MedColors.blue : MedColors.text,
                ),
              ),
            ),
            if (station.id != null)
              Text(
                '#${station.id}',
                style: TextStyle(
                  fontFamily: MedFonts.mono,
                  fontSize: 11,
                  color: isSelected ? MedColors.blue : MedColors.text4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
