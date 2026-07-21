part of 'home_screen.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HomeNotifier>();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: MedRadius.lgAll,
        child: Column(
          children: [
            // Menü listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: notifier.parentMenuItems.length,
                itemBuilder: (context, index) {
                  final parent = notifier.parentMenuItems[index];
                  final isActive = notifier.activeTab == index;
                  return _SidebarParentItem(menu: parent, isActive: isActive, onTap: () => notifier.changeTab(parent));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarParentItem extends StatefulWidget {
  const _SidebarParentItem({required this.menu, required this.isActive, required this.onTap});

  final MenuItem menu;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_SidebarParentItem> createState() => _SidebarParentItemState();
}

class _SidebarParentItemState extends State<_SidebarParentItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.menu.children.isNotEmpty;
    final activeChild = context.watch<HomeNotifier>().activeChildMenu;
    final locale = Localizations.localeOf(context);

    return Column(
      children: [
        // Parent satırı
        InkWell(
          onTap: () {
            widget.onTap();
            if (hasChildren) setState(() => _expanded = !_expanded);
          },
          borderRadius: MedRadius.mdAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(borderRadius: MedRadius.mdAll),
            child: Row(
              children: [
                // İkon
                Icon(widget.menu.unicode.toIcon, size: 17, color: MedColors.text2),
                const SizedBox(width: 9),

                // İsim
                Expanded(
                  child: Text(
                    widget.menu.localizedName(locale),

                    style: MedTextStyles.bodyMd(color: MedColors.text2, weight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Chevron — child'ı varsa
                if (hasChildren)
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 11, color: MedColors.text2),
                  ),
              ],
            ),
          ),
        ),

        // Child'lar
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded && hasChildren
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.menu.children
                      .map((child) => _SidebarChildItem(child: child, isActive: activeChild?.id == child.id))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SidebarChildItem extends StatelessWidget {
  const _SidebarChildItem({required this.child, required this.isActive});

  final MenuItem child;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return InkWell(
      onTap: () => context.read<HomeNotifier>().selectChild(child),
      borderRadius: MedRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(left: 28, right: 6, top: 1, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? MedColors.blueLight : Colors.transparent,
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            // Nokta göstergesi
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? MedColors.blue : MedColors.border),
            ),
            Expanded(
              child: Text(
                child.localizedName(locale),

                style: MedTextStyles.bodySm(
                  color: isActive ? MedColors.blue : MedColors.text3,
                  weight: isActive ? FontWeight.w600 : FontWeight.w400,
                ).copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
