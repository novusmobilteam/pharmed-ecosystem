// pharmed-client/lib/features/fingerprint_test/view/fingerprint_test_screen.dart
//
// [SWREQ-FP-041]
// Parmak izi okuyucu test ekranı — Ayarlar › Debug › "Parmak izi okuyucu".
//
// Düzen:
//   [Sol 340]  Okuyucu durumu + okuma ayarları
//   [Orta]     Son okuma: görüntü, kalite, canlılık, süre + eylemler + gönderim simülasyonu
//   [Sağ 360]  İstatistikler + deneme geçmişi
//
// Not: Debug ayarları gibi geliştirici aracıdır; metinler ARB'ye taşınmadı.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/core/hardware/fingerprint/fingerprint.dart';
import 'package:pharmed_client/features/auth/auth.dart';

import '../notifier/fingerprint_test_notifier.dart';
import 'fingerprint_image_view.dart';

class FingerprintTestScreen extends ConsumerWidget {
  const FingerprintTestScreen({super.key});

  static Future<void> show(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FingerprintTestScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(fingerprintTestNotifierProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(authNotifierProvider.notifier).onUserActivity(),
      child: Scaffold(
        backgroundColor: MedColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(n: n),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 340,
                        child: ListView(
                          children: [
                            _ScannerCard(n: n),
                            const SizedBox(height: MedSpacing.xl),
                            _SettingsCard(n: n),
                          ],
                        ),
                      ),
                      const SizedBox(width: MedSpacing.xl),
                      Expanded(child: _CaptureCard(n: n)),
                      const SizedBox(width: MedSpacing.xl),
                      SizedBox(width: 360, child: _HistoryCard(n: n)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Üst bar
// ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final (label, style) = switch (n) {
      _ when n.isOpening => ('Açılıyor…', MedChipStyle.info),
      _ when n.isOpen => ('${n.scannerInfo?.model ?? 'Okuyucu'} hazır', MedChipStyle.success),
      _ when n.openFailure != null => ('Okuyucu hatası', MedChipStyle.danger),
      _ => ('Okuyucu kapalı', MedChipStyle.neutral),
    };

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: MedSpacing.touchTarget,
            height: MedSpacing.touchTarget,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: MedColors.text2),
              tooltip: 'Geri',
            ),
          ),
          const SizedBox(width: MedSpacing.md),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.fingerprint, color: Colors.white, size: 22),
          ),
          const SizedBox(width: MedSpacing.lg),
          Text('Parmak İzi Okuyucu Testi', style: MedTextStyles.titleLg(color: MedColors.text)),
          const SizedBox(width: MedSpacing.lg),
          const MedChip(
            label: 'DEV',
            style: MedChipStyle.warning,
            shape: MedChipShape.pill,
            size: MedChipSize.sm,
            showBorder: false,
          ),
          if (n.isMock) ...[
            const SizedBox(width: MedSpacing.sm),
            const MedChip(
              label: 'MOCK',
              style: MedChipStyle.info,
              shape: MedChipShape.pill,
              size: MedChipSize.sm,
              showBorder: false,
            ),
          ],
          const Spacer(),
          MedStatusDot(
            color: switch (style) {
              MedChipStyle.success => MedColors.green,
              MedChipStyle.danger => MedColors.red,
              MedChipStyle.info => MedColors.blue,
              _ => MedColors.text4,
            },
            isPulsing: n.isCapturing,
          ),
          const SizedBox(width: MedSpacing.md),
          MedChip(label: label, style: style),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sol: okuyucu
// ─────────────────────────────────────────────────────────────────

class _ScannerCard extends StatelessWidget {
  const _ScannerCard({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final info = n.scannerInfo;
    final settings = n.bioMiniSettings;
    final secuGen = n.secuGenSettings;

    return _Card(
      title: 'Okuyucu',
      dotColor: n.isOpen ? MedColors.green : MedColors.text4,
      children: [
        if (n.openFailure != null) ...[
          _Banner(
            color: MedColors.red,
            background: MedColors.redLight,
            text: '${fingerprintFailureLabel(n.openFailure!)}\n${_openHelp(n.openFailure!)}',
          ),
          const SizedBox(height: MedSpacing.lg),
        ],
        _KeyValue('ÜRETİCİ', switch (info?.vendor) {
          'suprema' => 'Suprema (BioMini)',
          'secugen' => 'SecuGen',
          'mock' => 'Mock',
          _ => '—',
        }),
        _KeyValue('MODEL', info?.model ?? '—'),
        _KeyValue('TİP KODU', info == null ? '—' : '${info.scannerType}'),
        _KeyValue('SERİ NO', info?.serial ?? '—'),
        _KeyValue('SDK', info?.sdkVersion ?? '—'),
        if (info != null)
          _KeyValue(
            'CANLILIK',
            info.livenessActive ? 'Etkin' : 'YOK — sahte parmak tespit edilmez',
            valueColor: info.livenessActive ? MedColors.green : MedColors.amber,
          ),
        if (secuGen != null) ...[
          const Divider(height: 24, color: MedColors.border2),
          _KeyValue('ŞABLON', secuGen.templateFormat.wireName),
          _KeyValue('ALAN EŞİĞİ', '${secuGen.captureAreaQuality}'),
          _KeyValue('SMART CAPTURE', secuGen.smartCapture ? 'Açık' : 'Kapalı'),
          _KeyValue('PARMAK SORGUSU', 'Sezgisel (tek kare kalitesi)'),
        ],
        if (settings != null) ...[
          const Divider(height: 24, color: MedColors.border2),
          _KeyValue('MOD', settings.captureMode == BioMiniCaptureMode.device ? 'Cihaz üstü' : 'PC (host)'),
          _KeyValue('ŞABLON', settings.templateFormat.wireName),
          _KeyValue(
            'CANLILIK (LFD)',
            settings.lfdActive ? 'Seviye ${settings.lfdLevel}' : 'Kapalı',
            valueColor: settings.lfdActive ? null : MedColors.amber,
          ),
          _KeyValue('GÜVENLİK', settings.securityLevel?.toString() ?? 'Cihaz varsayılanı'),
        ],
        const SizedBox(height: MedSpacing.lg),
        Row(
          children: [
            Expanded(
              child: MedButton(
                label: n.isOpen ? 'Yeniden Aç' : 'Okuyucuyu Aç',
                onPressed: n.isOpening || n.isCapturing ? null : n.open,
                isLoading: n.isOpening,
                fullWidth: true,
              ),
            ),
            const SizedBox(width: MedSpacing.md),
            Expanded(
              child: MedButton(
                label: 'Kapat',
                variant: MedButtonVariant.ghost,
                onPressed: n.isOpen && !n.isOpening ? n.close : null,
                fullWidth: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.md),
        MedButton(
          label: 'Parmak sensörde mi?',
          variant: MedButtonVariant.secondary,
          onPressed: n.isOpen && !n.isCapturing ? n.checkFingerOn : null,
          fullWidth: true,
        ),
        if (n.fingerOn != null || n.fingerOnFailure != null) ...[
          const SizedBox(height: MedSpacing.sm),
          Text(
            n.fingerOnFailure != null
                ? 'Sorgu başarısız: ${fingerprintFailureLabel(n.fingerOnFailure!)}'
                : (n.fingerOn! ? 'Sensörde parmak VAR' : 'Sensör boş'),
            style: MedTextStyles.monoSm(color: MedColors.text2),
          ),
        ],
      ],
    );
  }

  static String _openHelp(FingerprintFailureReason r) => switch (r) {
    FingerprintFailureReason.libraryNotFound =>
      'SDK DLL\'leri exe\'nin yanında mı? (SecuGen: sgfplib/sgfpamx/sgwsqlib.dll, '
          'Suprema: UFScanner.dll — build sonrası CMake kopyalar)',
    FingerprintFailureReason.deviceNotFound =>
      'Takılı okuyucu bulunamadı. Okuyucu Aygıt Yöneticisi\'nde "Fingerprint devices" '
          'altında görünmeli; görünmüyorsa üreticinin sürücüsü kurulu değildir '
          '(SecuGen: WinDriver_u10, Suprema: Sup_Fingerprint_Driver). Üreticinin demo '
          'uygulaması da okuyucuyu görmüyorsa sorun uygulamada değil sürücü/kablodadır.',
    FingerprintFailureReason.busy =>
      'Okuyucuyu başka bir uygulama (ör. SDK demosu) kullanıyor olabilir; kapatıp tekrar deneyin.',
    _ => 'Ayrıntı için logdaki SW-UNIT-FP kayıtlarına bakın.',
  };
}

// ─────────────────────────────────────────────────────────────────
// Sol: okuma ayarları
// ─────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final locked = n.isCapturing || n.isContinuous;
    return _Card(
      title: 'Okuma Ayarları',
      dotColor: MedColors.blue,
      children: [
        _CounterRow(
          label: 'Zaman aşımı (sn)',
          description: 'Parmak bu süre içinde okutulmazsa okuma biter',
          value: n.timeoutSeconds,
          min: 3,
          max: 30,
          step: 1,
          enabled: !locked,
          onChanged: n.setTimeoutSeconds,
        ),
        _CounterRow(
          label: 'Min. kalite',
          description: 'Üretici önerisi — Suprema: giriş ≥30 · SecuGen: giriş ≥40 · ikisi de kayıt ≥50',
          value: n.minQuality,
          min: 10,
          max: 90,
          step: 5,
          enabled: !locked,
          onChanged: n.setMinQuality,
        ),
        _SwitchRow(
          label: 'Görüntüyü göster',
          description: 'Yalnızca test için; girişte görüntü alınmaz',
          value: n.includeImage,
          onChanged: locked ? null : n.setIncludeImage,
        ),
        const SizedBox(height: MedSpacing.sm),
        Text(
          'Okuyucu otomatik seçilir (önce SecuGen, sonra Suprema). Üreticiye özel ayarlar '
          'uygulama başlarken --dart-define ile verilir: FINGERPRINT_VENDOR, '
          'BIOMINI_LFD_LEVEL, BIOMINI_CAPTURE_MODE, SECUGEN_AREA_QUALITY.',
          style: MedTextStyles.bodySm(color: MedColors.text3),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Orta: son okuma + eylemler + gönderim simülasyonu
// ─────────────────────────────────────────────────────────────────

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final last = n.lastAttempt;
    final capture = n.lastCapture;
    final showImage = last?.capture?.image ?? capture?.image;

    final placeholder = switch (n) {
      _ when !n.isOpen => 'Önce okuyucuyu açın',
      _ when n.isCapturing => n.continuousHint ?? 'Parmağınızı okuyucuya koyun',
      _ => 'Tek Okuma veya Sürekli Okuma ile başlayın',
    };

    return _Card(
      title: 'Son Okuma',
      dotColor: last == null ? MedColors.text4 : (last.isSuccess ? MedColors.green : MedColors.red),
      trailing: last == null ? null : _ResultChip(attempt: last),
      expand: true,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FingerprintImageView(image: n.isCapturing ? null : showImage, placeholder: placeholder),
                    ),
                    if (n.isCapturing)
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Center(child: MedStatusDot(color: MedColors.blue, size: 12, isPulsing: true)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: MedSpacing.xl),
              Expanded(flex: 4, child: _Metrics(n: n)),
            ],
          ),
        ),
        const SizedBox(height: MedSpacing.xl),
        _Actions(n: n),
        const Divider(height: 32, color: MedColors.border2),
        _SendSimulation(n: n),
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final last = n.lastAttempt;
    final c = last?.capture;

    return ListView(
      children: [
        _BigMetric(
          label: 'KALİTE',
          value: c == null ? '—' : '${c.quality}',
          suffix: '/ 100',
          color: c == null ? MedColors.text4 : _qualityColor(c.quality),
          progress: c == null ? null : c.quality / 100,
          hint: 'Eşik: ${n.minQuality}',
        ),
        const SizedBox(height: MedSpacing.xl),
        _BigMetric(
          label: 'CANLILIK SKORU',
          value: c?.lfdScore?.toString() ?? '—',
          color: c?.lfdScore == null ? MedColors.text4 : MedColors.text,
          hint: c != null && c.lfdScore == null ? 'LFD kapalı veya desteklenmiyor' : null,
        ),
        const SizedBox(height: MedSpacing.xl),
        _KeyValue('SÜRE', last == null ? '—' : '${last.elapsed.inMilliseconds} ms'),
        _KeyValue('ŞABLON', c == null ? '—' : '${c.templateSize} bayt · ${c.format.wireName}'),
        if (c?.image != null)
          _KeyValue('GÖRÜNTÜ', '${c!.image!.width}×${c.image!.height} · ${c.image!.resolutionDpi} dpi'),
        if (last != null && !last.isSuccess) ...[
          const SizedBox(height: MedSpacing.md),
          _Banner(
            color: MedColors.red,
            background: MedColors.redLight,
            text:
                '${fingerprintFailureLabel(last.failure!)}'
                '${last.sdkStatus != null ? '\nSDK durum kodu: ${last.sdkStatus}' : ''}',
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final canStart = n.isOpen && !n.isCapturing && !n.isContinuous;
    return Row(
      children: [
        Expanded(
          child: MedButton(
            label: 'Tek Okuma',
            size: MedButtonSize.lg,
            prefixIcon: const Icon(Icons.fingerprint),
            onPressed: canStart ? n.captureOnce : null,
            isLoading: n.isCapturing && !n.isContinuous,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: MedSpacing.lg),
        Expanded(
          child: n.isContinuous
              ? MedButton(
                  label: 'Sürekli Okumayı Durdur',
                  size: MedButtonSize.lg,
                  variant: MedButtonVariant.error,
                  prefixIcon: const Icon(Icons.stop_rounded),
                  onPressed: n.stopContinuous,
                  fullWidth: true,
                )
              : MedButton(
                  label: 'Sürekli Okuma (giriş gibi)',
                  size: MedButtonSize.lg,
                  variant: MedButtonVariant.secondary,
                  prefixIcon: const Icon(Icons.repeat_rounded),
                  onPressed: canStart ? n.startContinuous : null,
                  fullWidth: true,
                ),
        ),
        const SizedBox(width: MedSpacing.lg),
        MedButton(
          label: 'İptal',
          size: MedButtonSize.lg,
          variant: MedButtonVariant.ghost,
          onPressed: n.isCapturing && !n.isContinuous ? n.cancelCapture : null,
        ),
      ],
    );
  }
}

class _SendSimulation extends StatelessWidget {
  const _SendSimulation({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final capture = n.lastCapture;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SERVİSE GÖNDERİM (SİMÜLASYON)', style: _sectionLabel),
                  const SizedBox(height: 2),
                  Text(
                    capture == null
                        ? 'Önce başarılı bir okuma yapın.'
                        : 'Son başarılı okuma servise gidecek gövdeye dönüştürülür. İstek atılmaz; '
                              'yalnızca loglanır (şablon loglanmaz).',
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MedSpacing.lg),
            MedButton(
              label: 'Gönder (simülasyon)',
              variant: MedButtonVariant.success,
              prefixIcon: const Icon(Icons.cloud_upload_outlined),
              onPressed: capture != null && !n.isSending ? n.simulateSend : null,
              isLoading: n.isSending,
            ),
          ],
        ),
        if (n.payloadPreview != null) ...[
          const SizedBox(height: MedSpacing.md),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            padding: MedSpacing.insetLg,
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border),
              borderRadius: MedRadius.mdAll,
            ),
            child: SingleChildScrollView(
              child: SelectableText(n.payloadPreview!, style: MedTextStyles.monoSm(color: MedColors.text2)),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sağ: istatistik + geçmiş
// ─────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.n});
  final FingerprintTestNotifier n;

  @override
  Widget build(BuildContext context) {
    final failures = n.failureCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return _Card(
      title: 'Geçmiş',
      dotColor: MedColors.text3,
      expand: true,
      trailing: n.attempts.isEmpty
          ? null
          : MedButton(
              label: 'Temizle',
              size: MedButtonSize.sm,
              variant: MedButtonVariant.ghost,
              onPressed: n.clearHistory,
            ),
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(label: 'BAŞARILI', value: '${n.successCount}', color: MedColors.green),
            ),
            const SizedBox(width: MedSpacing.md),
            Expanded(
              child: _MiniStat(label: 'HATALI', value: '${n.failureCount}', color: MedColors.red),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniStat(label: 'ORT. KALİTE', value: _fmt(n.averageQuality)),
            ),
            const SizedBox(width: MedSpacing.md),
            Expanded(
              child: _MiniStat(label: 'ORT. LFD', value: _fmt(n.averageLfdScore)),
            ),
            const SizedBox(width: MedSpacing.md),
            Expanded(
              child: _MiniStat(label: 'ORT. MS', value: _fmt(n.averageCaptureMs)),
            ),
          ],
        ),
        if (failures.isNotEmpty) ...[
          const SizedBox(height: MedSpacing.md),
          Wrap(
            spacing: MedSpacing.sm,
            runSpacing: MedSpacing.sm,
            children: [
              for (final f in failures)
                MedChip(
                  label: fingerprintFailureLabel(f.key),
                  count: f.value,
                  style: MedChipStyle.danger,
                  size: MedChipSize.sm,
                ),
            ],
          ),
        ],
        const Divider(height: 24, color: MedColors.border2),
        Expanded(
          child: n.attempts.isEmpty
              ? Center(
                  child: Text('Henüz okuma yok', style: MedTextStyles.bodySm(color: MedColors.text3)),
                )
              : ListView.separated(
                  itemCount: n.attempts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: MedColors.border2),
                  itemBuilder: (_, i) => _AttemptRow(attempt: n.attempts[i]),
                ),
        ),
      ],
    );
  }

  static String _fmt(double? v) => v == null ? '—' : v.toStringAsFixed(0);
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({required this.attempt});
  final FingerprintAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final c = attempt.capture;
    final t = attempt.at;
    String two(int v) => v.toString().padLeft(2, '0');

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Icon(
            attempt.isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 18,
            color: attempt.isSuccess ? MedColors.green : MedColors.red,
          ),
          const SizedBox(width: MedSpacing.md),
          Text('${two(t.hour)}:${two(t.minute)}:${two(t.second)}', style: MedTextStyles.monoSm(color: MedColors.text3)),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              c != null
                  ? 'Q ${c.quality}${c.lfdScore != null ? ' · LFD ${c.lfdScore}' : ''}'
                  : fingerprintFailureLabel(attempt.failure!),
              style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${attempt.elapsed.inMilliseconds} ms', style: MedTextStyles.monoXs(color: MedColors.text3)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Etiketler
// ─────────────────────────────────────────────────────────────────

/// Hata nedeninin kullanıcıya gösterilecek Türkçe karşılığı.
/// Giriş/kayıt ekranları yazılırken ARB'ye (`hw_fingerprint_*`) taşınacak.
String fingerprintFailureLabel(FingerprintFailureReason r) => switch (r) {
  FingerprintFailureReason.libraryNotFound => 'Okuyucu kütüphanesi bulunamadı',
  FingerprintFailureReason.deviceNotFound => 'Okuyucu bulunamadı',
  FingerprintFailureReason.deviceDisconnected => 'Okuyucu bağlantısı koptu',
  FingerprintFailureReason.notOpen => 'Okuyucu açık değil',
  FingerprintFailureReason.busy => 'Okuyucu meşgul',
  FingerprintFailureReason.timeout => 'Zaman aşımı',
  FingerprintFailureReason.cancelled => 'İptal edildi',
  FingerprintFailureReason.fingerOnSensor => 'Parmağınızı kaldırıp tekrar koyun',
  FingerprintFailureReason.fakeFinger => 'Sahte parmak tespit edildi',
  FingerprintFailureReason.lowQuality => 'Kalite yetersiz',
  FingerprintFailureReason.extractionFailed => 'Parmak düzgün yerleşmedi',
  FingerprintFailureReason.sensorDirty => 'Sensör kirli',
  FingerprintFailureReason.unexpected => 'Beklenmeyen hata',
};

Color _qualityColor(int q) => q >= 50 ? MedColors.green : (q >= 30 ? MedColors.amber : MedColors.red);

TextStyle get _sectionLabel => MedTextStyles.monoXs(color: MedColors.text3).copyWith(letterSpacing: 0.8);

// ─────────────────────────────────────────────────────────────────
// Yardımcı widget'lar
// ─────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.dotColor,
    required this.children,
    this.trailing,
    this.expand = false,
  });

  final String title;
  final Color dotColor;
  final List<Widget> children;
  final Widget? trailing;

  /// true → gövde kalan yüksekliği doldurur (children içinde Expanded kullanılabilir).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.midAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: MedColors.border2)),
            ),
            child: Row(
              children: [
                MedStatusDot(color: dotColor),
                const SizedBox(width: MedSpacing.md),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: MedTextStyles.titleSm(color: MedColors.text2).copyWith(letterSpacing: 0.8),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          if (expand) Expanded(child: body) else body,
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: _sectionLabel)),
          Expanded(
            child: Text(
              value,
              style: MedTextStyles.bodyMd(color: valueColor ?? MedColors.text2, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
    this.progress,
    this.hint,
  });

  final String label;
  final String value;
  final Color color;
  final String? suffix;
  final double? progress;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _sectionLabel),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: MedTextStyles.numericXl(color: color)),
            if (suffix != null) ...[
              const SizedBox(width: 6),
              Text(suffix!, style: MedTextStyles.monoSm(color: MedColors.text3)),
            ],
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: MedRadius.smAll,
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              color: color,
              backgroundColor: MedColors.surface3,
            ),
          ),
        ],
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint!, style: MedTextStyles.bodySm(color: MedColors.text3)),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _sectionLabel),
          const SizedBox(height: 2),
          Text(value, style: MedTextStyles.titleMd(color: color ?? MedColors.text)),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.attempt});
  final FingerprintAttempt attempt;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      label: attempt.isSuccess ? 'Başarılı' : fingerprintFailureLabel(attempt.failure!),
      style: attempt.isSuccess ? MedChipStyle.success : MedChipStyle.danger,
      shape: MedChipShape.pill,
      showBorder: false,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.background, required this.text});
  final Color color;
  final Color background;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color.withAlpha(60)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Text(
        text,
        style: MedTextStyles.bodySm(color: color, weight: FontWeight.w600),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String description;
  final int value;
  final int min;
  final int max;
  final int step;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _LabelBlock(label: label, description: description),
          ),
          const SizedBox(width: MedSpacing.md),
          Opacity(
            opacity: enabled ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !enabled,
              child: MedCounter(
                value: value,
                min: min,
                max: max,
                onDecrement: () => onChanged(value - step),
                onIncrement: () => onChanged(value + step),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.description, required this.value, required this.onChanged});
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Row(
          children: [
            Expanded(
              child: _LabelBlock(label: label, description: description),
            ),
            const SizedBox(width: MedSpacing.md),
            Opacity(
              opacity: enabled ? 1 : 0.4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 26,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: value ? MedColors.blue : MedColors.border,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelBlock extends StatelessWidget {
  const _LabelBlock({required this.label, required this.description});
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(description, style: MedTextStyles.bodySm(color: MedColors.text3)),
      ],
    );
  }
}
