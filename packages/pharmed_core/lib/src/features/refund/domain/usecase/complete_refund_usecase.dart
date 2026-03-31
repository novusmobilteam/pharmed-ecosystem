import 'package:pharmed_core/pharmed_core.dart';

class CompleteRefundParams {
  final ReturnType type;
  final int id;
  final double quantity;
  // Yerine İade'de gerekiyor
  final int? cabinDrawerDetailId;

  CompleteRefundParams({required this.type, required this.id, required this.quantity, this.cabinDrawerDetailId});
}

class CompleteRefundUseCase {
  final IRefundRepository _repository;

  CompleteRefundUseCase(this._repository);

  Future<Result<void>> call(CompleteRefundParams params) async {
    switch (params.type) {
      case ReturnType.toDrawer:
        return _repository.refundToDrawer(id: params.id, quantity: params.quantity);
      case ReturnType.toOrigin:
        return _repository.refundToOrigin(
          id: params.id,
          quantity: params.quantity,
          cabinDrawerDetailId: params.cabinDrawerDetailId ?? 0,
        );
      case ReturnType.toPharmacy:
        return _repository.refundToPharmacy(id: params.id, quantity: params.quantity);
      case ReturnType.toReturnBox:
        return _repository.refundToBox(id: params.id, quantity: params.quantity);
    }
  }
}
