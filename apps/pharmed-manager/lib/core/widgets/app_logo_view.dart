import 'package:flutter/material.dart';

import '../theme/app_images.dart';

class AppLogoView extends StatelessWidget {
  const AppLogoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.appLogo,
      width: 250,
      height: 80,
      color: Colors.red,
    );
  }
}
