import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_manager/features/auth/view/login_screen.dart';
import 'package:pharmed_manager/features/auth/notifier/auth_state.dart';
import 'package:pharmed_manager/features/home/view/home_screen.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;

    return switch (authState) {
      AuthLoggedOut() => const LoginScreen(),
      AuthLoading() => const LoginScreen(),
      AuthLoggedIn() => const HomeScreen(),
      AuthError() => const LoginScreen(),
      AuthSessionExpiring() => const LoginScreen(),
    };
  }
}
