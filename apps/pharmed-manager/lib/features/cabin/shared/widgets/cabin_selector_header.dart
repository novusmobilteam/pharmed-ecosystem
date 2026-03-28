part of 'cabin_editor/cabin_editor_view.dart';

/// Kabinleri yatayda listeleyen ve seçim yaptıran widget
class CabinSelectorHeader extends StatelessWidget {
  final List<Cabin> cabins;
  final Cabin? selectedCabin;
  final Function(Cabin) onCabinSelected;

  const CabinSelectorHeader({
    super.key,
    required this.cabins,
    required this.selectedCabin,
    required this.onCabinSelected,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Yüksekliği biraz daralttık
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: cabins.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24), // Öğeler arası boşluğu açtık
        itemBuilder: (context, index) {
          final cabin = cabins[index];
          final isSelected = selectedCabin?.id == cabin.id;

          return InkWell(
            onTap: () => onCabinSelected(cabin),
            hoverColor: Colors.transparent,
            splashColor: context.colorScheme.primary.withAlpha(20),
            highlightColor: Colors.transparent,
            child: SizedBox(
              width: 80, // Sabit genişlik hizalamayı korur
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Silüet Alanı
                  Expanded(
                    child: AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0, // Seçili olan hafif büyüsün
                      duration: const Duration(milliseconds: 200),
                      child: _CabinPhysicalSilhouette(
                        type: cabin.type,
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 2. Kabin İsmi
                  Text(
                    cabin.name ?? "İsimsiz",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CabinPhysicalSilhouette extends StatelessWidget {
  final CabinType? type;
  final bool isSelected;

  const _CabinPhysicalSilhouette({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;
    final idleColor = context.colorScheme.outlineVariant;
    final activeColor = isSelected ? primaryColor : idleColor;

    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (type == CabinType.serum)
            // Serum/Komodin Tipi: Alçak ve Geniş
            _buildBase(width: 38, height: 28, color: activeColor, rows: 2)
          else if (type == CabinType.freezer)
            // Buzdolabı Tipi: Uzun, Tek Kapaklı
            _buildBase(width: 28, height: 45, color: activeColor, rows: 0, isFreezer: true)
          else
            // Master/Slave Tipi: Uzun, Çok Çekmeceli
            _buildBase(width: 32, height: 45, color: activeColor, rows: 4),
        ],
      ),
    );
  }

  Widget _buildBase({
    required double width,
    required double height,
    required Color color,
    required int rows,
    bool isFreezer = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 2),
        color: isSelected ? color.withAlpha(15) : Colors.transparent,
      ),
      child: isFreezer
          ? Center(
              child: Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                rows,
                (_) => Container(
                  height: 1.5,
                  color: color.withAlpha(100),
                ),
              ),
            ),
    );
  }
}
