import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class BranchFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateBranchUseCase _createBranchUseCase;
  final UpdateBranchUseCase _updateBranchUseCase;
  Branch _branch;

  BranchFormNotifier({
    required CreateBranchUseCase createBranchUseCase,
    required UpdateBranchUseCase updateBranchUseCase,
    Branch? branch,
  }) : _createBranchUseCase = createBranchUseCase,
       _updateBranchUseCase = updateBranchUseCase,
       _branch = branch ?? Branch();

  OperationKey submitOp = OperationKey.submit();

  Branch get branch => _branch;
  bool get isCreate => _branch.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  // Functions
  Future<void> submit() async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createBranchUseCase.call(branch) : _updateBranchUseCase.call(branch),
    );
  }

  void updateName(String? value) {
    _branch = _branch.updateName(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _branch = _branch.updateStatus(value);
    notifyListeners();
  }
}
