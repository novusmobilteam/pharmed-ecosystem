import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../features/settings/presentation/view/settings_view.dart';
import '../storage/auth/auth.dart';
import 'clock_view.dart';

class DashboardStatusView extends StatelessWidget {
  const DashboardStatusView({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: width,
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClockView.mini(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: VerticalDivider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                indent: 8,
                endIndent: 8,
              ),
            ),
            Expanded(child: const _InitialsProfileWidget()),
            IconButton(
              onPressed: () => showSettingsView(context),
              icon: Icon(PhosphorIcons.gear()),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsProfileWidget extends StatelessWidget {
  const _InitialsProfileWidget();

  @override
  Widget build(BuildContext context) {
    final authStorage = context.read<AuthStorageNotifier>();
    final theme = Theme.of(context);

    final String fullName = authStorage.user?.fullName.toString() ?? 'Kullanıcı';
    final String role = (authStorage.user?.isAdmin ?? false) ? 'Admin' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fullName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // İsim uzunsa ... koy
            ),
            Text(
              role,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
