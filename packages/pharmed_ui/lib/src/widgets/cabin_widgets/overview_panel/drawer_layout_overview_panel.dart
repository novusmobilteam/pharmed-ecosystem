part of 'overview_panel.dart';

// [SWREQ-UI-CABINOVERVIEW-002] [IEC 62304 §5.5]
//
// Bir DrawerQueueItem'ın (aktif çekmece/göz) fiziksel konumunu ve o anki
// doldurma/alım durumunu şematik bir grid olarak çizen panel — kübik
// (4 sütunlu göz grid'i, opsiyonel birleşik iade gözü) ve birim doz
// (derinlik/step bazlı grid) olmak üzere iki farklı çizim moduna sahiptir.
//
// Önceden CabinOverviewExecutionPanel'in İÇİNDE (_LocationSection) yaşıyordu
// — bağımsız bir widget'a çıkarıldı ki tek bir aktif item'ın konum rehberi,
// üstteki satır listesine (hangi çekmecelerin kuyrukta olduğu) bağımlı
// olmadan, farklı bağlamlarda (örn. çoklu kabin şeridinin altında) tek
// başına kullanılabilsin.
//
// Sınıf: Class B

// Aktif çekmecenin/gözün göz grid'ini (kübik) ya da derinlik grid'ini
// (birim doz) çizer. Artık TEK BAŞINA görüneceği için önceki versiyondan
// daha kompakt: küçük hücreler, legend yok (renk anlamı diğer panellerle
// zaten tutarlı: mavi=aktif, yeşil=tamam, gri=boş).
class DrawerLayoutOverviewPanel extends StatelessWidget {
  const DrawerLayoutOverviewPanel({super.key, required this.item});

  final DrawerQueueItem item;

  static const double _spacing = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: MedDecoration.panelDecoration.copyWith(border: Border.all(color: MedColors.border)),
      // Expanded/SizedBox olmadan Container kendi içeriğine göre büzülür —
      // grid'in mevcut alanı DOLDURMASI için sınırlı bir yükseklik/genişlik
      // vermemiz gerekiyor. Bu widget'ı çağıran taraf zaten Expanded içine
      // koyuyorsa (execution view'daki flex:3 gibi) bu SizedBox.expand
      // o kısıtı aşağı, LayoutBuilder'a taşıyor.
      child: SizedBox.expand(child: item.isKubik ? _kubikGrid(context) : _unitDoseGrid(context)),
    );
  }

  Widget _kubikGrid(BuildContext context) {
    const columnCount = 4;

    // Seçim paneliyle AYNI görsel sıra — ham unit sırası fiziksel düzenle
    // eşleşmiyor (bkz. CabinOverviewSelectionPanel / kübik transpozisyon).
    final visualUnits = kubikUnitsInVisualOrder(item.units, columnCount: columnCount);

    // İade çekmecesinde son sütun fiziksel olarak tek kutu — tek tek
    // çizilmez, tek bir blok olarak gösterilir.
    final isReturnDrawer = item.group.isReturnDrawer;
    final normalColumnCount = isReturnDrawer ? columnCount - 1 : columnCount;

    // Her görsel hücre için item.units'teki HAM indeks — aktif/tamamlanan
    // işaretleri bu indekslere göre tutuluyor.
    final normalIndices = <int>[
      for (var i = 0; i < visualUnits.length; i++)
        if (!isReturnDrawer || i % columnCount != columnCount - 1) item.units.indexOf(visualUnits[i]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowCount = (visualUnits.length / columnCount).ceil();
        final cellHeight = rowCount > 0
            ? (constraints.maxHeight - _spacing * (rowCount - 1)) / rowCount
            : constraints.maxHeight;

        final grid = GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: normalColumnCount,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            mainAxisExtent: cellHeight,
          ),
          itemCount: normalIndices.length,
          itemBuilder: (context, i) {
            final rawIndex = normalIndices[i];
            return _Cell(
              isCompleted: item.completedTargetIndexes.contains(rawIndex),
              isActive: item.activeTargetIndex == rawIndex,
            );
          },
        );

        if (!isReturnDrawer) return grid;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: normalColumnCount, child: grid),
            const SizedBox(width: _spacing),
            Expanded(
              child: _ReturnBlock(
                isActive: item.isReturnDrawerTarget && item.status == DrawerQueueStatus.active,
                isCompleted: item.isReturnDrawerTarget && item.status == DrawerQueueStatus.completed,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _unitDoseGrid(BuildContext context) {
    final unitCount = item.units.length;
    final steps = item.numberOfSteps > 0 ? item.numberOfSteps : 1;

    final grid = List.generate(steps, (_) => List<_CellState>.filled(unitCount, _CellState.idle, growable: false));

    final hasPreciseData = item.completedCells.isNotEmpty || item.activeStepNo != null || item.activeCells.isNotEmpty;

    for (final (unitIdx, stepNo) in item.completedCells) {
      final r = steps - stepNo;
      if (r >= 0 && r < steps && unitIdx >= 0 && unitIdx < unitCount) {
        grid[r][unitIdx] = _CellState.completed;
      }
    }

    if (!hasPreciseData) {
      for (final unitIdx in item.completedTargetIndexes) {
        if (unitIdx < 0 || unitIdx >= unitCount) continue;
        for (final row in grid) {
          row[unitIdx] = _CellState.completed;
        }
      }
    }

    if (item.activeCells.isNotEmpty) {
      for (final (unitIdx, stepNo) in item.activeCells) {
        final r = steps - stepNo;
        if (r >= 0 && r < steps && unitIdx >= 0 && unitIdx < unitCount) {
          grid[r][unitIdx] = _CellState.active;
        }
      }
    } else {
      final activeUnit = item.activeTargetIndex;
      if (activeUnit != null && activeUnit >= 0 && activeUnit < unitCount) {
        if (item.activeStepNo != null) {
          final r = steps - item.activeStepNo!;
          if (r >= 0 && r < steps) grid[r][activeUnit] = _CellState.active;
        } else {
          for (final row in grid) {
            row[activeUnit] = _CellState.active;
          }
        }
      }
    }

    return Column(
      // mainAxisSize: min KALDIRILDI — Column artık SizedBox.expand'in
      // verdiği tüm yüksekliği dolduruyor, Expanded'lar bu alanı satırlar
      // arasında eşit bölüşüyor.
      children: [
        for (var r = 0; r < steps; r++) ...[
          if (r > 0) const SizedBox(height: _spacing),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text('${steps - r}', style: MedTextStyles.monoXs(color: MedColors.text3)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      for (var c = 0; c < unitCount; c++) ...[
                        if (c > 0) const SizedBox(width: _spacing),
                        Expanded(
                          child: _Cell(
                            isCompleted: grid[r][c] == _CellState.completed,
                            isActive: grid[r][c] == _CellState.active,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _CellState { idle, active, completed }

class _Cell extends StatelessWidget {
  const _Cell({required this.isCompleted, required this.isActive});
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border) = isCompleted
        ? (MedColors.greenLight, MedColors.green)
        : isActive
        ? (MedColors.blueLight, MedColors.blue)
        : (MedColors.surface, MedColors.border);

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: isActive ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isCompleted
            ? Center(child: Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 12, color: MedColors.green))
            : null,
      ),
    );
  }
}

/// İade çekmecesinin birleşik son sütunu — fiziksel olarak tek kutu.
class _ReturnBlock extends StatelessWidget {
  const _ReturnBlock({required this.isActive, required this.isCompleted});

  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color text) = isCompleted
        ? (MedColors.greenLight, MedColors.green, MedColors.green)
        : isActive
        ? (MedColors.blueLight, MedColors.blue, MedColors.blue)
        : (MedColors.amberLight, MedColors.amber, MedColors.amber);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isActive ? 2 : 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.cabinDesign_returnBadge,
        style: MedTextStyles.monoXs(color: text),
        textAlign: TextAlign.center,
      ),
    );
  }
}
