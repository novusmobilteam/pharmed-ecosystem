import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.isLoading,
    required this.canGoPrev,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.goToPage,
    required this.canGoNext,
  });

  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Function(int page) goToPage;

  /// Görünecek sayfa numaralarının aralığını hesaplar — mevcut sayfanın
  /// etrafında en fazla 5 numara gösterir, taşan uçları kırpar.
  List<int> _visiblePages() {
    const windowSize = 5;

    if (totalPages <= windowSize) {
      return List.generate(totalPages, (i) => i + 1);
    }

    int start = currentPage - (windowSize ~/ 2);
    int end = start + windowSize - 1;

    if (start < 1) {
      start = 1;
      end = windowSize;
    }
    if (end > totalPages) {
      end = totalPages;
      start = end - windowSize + 1;
    }

    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 4.0,
        children: [
          _PageArrow(icon: PhosphorIcons.caretLeft(), onTap: canGoPrev && !isLoading ? onPreviousPage : null),
          if (pages.first > 1) ...[
            _PageNumber(page: 1, isSelected: false, onTap: () => goToPage(1)),
            if (pages.first > 2) Text('...', style: MedTextStyles.bodyMd()),
          ],
          for (final page in pages)
            _PageNumber(page: page, isSelected: page == currentPage, onTap: isLoading ? null : () => goToPage(page)),
          if (pages.last < totalPages) ...[
            if (pages.last < totalPages - 1) Text('...', style: MedTextStyles.bodyMd()),
            _PageNumber(page: totalPages, isSelected: false, onTap: () => goToPage(totalPages)),
          ],
          _PageArrow(icon: PhosphorIcons.caretRight(), onTap: canGoNext && !isLoading ? onNextPage : null),
        ],
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({required this.page, required this.isSelected, this.onTap});

  final int page;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blue : Colors.transparent,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border),
        ),
        child: Text('$page', style: MedTextStyles.monoSm(color: isSelected ? Colors.white : MedColors.text)),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: MedColors.border)),
        child: Icon(icon, size: 16, color: enabled ? MedColors.text : MedColors.text4),
      ),
    );
  }
}
