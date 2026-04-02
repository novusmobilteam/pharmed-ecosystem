import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/dashboard_status_view.dart';
import '../../../core/widgets/navigation_sidebar.dart';
import '../notifier/home_notifier.dart';
import 'grid_menu_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeNotifier>().fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SizedBox(),
      tablet: SizedBox(),
      desktop: Scaffold(
        body: Consumer<HomeNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isFetching && notifier.isEmpty) {
              return Center(child: CircularProgressIndicator.adaptive());
            }

            if (notifier.isEmpty) {
              return Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonEmptyStates.generic(
                    icon: PhosphorIcons.fingerprint(),
                    message: 'Yetkili Menü Bulunamadı',
                    subMessage:
                        'Hesabınıza tanımlanmış erişim yetkisi bulunmamaktadır.\nErişim sağlamak için sistem yöneticiniz ile iletişime geçiniz.',
                  ),
                  SizedBox(
                    width: 200,
                    child: PharmedButton(
                      onPressed: () {
                        context.read<AuthManagerNotifier>().logout();
                      },
                      label: 'Çıkış Yap',
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              );
            }

            return Padding(padding: AppDimensions.pagePadding, child: _HomeView());
          },
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static const double kRightColumnWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeNotifier>(
      builder: (context, notifier, _) {
        if (notifier.parentMenuItems.isEmpty || notifier.isFetching) {
          return Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.parentMenuItems.isEmpty) {
          return Column(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonEmptyStates.generic(
                icon: PhosphorIcons.fingerprint(),
                message: 'Yetkili Menü Bulunamadı',
                subMessage:
                    'Hesabınıza tanımlanmış erişim yetkisi bulunmamaktadır.\nErişim sağlamak için sistem yöneticiniz ile iletişime geçiniz.',
              ),
              SizedBox(
                width: 200,
                child: PharmedButton(
                  onPressed: () {
                    context.read<AuthManagerNotifier>().logout();
                  },
                  label: 'Çıkış Yap',
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          );
        }

        return Row(
          spacing: 20,
          children: [
            // Menüler
            NavigationSidebar(
              key: ValueKey(notifier.parentMenuItems),
              selectedIndex: notifier.activeTab,
              onTap: notifier.changeTab,
              items: notifier.parentMenuItems,
            ),
            Expanded(
              flex: 4,
              child: GridMenuView(
                key: ValueKey(notifier.menuItems),
                childAspectRatio: 2,
                crossAxisCount: 3,
                title: notifier.parentMenuItems.isNotEmpty
                    ? (notifier.parentMenuItems[notifier.activeTab].label ?? "Menü")
                    : "Menü",
                items: notifier.activeTabMenuItems,
              ),
            ),
            // Status & Favorites
            SizedBox(
              width: kRightColumnWidth,
              child: Column(
                children: [
                  DashboardStatusView(width: kRightColumnWidth),
                  // Expanded(child: FavoriteQuickAccess(allMenuItems: notifier.menuItems)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
