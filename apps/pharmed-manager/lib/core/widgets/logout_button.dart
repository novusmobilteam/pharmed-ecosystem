import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../core.dart';
import '../storage/auth/auth.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          MessageUtils.showConfirmLogoutDialog(
            context: context,
            onConfirm: () {
              context.read<AuthStorageNotifier>().clearAuth();
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.red.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(PhosphorIconsRegular.signOut, color: Colors.red, size: 22),
              const SizedBox(width: 12),
              Text(
                'Çıkış Yap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
