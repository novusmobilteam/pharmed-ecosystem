// lib/features/setup_wizard/presentation/screen/steps/step5_summary.dart
//
// [SWREQ-SETUP-UI-015]
// Adım 5 — Kurulum özeti ve tamamla.
// 2×2 kart ızgarasında tüm adımların özeti + "Tamamla" butonu.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import '../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../shared/widgets/atoms/med_button.dart';
import '../../../domain/model/cabin_setup_config.dart';
import '../../../domain/model/wizard_draft.dart';
import 'step_shared.dart';

class Step5Summary extends StatelessWidget {
  const Step5Summary({
    super.key,
    required this.draft,
    required this.onFinish,
    required this.onBack,
    this.isSaving = false,
  });

  final WizardDraft draft;
  final VoidCallback onFinish;
  final VoidCallback onBack;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(
          badge: 'Adım 4 / 4',
          title: 'Kurulum Özeti',
          subtitle: 'Tüm ayarları gözden geçirin. Onayladıktan sonra kabin sisteme kaydedilir.',
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Column(
              children: [
                // 2×2 Kart ızgarası
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _SummaryCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'KABİN BİLGİLERİ',
                            color: MedColors.blue,
                            bgColor: MedColors.blueLight,
                            rows: _buildBasicInfoRows(draft),
                          ),
                          const SizedBox(height: 12),
                          _SummaryCard(
                            icon: Icons.layers_outlined,
                            title: 'ÇEKMECE YAPISI',
                            color: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF5F3FF),
                            rows: _buildDrawerRows(draft),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CabinetPreviewCard(draft: draft),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Alt buton satırı — özel Tamamla butonu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: const BoxDecoration(
            color: MedColors.surface2,
            border: Border(top: BorderSide(color: MedColors.border2)),
          ),
          child: Row(
            children: [
              MedButton(
                label: 'Geri',
                variant: MedButtonVariant.ghost,
                prefixIcon: const Icon(Icons.arrow_back_rounded, size: 16),
                onPressed: isSaving ? null : onBack,
              ),
              const Spacer(),
              MedButton(
                label: isSaving ? 'Kaydediliyor…' : 'Kurulumu Tamamla',
                size: MedButtonSize.lg,
                prefixIcon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                onPressed: isSaving ? null : onFinish,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Kart satır oluşturucular ─────────────────────────────────────

  List<_SummaryRow> _buildBasicInfoRows(WizardDraft draft) {
    final info = draft.basicInfo;
    if (info == null) return [];
    return [
      _SummaryRow(label: 'Kabin Adı', value: info.cabinName),
      _SummaryRow(label: 'Tip', value: draft.cabinetType?.label ?? '—'),
      _SummaryRow(label: 'Konum', value: info.location.isEmpty ? '—' : info.location),
      _SummaryRow(label: 'IP Adresi', value: info.ipAddress, mono: true),
      _SummaryRow(label: 'Port', value: info.port.toString(), mono: true),
    ];
  }

  List<_SummaryRow> _buildDrawerRows(WizardDraft draft) {
    final config = draft.drawerConfig;
    if (config == null) return [];
    if (config is StandardDrawerConfig) {
      return [
        _SummaryRow(label: 'Tip', value: config.drawerType.label),
        _SummaryRow(label: 'Bölüm', value: '${config.sections}'),
        if (config.drawerType == DrawerType.unitDose) _SummaryRow(label: 'Derinlik', value: '${config.depth}'),
        _SummaryRow(label: 'Kaynak', value: config.scannedFromDevice ? 'Cihazdan Okundu' : 'Manuel Girildi'),
      ];
    } else if (config is MobileDrawerConfig) {
      return [
        _SummaryRow(label: 'Sıra Sayısı', value: '${config.drawerCount}'),
        for (final row in config.rows) _SummaryRow(label: 'Sıra ${row.rowIndex}', value: row.drawerType.label),
      ];
    }
    return [];
  }
}

// ── Özet kartı ────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: MedColors.border2)),
              color: bgColor.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: MedFonts.mono,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Satırlar
          Padding(
            padding: const EdgeInsets.all(14),
            child: rows.isEmpty
                ? const Text(
                    'Bilgi yok',
                    style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        _SummaryRowWidget(row: rows[i]),
                        if (i < rows.length - 1) const Divider(height: 12, color: MedColors.border2),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  const _SummaryRow({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;
}

class _SummaryRowWidget extends StatelessWidget {
  const _SummaryRowWidget({required this.row});
  final _SummaryRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          row.label,
          style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
        ),
        const Spacer(),
        Text(
          row.value,
          style: TextStyle(
            fontFamily: row.mono ? MedFonts.mono : MedFonts.sans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MedColors.text,
          ),
        ),
      ],
    );
  }
}

// ── Kabin önizleme kartı ──────────────────────────────────────────

class _CabinetPreviewCard extends StatelessWidget {
  const _CabinetPreviewCard({required this.draft});
  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: MedColors.border2)),
              color: MedColors.surface2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(
              children: [
                Icon(Icons.view_in_ar_outlined, size: 16, color: MedColors.text3),
                SizedBox(width: 8),
                Text(
                  'KABİN ÖNİZLEME',
                  style: TextStyle(
                    fontFamily: MedFonts.mono,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: MedColors.text3,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: draft.cabinetType == CabinType.master
                  ? _StandardPreview(draft: draft)
                  : _MobilePreview(draft: draft),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandardPreview extends StatelessWidget {
  const _StandardPreview({required this.draft});
  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final sections = (draft.drawerConfig is StandardDrawerConfig)
        ? (draft.drawerConfig as StandardDrawerConfig).sections
        : 5;

    return Column(
      children: [
        // Kabin gövdesi
        Container(
          width: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE2ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB8C6D6), width: 1.5),
          ),
          child: Column(
            children: [
              // Top panel
              Container(
                height: 12,
                decoration: BoxDecoration(color: const Color(0xFFC8D4E4), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E)),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < sections; i++) ...[
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF1F8),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFFC8D2E0)),
                  ),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(color: const Color(0xFF9AADC0), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
                if (i < sections - 1) const SizedBox(height: 2),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          draft.basicInfo?.cabinName ?? 'Standart Kabin',
          style: const TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: MedColors.text2,
          ),
        ),
      ],
    );
  }
}

class _MobilePreview extends StatelessWidget {
  const _MobilePreview({required this.draft});
  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final rowCount = (draft.drawerConfig is MobileDrawerConfig)
        ? (draft.drawerConfig as MobileDrawerConfig).drawerCount
        : 4;

    return Column(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFD4DCEA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB8C6D6), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(color: const Color(0xFFBCCAD8), borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < rowCount; i++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF1F8),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: const Color(0xFFC8D2E0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF1F8),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: const Color(0xFFC8D2E0)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < rowCount - 1) const SizedBox(height: 2),
              ],
              const SizedBox(height: 4),
              // Tekerler
              Container(
                height: 6,
                decoration: BoxDecoration(color: const Color(0xFF8090A8), borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          draft.basicInfo?.cabinName ?? 'Mobil Kabin',
          style: const TextStyle(
            fontFamily: MedFonts.title,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: MedColors.text2,
          ),
        ),
      ],
    );
  }
}
