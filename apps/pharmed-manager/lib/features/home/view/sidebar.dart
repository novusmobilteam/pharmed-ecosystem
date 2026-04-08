part of 'home_screen.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HomeNotifier>();

    return Container(
      width: 240,
      height: double.infinity,
      color: MedColors.text,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifier.parentMenuItems.length,
        itemBuilder: (context, index) {
          final parent = notifier.parentMenuItems[index];
          final isActive = notifier.activeTab == index;
          return _SidebarParentItem(menu: parent, isActive: isActive, onTap: () => notifier.changeTab(parent));
        },
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
    final textColor = _expanded ? Colors.white : Colors.white.withAlpha(55);
    final activeChild = context.watch<HomeNotifier>().activeChildMenu;

    return Column(
      children: [
        // Parent satırı
        GestureDetector(
          onTap: () {
            widget.onTap();
            if (hasChildren) setState(() => _expanded = !_expanded);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                // Sol aktif çizgi
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 3,
                  height: 16,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(2)),
                ),
                Icon(widget.menu.unicode.toIcon, color: textColor, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.menu.name ?? '-',
                    style: MedTextStyles.bodySm().copyWith(
                      color: _expanded ? Colors.white : Colors.white.withOpacity(0.55),
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
    return GestureDetector(
      onTap: () => context.read<HomeNotifier>().selectChild(child),
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? Colors.white : Colors.transparent),
            ),
            Expanded(
              child: Text(
                child.name ?? '-',
                style: MedTextStyles.bodySm().copyWith(color: isActive ? Colors.white : MedColors.text4, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
