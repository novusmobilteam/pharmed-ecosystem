part of 'dashboard_screen.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardNotifier>(
      builder: (context, notifier, child) {
        final menuTree = notifier.menuTree ?? const <MenuItem>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(menuTree.length, (index) {
                    final group = menuTree.elementAt(index);
                    return Padding(
                      padding: MedSpacing.insetXl * 1.5,
                      child: Column(
                        spacing: 8.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name.toString(), style: MedTextStyles.titleSm()),
                          Divider(),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              mainAxisExtent: 100,
                            ),
                            itemCount: group.children.length,
                            itemBuilder: (context, gridIndex) {
                              final item = group.children.elementAt(gridIndex);
                              return GestureDetector(
                                onTap: () => isLoggedIn ? notifier.navigateTo(item.id) : null,
                                child: Container(
                                  padding: MedSpacing.insetMd,
                                  decoration: BoxDecoration(
                                    color: MedColors.surface2,
                                    border: Border.all(color: MedColors.border2, width: 1.5),
                                  ),
                                  child: Column(
                                    spacing: 8.0,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(color: MedColors.surface3),
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(iconDataFromUnicode(item.unicode), size: 16),
                                      ),
                                      Text(item.name.toString(), style: MedTextStyles.titleSm()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
