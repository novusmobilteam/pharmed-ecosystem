// [SWREQ-UI-CAB-003]
// Kabin işlemleri ekranının orta paneli.
// Seçili çekmeceye ait gözleri tıklanabilir olarak gösterir.
//
// Çekmece tipine göre farklı layout üretir, görsel her zaman aynıdır:
//   - Kübik      → NxM grid, her DrawerUnit bir göz
//   - Birim Doz  → gruplar + derinlik ekseni, pozisyon tabanlı (unitId + stepNo)
//   - Serum      → placeholder (TODO)
//
// Tıklama:
//   - Kübik: onCellTap(unit, null)
//   - Birim Doz: onCellTap(unit, stepNo)
//
// Assign modunda göz rengi ve içeriği [assignments] üzerinden gelir.
// Diğer modlarda [stocks] üzerinden gelir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/cabin/presentation/state/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Seçili çekmeceye ait gözleri gösterir.
///
/// [group] null ise boş durum gösterilir.
/// [assignments] assign modunda göz rengi ve ilaç adı için kullanılır.
/// [stocks] fill/count modlarında stok miktarı için kullanılır.
class DrawerDetailPanel extends StatelessWidget {
  const DrawerDetailPanel({
    super.key,
    required this.mode,
    this.group,
    this.stocks = const [],
    this.assignments = const [],
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final CabinOperationMode mode;
  final DrawerGroup? group;
  final List<CabinStock> stocks;
  final List<CabinAssignment> assignments;
  final int? selectedUnitId;
  final int? selectedStepNo;

  /// Kübik: (unit, null), Birim Doz: (unit, stepNo)
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final g = group;
    if (g == null) return const _EmptyState();

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 2),
        borderRadius: MedRadius.lgAll,
        boxShadow: const [
          BoxShadow(color: Color(0x1A1E3264), blurRadius: 16, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0A1E3264), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailHeader(group: g, mode: mode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _DetailBody(
                group: g,
                mode: mode,
                stocks: stocks,
                assignments: assignments,
                selectedUnitId: selectedUnitId,
                selectedStepNo: selectedStepNo,
                onCellTap: onCellTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.group, required this.mode});

  final DrawerGroup group;
  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_typeLabel(group), style: MedTextStyles.titleMd()),
          const SizedBox(height: 3),
          Text(_subLabel(group), style: MedTextStyles.monoMd(color: MedColors.text3)),
          const SizedBox(height: 8),
          _ModeBanner(mode: mode),
        ],
      ),
    );
  }

  String _typeLabel(DrawerGroup g) {
    if (g.isSerum) return 'Serum Çekmece';
    if (g.isKubik) return 'Kübik Çekmece';
    return 'Birim Doz Çekmece';
  }

  String _subLabel(DrawerGroup g) {
    if (g.isKubik) {
      final count = g.units.length;
      const cols = 4;
      final rows = (count / cols).ceil();
      return '$cols×$rows ($count göz)';
    }
    if (g.isSerum) return 'Raf görünümü';
    final config = g.slot.drawerConfig;
    final steps = config?.numberOfSteps ?? 0;
    final mult = config?.stepMultiplier ?? 1;
    return '${g.units.length} grup · $steps adım × $mult';
  }
}

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({required this.mode});
  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    final (bg, border, text, message) = _config(mode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: text),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, fontWeight: FontWeight.w500, color: text),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _config(CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign => (
      const Color(0xFFE8F1FC),
      const Color(0xFFC4D9F5),
      const Color(0xFF1256AA),
      'İlaç Atama — gözlere ilaç atayın, min/maks/kritik değerleri belirleyin.',
    ),
    CabinOperationMode.fill => (
      const Color(0xFFE6F7F2),
      const Color(0xFF9ED9C4),
      const Color(0xFF086E4A),
      'İlaç Dolum — dolum yapılacak göze dokunun, miktarı girin.',
    ),
    CabinOperationMode.count => (
      const Color(0xFFFEF3E2),
      const Color(0xFFF5C97A),
      const Color(0xFF92520A),
      'Sayım — fiili miktarı girin, sistem farkı hesaplayacak.',
    ),
    CabinOperationMode.fault => (
      const Color(0xFFFEF2F2),
      const Color(0xFFF9A8A8),
      const Color(0xFF9B1C1C),
      'Arıza — arızalı gözü işaretleyin ve açıklama girin.',
    ),
  };
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.group,
    required this.mode,
    required this.stocks,
    required this.assignments,
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final List<CabinStock> stocks;
  final List<CabinAssignment> assignments;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  /// Birim doz lookup: (unitId, stepNo) → CabinStock
  Map<(int, int), CabinStock> get _stockByUnitAndStep {
    final map = <(int, int), CabinStock>{};
    for (final s in stocks) {
      final unitId = s.cabinDrawerDetail?.drawerUnit?.id;
      final stepNo = s.cabinDrawerDetail?.stepNo;
      if (unitId != null && stepNo != null) map[(unitId, stepNo)] = s;
    }
    return map;
  }

  /// Kübik lookup: unitId → CabinStock
  Map<int, CabinStock> get _stockByUnitId {
    final map = <int, CabinStock>{};
    for (final s in stocks) {
      final unitId = s.cabinDrawerDetail?.drawerUnit?.id;
      if (unitId != null) map[unitId] = s;
    }
    return map;
  }

  /// Atama lookup: unitId → CabinAssignment
  Map<int, CabinAssignment> get _assignmentByUnitId {
    final map = <int, CabinAssignment>{};
    for (final a in assignments) {
      final unitId = a.cabinDrawerId;
      if (unitId != null) map[unitId] = a;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (group.isSerum) return const _SerumDetailView();

    if (group.isKubik) {
      return _KubicDetailView(
        group: group,
        mode: mode,
        stockByUnitId: _stockByUnitId,
        assignmentByUnitId: _assignmentByUnitId,
        selectedUnitId: selectedUnitId,
        onCellTap: (unit) => onCellTap?.call(unit, null),
      );
    }

    return _UnitDoseDetailView(
      group: group,
      mode: mode,
      stockByUnitAndStep: _stockByUnitAndStep,
      assignmentByUnitId: _assignmentByUnitId,
      selectedUnitId: selectedUnitId,
      selectedStepNo: selectedStepNo,
      onCellTap: onCellTap,
    );
  }
}

class _KubicDetailView extends StatelessWidget {
  const _KubicDetailView({
    required this.group,
    required this.mode,
    required this.stockByUnitId,
    required this.assignmentByUnitId,
    this.selectedUnitId,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final Map<int, CabinStock> stockByUnitId;
  final Map<int, CabinAssignment> assignmentByUnitId;
  final int? selectedUnitId;
  final void Function(DrawerUnit unit)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final units = group.units;
    const crossAxisCount = 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE8F5),
            border: Border.all(color: const Color(0xFFA8BEDB), width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              mainAxisExtent: 120,
            ),
            itemCount: units.length,
            itemBuilder: (context, i) {
              final unit = units[i];
              final stock = stockByUnitId[unit.id];
              final assignment = assignmentByUnitId[unit.id];
              return _CabinCell(
                unit: unit,
                stock: stock,
                assignment: assignment,
                mode: mode,
                code: '',
                isSelected: selectedUnitId == unit.id,
                isKubik: true,
                onTap: unit.workingStatus == CabinWorkingStatus.working ? () => onCellTap?.call(unit) : null,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _ModeLegend(mode: mode),
      ],
    );
  }
}

class _UnitDoseDetailView extends StatelessWidget {
  const _UnitDoseDetailView({
    required this.group,
    required this.mode,
    required this.stockByUnitAndStep,
    required this.assignmentByUnitId,
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final Map<(int, int), CabinStock> stockByUnitAndStep;
  final Map<int, CabinAssignment> assignmentByUnitId;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final config = group.slot.drawerConfig;
    final numberOfSteps = config?.numberOfSteps ?? 6;
    final stepMultiplier = config?.stepMultiplier ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E4F0),
                  border: Border.all(color: const Color(0xFFA0B8D0), width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    for (int step = 0; step < numberOfSteps; step++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            for (int gi = 0; gi < group.units.length; gi++) ...[
                              for (int w = 0; w < stepMultiplier; w++) ...[
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      final unit = group.units[gi];
                                      final stepNo = step * stepMultiplier + w + 1;
                                      final stock = stockByUnitAndStep[(unit.id, stepNo)];
                                      final assignment = assignmentByUnitId[unit.id];
                                      return _CabinCell(
                                        unit: unit,
                                        stock: stock,
                                        assignment: assignment,
                                        mode: mode,
                                        code: 'G${gi + 1}·$stepNo',
                                        isSelected: selectedUnitId == unit.id && selectedStepNo == stepNo,
                                        isKubik: false,
                                        onTap: unit.workingStatus == CabinWorkingStatus.working
                                            ? () => onCellTap?.call(unit, stepNo)
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                                if (w < stepMultiplier - 1) const SizedBox(width: 2),
                              ],
                              if (gi < group.units.length - 1)
                                Container(
                                  width: 3,
                                  height: 24,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA0B8D0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ModeLegend(mode: mode),
      ],
    );
  }
}

/// Hem kübik hem birim doz'da kullanılan tek göz widget'ı.
///
/// Assign modunda renk ve içerik [assignment]'tan gelir.
/// Diğer modlarda [stock]'tan gelir.
///
/// [isKubik] true → kare görünüm, false → sabit 24px yükseklik.
/// [onTap] null → kilitli (arızalı/bakım).
class _CabinCell extends StatelessWidget {
  const _CabinCell({
    required this.unit,
    required this.mode,
    required this.code,
    required this.isSelected,
    required this.isKubik,
    this.stock,
    this.assignment,
    this.onTap,
  });

  final DrawerUnit unit;
  final CabinStock? stock;
  final CabinAssignment? assignment;
  final CabinOperationMode mode;
  final String code;
  final bool isSelected;
  final bool isKubik;
  final VoidCallback? onTap;

  bool get _isLocked => onTap == null;

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus();
    final colors = _CellColors.of(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: isKubik ? null : 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isLocked ? [const Color(0xFFF0F0F0), const Color(0xFFE0E0E0)] : [colors.bgLight, colors.bgDark],
          ),
          border: Border.all(
            color: isSelected ? MedColors.blue : (_isLocked ? const Color(0xFFCCCCCC) : colors.border),
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(isKubik ? 7 : 5),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x4D1A6FD8), blurRadius: 8, offset: Offset(0, 2))]
              : null,
        ),
        child: _isLocked ? _lockedContent() : _activeContent(),
      ),
    );
  }

  Widget _lockedContent() => Center(
    child: Icon(
      unit.workingStatus == CabinWorkingStatus.faulty ? Icons.error_outline : Icons.build_circle_outlined,
      size: isKubik ? 16 : 10,
      color: unit.workingStatus == CabinWorkingStatus.faulty ? MedColors.red : MedColors.amber,
    ),
  );

  Widget _activeContent() {
    if (isKubik) {
      return Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0x993250780),
              ),
            ),
          ),
          Positioned(bottom: 4, left: 4, right: 4, child: _cellContent()),
        ],
      );
    }

    // Birim doz — assign modunda ilaç adı gösterilmez, sadece renk yeterli
    if (mode == CabinOperationMode.assign) {
      return Center(child: _cellContent());
    }

    final s = stock;
    if (s == null) return const SizedBox.shrink();
    return Center(child: _stockContent(s));
  }

  /// Kübik cell içeriği — moda göre farklı bilgi
  Widget _cellContent() => switch (mode) {
    CabinOperationMode.assign => _assignContent(),
    CabinOperationMode.fill || CabinOperationMode.count => _stockFillContent(),
    CabinOperationMode.fault => const SizedBox.shrink(),
  };

  /// Assign modunda: ilaç adı (atanmışsa)
  Widget _assignContent() {
    final a = assignment;
    if (a == null || a.id == null) return const SizedBox.shrink();

    final drugName = a.medicine?.name ?? '—';

    return Text(
      drugName,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xCC1256AA),
      ),
    );
  }

  /// Fill/Count modunda: ilaç adı + miktar
  Widget _stockFillContent() {
    final s = stock;
    if (s == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.medicine?.name != null)
          Text(
            s.medicine!.name!.split(' ').take(2).join(' '),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 7, color: const Color(0xCC1A6FD8)),
          ),
        Text(
          '${s.quantity?.toInt() ?? 0}/${s.assignment?.maxQuantity?.toInt() ?? 0}',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: MedFonts.mono, fontSize: 8, fontWeight: FontWeight.w600, color: _qtyColor(s)),
        ),
      ],
    );
  }

  Widget _stockContent(CabinStock s) => Text(
    '${s.quantity?.toInt() ?? 0}',
    textAlign: TextAlign.center,
    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 8, fontWeight: FontWeight.w600, color: _qtyColor(s)),
  );

  Color _qtyColor(CabinStock s) {
    final qty = s.quantity?.toDouble() ?? 0;
    final crit = s.assignment?.criticalQuantity?.toDouble() ?? 0;
    final min = s.assignment?.minQuantity?.toDouble() ?? 0;
    if (qty <= crit) return MedColors.red;
    if (qty <= min) return MedColors.amber;
    return MedColors.green;
  }

  _DrawerCellStatus _resolveStatus() {
    if (unit.workingStatus == CabinWorkingStatus.faulty) return _DrawerCellStatus.fault;
    if (unit.workingStatus == CabinWorkingStatus.maintenance) return _DrawerCellStatus.maintenance;

    // Assign modunda renk atama üzerinden gelir
    if (mode == CabinOperationMode.assign) {
      final a = assignment;
      if (a != null && a.id != null) return _DrawerCellStatus.assigned;
      return _DrawerCellStatus.empty;
    }

    // Diğer modlarda stok üzerinden
    final s = stock;
    if (s == null) return _DrawerCellStatus.empty;
    final qty = s.quantity?.toDouble() ?? 0;
    final crit = s.assignment?.criticalQuantity?.toDouble() ?? 0;
    final min = s.assignment?.minQuantity?.toDouble() ?? 0;
    if (qty == 0) return _DrawerCellStatus.empty;
    if (qty <= crit) return _DrawerCellStatus.critical;
    if (qty <= min) return _DrawerCellStatus.low;
    return _DrawerCellStatus.assigned;
  }
}

class _SerumDetailView extends StatelessWidget {
  const _SerumDetailView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.smAll,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined, size: 32, color: MedColors.text4),
            const SizedBox(height: 8),
            Text('Serum görünümü', style: MedTextStyles.bodySm(color: MedColors.text3)),
            const SizedBox(height: 4),
            Text('TODO: Serum iç yapısı netleşince tamamlanacak', style: MedTextStyles.monoSm(color: MedColors.text4)),
          ],
        ),
      ),
    );
  }
}

class _ModeLegend extends StatelessWidget {
  const _ModeLegend({required this.mode});

  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: _items(mode).map((item) {
        final colors = _CellColors.of(item.$1);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.bgLight,
                border: Border.all(color: colors.border, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 5),
            Text(item.$2, style: MedTextStyles.bodySm(color: MedColors.text2)),
          ],
        );
      }).toList(),
    );
  }

  List<(_DrawerCellStatus, String)> _items(CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign => [
      (_DrawerCellStatus.empty, 'Boş göz (ata)'),
      (_DrawerCellStatus.assigned, 'İlaç atanmış'),
      (_DrawerCellStatus.fault, 'Arızalı'),
      (_DrawerCellStatus.maintenance, 'Bakımda'),
    ],
    CabinOperationMode.fill => [
      (_DrawerCellStatus.empty, 'Boş (dolum yok)'),
      (_DrawerCellStatus.assigned, 'Normal stok'),
      (_DrawerCellStatus.low, 'Dolum gerekiyor'),
      (_DrawerCellStatus.critical, 'Acil dolum'),
    ],
    CabinOperationMode.count => [
      (_DrawerCellStatus.assigned, 'Sayılacak (ilaçlı)'),
      (_DrawerCellStatus.low, 'Düşük stok'),
      (_DrawerCellStatus.empty, 'Boş (atla)'),
    ],
    CabinOperationMode.fault => [
      (_DrawerCellStatus.assigned, 'Normal çalışıyor'),
      (_DrawerCellStatus.fault, 'Arıza bildirildi'),
      (_DrawerCellStatus.empty, 'Boş göz'),
    ],
  };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.lgAll,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: MedColors.text4),
            const SizedBox(height: 16),
            Text('Bir çekmeceye dokunun', style: MedTextStyles.bodyMd(color: MedColors.text3)),
            const SizedBox(height: 6),
            Text(
              'Kübik · Birim Doz · Serum iç yapıları görüntülenecek',
              style: MedTextStyles.monoMd(color: MedColors.text4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Göz durum enum ve renk yardımcısı
// ─────────────────────────────────────────────────────────────────

enum _DrawerCellStatus { empty, assigned, low, critical, fault, maintenance }

final class _CellColors {
  const _CellColors({required this.bgLight, required this.bgDark, required this.border});

  final Color bgLight;
  final Color bgDark;
  final Color border;

  static _CellColors of(_DrawerCellStatus status) => switch (status) {
    _DrawerCellStatus.empty => const _CellColors(
      bgLight: Color(0xFFE8EDF5),
      bgDark: Color(0xFFD8E2EE),
      border: Color(0xFFA8B8CC),
    ),
    _DrawerCellStatus.assigned => const _CellColors(
      bgLight: Color(0xFFDDEEFF),
      bgDark: Color(0xFFC8D8EE),
      border: Color(0xFF7AB0D8),
    ),
    _DrawerCellStatus.low => const _CellColors(
      bgLight: Color(0xFFFFFBEB),
      bgDark: Color(0xFFFEF3C7),
      border: Color(0xFFF5C97A),
    ),
    _DrawerCellStatus.critical => const _CellColors(
      bgLight: Color(0xFFFEF2F2),
      bgDark: Color(0xFFFDE8E8),
      border: Color(0xFFF9A8A8),
    ),
    _DrawerCellStatus.fault => const _CellColors(
      bgLight: Color(0xFFFFF0F0),
      bgDark: Color(0xFFFEE2E2),
      border: Color(0xFFDC2626),
    ),
    _DrawerCellStatus.maintenance => const _CellColors(
      bgLight: Color(0xFFFFFBEB),
      bgDark: Color(0xFFFEF3C7),
      border: Color(0xFFF59E0B),
    ),
  };
}
