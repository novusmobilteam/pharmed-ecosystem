// lib/shared/widgets/pharmed_search_dialog.dart
//
// Generic arama + infinite scroll seçim dialogu.
//
// Client'ta infinite scroll kullanılır.
// Manager'da ayrı bir PharmedPagedDialog yazılacak (ilerleyen adımda).
//
// KULLANIM:
//   final result = await PharmedSearchDialog.show<Medicine>(
//     context: context,
//     title: 'İlaç Seç',
//     dataSource: (skip, take, search) =>
//         ref.read(getDrugsUseCaseProvider).call(
//           GetDrugsParams(skip: skip, take: take, search: search),
//         ),
//     labelBuilder: (m) => m.name ?? '—',
//   );
//   if (result != null) { ... }
//
// BAĞIMLILIK:
//   - pharmed_core: Selectable, ApiResponse, Result
//   - pharmed_ui: MedColors, MedFonts, MedTextStyles, MedRadius
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

  /// Her item için gösterilecek ana metin.
  final String? Function(T item) labelBuilder;

  /// Her item için gösterilecek ikincil metin — opsiyonel.
  final String? Function(T item)? subtitleBuilder;

  /// Sayfa başına item sayısı.
  final int pageSize;

  final bool multi;
  final List<T>? initiallySelected;

  /// Dialog'u gösterir ve seçilen item'ı döndürür.
  /// İptal edilirse null döner.
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
    if (_isLoading || _isLoadingMore) return;

    final skip = reset ? 0 : _items.length;

    if (!reset && _totalCount != -1 && _items.length >= _totalCount) return;

    setState(() {
      if (reset) {
        _isLoading = true;
        _error = null;
      } else {
        _isLoadingMore = true;
      }
    });

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
  }

  // ── Scroll — infinite scroll tetikleyici ─────────────────────────

  void _onScroll() {
    if (_isLoading || _isLoadingMore || _isFetchingMore) return;
    if (_totalCount != -1 && _items.length >= _totalCount) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
      _isFetchingMore = true; // setState olmadan, sync olarak set et
      _fetch();
    }
  }

  // ── Arama — debounced ────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_search == value.trim()) return;
      _search = value.trim();
      _fetch(reset: true);
    });
  }

  // ── Seçim ────────────────────────────────────────────────────────

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

  String? get _footerLabel {
    if (widget.multi) {
      if (_selectedIds.isEmpty) return null;
      return '${_selectedIds.length} öğe seçildi';
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MedColors.border, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x1A0F192D), blurRadius: 40, offset: Offset(0, 12)),
            BoxShadow(color: Color(0x0F0F192D), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              title: widget.title,
              onClose: () => Navigator.of(context).pop(), // Multi modda "Tümünü Seç" aksiyonu
              action: widget.multi
                  ? _SelectAllButton(
                      allSelected: _selectedIds.length == _items.length && _items.isNotEmpty,
                      onTap: () {
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
            _DialogFooter(selectedLabel: _footerLabel, onConfirm: _hasSelection ? _onConfirm : null),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: () => _fetch(reset: true));
    }

    if (_items.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Listenin sonunda yükleme göstergesi
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
// Header
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MedColors.text,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (action != null) ...[action!, const SizedBox(width: 8)],
          _CloseButton(onTap: onClose),
        ],
      ),
    );
  }
}

class _SelectAllButton extends StatelessWidget {
  const _SelectAllButton({required this.allSelected, required this.onTap});

  final bool allSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: MedColors.border),
        ),
        child: Text(
          allSelected ? 'Seçimi Kaldır' : 'Tümünü Seç',
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: MedColors.text2,
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MedColors.border),
        ),
        child: Icon(Icons.close_rounded, size: 16, color: MedColors.text3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Arama çubuğu
// ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text),
        decoration: InputDecoration(
          hintText: 'Ara...',
          hintStyle: TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text3),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: MedColors.text3),
          filled: true,
          fillColor: MedColors.surface2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: MedColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: MedColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: MedColors.blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Liste item
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? MedColors.blue : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            if (showCheckbox) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? MedColors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
                ),
                child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? MedColors.blue : MedColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
                    ),
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
// Footer
// ─────────────────────────────────────────────────────────────────

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.selectedLabel, required this.onConfirm});

  final String? selectedLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: MedColors.border2, width: 1.5)),
      ),
      child: Row(
        children: [
          // Seçili item etiketi
          Expanded(
            child: selectedLabel != null
                ? Row(
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: MedColors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedLabel!,
                          style: TextStyle(
                            fontFamily: MedFonts.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MedColors.text2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text('Seçim yapılmadı', style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          const SizedBox(width: 12),

          // İptal
          _FooterButton(label: 'İptal', onTap: () => Navigator.of(context).pop(), isPrimary: false),
          const SizedBox(width: 8),

          // Seç
          _FooterButton(label: 'Seç', onTap: onConfirm, isPrimary: true),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.label, required this.onTap, required this.isPrimary});

  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? (isDisabled ? MedColors.surface3 : MedColors.blue) : MedColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? (isDisabled ? MedColors.border : MedColors.blue) : MedColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPrimary ? (isDisabled ? MedColors.text3 : Colors.white) : MedColors.text2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Boş durum
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 32, color: MedColors.text4),
          const SizedBox(height: 10),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MedColors.text3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hata durumu
// ─────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 32, color: MedColors.red),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: MedColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MedColors.border),
              ),
              child: Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MedColors.text2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
