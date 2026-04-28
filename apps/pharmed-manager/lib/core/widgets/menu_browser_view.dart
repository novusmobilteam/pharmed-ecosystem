import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class MenuBrowserView extends StatefulWidget {
  const MenuBrowserView({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onItemSelected,
    required this.onCategoryToggled,
    required this.isCategoryFullySelected,
    required this.isCategoryPartiallySelected,
  });

  final List<MenuItem> items;
  final List<MenuItem> selectedItems;
  final void Function(MenuItem item) onItemSelected;
  final void Function(MenuItem category) onCategoryToggled;
  final bool Function(MenuItem category) isCategoryFullySelected;
  final bool Function(MenuItem category) isCategoryPartiallySelected;

  @override
  State<MenuBrowserView> createState() => _MenuBrowserViewState();
}

class _MenuBrowserViewState extends State<MenuBrowserView> {
  int _activeIndex = 0;
  String _searchQuery = '';

  List<MenuItem> get _parents => widget.items.where((m) => m.parentId == null).toList();

  List<MenuItem> get _filteredParents {
    if (_searchQuery.isEmpty) return _parents;
    return _parents.where((m) => (m.label ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  int _countSelected(MenuItem category) {
    final allIds = _getAllIds(category);
    return widget.selectedItems.where((m) => allIds.contains(m.id)).length;
  }

  Set<int> _getAllIds(MenuItem node) {
    final ids = <int>{};
    for (final child in node.children) {
      if (child.id != null) ids.add(child.id!);
      // alt kategoriler varsa recursive devam et
      if (child.children.isNotEmpty) ids.addAll(_getAllIds(child));
    }
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    final parents = _filteredParents;
    final activeParent = parents.isNotEmpty && _activeIndex < parents.length ? parents[_activeIndex] : null;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                parents: parents,
                activeIndex: _activeIndex,
                searchQuery: _searchQuery,
                selectedItems: widget.selectedItems,
                countSelected: _countSelected,
                onSearchChanged: (q) => setState(() {
                  _searchQuery = q;
                  _activeIndex = 0;
                }),
                onCategoryTap: (i) => setState(() => _activeIndex = i),
                onCategoryToggle: widget.onCategoryToggled,
                isCategoryFullySelected: widget.isCategoryFullySelected,
                isCategoryPartiallySelected: widget.isCategoryPartiallySelected,
              ),
              _ContentPanel(
                activeParent: activeParent,
                selectedItems: widget.selectedItems,
                onItemSelected: widget.onItemSelected,
                onCategoryToggled: widget.onCategoryToggled,
                isCategoryFullySelected: widget.isCategoryFullySelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.parents,
    required this.activeIndex,
    required this.searchQuery,
    required this.selectedItems,
    required this.countSelected,
    required this.onSearchChanged,
    required this.onCategoryTap,
    required this.onCategoryToggle,
    required this.isCategoryFullySelected,
    required this.isCategoryPartiallySelected,
  });

  final List<MenuItem> parents;
  final int activeIndex;
  final String searchQuery;
  final List<MenuItem> selectedItems;
  final int Function(MenuItem) countSelected;
  final void Function(String) onSearchChanged;
  final void Function(int) onCategoryTap;
  final void Function(MenuItem) onCategoryToggle;
  final bool Function(MenuItem) isCategoryFullySelected;
  final bool Function(MenuItem) isCategoryPartiallySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(right: BorderSide(color: MedColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: MedColors.border2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KATEGORİLER', style: MedTextStyles.monoXs()),
                const SizedBox(height: 10),
                _SearchField(value: searchQuery, onChanged: onSearchChanged),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: parents.length,
              itemBuilder: (context, index) {
                final cat = parents[index];
                return _CategoryItem(
                  category: cat,
                  isActive: index == activeIndex,
                  isFullySelected: isCategoryFullySelected(cat),
                  isPartiallySelected: isCategoryPartiallySelected(cat),
                  selectedCount: countSelected(cat),
                  totalCount: cat.children.length,
                  onTap: () => onCategoryTap(index),
                  onToggle: () => onCategoryToggle(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: MedTextStyles.bodyMd(),
      decoration: InputDecoration(
        hintText: 'Kategori ara...',
        hintStyle: MedTextStyles.bodyMd(color: MedColors.text3),
        prefixIcon: const Icon(Icons.search_rounded, size: 16, color: MedColors.text3),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: MedColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isActive,
    required this.isFullySelected,
    required this.isPartiallySelected,
    required this.selectedCount,
    required this.totalCount,
    required this.onTap,
    required this.onToggle,
  });

  final MenuItem category;
  final bool isActive;
  final bool isFullySelected;
  final bool isPartiallySelected;
  final int selectedCount;
  final int totalCount;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? MedColors.blueLight : Colors.transparent,
        borderRadius: MedRadius.smAll,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MedRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CheckboxIcon(isFull: isFullySelected, isPartial: isPartiallySelected),
                  ),
                ),
                Expanded(
                  child: Text(
                    category.name ?? '-',
                    style: MedTextStyles.bodyMd(
                      color: isActive ? MedColors.blue : MedColors.text2,
                      weight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _CategoryBadge(isFull: isFullySelected, selectedCount: selectedCount, totalCount: totalCount),
                if (isActive) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 14, color: MedColors.blue),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxIcon extends StatelessWidget {
  const _CheckboxIcon({required this.isFull, required this.isPartial});

  final bool isFull;
  final bool isPartial;

  @override
  Widget build(BuildContext context) {
    if (isFull) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
        child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
      );
    }
    if (isPartial) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: MedColors.blueLight,
          borderRadius: MedRadius.smAll,
          border: Border.all(color: MedColors.blue, width: 1.5),
        ),
        child: const Icon(Icons.remove_rounded, size: 13, color: MedColors.blue),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.border, width: 1.5),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.isFull, required this.selectedCount, required this.totalCount});

  final bool isFull;
  final int selectedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isFull ? MedColors.greenLight : MedColors.surface3,
        borderRadius: MedRadius.xlAll,
      ),
      child: Text(
        '$selectedCount/$totalCount',
        style: MedTextStyles.monoXs(color: isFull ? MedColors.green : MedColors.text3),
      ),
    );
  }
}

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({
    required this.activeParent,
    required this.selectedItems,
    required this.onItemSelected,
    required this.onCategoryToggled,
    required this.isCategoryFullySelected,
  });

  final MenuItem? activeParent;
  final List<MenuItem> selectedItems;
  final void Function(MenuItem) onItemSelected;
  final void Function(MenuItem) onCategoryToggled;
  final bool Function(MenuItem) isCategoryFullySelected;

  @override
  Widget build(BuildContext context) {
    if (activeParent == null) return const Expanded(child: SizedBox.shrink());
    final isAllSelected = isCategoryFullySelected(activeParent!);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: MedColors.border2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text((activeParent!.label ?? '').toUpperCase(), style: MedTextStyles.titleSm()),
                InkWell(
                  onTap: () => onCategoryToggled(activeParent!),
                  borderRadius: MedRadius.smAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: MedColors.blue, width: 1.5),
                      borderRadius: MedRadius.smAll,
                    ),
                    child: Text(
                      isAllSelected ? 'Seçimi Kaldır' : 'Tümünü Seç',
                      style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: activeParent!.children.isEmpty
                ? const _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: activeParent!.children.length,
                    itemBuilder: (context, index) {
                      final item = activeParent!.children[index];
                      final isSelected = selectedItems.any((i) => i.id == item.id);
                      return _MenuCard(item: item, isSelected: isSelected, onTap: () => onItemSelected(item));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_off_rounded, size: 48, color: MedColors.text3.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Bu kategoride menü bulunamadı', style: MedTextStyles.bodyMd(color: MedColors.text3)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.isSelected, required this.onTap});

  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blueLight : MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MedRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected ? MedColors.blue.withValues(alpha: 0.12) : MedColors.surface3,
                        borderRadius: MedRadius.mdAll,
                      ),
                      child: Icon(
                        item.unicode.toIcon ?? Icons.grid_view_rounded,
                        size: 18,
                        color: isSelected ? MedColors.blue : MedColors.text3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.label ?? 'İsimsiz',
                      style: MedTextStyles.bodyMd(
                        color: isSelected ? MedColors.blue : MedColors.text,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
