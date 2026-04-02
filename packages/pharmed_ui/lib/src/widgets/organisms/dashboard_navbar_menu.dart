// lib/shared/widgets/organisms/kabin_mega_menu.dart
//
// [SWREQ-UI-NAV-KABIN-001]
// "Kabin Yönetimi" menü öğesine tıklandığında açılan mega menü paneli.
// Sol sidebar → kategori seçimi  |  Sağ → 2×2 kart grid + hızlı butonlar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart' hide MaterialType;
import 'package:pharmed_ui/pharmed_ui.dart';

class DashboardNavbarMenu extends StatelessWidget {
  const DashboardNavbarMenu({
    super.key,
    this.onCardTap,
    this.onQuickTap,
    required this.parentId,
    required this.flattenedMenus,
  });

  final int parentId;
  final List<MenuItem> flattenedMenus;
  final void Function(int id)? onCardTap;
  final void Function(String id)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    // 1. Bu menüye ait alt öğeleri filtrele
    final children = flattenedMenus.where((m) => m.parentId == parentId).toList();

    // Tasarım gereği 2x2 grid yapısını korumak için (veya daha fazlası için)
    // Eğer alt menü yoksa boş dönebilir veya bir uyarı gösterebilirsin.
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dinamik Başlık (Parent menü adı)
              _buildHeader(context),
              const SizedBox(height: 16),

              // Dinamik Grid (2 sütunlu)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: children.map((item) {
                  return SizedBox(
                    width: 248, // (600 - padding - spacing) / 2
                    child: _SubCard(item: item, onTap: (id) => onCardTap?.call(id)),
                  );
                }).toList(),
              ),

              // Eğer bu menü için özel hızlı aksiyonlar tanımlıysa
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final parent = flattenedMenus.firstWhere((m) => m.id == parentId);
    return Row(
      children: [
        Text(parent.name ?? '-', style: MedTextStyles.titleMd()),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: MedColors.border2, thickness: 1)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // Burada projenin mantığına göre hızlı aksiyonlar eklenebilir.
    // Eğer MenuItem modelinde 'isQuickAction' gibi bir flag varsa filtreleyebilirsin.
    return const SizedBox.shrink();
  }
}

class _SubCard extends StatefulWidget {
  const _SubCard({required this.item, required this.onTap});

  final MenuItem item;
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
              // İkon Alanı
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
              // Metin Alanı
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
