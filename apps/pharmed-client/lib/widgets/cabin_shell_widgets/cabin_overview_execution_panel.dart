// [SWREQ-UI-CABINOVERVIEW-001] [IEC 62304 §5.5]
//
// Master kabin işlem YÜRÜTME fazında, TEK aktif konumun rehberini gösteren
// panel. Önceden bu dosya seçim/yürütme/bilgi modlarının hepsini tek çatı
// altında topluyordu — seçim artık kendi göz-grid'i olan
// CabinOverviewSelectionPanel'e, bilgi/arıza modu ayrı bir widget'a taşındı.
// Bu dosya SADECE yürütme: sağda satır listesi + altta seçili işin konum
// rehberi (kübik grid / birim doz üstten görünüm).
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinOverviewExecutionPanel extends StatelessWidget {
  const CabinOverviewExecutionPanel({super.key, required this.items, required this.activeIndex});

  final List<DrawerQueueItem> items;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final inQueue = items.where((i) => i.isInQueue).length;
    final completed = items.where((i) => i.status == DrawerQueueStatus.completed).length;
    final activeItem = items.firstWhereOrNull((i) => i.status == DrawerQueueStatus.active);

    final rows = items.map((item) {
      final (Color border, Color bg, Color text) = switch (item.status) {
        DrawerQueueStatus.active => (MedColors.blue, MedColors.blueLight, MedColors.blue),
        DrawerQueueStatus.completed => (MedColors.green, MedColors.greenLight, MedColors.text),
        DrawerQueueStatus.failed => (MedColors.red, MedColors.redLight, MedColors.text),
        DrawerQueueStatus.pending => (MedColors.border, MedColors.surface, MedColors.text),
        DrawerQueueStatus.notInQueue => (MedColors.border, MedColors.surface2, MedColors.text3),
      };

      return _OverviewRow(
        id: item.address,
        title: item.address,
        subtitle: item.isKubik ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
        segmentCount: item.isKubik ? 1 : item.units.length,
        borderColor: border,
        backgroundColor: bg,
        borderWidth: item.status == DrawerQueueStatus.active ? 1.5 : 1,
        textColor: text,
        trailing: _statusIcon(item.status),
      );
    }).toList();

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
            title: 'KABİN GENEL BAKIŞ',
            countLabel: '$completed/$inQueue',
            rows: rows,
            focusedRowId: activeItem?.address,
            maxListHeight: 300,
          ),
          if (activeItem != null) ...[
            Divider(height: 1, thickness: 1, color: MedColors.border),
            Flexible(child: _LocationSection(detail: _locationDetailFor(activeItem))),
          ],
        ],
      ),
    );
  }

  static Widget _statusIcon(DrawerQueueStatus status) {
    return switch (status) {
      DrawerQueueStatus.completed => Icon(
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        size: 16,
        color: MedColors.green,
      ),
      DrawerQueueStatus.failed => Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.red),
      DrawerQueueStatus.active => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(999)),
      ),
      DrawerQueueStatus.notInQueue => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      DrawerQueueStatus.pending => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.border2, borderRadius: BorderRadius.circular(999)),
      ),
    };
  }

  static _LocationDetail _locationDetailFor(DrawerQueueItem item) {
    final isReturnBoxTarget = item.isReturnDrawerTarget;

    if (isReturnBoxTarget && item.isKubik) {
      const mergedCount = 4;
      final normalCount = (item.units.length - mergedCount).clamp(0, item.units.length);
      final normalUnits = item.units.sublist(0, normalCount);

      // İade çekmecesinde (ReturnType.toDrawer) TÜM hedefler TEK ADIMDA
      // tamamlanır (bkz. MasterRefundNotifier.confirmCurrent, job.isReturnDrawer
      // dalı) — kübikteki gibi lid-by-lid bir "aktif hücre" kavramı YOK.
      // item.activeTargetIndex, donanım adresi için seçilen RASTGELE unit'e
      // (bkz. _resolveReturnDrawerAssignment) bağımlıydı ve bu genelde bir
      // NORMAL hücreyi yanlışlıkla aktif gösteriyordu. Gerçek hedef HER ZAMAN
      // birleşik son-4-hücre İADE kutusudur — normal hücreler hep idle kalır,
      // kutu bu fonksiyon zaten SADECE aktif item için çağrıldığı için
      // (bkz. build()'teki activeItem filtresi) doğrudan active kabul edilir.
      final rawNormalStates = List<_CellState>.filled(normalCount, _CellState.idle);
      final normalStates = reorderParallelToVisual(normalUnits, rawNormalStates, columnCount: 3);

      return _LocationDetail(
        address: item.address,
        typeLabel: 'KÜBİK',
        isKubik: true,
        cellStates: normalStates,
        mergedTrailingState: _CellState.active,
        mergedTrailingLabel: 'İADE',
        legendItems: const [
          _LegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Şu an dolduruluyor'),
          _LegendItem(color: MedColors.green, background: MedColors.greenLight, label: 'Tamamlandı'),
          _LegendItem(color: MedColors.border, background: MedColors.surface, label: 'Sırada'),
        ],
      );
    }

    if (item.isKubik) {
      final rawCellStates = [
        for (int i = 0; i < item.units.length; i++)
          item.completedTargetIndexes.contains(i)
              ? _CellState.completed
              : item.activeTargetIndex == i
              ? _CellState.active
              : !item.isInQueue
              ? _CellState.excluded
              : _CellState.idle,
      ];
      final cellStates = reorderParallelToVisual(item.units, rawCellStates, columnCount: 4);

      return _LocationDetail(
        address: item.address,
        typeLabel: 'KÜBİK',
        isKubik: true,
        cellStates: cellStates,
        legendItems: const [
          _LegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Şu an dolduruluyor'),
          _LegendItem(color: MedColors.green, background: MedColors.greenLight, label: 'Tamamlandı'),
          _LegendItem(color: MedColors.border, background: MedColors.surface, label: 'Sırada'),
        ],
      );
    }

    final unitCount = item.units.length;
    final steps = item.numberOfSteps > 0 ? item.numberOfSteps : 1;

    final grid = List.generate(steps, (_) => List<_CellState>.filled(unitCount, _CellState.idle, growable: false));

    // Hassas mod: en az bir completedCell VEYA activeStepNo varsa (bu ekran
    // stockIdAt sağlıyor demektir) — o zaman TAM hücre bazlı işaretleriz.
    final hasPreciseData = item.completedCells.isNotEmpty || item.activeStepNo != null;

    for (final (unitIdx, stepNo) in item.completedCells) {
      final r = stepNo - 1;
      if (r >= 0 && r < steps && unitIdx >= 0 && unitIdx < unitCount) {
        grid[r][unitIdx] = _CellState.completed;
      }
    }

    // FALLBACK: hassas veri yoksa (stockIdAt henüz sağlanmıyor), tamamlanan/
    // aktif sütunun TÜM derinliğini boyar — en azından "bu göz" bilgisi kaybolmaz.
    if (!hasPreciseData) {
      for (final unitIdx in item.completedTargetIndexes) {
        if (unitIdx < 0 || unitIdx >= unitCount) continue;
        for (final row in grid) {
          row[unitIdx] = _CellState.completed;
        }
      }
    }

    final activeUnit = item.activeTargetIndex;
    if (activeUnit != null && activeUnit >= 0 && activeUnit < unitCount) {
      if (item.activeStepNo != null) {
        final r = item.activeStepNo! - 1;
        if (r >= 0 && r < steps) grid[r][activeUnit] = _CellState.active;
      } else {
        for (final row in grid) {
          row[activeUnit] = _CellState.active;
        }
      }
    }

    return _LocationDetail(
      address: item.address,
      typeLabel: 'BİRİM DOZ',
      isKubik: false,
      cellStates: const [],
      depthGrid: grid,
      legendItems: const [
        _LegendItem(color: MedColors.blue, background: MedColors.blueLight, label: 'Şu an dolduruluyor'),
        _LegendItem(color: MedColors.green, background: MedColors.greenLight, label: 'Tamamlandı'),
        _LegendItem(color: MedColors.border, background: MedColors.surface, label: 'Sırada'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Üst satır listesi
// ─────────────────────────────────────────────────────────────────────────

enum _CellState { idle, active, completed, failed, excluded }

@immutable
class _OverviewRow {
  const _OverviewRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.segmentCount,
    required this.borderColor,
    required this.backgroundColor,
    this.borderWidth = 1,
    this.textColor,
    this.trailing,
  });

  final String id;
  final String title;
  final String subtitle;
  final int segmentCount;
  final Color borderColor;
  final Color backgroundColor;
  final double borderWidth;
  final Color? textColor;
  final Widget? trailing;
}

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
  final List<_OverviewRow> rows;
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
  final _OverviewRow row;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
              children: List.generate(
                row.segmentCount,
                (i) => Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: row.borderColor.withAlpha(102),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Konum Rehberi
// ─────────────────────────────────────────────────────────────────────────

@immutable
class _LegendItem {
  const _LegendItem({required this.color, required this.background, required this.label});
  final Color color;
  final Color background;
  final String label;
}

@immutable
class _LocationDetail {
  const _LocationDetail({
    required this.address,
    required this.typeLabel,
    required this.isKubik,
    required this.cellStates,
    this.legendItems = const [],
    this.mergedTrailingState,
    this.mergedTrailingLabel,
    this.depthGrid,
  });

  final String address;
  final String typeLabel;
  final bool isKubik;
  final List<_CellState> cellStates;
  final List<_LegendItem> legendItems;
  final _CellState? mergedTrailingState;
  final String? mergedTrailingLabel;
  final List<List<_CellState>>? depthGrid;
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.detail});
  final _LocationDetail detail;

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
          detail.isKubik
              ? _KubikGrid(
                  cellStates: detail.cellStates,
                  mergedTrailingState: detail.mergedTrailingState,
                  mergedTrailingLabel: detail.mergedTrailingLabel,
                )
              : _UnitDoseDepthGrid(grid: detail.depthGrid ?? const []),
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

class _KubikGrid extends StatelessWidget {
  const _KubikGrid({required this.cellStates, this.mergedTrailingState, this.mergedTrailingLabel});

  final List<_CellState> cellStates;
  final _CellState? mergedTrailingState;
  final String? mergedTrailingLabel;

  static const int _cols = 4;
  static const double _cellHeight = 48;
  static const double _spacing = 5;

  @override
  Widget build(BuildContext context) {
    final merged = mergedTrailingState;

    if (merged == null) {
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
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            mainAxisExtent: _cellHeight,
          ),
          itemCount: cellStates.length,
          itemBuilder: (_, i) => _CellBox(index: i, state: cellStates[i]),
        ),
      );
    }

    const normalCols = _cols - 1;
    final rows = (cellStates.length / normalCols).ceil();
    final gridHeight = rows * _cellHeight + (rows - 1) * _spacing;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8F5),
        border: Border.all(color: const Color(0xFFA8BEDB), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: normalCols,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: normalCols,
                crossAxisSpacing: _spacing,
                mainAxisSpacing: _spacing,
                mainAxisExtent: _cellHeight,
              ),
              itemCount: cellStates.length,
              itemBuilder: (_, i) => _CellBox(index: i, state: cellStates[i]),
            ),
          ),
          const SizedBox(width: _spacing),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: gridHeight,
              child: _CellBox(index: cellStates.length, state: merged, label: mergedTrailingLabel ?? 'İADE'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitDoseDepthGrid extends StatelessWidget {
  const _UnitDoseDepthGrid({required this.grid});

  /// [row][col] — row 0 = step 1 (çekmecenin ÖNÜ). Bu yön varsayımı
  /// donanım dokümantasyonundaki stepNo artışına dayanıyor — hardware
  /// testiyle teyit edilmeli, yanlışsa satırları ters çevirmek yeterli.
  final List<List<_CellState>> grid;

  static const double _cellSize = 28;
  static const double _spacing = 4;

  @override
  Widget build(BuildContext context) {
    if (grid.isEmpty || grid.first.isEmpty) return const SizedBox.shrink();

    final rowCount = grid.length;
    final colCount = grid.first.length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              for (int c = 0; c < colCount; c++) ...[
                if (c > 0) const SizedBox(width: _spacing),
                Expanded(
                  child: Text(
                    String.fromCharCode(65 + c),
                    textAlign: TextAlign.center,
                    style: MedTextStyles.monoXs(color: MedColors.text3),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          for (int r = 0; r < rowCount; r++) ...[
            if (r > 0) const SizedBox(height: _spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 20,
                  child: Text('${r + 1}', style: MedTextStyles.monoXs(color: MedColors.text3)),
                ),
                for (int c = 0; c < colCount; c++) ...[
                  if (c > 0) const SizedBox(width: _spacing),
                  SizedBox(
                    width: _cellSize * 2,
                    height: _cellSize,
                    child: _CellBox(index: r * colCount + c, state: grid[r][c], padded: false),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CellBox extends StatelessWidget {
  const _CellBox({required this.index, required this.state, this.label, this.padded = true});
  final int index;
  final _CellState state;
  final String? label;

  /// false ise (dış boyutu zaten sabitlenmiş, satır/sütun başlıklı grid'ler
  /// gibi) dikey padding UYGULANMAZ — sabit küçük hücrelerde padding
  /// content'i eziyordu (bkz. _UnitDoseDepthGrid, 32px hücre + 32px padding).
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color textColor;
    final double borderWidth;
    final List<BoxShadow>? shadow;
    final Widget? icon;

    switch (state) {
      case _CellState.completed:
        bg = MedColors.greenLight;
        border = MedColors.green;
        textColor = MedColors.green;
        borderWidth = 1.5;
        shadow = null;
        icon = Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 14, color: MedColors.green);
      case _CellState.failed:
        bg = MedColors.redLight;
        border = MedColors.red;
        textColor = MedColors.red;
        borderWidth = 1.5;
        shadow = null;
        icon = Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 14, color: MedColors.red);
      case _CellState.active:
        bg = MedColors.blueLight;
        border = MedColors.blue;
        textColor = MedColors.blue;
        borderWidth = 2;
        shadow = [const BoxShadow(color: Color(0x331A6FD8), blurRadius: 6, offset: Offset(0, 2))];
        icon = null;
      case _CellState.excluded:
        bg = MedColors.surface2;
        border = MedColors.border;
        textColor = MedColors.text4;
        borderWidth = 1.5;
        shadow = null;
        icon = null;
      case _CellState.idle:
        bg = MedColors.surface;
        border = MedColors.border;
        textColor = MedColors.text4;
        borderWidth = 1.5;
        shadow = null;
        icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: (padded && label != null) ? const EdgeInsets.symmetric(vertical: 16, horizontal: 4) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: borderWidth),
        borderRadius: BorderRadius.circular(6),
        boxShadow: shadow,
      ),
      child: Center(
        child:
            icon ??
            (label != null ? Text(label!, style: MedTextStyles.monoXs(color: textColor)) : const SizedBox.shrink()),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});
  final _LegendItem item;

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
