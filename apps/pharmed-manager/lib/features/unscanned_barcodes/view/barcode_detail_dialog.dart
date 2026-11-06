part of 'unscanned_barcodes_screen.dart';

/// Okutulmayan / okutulan / silinen karekod listelerindeki bir kalemin
/// tüm ayrıntılarını gösteren salt-okunur dialog.
///
/// Tablo kolonlarına sığmayan bilgiler (silme açıklaması, order açıklaması,
/// doktor, servis, order saati, order edilen / uygulanan miktar vb.) burada
/// gösterilir. Üç liste modu da aynı dialog'u kullanır; moda özgü alanlar
/// ([BarcodeListMode.unscanned] → uyarı durumu, [BarcodeListMode.deleted] →
/// silme açıklaması) koşullu eklenir.
class BarcodeDetailDialog extends StatelessWidget {
  const BarcodeDetailDialog({super.key, required this.item, required this.mode});

  final PrescriptionItem item;
  final BarcodeListMode mode;

  static Future<void> show(BuildContext context, {required PrescriptionItem item, required BarcodeListMode mode}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => BarcodeDetailDialog(item: item, mode: mode),
    );
  }

  static String _v(Object? value) => (value == null || value.toString().trim().isEmpty) ? '-' : value.toString();

  String _quantityText(BuildContext context, num? quantity) {
    if (quantity == null) return '-';
    return item.medicine?.prescriptionDoseText(context, quantity) ?? quantity.formatFractional;
  }

  List<(String, String)> _fields(BuildContext context) {
    final l10n = context.l10n;
    final hospitalization = item.prescription?.hospitalization;
    final patient = hospitalization?.patient;

    return [
      (l10n.drugActivity_table_patientColumn, _v(patient?.fullName)),
      (l10n.patient_fieldProtocolNo, _v(patient?.protocolNo)),
      (l10n.hospitalization_fieldPhysicalService, _v(hospitalization?.physicalService?.name)),
      (l10n.hospitalization_fieldDoctor, _v(item.doctor?.fullName)),
      (l10n.patientInventory_table_barcodeColumn, _v(item.medicine?.barcode)),
      (l10n.unscannedBarcodes_detail_orderTimeLabel, _v(item.time.formattedDateTime)),
      (l10n.unscannedBarcodes_detail_prescribedQuantityLabel, _quantityText(context, item.dosePiece)),
      (l10n.unscannedBarcodes_detail_appliedQuantityLabel, _quantityText(context, item.receiveDosePiece)),
      (l10n.unscannedBarcodes_detail_applicationDateLabel, _v(item.applicationDate.formattedDateTime)),
      (l10n.movement_performedBy, _v(item.applicationUser?.fullName)),
      (l10n.unscannedBarcodes_table_scannedCountColumn, '${item.qrCodeCount ?? 0}'),
      (l10n.unscannedBarcodes_table_missingCountColumn, _v(item.missingQrCodeCount)),
      if (mode == BarcodeListMode.unscanned)
        (
          l10n.unscannedBarcodes_table_warningColumn,
          item.isWarningOn ? l10n.unscannedBarcodes_status_warningOn : l10n.unscannedBarcodes_status_warningOff,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final isDeleted = mode == BarcodeListMode.deleted;
    final orderDescription = item.description?.trim();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailDialogHeader(title: l10n.unscannedBarcodes_detailDialogTitle, subtitle: item.medicine?.name),
            Divider(height: 1, color: MedColors.border2),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MedSpacing.xl2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Silinen kayıtlarda en kritik bilgi silme gerekçesi — en üstte, vurgulu.
                    if (isDeleted) ...[
                      _DetailTextBlock(
                        label: l10n.unscannedBarcodes_detail_deleteDescriptionLabel,
                        value: _v(item.deleteDescription),
                        icon: PhosphorIcons.trash(),
                        color: MedColors.red,
                        background: MedColors.redLight,
                      ),
                      const SizedBox(height: MedSpacing.xl),
                    ],
                    _DetailInfoGrid(fields: _fields(context)),
                    if (orderDescription != null && orderDescription.isNotEmpty) ...[
                      const SizedBox(height: MedSpacing.xl),
                      _DetailTextBlock(
                        label: l10n.unscannedBarcodes_detail_orderDescriptionLabel,
                        value: orderDescription,
                        icon: PhosphorIcons.note(),
                        color: MedColors.text2,
                        background: MedColors.surface2,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailDialogHeader extends StatelessWidget {
  const _DetailDialogHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: MedTextStyles.titleSm(color: MedColors.text)),
                if (subtitle case final s? when s.isNotEmpty)
                  Text(s, style: MedTextStyles.bodyMd(color: MedColors.text3)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: Icon(PhosphorIcons.x(), size: 18, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

class _DetailInfoGrid extends StatelessWidget {
  const _DetailInfoGrid({required this.fields});

  final List<(String, String)> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = MedSpacing.lg;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (label, value) in fields)
              SizedBox(
                width: itemWidth,
                child: _DetailInfoTile(label: label, value: value),
              ),
          ],
        );
      },
    );
  }
}

class _DetailInfoTile extends StatelessWidget {
  const _DetailInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: 10),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
          const SizedBox(height: 2),
          Tooltip(
            message: value,
            waitDuration: const Duration(milliseconds: 600),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MedTextStyles.bodyMd(color: MedColors.text).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uzun serbest metinler (silme / order açıklaması) için tam genişlikli,
/// satır sınırı olmayan blok.
class _DetailTextBlock extends StatelessWidget {
  const _DetailTextBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MedSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: MedSpacing.sm),
              Text(label, style: MedTextStyles.bodySm(color: color).copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: MedSpacing.sm),
          SelectableText(value, style: MedTextStyles.bodyMd(color: MedColors.text)),
        ],
      ),
    );
  }
}
