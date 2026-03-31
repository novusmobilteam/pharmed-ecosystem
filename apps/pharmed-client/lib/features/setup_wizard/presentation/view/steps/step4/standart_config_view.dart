part of 'step4_drawer_config.dart';

class _StandardScanBody extends StatelessWidget {
  const _StandardScanBody({
    required this.scanState,
    required this.onScan,
    required this.onReset,
    required this.scanLogs,
    required this.scannedLayout,
  });

  final DrawerScanState scanState;
  final VoidCallback onScan;
  final VoidCallback onReset;
  final List<ScanLogEntry> scanLogs;
  final List<DrawerGroup> scannedLayout;

  @override
  Widget build(BuildContext context) {
    //return _ScanInProgress(logs: scanLogs);
    return switch (scanState) {
      DrawerScanState.idle => _ScanIdle(onScan: onScan),
      DrawerScanState.scanning => _ScanInProgress(logs: scanLogs),
      DrawerScanState.found => _ScanFound(logs: scanLogs, scannedLayout: scannedLayout, onReset: onReset),
      DrawerScanState.error => _ScanError(logs: scanLogs, onRetry: onScan),
    };
  }
}

class _ScanIdle extends StatelessWidget {
  const _ScanIdle({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MedColors.blueLight,
                shape: BoxShape.circle,
                border: Border.all(color: MedColors.blue.withOpacity(0.2), width: 2),
              ),
              child: Icon(Icons.settings_input_component_rounded, size: 36, color: MedColors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Cihazı Tara',
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: MedColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seri port üzerinden bağlı kabinin çekmece yapısı otomatik okunacaktır.',
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            MedButton(
              label: 'Taramayı Başlat',
              size: MedButtonSize.lg,
              prefixIcon: const Icon(Icons.radar_rounded, size: 18),
              onPressed: onScan,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanInProgress extends StatelessWidget {
  const _ScanInProgress({required this.logs});
  final List<ScanLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    final headerMessage = logs.isNotEmpty ? (logs.last.headerMessage ?? 'Kabin Taranıyor..') : 'Kabin Taranıyor..';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Başlık
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MedColors.blueLight,
              border: Border.all(color: MedColors.blue),
            ),
            child: Icon(Icons.computer_outlined, color: MedColors.blue),
          ),
          const SizedBox(height: 10),
          Text(
            headerMessage,
            style: TextStyle(
              fontFamily: MedFonts.title,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MedColors.text,
            ),
          ),
          const SizedBox(height: 20),
          _ScanLogList(logs: logs),
        ],
      ),
    );
  }
}

class _ScanFound extends StatelessWidget {
  const _ScanFound({required this.logs, required this.scannedLayout, required this.onReset});

  final List<ScanLogEntry> logs;
  final List<DrawerGroup> scannedLayout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başarı banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MedColors.greenLight,
              border: Border.all(color: MedColors.green.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 20, color: MedColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarama Başarılı — ${scannedLayout.length} çekmece bulundu',
                        style: TextStyle(
                          fontFamily: MedFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MedColors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kabin iç dizaynı cihazdan başarıyla okundu. Aşağıdaki yapıyı onaylayın.',
                        style: TextStyle(
                          fontFamily: MedFonts.sans,
                          fontSize: 11,
                          color: MedColors.green.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Çekmece listesi
          for (int i = 0; i < scannedLayout.length; i++) _ScannedDrawerRow(index: i, group: scannedLayout[i]),

          const SizedBox(height: 20),

          // Alt aksiyonlar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Yapı yanlışsa geri dönüp bağlantı bilgilerini kontrol edin.',
                    style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
                  ),
                ),
                const SizedBox(width: 12),
                MedButton(
                  label: 'Yeniden Tara',
                  variant: MedButtonVariant.ghost,
                  size: MedButtonSize.sm,
                  prefixIcon: const Icon(Icons.refresh_rounded, size: 15),
                  onPressed: onReset,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannedDrawerRow extends StatelessWidget {
  const _ScannedDrawerRow({required this.index, required this.group});
  final int index;
  final DrawerGroup group;

  @override
  Widget build(BuildContext context) {
    final typeName = group.slot.drawerConfig?.drawerType?.name ?? '—';
    final compartmentCount = group.slot.drawerConfig?.drawerType?.compartmentCount ?? 0;
    final isKubik = group.slot.drawerConfig?.drawerType?.isKubik ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'ÇEKMECE ${index + 1}',
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: MedColors.text3,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isKubik ? Icons.grid_view_rounded : Icons.view_agenda_rounded, size: 13, color: MedColors.text3),
                const SizedBox(width: 5),
                Text(
                  typeName,
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: MedColors.text2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (compartmentCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(6)),
              child: Text(
                isKubik ? '$compartmentCount göz' : '${group.units.length} sıra',
                style: TextStyle(
                  fontFamily: MedFonts.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: MedColors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.logs, required this.onRetry});
  final List<ScanLogEntry> logs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hata banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MedColors.redLight,
              border: Border.all(color: MedColors.red.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 20, color: MedColors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tarama başarısız. COM port bağlantısını kontrol edip tekrar deneyin.',
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MedColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log listesi (hataya kadar olan adımlar)
          if (logs.isNotEmpty) _ScanLogList(logs: logs),

          const SizedBox(height: 20),
          MedButton(
            label: 'Tekrar Dene',
            variant: MedButtonVariant.secondary,
            prefixIcon: const Icon(Icons.refresh_rounded, size: 16),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

// ── Log listesi (ortak) ───────────────────────────────────────────

class _ScanLogList extends StatelessWidget {
  const _ScanLogList({required this.logs});
  final List<ScanLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [for (final log in logs) _ScanLogRow(entry: log)]),
    );
  }
}

class _ScanLogRow extends StatelessWidget {
  const _ScanLogRow({required this.entry});
  final ScanLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          SizedBox(
            width: 20,
            height: 20,
            child: switch (entry.status) {
              ScanLogStatus.pending => SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.8, valueColor: AlwaysStoppedAnimation(MedColors.blue)),
              ),
              ScanLogStatus.ok => Icon(Icons.check_circle_rounded, size: 16, color: MedColors.green),
              ScanLogStatus.error => Icon(Icons.cancel_rounded, size: 16, color: MedColors.red),
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: entry.status == ScanLogStatus.error ? MedColors.red : MedColors.text2,
                  ),
                ),
                if (entry.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.detail!,
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 10,
                      color: entry.status == ScanLogStatus.error ? MedColors.red.withOpacity(0.7) : MedColors.text3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
