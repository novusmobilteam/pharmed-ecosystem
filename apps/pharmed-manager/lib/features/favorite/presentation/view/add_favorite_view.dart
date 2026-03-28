part of 'favorite_quick_access.dart';

class AddFavoriteView extends StatefulWidget {
  final List<MenuItem> allMenuItems;

  const AddFavoriteView({super.key, required this.allMenuItems});

  @override
  State<AddFavoriteView> createState() => _AddFavoriteViewState();
}

class _AddFavoriteViewState extends State<AddFavoriteView> {
  late FavoriteNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = context.read<FavoriteNotifier>();
    _notifier.initializePending();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          maxHeight: 800,
          width: context.width * 0.85,
          title: 'Favori Menülerinizi Düzenleyin',
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Menü
              SizedBox(
                width: 240,
                child: _SideListView(
                  parents: notifier.parents,
                  activeIndex: notifier.activeParentIndex,
                  onTap: notifier.selectParent,
                ),
              ),

              // Sağ Grid
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _GridView(
                        parent: notifier.parents.isNotEmpty ? notifier.parents[notifier.activeParentIndex] : null,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: PharmedButton(
                        onPressed: () {
                          notifier.saveFavorites(
                            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                            onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                          );
                        },
                        isActive: notifier.pendingFavorites.isNotEmpty,
                        isLoading: notifier.isLoading(notifier.submitOp),
                        label: 'Kaydet',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SideListView extends StatelessWidget {
  final List<MenuItem> parents;
  final int activeIndex;
  final Function(MenuItem) onTap;

  const _SideListView({
    required this.parents,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PharmedSideListView<MenuItem>(
      items: parents,
      labelBuilder: (item) => item.label,
      activeIndex: activeIndex,
      onTap: onTap,
    );
  }
}

class _GridView extends StatelessWidget {
  final MenuItem? parent;

  const _GridView({this.parent});

  @override
  Widget build(BuildContext context) {
    if (parent == null) return const SizedBox.shrink();

    final children = parent!.children;

    return Consumer<FavoriteNotifier>(
      builder: (context, notifier, _) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2.2, // Kart oranlarını iyileştirdik
            ),
            itemBuilder: (context, index) {
              final child = children[index];
              final bool isFav = notifier.isPendingFavorite(child.id ?? 0);

              return MenuCard(
                item: child,
                showFavoriteButton: true,
                isFavorite: isFav,
                onFavoriteToggle: () => notifier.togglePending(
                  child,
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
