import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MasterRefundView extends ConsumerWidget {
  const MasterRefundView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(child: Text(context.l10n.refund_masterScreenNotReady));
  }
}
