// [SWREQ-UI-SELECTIONDIALOG-001] [IEC 62304 §5.5]
// Generic arama + infinite scroll seçim dialogu.
//
// TEMİZLİK: iç kopya widget'lar ortak widget'lara delege edildi:
//   _EmptyState  → EmptyStateWidget(noResults)
//   _ErrorState  → EmptyStateWidget(custom) + MedButton
//   _FooterButton→ MedButton
//   _SelectAllBtn→ MedButton(ghost)
//   _CloseButton → MedRectangleIconButton
//   header gradient renkleri token'a bağlandı
// MANTIK (_fetch/_onScroll/debounce/seçim) hiç değişmedi.
//
// BAĞIMLILIK: pharmed_core (Selectable, ApiResponse, Result), pharmed_data.
//   (Bu dosya pharmed_ui'yi core'a bağlayanlardan; saflaştırma fazında
//    app katmanına taşınması değerlendirilecek.)
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

typedef SearchDataSource<T> = Future<Result<ApiResponse<List<T>>?>> Function(int skip, int take, String? search);

class SelectionDialog<T extends Selectable> extends StatefulWidget {
  const SelectionDialog({
    super.key,
    required this.title,
    required this.dataSource,
    required this.labelBuilder,
    this.subtitleBuilder,
    this.pageSize = 20,
    this.multi = false,
    this.initiallySelected,
  });

  final String title;
  final SearchDataSource<T> dataSource;
  final String? Function(T item) labelBuilder;
  final String? Function(T item)? subtitleBuilder;
  final int pageSize;
  final bool multi;
  final List<T>? initiallySelected;

  static Future<T?> show<T extends Selectable>(
    BuildContext context, {
    required String title,
    required SearchDataSource<T> dataSource,
    required String? Function(T item) labelBuilder,
    String? Function(T item)? subtitleBuilder,
    int pageSize = 20,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0x800F192D),
      builder: (_) => SelectionDialog<T>(
        title: title,
        dataSource: dataSource,
        labelBuilder: labelBuilder,
        subtitleBuilder: subtitleBuilder,
        pageSize: pageSize,
        multi: false,
      ),
    );
  }

  static Future<List<T>?> showMulti<T extends Selectable>(
    BuildContext context, {
    required String title,
    required SearchDataSource<T> dataSource,
    required String? Function(T item) labelBuilder,
    String? Function(T item)? subtitleBuilder,
    List<T>? initiallySelected,
    int pageSize = 20,
  }) {
    return showDialog<List<T>>(
      context: context,
      barrierColor: const Color(0x800F192D),
      builder: (_) => SelectionDialog<T>(
        title: title,
        dataSource: dataSource,
        labelBuilder: labelBuilder,
        subtitleBuilder: subtitleBuilder,
        pageSize: pageSize,
        multi: true,
        initiallySelected: initiallySelected,
      ),
    );
  }

  @override
  State<SelectionDialog<T>> createState() => _SelectionDialogState<T>();
}

class _SelectionDialogState<T extends Selectable> extends State<SelectionDialog<T>> {
  final List<T> _items = [];
  int _totalCount = -1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isFetchingMore = false;
  String? _error;
  String _search = '';
  T? _selected;
  late Set<Object?> _selectedIds;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedIds = {for (final e in (widget.initiallySelected ?? [])) e.id};
    _scrollController.addListener(_onScroll);
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_isLoading || _isLoadingMore) {
      _isFetchingMore = false;
      return;
    }

    final skip = reset ? 0 : _items.length;

    if (!reset && _totalCount != -1 && _items.length >= _totalCount) {
      _isFetchingMore = false;
      return;
    }

    setState(() {
      if (reset) {
        _isLoading = true;
        _error = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await widget.dataSource(skip, widget.pageSize, _search.isEmpty ? null : _search);
      if (!mounted) return;

      result.when(
        ok: (response) {
          setState(() {
            if (reset) _items.clear();
            _items.addAll(response?.data ?? []);
            _totalCount = response?.totalCount ?? 0;
            _isLoading = false;
            _isLoadingMore = false;
          });
        },
        error: (e) {
          setState(() {
            _error = e.message;
            _isLoading = false;
            _isLoadingMore = false;
          });
        },
      );
    } finally {
      _isFetchingMore = false;
    }
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore || _isFetchingMore) return;
    if (_totalCount != -1 && _items.length >= _totalCount) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
      _isFetchingMore = true;
      _fetch();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_search == value.trim()) return;
      _search = value.trim();
      _fetch(reset: true);
    });
  }

  void _onItemTap(T item) {
    setState(() {
      if (widget.multi) {
        final newSet = Set<Object?>.from(_selectedIds);
        if (newSet.contains(item.id)) {
          newSet.remove(item.id);
        } else {
          newSet.add(item.id);
        }
        _selectedIds = newSet;
      } else {
        _selected = item;
      }
    });
  }

  void _onConfirm() {
    if (widget.multi) {
      final selected = _items.where((e) => _selectedIds.contains(e.id)).toList();
      Navigator.of(context).pop(selected);
    } else {
      if (_selected != null) Navigator.of(context).pop(_selected);
    }
  }

  bool get _hasSelection => widget.multi ? _selectedIds.isNotEmpty : _selected != null;

  String? _footerLabel(BuildContext context) {
    if (widget.multi) {
      if (_selectedIds.isEmpty) return null;
      return context.l10n.selectionDialog_selectedCount(_selectedIds.length);
    }
    return _selected != null ? widget.labelBuilder(_selected as T) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 620),
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.xl2All,
          border: Border.all(color: MedColors.border, width: 1.5),
          boxShadow: MedShadows.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              title: widget.title,
              onClose: () => Navigator.of(context).pop(),
              action: widget.multi
                  ? MedButton(
                      label: (_selectedIds.length == _items.length && _items.isNotEmpty)
                          ? context.l10n.common_deselectAllButton
                          : context.l10n.common_selectAllButton,
                      variant: MedButtonVariant.ghost,
                      size: MedButtonSize.sm,
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.length == _items.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds = _items.map((e) => e.id).toSet();
                          }
                        });
                      },
                    )
                  : null,
            ),
            _SearchBar(controller: _searchController, onChanged: _onSearchChanged),
            Flexible(child: _buildList()),
            _DialogFooter(selectedLabel: _footerLabel(context), onConfirm: _hasSelection ? _onConfirm : null),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: MedLoadingIndicator()),
      );
    }

    if (_error != null) {
      // EmptyStateWidget(custom) + retry butonu (compact'ta action gizli
      // olduğu için Column ile elle diziyoruz).
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyStateWidget(variant: EmptyStateVariant.error, size: EmptyStateSize.compact),
            const SizedBox(height: 12),
            MedButton(
              label: context.l10n.common_retryButton,
              variant: MedButtonVariant.ghost,
              size: MedButtonSize.sm,
              onPressed: () => _fetch(reset: true),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noResults, size: EmptyStateSize.compact);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: MedLoadingIndicator()),
          );
        }

        final item = _items[index];
        final isSelected = widget.multi ? _selectedIds.contains(item.id) : _selected?.id == item.id;

        return _SearchListItem(
          label: widget.labelBuilder(item) ?? '-',
          subtitle: widget.subtitleBuilder?.call(item),
          isSelected: isSelected,
          showCheckbox: widget.multi,
          onTap: () => _onItemTap(item),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header — gradient token'a bağlandı, kapat butonu MedRectangleIconButton
// ─────────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.onClose, this.action});

  final String title;
  final VoidCallback onClose;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MedColors.uiPanelBg, Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: MedTextStyles.titleMd())),
          if (action != null) ...[action!, const SizedBox(width: 8)],
          MedRectangleIconButton(iconData: Icons.close_rounded, size: 32, iconSize: 16, onPressed: onClose),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Arama çubuğu (BIRAKILDI — özel fill/prefix davranışı)
// ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: MedTextStyles.bodyLg(color: MedColors.text),
        decoration: InputDecoration(
          hintText: context.l10n.common_searchHint,
          hintStyle: MedTextStyles.bodyLg(color: MedColors.text3),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: MedColors.text3),
          filled: true,
          fillColor: MedColors.surface2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: MedRadius.mdAll,
            borderSide: const BorderSide(color: MedColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: MedRadius.mdAll,
            borderSide: const BorderSide(color: MedColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: MedRadius.mdAll,
            borderSide: const BorderSide(color: MedColors.blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Liste item (BIRAKILDI — kendine özgü seçim görseli)
// ─────────────────────────────────────────────────────────────────
class _SearchListItem extends StatelessWidget {
  const _SearchListItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.showCheckbox = false,
  });

  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool showCheckbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : Colors.transparent,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isSelected ? MedColors.blue : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            if (showCheckbox) ...[
              MedCheckbox(value: isSelected, size: MedCheckboxSize.sm, onChanged: (_) => onTap()),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: MedTextStyles.bodyLg(
                      color: isSelected ? MedColors.blue : MedColors.text,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: MedTextStyles.bodySm(color: MedColors.text3)),
                  ],
                ],
              ),
            ),
            if (!showCheckbox && isSelected) Icon(Icons.check_circle_rounded, size: 16, color: MedColors.blue),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Footer — butonlar MedButton'a delege
// ─────────────────────────────────────────────────────────────────
class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.selectedLabel, required this.onConfirm});

  final String? selectedLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: MedColors.border2, width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: selectedLabel != null
                ? Row(
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: MedColors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedLabel!,
                          style: MedTextStyles.bodyMd(color: MedColors.text2, weight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(context.l10n.selectionDialog_noSelection, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          const SizedBox(width: 12),
          MedButton(
            label: context.l10n.common_cancelButton,
            variant: MedButtonVariant.ghost,
            size: MedButtonSize.sm,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          MedButton(
            label: context.l10n.selectionDialog_confirmButton,
            variant: MedButtonVariant.primary,
            size: MedButtonSize.sm,
            onPressed: onConfirm, // null → MedButton otomatik disabled
          ),
        ],
      ),
    );
  }
}
