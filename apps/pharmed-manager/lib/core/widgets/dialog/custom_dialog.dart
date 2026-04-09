import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.width,
    this.height,
    this.maxHeight,
    this.showHeader = true,
    this.actions = const [],
    this.showSearch = false,
    this.showAdd = false,
    this.isLoading = false,
    this.loadingText = 'Yükleniyor...',
    this.searchController,
    this.searchHintText = 'Ara...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onAddPressed,
    this.trailingIcon,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final double? width;
  final double? height;
  final double? maxHeight;
  final bool showHeader;
  final List<Widget> actions;
  final bool showSearch;
  final bool showAdd;
  final bool isLoading;
  final String loadingText;
  final TextEditingController? searchController;
  final String searchHintText;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onAddPressed;
  final Widget? trailingIcon;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late TextEditingController _searchController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (!_isSearchExpanded) {
      _searchController.clear();
      widget.onSearchChanged?.call('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent, // Arka planı container halledecek
      insetPadding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,

      child: Container(
        width: widget.width ?? context.width * 0.4,
        height: widget.height ?? 600,
        constraints: BoxConstraints(maxHeight: widget.maxHeight ?? context.height * 0.8),
        decoration: BoxDecoration(
          color: colorScheme.surface, // Tema tabanlı zemin rengi
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showHeader) _buildHeader(context, colorScheme),
                  Expanded(child: _buildContent(context)),
                ],
              ),

              // Loading Overlay (Tüm içeriğin üzerine gelir)
              if (widget.isLoading) _buildLoadingOverlay(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          if (widget.trailingIcon != null) ...[widget.trailingIcon!, const SizedBox(width: 12)],
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Arama ---
              if (widget.showSearch) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.centerRight,
                  child: _isSearchExpanded
                      ? SizedBox(width: 250, child: _buildSearchField(context, colorScheme))
                      : IconButton(
                          icon: Icon(PhosphorIcons.magnifyingGlass()),
                          color: colorScheme.onSurfaceVariant,
                          onPressed: widget.isLoading ? null : _toggleSearch,
                          tooltip: "Ara",
                        ),
                ),
                const SizedBox(width: 8),
              ],

              // --- Ekle ---
              if (widget.showAdd) ...[
                IconButton(
                  icon: Icon(PhosphorIcons.plus()),
                  color: colorScheme.primary,
                  onPressed: widget.isLoading ? null : widget.onAddPressed,
                  tooltip: "Ekle",
                ),
                const SizedBox(width: 8),
              ],

              // --- Ekstra Actionlar ---
              ...widget.actions,

              if (widget.actions.isNotEmpty) const SizedBox(width: 8),

              // --- Kapat ---
              IconButton(
                icon: Icon(PhosphorIcons.x()),
                color: colorScheme.onSurfaceVariant,
                tooltip: "Kapat",
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => widget.onSearchChanged?.call(val),
        onSubmitted: (val) => widget.onSearchSubmitted?.call(val),
        enabled: !widget.isLoading,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.searchHintText,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: colorScheme.onSurfaceVariant, size: 18),
          suffixIcon: IconButton(
            icon: Icon(PhosphorIcons.x(), size: 16),
            color: colorScheme.onSurfaceVariant,
            onPressed: widget.isLoading ? null : _toggleSearch,
            padding: EdgeInsets.zero,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // İçerik kısmı
    return Padding(padding: const EdgeInsets.all(24.0), child: widget.child);
  }

  Widget _buildLoadingOverlay(BuildContext context, ColorScheme colorScheme) {
    return Positioned.fill(
      child: Container(
        color: colorScheme.surface.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                widget.loadingText,
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
