import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_model.dart';
import '../../core/cabin_session.dart';
import '../../core/cabin_type.dart';
import '../../core/client_cache_reader.dart';
import '../../core/providers.dart';
import '../../widgets/common.dart';

/// Kabin keşfi: bu bilgisayardaki client tanımıyla devam etme ya da hattı ve
/// kartları tek seferde tarama. Sonuç adres → kabin → çekmece/kapak
/// hiyerarşisinde, anlamlı adlarla gösterilir.
class CabinPage extends ConsumerStatefulWidget {
  const CabinPage({super.key});

  @override
  ConsumerState<CabinPage> createState() => _CabinPageState();
}

class _CabinPageState extends ConsumerState<CabinPage> {
  bool _scanning = false;
  String? _progress;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cabinSessionProvider.notifier).loadClientCache());
  }

  Future<void> _scan() async {
    final type = ref.read(sessionProvider).cabinType;
    setState(() {
      _scanning = true;
      _progress = 'Tarama başlıyor…';
    });
    try {
      await ref
          .read(cabinSessionProvider.notifier)
          .scan(
            patientBased: type == HwCabinType.patientBased,
            onProgress: (m) {
              if (mounted) setState(() => _progress = m);
            },
          );
    } catch (e) {
      if (mounted) showMessage(context, 'Tarama tamamlanamadı: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _scanning = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cabin = ref.watch(cabinSessionProvider);
    final session = ref.watch(sessionProvider);
    final connected = session.port != null;
    final active = cabin.active;

    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: [
        if (!cabin.cacheChecked)
          const SectionCard(
            title: 'Kabin',
            child: Row(
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: MedSpacing.lg),
                Text('Bu bilgisayardaki kabin tanımı aranıyor…'),
              ],
            ),
          )
        else if (active == null)
          _StartCard(
            cache: cabin.cache,
            cabinType: session.cabinType,
            connected: connected,
            scanning: _scanning,
            progress: _progress,
            onUseCache: () => ref.read(cabinSessionProvider.notifier).useClientDefinition(),
            onScan: _scan,
          )
        else ...[
          _ActiveHeader(
            snapshot: active,
            hasCache: cabin.hasCache,
            connected: connected,
            scanning: _scanning,
            progress: _progress,
            onScan: _scan,
            onUseCache: active.source == CabinSource.scan && cabin.hasCache
                ? () => ref.read(cabinSessionProvider.notifier).useClientDefinition()
                : null,
          ),
          if (cabin.scan != null && cabin.hasCache) _DifferencesCard(differences: cabin.differences),
          if (cabin.scan?.definitionsMissing ?? false)
            const Padding(
              padding: EdgeInsets.only(bottom: MedSpacing.lg),
              child: ErrorText('Çekmece tanımları servisten alınamadı; çekmeceler tip numarasıyla gösteriliyor.'),
            ),
          if (active.cabins.isEmpty)
            const SectionCard(title: 'Sonuç', child: ErrorText('Hatta cevap veren yönetim kartı bulunamadı.'))
          else
            for (final c in active.cabins) _CabinCard(cabin: c, source: active.source),
        ],
      ],
    );
  }
}

// ── Başlangıç: client tanımı mı, tarama mı ─────────────────────────────

class _StartCard extends StatelessWidget {
  const _StartCard({
    required this.cache,
    required this.cabinType,
    required this.connected,
    required this.scanning,
    required this.progress,
    required this.onUseCache,
    required this.onScan,
  });

  final ClientCacheResult? cache;
  final HwCabinType? cabinType;
  final bool connected;
  final bool scanning;
  final String? progress;
  final VoidCallback onUseCache;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final c = cache;
    if (c == null) {
      return SectionCard(
        title: 'Kabin',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bu bilgisayarda client kabin tanımı bulunamadı. Kabini tarayarak devam edin.'),
            const SizedBox(height: MedSpacing.lg),
            _ScanButton(connected: connected, scanning: scanning, progress: progress, onScan: onScan, primary: true),
          ],
        ),
      );
    }

    final snapshot = c.snapshot;
    final mobileSetup = c.isMobileSetup;
    final mismatch =
        c.deviceMode != null &&
        cabinType != null &&
        (mobileSetup ? cabinType != HwCabinType.patientBased : cabinType != HwCabinType.medicineBased);
    final savedAt = c.savedAt;

    return SectionCard(
      title: 'Tanımlı cihaz var',
      trailing: const StatusBadge(status: TestStatus.info, label: 'Client tanımı'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bu bilgisayarda tanımlı kabin bulundu. Bununla devam etmek ister misiniz?', style: MedTextStyles.bodyLg()),
          const SizedBox(height: MedSpacing.lg),
          _InfoLine('Kabinler', snapshot.cabins.map((x) => x.title).join(', ')),
          _InfoLine('Özet', snapshot.summary),
          if (c.stationName != null || c.stationId != null) _InfoLine('İstasyon', '${c.stationName ?? '-'} (${c.stationId ?? '-'})'),
          if (c.comPort != null) _InfoLine('Client COM portu', c.comPort!),
          if (savedAt != null) _InfoLine('Son kayıt', _formatDateTime(savedAt)),
          if (mismatch) ...[
            const SizedBox(height: MedSpacing.md),
            _Notice(
              status: TestStatus.warning,
              text:
                  'Bu bilgisayardaki client ${mobileSetup ? 'Hasta Bazlı (mobil)' : 'İlaç Bazlı'} olarak kurulu; '
                  'seçtiğiniz kabin tipi ${cabinType!.label}.',
            ),
          ],
          const SizedBox(height: MedSpacing.xl),
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: scanning ? null : onUseCache,
                icon: const Icon(Icons.check),
                label: const Text('Bu tanımla devam et'),
              ),
              _ScanButton(connected: connected, scanning: scanning, progress: progress, onScan: onScan, primary: false),
            ],
          ),
          const SizedBox(height: MedSpacing.md),
          Text(
            'Yeniden tarama client tanımını değiştirmez; sonuçlar yalnızca bu oturumda tutulur.',
            style: hintStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.connected,
    required this.scanning,
    required this.progress,
    required this.onScan,
    required this.primary,
  });

  final bool connected;
  final bool scanning;
  final String? progress;
  final VoidCallback onScan;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final button = primary
        ? BusyButton(label: 'Kabini tara', icon: Icons.radar, busy: scanning, onPressed: connected ? onScan : null)
        : OutlinedButton.icon(
            onPressed: connected && !scanning ? onScan : null,
            icon: scanning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar),
            label: const Text('Yeniden tara'),
          );
    return Wrap(
      spacing: MedSpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        button,
        if (!connected) const NotConnectedHint(),
        if (scanning && progress != null) Text(progress!, style: hintStyle()),
      ],
    );
  }
}

// ── Aktif tanım ────────────────────────────────────────────────────────

class _ActiveHeader extends StatelessWidget {
  const _ActiveHeader({
    required this.snapshot,
    required this.hasCache,
    required this.connected,
    required this.scanning,
    required this.progress,
    required this.onScan,
    required this.onUseCache,
  });

  final CabinSnapshot snapshot;
  final bool hasCache;
  final bool connected;
  final bool scanning;
  final String? progress;
  final VoidCallback onScan;
  final VoidCallback? onUseCache;

  @override
  Widget build(BuildContext context) {
    final fromScan = snapshot.source == CabinSource.scan;
    return SectionCard(
      title: 'Kabin',
      trailing: StatusBadge(
        status: TestStatus.info,
        label: fromScan ? 'Tarama · ${_formatClock(snapshot.time)}' : 'Client tanımı',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(snapshot.cabins.isEmpty ? 'Kabin bulunamadı' : snapshot.summary, style: MedTextStyles.titleSm()),
          const SizedBox(height: MedSpacing.lg),
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ScanButton(connected: connected, scanning: scanning, progress: progress, onScan: onScan, primary: false),
              if (onUseCache != null)
                TextButton.icon(
                  onPressed: scanning ? null : onUseCache,
                  icon: const Icon(Icons.history),
                  label: const Text('Client tanımına dön'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifferencesCard extends StatelessWidget {
  const _DifferencesCard({required this.differences});

  final List<CabinDifference> differences;

  @override
  Widget build(BuildContext context) {
    final ok = differences.isEmpty;
    return SectionCard(
      title: 'Client tanımı ile karşılaştırma',
      trailing: StatusBadge(
        status: ok ? TestStatus.passed : TestStatus.failed,
        label: ok ? 'Uyumlu' : '${differences.length} fark',
      ),
      child: ok
          ? const Text('Taranan kabinler client tanımıyla aynı.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in differences)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MedSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusIcon(status: TestStatus.failed, size: 16),
                        const SizedBox(width: MedSpacing.md),
                        SizedBox(width: 24, child: Text(d.cabinLetter, style: MedTextStyles.titleSm())),
                        Expanded(child: Text(d.message)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CabinCard extends StatelessWidget {
  const _CabinCard({required this.cabin, required this.source});

  final CabinInfo cabin;
  final CabinSource source;

  @override
  Widget build(BuildContext context) {
    final TestStatus status;
    final String label;
    if (cabin.needsLidCount) {
      status = TestStatus.warning;
      label = 'Tanım bekliyor';
    } else if (cabin.hasProblems) {
      status = TestStatus.warning;
      label = 'Kontrol edin';
    } else {
      status = TestStatus.passed;
      label = source == CabinSource.scan ? 'Bulundu' : 'Tanımlı';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: MedSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(MedSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
                  child: Text(cabin.letter, style: MedTextStyles.titleMd(color: MedColors.blue)),
                ),
                const SizedBox(width: MedSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cabin.kind.label, style: MedTextStyles.titleMd()),
                      if (cabin.name != null) Text(cabin.name!, style: hintStyle(fontSize: 12)),
                    ],
                  ),
                ),
                StatusBadge(status: status, label: label),
              ],
            ),
            if (cabin.needsLidCount) ...[
              const SizedBox(height: MedSpacing.lg),
              const _Notice(
                status: TestStatus.warning,
                text:
                    'Serum kabininde kapak sayısı karttan okunamaz. Kapak sayısı ve raf tanımı serum tanım '
                    'ekranında yapılacak (en fazla 4 kapak).',
              ),
            ],
            for (final w in cabin.warnings) ...[
              const SizedBox(height: MedSpacing.md),
              _Notice(status: TestStatus.warning, text: w),
            ],
            if (cabin.kind == CabinKind.mobile && cabin.units.isEmpty) ...[
              const SizedBox(height: MedSpacing.md),
              Text(
                source == CabinSource.scan
                    ? 'Mobil kabin çekmeceleri karttan okunamaz; çekmece testleri port bazlı yapılır.'
                    : 'Tanımda mobil çekmece yok.',
                style: hintStyle(),
              ),
            ],
            if (cabin.units.isNotEmpty) ...[
              const SizedBox(height: MedSpacing.lg),
              const Divider(height: 1),
              for (final u in cabin.units) _UnitRow(unit: u, showRaw: source == CabinSource.scan),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.unit, required this.showRaw});

  final CabinUnit unit;
  final bool showRaw;

  IconData get _icon => switch (unit.kind) {
    UnitKind.kubik => Icons.grid_view,
    UnitKind.unitDose => Icons.view_agenda_outlined,
    UnitKind.serum => Icons.water_drop_outlined,
    UnitKind.mobile => Icons.inbox_outlined,
    UnitKind.unknown => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final details = [
      if (unit.compartmentCount != null && unit.kind != UnitKind.serum) '${unit.compartmentCount} göz',
      if (showRaw && unit.rawResponse != null) 'ham ${unit.rawResponse}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MedSpacing.md),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(unit.locationLabel, style: monoStyle())),
          Icon(_icon, size: 18, color: MedColors.text3),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.name, style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600)),
                if (details.isNotEmpty) Text(details, style: hintStyle(fontSize: 12)),
                if (unit.problem != null) ErrorText(unit.problem!),
              ],
            ),
          ),
          if (unit.problem != null) const StatusIcon(status: TestStatus.warning),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MedSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: hintStyle())),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.status, required this.text});

  final TestStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = status.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border()),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, size: 18, color: colors.foreground),
          const SizedBox(width: MedSpacing.md),
          Expanded(child: Text(text, style: TextStyle(color: MedColors.text))),
        ],
      ),
    );
  }
}

String _two(int v) => v.toString().padLeft(2, '0');

String _formatClock(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

String _formatDateTime(DateTime t) => '${_two(t.day)}.${_two(t.month)}.${t.year} ${_formatClock(t)}';
