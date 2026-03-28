import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core.dart';

class RegistrationDialog extends StatefulWidget {
  const RegistrationDialog({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.onClose,
    this.width,
    this.height,
    this.maxHeight,
    this.isLoading = false,
    this.saveButtonText = 'Kaydet',
    this.cancelButtonText = 'İptal',
    this.actions = const [],
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.isButtonActive = true,
  });

  // ... (Değişkenler aynı) ...
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onClose;
  final double? width;
  final double? height;
  final double? maxHeight;
  final bool isLoading;
  final String saveButtonText;
  final String cancelButtonText;
  final List<Widget> actions;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final bool isButtonActive;

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  late final TextEditingController _searchController;
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Container(
        width: widget.width ?? context.width * 0.5,
        height: widget.height,
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight ?? context.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: widget.child,
                ),
              ),
              _buildFooter(context, colorScheme),
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
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          if (widget.showSearch) ...[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearchExpanded
                  ? SizedBox(width: 250, child: _buildSearchField(context, colorScheme))
                  : IconButton(
                      key: const ValueKey('search_btn'),
                      icon: Icon(PhosphorIcons.magnifyingGlass()),
                      color: colorScheme.onSurfaceVariant,
                      onPressed: widget.isLoading ? null : _toggleSearch,
                    ),
            ),
            const SizedBox(width: 8),
          ],
          ...widget.actions,
          if (widget.actions.isNotEmpty) const SizedBox(width: 8),
          IconButton(
            icon: Icon(PhosphorIcons.x()),
            color: colorScheme.onSurfaceVariant,
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                context.pop();
              }
            },
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
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        enabled: !widget.isLoading,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Ara...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass(),
            color: colorScheme.onSurfaceVariant,
            size: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(PhosphorIcons.x(), size: 16),
            color: colorScheme.onSurfaceVariant,
            onPressed: _toggleSearch,
            padding: EdgeInsets.zero,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 35,
            child: OutlinedButton(
              onPressed: () {
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  context.pop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outline),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(widget.cancelButtonText),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: (widget.isLoading || !widget.isButtonActive) ? null : widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : Text(widget.saveButtonText),
            ),
          ),
        ],
      ),
    );
  }
}
