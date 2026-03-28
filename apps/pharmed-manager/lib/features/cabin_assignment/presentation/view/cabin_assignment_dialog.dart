import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../widgets/editor/cabin_assignment_view.dart';

class CabinAssignmentDialog extends StatelessWidget {
  const CabinAssignmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'İlaç Atama',
      maxHeight: context.height,
      width: context.width * 0.9,
      child: CabinAssignmentView(),
    );
  }
}
