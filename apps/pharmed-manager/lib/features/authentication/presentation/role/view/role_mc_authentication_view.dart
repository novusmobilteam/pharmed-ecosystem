import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../notifier/role_mc_auth_notifier.dart';

class RoleMcAuthenticationView extends StatelessWidget {
  const RoleMcAuthenticationView({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleMcAuthNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return ListView(
          children: DrugOp.values.map((op) {
            final checked = notifier.roleAuth?.hasOp(op) ?? false;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomCheckboxTile(
                label: op.label,
                value: checked,
                onTap: () {
                  notifier.toggleAuth(op);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
