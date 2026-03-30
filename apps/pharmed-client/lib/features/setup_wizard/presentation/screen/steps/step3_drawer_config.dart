// lib/features/setup_wizard/presentation/screen/steps/step4_drawer_config.dart
//
// [SWREQ-SETUP-UI-014]
// Adım 4 — Çekmece yapısı.
// Standart: cihaz tarama + manuel yapılandırma.
// Mobil: sıra bazlı çekmece tanımı.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import '../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../shared/widgets/atoms/med_button.dart';
import '../../../../../shared/widgets/molecules/med_numeric_stepper.dart';
import '../../../../../shared/widgets/molecules/med_select_field.dart';
import '../../../domain/model/cabin_setup_config.dart';
import '../../state/setup_wizard_ui_state.dart';
import 'step_shared.dart';

class Step4DrawerConfig extends StatelessWidget {
  const Step4DrawerConfig({
    super.key,
    required this.cabinetType,
    required this.drawerConfig,
    required this.scanState,
    required this.onScanDevice,
    required this.onConfigChanged,
    required this.onNext,
    required this.onBack,
  });

  final CabinType cabinetType;
  final DrawerConfig? drawerConfig;
  final DrawerScanState scanState;
  final VoidCallback onScanDevice;
  final ValueChanged<DrawerConfig> onConfigChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(
          badge: 'Adım 4 / 5',
          title: 'Çekmece Yapısı',
          subtitle: cabinetType == CabinType.master
              ? 'Cihazı tarayarak çekmece yapısını otomatik algılayın veya manuel girin.'
              : 'Mobil kabinin sıra sayısını ve her sıranın çekmece tipini ayarlayın.',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: cabinetType == CabinType.master
                ? _StandardDrawerPanel(
                    config: drawerConfig is StandardDrawerConfig ? drawerConfig as StandardDrawerConfig : null,
                    scanState: scanState,
                    onScan: onScanDevice,
                    onChanged: onConfigChanged,
                  )
                : _MobileDrawerPanel(
                    config: drawerConfig is MobileDrawerConfig ? drawerConfig as MobileDrawerConfig : null,
                    onChanged: onConfigChanged,
                  ),
          ),
        ),
        StepFooter(onBack: onBack, onNext: onNext),
      ],
    );
  }
}

// ── Standart kabin: tarama / manuel panel ─────────────────────────

class _StandardDrawerPanel extends StatefulWidget {
  const _StandardDrawerPanel({
    required this.config,
    required this.scanState,
    required this.onScan,
    required this.onChanged,
  });

  final StandardDrawerConfig? config;
  final DrawerScanState scanState;
  final VoidCallback onScan;
  final ValueChanged<DrawerConfig> onChanged;

  @override
  State<_StandardDrawerPanel> createState() => _StandardDrawerPanelState();
}

class _StandardDrawerPanelState extends State<_StandardDrawerPanel> {
  bool _manualMode = false;

  // Manuel mod için yerel durum
  int _sections = 5;
  DrawerType _drawerType = DrawerType.cubic4x4;
  int _depth = 6;

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _sections = widget.config!.sections;
      _drawerType = widget.config!.drawerType;
      _depth = widget.config!.depth;
    }
  }

  void _emitManual() {
    widget.onChanged(
      StandardDrawerConfig(sections: _sections, drawerType: _drawerType, depth: _depth, scannedFromDevice: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tarama paneli ──
        _ScanPanel(scanState: widget.scanState, onScan: widget.onScan),

        if (widget.scanState == DrawerScanState.found && widget.config != null) ...[
          const SizedBox(height: 20),
          _ScannedResultCard(config: widget.config!),
        ],

        const SizedBox(height: 20),

        // ── Manuel giriş seçeneği ──
        GestureDetector(
          onTap: () => setState(() => _manualMode = !_manualMode),
          child: Row(
            children: [
              Icon(
                _manualMode ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: MedColors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                _manualMode ? 'Manuel girişi gizle' : 'Manuel olarak gir',
                style: const TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MedColors.blue,
                ),
              ),
            ],
          ),
        ),

        if (_manualMode) ...[
          const SizedBox(height: 16),
          _ManualConfigForm(
            sections: _sections,
            drawerType: _drawerType,
            depth: _depth,
            onSectionsChanged: (v) {
              setState(() => _sections = v);
              _emitManual();
            },
            onDrawerTypeChanged: (v) {
              if (v == null) return;
              setState(() => _drawerType = v);
              _emitManual();
            },
            onDepthChanged: (v) {
              setState(() => _depth = v);
              _emitManual();
            },
          ),
        ],
      ],
    );
  }
}

// ── Tarama paneli ─────────────────────────────────────────────────

class _ScanPanel extends StatelessWidget {
  const _ScanPanel({required this.scanState, required this.onScan});

  final DrawerScanState scanState;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: MedShadows.sm,
      ),
      child: switch (scanState) {
        DrawerScanState.idle => _ScanIdle(onScan: onScan),
        DrawerScanState.scanning => const _ScanInProgress(),
        DrawerScanState.found => const _ScanFound(),
        DrawerScanState.error => _ScanError(onRetry: onScan),
      },
    );
  }
}

class _ScanIdle extends StatelessWidget {
  const _ScanIdle({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.radar_rounded, size: 28, color: MedColors.blue),
        ),
        const SizedBox(height: 12),
        const Text(
          'Cihaz Taraması',
          style: TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MedColors.text,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cihazın IP adresine bağlanarak çekmece yapısını otomatik okur.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        MedButton(label: 'Cihazı Tara', prefixIcon: const Icon(Icons.search_rounded, size: 16), onPressed: onScan),
      ],
    );
  }
}

class _ScanInProgress extends StatefulWidget {
  const _ScanInProgress();

  @override
  State<_ScanInProgress> createState() => _ScanInProgressState();
}

class _ScanInProgressState extends State<_ScanInProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotationTransition(
          turns: _ctrl,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.radar_rounded, size: 28, color: MedColors.blue),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Taranıyor…',
          style: TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MedColors.blue,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cihaz bağlantısı kurulmaya çalışılıyor, lütfen bekleyin.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ScanFound extends StatelessWidget {
  const _ScanFound();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: const Color(0xFFE6F7F2), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.check_circle_rounded, size: 28, color: Color(0xFF0D9E6C)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Cihaz Bulundu',
          style: TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D9E6C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Çekmece yapısı başarıyla okundu.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.error_outline_rounded, size: 28, color: Color(0xFFDC2626)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tarama Başarısız',
          style: TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDC2626),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cihaza bağlanılamadı. IP adresini kontrol edin veya manuel giriş yapın.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        MedButton(
          label: 'Tekrar Dene',
          variant: MedButtonVariant.secondary,
          prefixIcon: const Icon(Icons.refresh_rounded, size: 16),
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _ScannedResultCard extends StatelessWidget {
  const _ScannedResultCard({required this.config});
  final StandardDrawerConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0D9E6C).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF0D9E6C)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Okunan Yapı',
                  style: TextStyle(
                    fontFamily: MedFonts.mono,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9E6C),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${config.sections} bölüm · ${config.drawerType.label} · Derinlik ${config.depth}',
                  style: const TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9E6C),
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

class _ManualConfigForm extends StatelessWidget {
  const _ManualConfigForm({
    required this.sections,
    required this.drawerType,
    required this.depth,
    required this.onSectionsChanged,
    required this.onDrawerTypeChanged,
    required this.onDepthChanged,
  });

  final int sections;
  final DrawerType drawerType;
  final int depth;
  final ValueChanged<int> onSectionsChanged;
  final ValueChanged<DrawerType?> onDrawerTypeChanged;
  final ValueChanged<int> onDepthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANUEL YAPILANDIRMA',
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: MedColors.text3,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bölüm Sayısı',
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MedColors.text2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MedNumericStepper(value: sections, min: 1, max: 5, onChanged: onSectionsChanged),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: MedSelectField<DrawerType>(
                  label: 'Çekmece Tipi',
                  value: drawerType,
                  options: DrawerType.values.map((t) => MedSelectOption(label: t.label, value: t)).toList(),
                  onChanged: onDrawerTypeChanged,
                ),
              ),
            ],
          ),
          if (drawerType == DrawerType.unitDose) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Derinlik (1–12)',
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MedColors.text2,
                  ),
                ),
                const SizedBox(height: 8),
                MedNumericStepper(value: depth, min: 1, max: 12, onChanged: onDepthChanged),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Mobil kabin çekmece paneli ────────────────────────────────────

class _MobileDrawerPanel extends StatefulWidget {
  const _MobileDrawerPanel({required this.config, required this.onChanged});

  final MobileDrawerConfig? config;
  final ValueChanged<DrawerConfig> onChanged;

  @override
  State<_MobileDrawerPanel> createState() => _MobileDrawerPanelState();
}

class _MobileDrawerPanelState extends State<_MobileDrawerPanel> {
  late int _rowCount;
  late List<MobileDrawerRow> _rows;

  @override
  void initState() {
    super.initState();
    _rowCount = widget.config?.drawerCount ?? 4;
    _rows = widget.config?.rows ?? _buildDefaultRows(4);
  }

  List<MobileDrawerRow> _buildDefaultRows(int count) {
    return List.generate(count, (i) => MobileDrawerRow(rowIndex: i + 1, drawerType: DrawerType.cubic4x4, columns: 2));
  }

  void _onRowCountChanged(int count) {
    setState(() {
      _rowCount = count;
      if (count > _rows.length) {
        // Yeni sıra ekle
        for (var i = _rows.length + 1; i <= count; i++) {
          _rows = [..._rows, MobileDrawerRow(rowIndex: i, drawerType: DrawerType.cubic4x4, columns: 2)];
        }
      } else {
        _rows = _rows.take(count).toList();
      }
    });
    _emit();
  }

  void _onRowTypeChanged(int index, DrawerType? type) {
    if (type == null) return;
    setState(() {
      _rows = [
        for (var i = 0; i < _rows.length; i++)
          if (i == index) _rows[i].copyWith(drawerType: type) else _rows[i],
      ];
    });
    _emit();
  }

  void _emit() {
    widget.onChanged(MobileDrawerConfig(drawerCount: _rowCount, rows: _rows));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sıra sayısı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: MedColors.border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: MedShadows.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOPLAM SIRA SAYISI',
                      style: TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: MedColors.text3,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Her sırada 2 çekmece yan yana yer alır.',
                      style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              MedNumericStepper(value: _rowCount, min: 1, max: 8, onChanged: _onRowCountChanged),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sıra kartları
        for (var i = 0; i < _rows.length; i++) ...[
          _MobileRowCard(row: _rows[i], onTypeChanged: (t) => _onRowTypeChanged(i, t)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MobileRowCard extends StatelessWidget {
  const _MobileRowCard({required this.row, required this.onTypeChanged});

  final MobileDrawerRow row;
  final ValueChanged<DrawerType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Sıra rozeti
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(
              '${row.rowIndex}',
              style: const TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: MedColors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Sıra ${row.rowIndex}',
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MedColors.text,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 200,
            child: MedSelectField<DrawerType>(
              label: 'Çekmece Tipi',
              value: row.drawerType,
              options: DrawerType.values.map((t) => MedSelectOption(label: t.label, value: t)).toList(),
              onChanged: onTypeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
