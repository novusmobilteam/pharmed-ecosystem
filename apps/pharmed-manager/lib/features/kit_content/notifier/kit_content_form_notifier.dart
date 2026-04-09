import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class KitContentFormNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<KitContent> {
  final CreateKitContentUseCase _createKitContentUseCase;
  final UpdateKitContentUseCase _updateKitContentUseCase;

  KitContentFormNotifier({
    required CreateKitContentUseCase createKitContentUseCase,
    required UpdateKitContentUseCase updateKitContentUseCase,
    KitContent? kitContent,
    int? kitId,
  }) : _createKitContentUseCase = createKitContentUseCase,
       _updateKitContentUseCase = updateKitContentUseCase,
       _kitContent = kitContent ?? KitContent(),
       _kitId = kitId;

  int? _kitId;

  // Variables
  KitContent _kitContent;
  KitContent get kitContent => _kitContent;

  bool get isCreate => _kitContent.id == null;

  OperationKey submitOp = OperationKey.submit();

  // Functions
  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final content = _kitContent.copyWith(kitId: _kitId);

    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createKitContentUseCase.call(content) : _updateKitContentUseCase.call(content),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateMaterial(Medicine? value) {
    _kitContent = _kitContent.copyWith(medicine: value);
    notifyListeners();
  }

  void updatePiece(String? value) {
    final piece = value != null && value.isNotEmpty ? int.tryParse(value) : null;
    _kitContent = _kitContent.copyWith(piece: piece);
    notifyListeners();
  }
}
