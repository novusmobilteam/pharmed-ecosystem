import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:pharmed_manager/features/firm/view/firm_screen.dart';
import 'package:pharmed_manager/features/warning/view/warning_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../medicine/presentation/view/medicine_screen.dart';
import '../../station_setup/view/station_screen.dart';
import '../notifier/home_notifier.dart';
part 'sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeNotifier>().fetchMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      context.read<AuthNotifier>().logout();
                    },
                    label: 'Çıkış Yap',
                    backgroundColor: Colors.black,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              DashboardAppBar(cabinLocation: '', cabinName: '', user: notifier.currentUser),
              Expanded(
                child: Row(
                  children: [
                    AppSidebar(),
                    Expanded(child: _HomeContent()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HomeNotifier>();
    final activeMenu = notifier.activeChildMenu; // aktif MenuItem

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(activeMenu?.route ?? 'default'), child: _buildContent(activeMenu)),
    );
  }

  Widget _buildContent(MenuItem? menu) {
    return switch (menu?.route) {
      'dashboard' || null => const SizedBox(),
      'station' => StationSetupScreen(menu: menu!),
      'firm' => FirmScreen(menu: menu!),
      'drug' => MedicineScreen(menu: menu!),
      'warning' => WarningScreen(menu: menu!),
      _ => const _NotFoundView(),
    };
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Sayfa bulunamadı'));
  }
}
