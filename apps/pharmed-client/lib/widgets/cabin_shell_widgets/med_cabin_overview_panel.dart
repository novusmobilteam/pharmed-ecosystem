// [SWREQ-UI-MEDOVERVIEW-001] [IEC 62304 §5.5]
//
// pharmed_ui — generic, domain-agnostic "kabin genel bakış" bileşeni.
// CabinDrawerSelectionGuide (seçim), CabinLocationGuide (yürütme) ve
// MobileCabinOverviewPanel (bilgi/arıza) widget'larının YERİNE geçer.
//
// Bu dosya hiçbir cabin domain modelini (DrawerGroup, DrawerQueueItem,
// MobileSlotVisual, ...) bilmez. Tüm domain mantığı (renk çözümü, tri-state,
// fault override, DrawerQueueStatus eşlemesi) ÇAĞIRAN tarafta çözülür ve
// buraya önceden hazırlanmış [MedOverviewRow]/[MedCabinLocationDetail]
// olarak beslenir. Bkz. cabin-shell-widgets skill §9 — "domain bilgisi
// çağıran panelde çözülür" prensibi.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Bir hücrenin (kübik lid veya birim doz gözü) görsel durumu.
///
/// Hem SEÇİM modunun (target/idle) hem YÜRÜTME modunun
/// (active/completed/failed) hem de "bu işleme dahil değil" (excluded)
/// durumunu tek bir ortak sözlükte ifade eder — [MedCabinLocationDetail]
/// bu enum'a bakarak render eder, kaynağın DrawerGroup mu DrawerQueueItem
/// mı olduğunu hiç bilmez.
enum MedCellState {
  /// Nötr, hiçbir özel anlamı yok (sırada/boş).
  idle,

  /// Seçim modunda: kullanıcı bu hücreyi seçti (henüz yürütülmüyor).
  target,

  /// Yürütme modunda: şu an fiziksel olarak işleniyor.
  active,

  /// Yürütme modunda: tamamlandı.
  completed,

  /// Yürütme modunda: hata.
  failed,

  /// Bu işleme hiç dahil değil (soluk, pasif gösterim).
  excluded,
}

/// [MedCabinOverviewPanel]'in üst listesindeki tek bir satır.
///
/// Tüm renk/trailing/tıklanabilirlik kararları ÇAĞIRAN tarafından
/// önceden verilir — bu sınıf saf bir veri taşıyıcıdır.
@immutable
class MedOverviewRow {
  const MedOverviewRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.segmentCount,
    required this.borderColor,
    required this.backgroundColor,
    this.borderWidth = 1,
    this.textColor,
    this.segmentColorAt,
    this.trailing,
    this.onTap,
  });

  /// Benzersiz kimlik — [MedCabinOverviewPanel.focusedRowId] ile eşleştirmede kullanılır.
  final String id;

  final String title;
  final String subtitle;

  /// Satırın altındaki mini önizleme şeridindeki segment sayısı.
  /// Kübik çekmece → 1 (tek çizgi). Birim doz çekmece → göz sayısı.
  /// 0 verilirse şerit hiç render edilmez.
  final int segmentCount;

  final Color borderColor;
  final Color backgroundColor;
  final double borderWidth;
  final Color? textColor;

  /// Segment şeridindeki her bir dilimin rengini üretir. null dönerse
  /// [borderColor]'ın soluk hali kullanılır.
  final Color? Function(int index)? segmentColorAt;

  /// Sağ taraf — checkbox (seçim), durum ikonu (yürütme) veya fault
  /// rozeti (bilgi modu). null → hiç render edilmez.
  final Widget? trailing;

  /// null → satır tıklanamaz.
  final VoidCallback? onTap;
}

/// Legend'da (Konum Rehberi altında) gösterilen tek bir açıklama satırı.
@immutable
class MedLegendItem {
  const MedLegendItem({required this.color, required this.background, required this.label});

  final Color color;
  final Color background;
  final String label;
}

/// Alt "Konum Rehberi" bölümünün verisi. null verilirse bu bölüm hiç
/// render edilmez (örn. bilgi/arıza modunda veya konum detayının anlamlı
/// olmadığı ekranlarda).
@immutable
class MedCabinLocationDetail {
  const MedCabinLocationDetail({
    required this.address,
    required this.typeLabel,
    required this.isKubik,
    required this.cellStates,
    this.legendItems = const [],
  });

  final String address;

  /// "Kübik" / "Birim Doz" gibi — başlığın yanında gösterilir.
  final String typeLabel;
  final bool isKubik;

  /// Kübik: her lid için bir eleman (4×N grid sırasıyla doldurulur).
  /// Birim doz: her göz için bir eleman (soldan sağa sütun).
  final List<MedCellState> cellStates;
  final List<MedLegendItem> legendItems;
}

/// Tek, mod-agnostik "kabin genel bakış" paneli.
///
/// Üstte satır listesi ([rows]), altta opsiyonel Konum Rehberi
/// ([locationDetail]). Mod (seçim/yürütme/bilgi) burada bir enum olarak
/// YOKTUR — çünkü satır davranışı (trailing/onTap/renk) zaten [rows]
/// içinde önceden çözülmüş geliyor. Widget sadece neyin verildiğini render
/// eder.
class MedCabinOverviewPanel extends StatelessWidget {
  const MedCabinOverviewPanel({
    super.key,
    required this.title,
    required this.rows,
    this.countLabel,
    this.locationDetail,
    this.focusedRowId,
    this.footer,
    this.hint,
    this.maxListHeight,
  });

  /// "KABİN GENEL BAKIŞ" gibi üst başlık.
  final String title;

  /// Sağ üstteki sayaç ("3/5 çekmece", "1/4", "4 çekmece"). null → gizli.
  final String? countLabel;

  final List<MedOverviewRow> rows;

  /// Şu an listede vurgulanan (kalın border) satırın id'si. Genelde
  /// yürütmede "aktif" iş, seçimde "son dokunulan" çekmece.
  final String? focusedRowId;

  /// null → Konum Rehberi bölümü hiç render edilmez.
  final MedCabinLocationDetail? locationDetail;

  /// Liste altında, ayraçla ayrılmış footer (örn. "Tümünü Seç" butonu +
  /// "3 çekmece seçili" özeti). null → hiç render edilmez.
  final Widget? footer;

  /// Liste altında küçük açıklama metni (örn. "arıza rengi kart
  /// kenarlığını override eder"). null → hiç render edilmez.
  final String? hint;

  /// Satır listesi için scroll sınırı. null → sınırsız (execution'da
  /// Konum Rehberi ile birlikte `Expanded` içinde kullanılabilmesi için).
  final double? maxListHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _OverviewSection(
            title: title,
            countLabel: countLabel,
            rows: rows,
            focusedRowId: focusedRowId,
            maxListHeight: maxListHeight,
          ),
          if (hint != null) ...[
            Divider(height: 1, thickness: 1, color: MedColors.border),
            Padding(
              padding: MedSpacing.insetMd,
              child: Text(hint!, style: MedTextStyles.bodySm(color: MedColors.text3)),
            ),
          ],
          if (locationDetail != null) ...[
            Divider(height: 1, thickness: 1, color: MedColors.border),
            Flexible(child: _LocationSection(detail: locationDetail!)),
          ],
          if (footer != null) ...[
            Divider(height: 1, thickness: 1, color: MedColors.border),
            Padding(padding: MedSpacing.insetMd, child: footer!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 1. Genel Bakış (satır listesi)
// ─────────────────────────────────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.title,
    required this.countLabel,
    required this.rows,
    required this.focusedRowId,
    required this.maxListHeight,
  });

  final String title;
  final String? countLabel;
  final List<MedOverviewRow> rows;
  final String? focusedRowId;
  final double? maxListHeight;

  @override
  Widget build(BuildContext context) {
    final list = Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          _RowTile(row: rows[i], isFocused: rows[i].id == focusedRowId),
          if (i < rows.length - 1) const SizedBox(height: 4),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: MedTextStyles.bodyMd(color: MedColors.text3)),
              if (countLabel != null) ...[
                const Spacer(),
                Text(countLabel!, style: MedTextStyles.monoMd(color: MedColors.text3)),
              ],
            ],
          ),
          const SizedBox(height: 12.0),
          maxListHeight != null
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight!),
                  child: SingleChildScrollView(child: list),
                )
              : list,
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.isFocused});

  final MedOverviewRow row;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: row.onTap,
      borderRadius: MedRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: row.backgroundColor,
          border: Border.all(color: row.borderColor, width: isFocused ? row.borderWidth + 0.5 : row.borderWidth),
          borderRadius: MedRadius.mdAll,
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
                      Text(row.title, style: MedTextStyles.titleSm(color: row.textColor)),
                      Text(row.subtitle, style: MedTextStyles.monoXs(color: MedColors.text3)),
                    ],
                  ),
                ),
                if (row.trailing != null) ...[const SizedBox(width: 8), row.trailing!],
              ],
            ),
            if (row.segmentCount > 0) ...[
              const SizedBox(height: 6),
              Row(
                spacing: 2,
                children: List.generate(row.segmentCount, (i) {
                  return Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: row.segmentColorAt?.call(i) ?? row.borderColor.withAlpha(102),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 2. Konum Rehberi (opsiyonel detay)
// ─────────────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.detail});

  final MedCabinLocationDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('KONUM REHBERİ', style: MedTextStyles.monoXs(color: MedColors.text3)),
              const Spacer(),
              Text(detail.typeLabel, style: MedTextStyles.monoXs(color: MedColors.text3)),
            ],
          ),
          const SizedBox(height: 4),
          Text(detail.address, style: MedTextStyles.titleLg()),
          const SizedBox(height: 14),
          detail.isKubik ? _KubikGrid(cellStates: detail.cellStates) : _UnitDoseTopView(cellStates: detail.cellStates),
          if (detail.legendItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < detail.legendItems.length; i++) ...[
                  _LegendRow(item: detail.legendItems[i]),
                  if (i < detail.legendItems.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Kübik çekmece — 4×N grid, her lid [MedCellState]'e göre boyanır.
class _KubikGrid extends StatelessWidget {
  const _KubikGrid({required this.cellStates});

  final List<MedCellState> cellStates;

  static const int _cols = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8F5),
        border: Border.all(color: const Color(0xFFA8BEDB), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          mainAxisExtent: 48,
        ),
        itemCount: cellStates.length,
        itemBuilder: (_, i) => _CellBox(index: i, state: cellStates[i]),
      ),
    );
  }
}

/// Birim doz çekmece — üstten bakış, yan yana bölmeler.
class _UnitDoseTopView extends StatelessWidget {
  const _UnitDoseTopView({required this.cellStates});

  final List<MedCellState> cellStates;

  @override
  Widget build(BuildContext context) {
    if (cellStates.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < cellStates.length; i++) ...[
              Expanded(
                child: _CellBox(
                  index: i,
                  state: cellStates[i],
                  label: String.fromCharCode(65 + i), // A, B, C...
                ),
              ),
              if (i < cellStates.length - 1)
                Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(color: const Color(0xFFA0B8D0), borderRadius: BorderRadius.circular(2)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tek hücre — hem kübik grid (numara) hem birim doz sütunu (harf) için
/// kullanılır. [label] verilmezse index+1 numara olarak gösterilir.
class _CellBox extends StatelessWidget {
  const _CellBox({required this.index, required this.state, this.label});

  final int index;
  final MedCellState state;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color textColor;
    final double borderWidth;
    final List<BoxShadow>? shadow;
    final Widget? icon;

    switch (state) {
      case MedCellState.completed:
        bg = MedColors.greenLight;
        border = MedColors.green;
        textColor = MedColors.green;
        borderWidth = 1.5;
        shadow = null;
        icon = Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 14, color: MedColors.green);
      case MedCellState.failed:
        bg = MedColors.redLight;
        border = MedColors.red;
        textColor = MedColors.red;
        borderWidth = 1.5;
        shadow = null;
        icon = Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 14, color: MedColors.red);
      case MedCellState.active:
        bg = MedColors.blueLight;
        border = MedColors.blue;
        textColor = MedColors.blue;
        borderWidth = 2;
        shadow = [const BoxShadow(color: Color(0x331A6FD8), blurRadius: 6, offset: Offset(0, 2))];
        icon = null;
      case MedCellState.target:
        bg = MedColors.blueLight;
        border = MedColors.blue;
        textColor = MedColors.blue;
        borderWidth = 1.5;
        shadow = null;
        icon = null;
      case MedCellState.excluded:
        bg = MedColors.surface2;
        border = MedColors.border;
        textColor = MedColors.text4;
        borderWidth = 1.5;
        shadow = null;
        icon = null;
      case MedCellState.idle:
        bg = MedColors.surface;
        border = MedColors.border;
        textColor = MedColors.text4;
        borderWidth = 1.5;
        shadow = null;
        icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: label != null ? const EdgeInsets.symmetric(vertical: 16, horizontal: 4) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: borderWidth),
        borderRadius: BorderRadius.circular(6),
        boxShadow: shadow,
      ),
      child: Center(
        child: icon ?? Text(label ?? '${index + 1}', style: MedTextStyles.monoXs(color: textColor)),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});

  final MedLegendItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: item.background,
            border: Border.all(color: item.color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(item.label, style: MedTextStyles.bodySm(color: MedColors.text2)),
        ),
      ],
    );
  }
}
