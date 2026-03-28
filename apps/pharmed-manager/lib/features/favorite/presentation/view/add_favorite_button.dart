part of 'favorite_quick_access.dart';

class AddFavoriteButton extends StatelessWidget {
  const AddFavoriteButton({super.key, required this.allMenuItems});

  final List<MenuItem> allMenuItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<FavoriteNotifier>(),
            child: AddFavoriteView(allMenuItems: allMenuItems),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsBold.plusCircle, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              "Favori Menü Ekle",
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Consumer<FavoriteNotifier>(
              builder: (context, vm, _) => Text(
                "${vm.favoriteIds.length} / 7",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
