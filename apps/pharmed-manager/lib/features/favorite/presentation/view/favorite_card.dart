part of 'favorite_quick_access.dart';

class MenuCard extends StatefulWidget {
  const MenuCard({
    super.key,
    required this.item,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  final MenuItem item;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Kartın ana rengi (Primary kullanıyoruz, dinamik de olabilir)
    final baseColor = colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Hover durumunda hafif yukarı kalkma efekti
          transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isHovered ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? baseColor.withValues(alpha: 0.5) : colorScheme.outline.withValues(alpha: 0.1),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              // --- 1. Katman: Arka Plan Filigranı (Süsleme) ---
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  widget.item.icon,
                  size: 130,
                  color: baseColor.withValues(alpha: 0.03), // Çok çok silik
                ),
              ),

              // --- 2. Katman: Ana İçerik ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İkon Kutusu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: baseColor,
                        size: 28,
                      ),
                    ),

                    const Spacer(), // İkon ile metni birbirinden uzaklaştırır

                    // Başlık
                    Text(
                      widget.item.label.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // --- 3. Katman: Favori Butonu (KOŞULLU) ---
              // Sadece showFavoriteButton true ise ekrana çizilir.
              if (widget.showFavoriteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.onFavoriteToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          widget.isFavorite ? PhosphorIcons.star(PhosphorIconsStyle.fill) : PhosphorIcons.star(),
                          color: widget.isFavorite ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
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
