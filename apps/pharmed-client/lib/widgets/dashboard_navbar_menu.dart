// [SWREQ-UI-NAV-KABIN-001]
// "Kabin Yönetimi" menü öğesine tıklandığında açılan mega menü paneli.
// Sol sidebar → kategori seçimi  |  Sağ → 2×2 kart grid + hızlı butonlar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// pharmed_core::MenuItem bağımlılığını kaldırmak için yerel model.
// pharmed-client bu modele MenuItem'ı map'ler.
// ─────────────────────────────────────────────────────────────────

class NavMenuItem {
  const NavMenuItem({this.id, this.parentId, this.name, this.description, this.unicode, this.route});

  final int? id;
  final int? parentId;
  final String? name;
  final String? description;
  final String? unicode;
  final String? route;
}

class DashboardNavbarMenu extends StatelessWidget {
  const DashboardNavbarMenu({
    super.key,
    this.onCardTap,
    this.onQuickTap,
    required this.parentId,
    required this.flattenedMenus,
  });

  final int parentId;
  final List<NavMenuItem> flattenedMenus;
  final void Function(int id)? onCardTap;
  final void Function(String id)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    final children = flattenedMenus.where((m) => m.parentId == parentId).toList();
    if (children.isEmpty) return const SizedBox.shrink();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border),
          borderRadius: const BorderRadius.only(
            topRight: MedRadius.lg,
            bottomLeft: MedRadius.lg,
            bottomRight: MedRadius.lg,
          ),
          boxShadow: MedShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: children.map((item) {
                  return SizedBox(
                    width: 248,
                    child: _SubCard(item: item, onTap: (id) => onCardTap?.call(id)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final parent = flattenedMenus.firstWhere((m) => m.id == parentId);
    return Row(
      children: [
        Text(parent.name ?? '-', style: MedTextStyles.titleMd()),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: MedColors.border2, thickness: 1)),
      ],
    );
  }
}

class _SubCard extends StatefulWidget {
  const _SubCard({required this.item, required this.onTap});

  final NavMenuItem item;
  final void Function(int id) onTap;

  @override
  State<_SubCard> createState() => _SubCardState();
}

class _SubCardState extends State<_SubCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final iconData = widget.item.unicode?.toIcon;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.item.id ?? 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? MedColors.blueLight : MedColors.surface2,
            border: Border.all(color: _hovered ? MedColors.blue.withAlpha(80) : MedColors.border2),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _hovered ? MedColors.blue : MedColors.surface3,
                  borderRadius: MedRadius.smAll,
                ),
                child: Icon(iconData, size: 16, color: _hovered ? Colors.white : MedColors.text2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name ?? '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _hovered ? MedColors.blue : MedColors.text,
                      ),
                    ),
                    if (widget.item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.item.description!,
                        style: MedTextStyles.bodySm(color: _hovered ? MedColors.text2 : MedColors.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
