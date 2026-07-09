part of 'med_table_view.dart';

class _TableToolbar<T extends TableData> extends StatelessWidget {
  const _TableToolbar({
    required this.searchController,
    required this.enableSearch,
    required this.onSearchChanged,
    required this.enableExcel,
    required this.enablePDF,
    required this.onExcelPressed,
    required this.onPdfPressed,
    required this.selectedCount,
    required this.selectionMode,
    required this.onClearSelection,
    this.enableDateFilter = false,
    this.currentDateRange,
    this.onDateFilterPressed,
    this.selectionActions,
    this.toolbarActions,
  });

  final TextEditingController searchController;
  final bool enableSearch;
  final ValueChanged<String> onSearchChanged;
  final bool enableExcel;
  final bool enablePDF;
  final VoidCallback onExcelPressed;
  final VoidCallback onPdfPressed;
  final int selectedCount;
  final TableSelectionMode selectionMode;
  final VoidCallback onClearSelection;
  final bool enableDateFilter;
  final DateTimeRange? currentDateRange;
  final VoidCallback? onDateFilterPressed;
  final List<Widget>? selectionActions;
  final List<Widget>? toolbarActions;

  bool get _hasExport => enableExcel || enablePDF;
  bool get _hasSelection => selectionMode != TableSelectionMode.none && selectedCount > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: _hasSelection ? const Color(0xFFEFF6FF) : Colors.white,
      child: Row(
        children: [
          // ── Sol: seçim bilgisi VEYA arama + tarih filtresi
          if (_hasSelection) ...[
            _SelectionInfo(count: selectedCount, onClear: onClearSelection),
            const SizedBox(width: 12),
            if (selectionActions != null)
              ...selectionActions!.map((w) => Padding(padding: const EdgeInsets.only(right: 6), child: w)),
          ] else ...[
            if (enableSearch)
              SizedBox(
                width: 240,
                child: _SearchField(controller: searchController, onChanged: onSearchChanged),
              ),
          ],

          const Spacer(),

          if (toolbarActions != null) ...[
            for (final action in toolbarActions!) ...[action, const SizedBox(width: 6)],
          ],

          // ── Sağ: tarih filtresi + export (her zaman)
          if (!_hasSelection && enableDateFilter) ...[
            MedRectangleIconButton(
              onPressed: onDateFilterPressed ?? () {},
              color: MedColors.blueLight,
              iconColor: MedColors.blue,
              iconData: currentDateRange != null ? PhosphorIcons.calendar() : PhosphorIcons.calendarBlank(),
            ),
            const SizedBox(width: 6),
          ],

          if (_hasExport) ...[
            if (enableExcel)
              MedRectangleIconButton(
                iconData: PhosphorIcons.microsoftExcelLogo(),
                tooltip: _hasSelection ? context.l10n.table_exportSelectedTooltip : 'Excel',
                color: MedColors.greenLight,
                iconColor: MedColors.green,
                onPressed: onExcelPressed,
              ),
            if (enableExcel && enablePDF) const SizedBox(width: 6),
            if (enablePDF)
              MedRectangleIconButton(
                iconData: PhosphorIcons.filePdf(),
                tooltip: _hasSelection ? 'PDF' : 'PDF',
                color: MedColors.redLight,
                iconColor: MedColors.red,
                onPressed: onPdfPressed,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── SEÇİM BİLGİSİ ───────────────────────────────────────────────────────────

class _SelectionInfo extends StatelessWidget {
  const _SelectionInfo({required this.count, required this.onClear});

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
          child: Text(
            context.l10n.table_selectedCountLabel(count),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onClear,
          child: Text(
            context.l10n.common_clearButton,
            style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: context.l10n.common_searchHint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, size: 17, color: Color(0xFF9CA3AF)),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () => onChanged(''),
                  child: const Icon(Icons.close, size: 14, color: Color(0xFF9CA3AF)),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F9FB),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }
}
