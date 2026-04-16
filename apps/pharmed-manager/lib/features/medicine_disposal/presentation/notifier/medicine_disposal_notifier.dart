import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../cabin/domain/entity/cabin_input_data.dart';

import '../../domain/usecase/dispose_material_usecase.dart';
import '../../domain/usecase/get_disposable_materials_usecase.dart';

class MedicineDisposalNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<MedicineAssignment> {
  final GetDisposableMaterialsUseCase _getDisposableMaterialsUseCase;
  final DisposeMaterialUseCase _disposeMaterialUseCase;

  MedicineDisposalNotifier({
    required GetDisposableMaterialsUseCase getDisposableMaterialsUseCase,
    required DisposeMaterialUseCase disposeMaterialUseCase,
  }) : _getDisposableMaterialsUseCase = getDisposableMaterialsUseCase,
       _disposeMaterialUseCase = disposeMaterialUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();
  bool get isFetching => isLoading(fetchOp);

  List<MedicineAssignment> _selectedItems = [];
  List<MedicineAssignment> get selectedItems => _selectedItems;

  void getDisposableMaterials() async {
    await execute(
      fetchOp,
      operation: () => _getDisposableMaterialsUseCase.call(),
      onData: (data) {
        allItems = data;
        notifyListeners();
      },
    );
  }

  void selectItem(MedicineAssignment item, {Function(String msg)? onFailed}) {
    final drug = item.medicine as Drug?;
    if (drug == null) return;

    if (!drug.isDestroyable) {
      onFailed?.call('Bu ilaç imha edilemez.');
      return;
    }

    final wasSelected = _selectedItems.contains(item);
    _selectedItems.clear();

    if (!wasSelected) {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  Future<Result<void>> submit(
    List<CabinInputData> data, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final body = data
        .where((c) => (c.quantity) > 0)
        .map((c) => DisposeMaterialParams(stockId: c.stockId ?? 0, dosePiece: c.quantity))
        .toList();

    // if (dosePiece == 0) {
    //   final msg = 'Lütfen geçerli bir miktar giriniz.';
    //   onFailed?.call(msg);
    //   return Result.error(CustomException(message: msg));
    // }

    final result = await _disposeMaterialUseCase.call(body);

    return result.when(
      ok: (_) {
        final msg = "İlaç İmha işlemi başarıyla tamamlandı.";
        onSuccess?.call(msg);
        getDisposableMaterials();
        return Result.ok(null);
      },
      error: (error) {
        onFailed?.call(error.message);
        return Result.error(error);
      },
    );
  }
}
