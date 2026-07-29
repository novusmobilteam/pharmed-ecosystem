// [SWREQ-DATA-INTAKE-002] [IEC 62304 §5.5]
// İlaç alım kalemlerinin "check" (doğrulama) use case'i.
//
// Backend check endpoint'i yalnızca DOĞRULAMA yapar (stok var mı + şahit
// uygun mu) — 200 dönüşü "evet alınabilir" demektir, tahsis bilgisi TAŞIMAZ.
//
// Fiziksel stok tahsisi (hangi cabinDrawrStockId'den ne kadar) İKİ farklı
// kaynaktan gelir:
//   - ORDERED akış: servis (GetIntakeItemsUseCase → MedicineIntakeItem.stock)
//     her prescriptionDetail için hedef stoğu ZATEN ÇÖZMÜŞ olarak döner.
//     Client bunu OLDUĞU GİBİ kullanır — yeniden hesaplamaz. Aynı çekmece/
//     ilaca ait birden fazla item farklı stockId'lere çözülmüş olabilir
//     (ör. aynı saatte 3 hastaya yazılan aynı ilaç → 616, 616, 617) — bu
//     zaten servisin kendi dağıtım kararıdır.
//   - ORDERLESS/FREE akış: belirli bir prescriptionDetail'e bağlı olmadığı
//     için servis önceden bir stok çözmez — bu durumda client
//     assignment.stocks üzerinden FIFO ile tahsis yapar (_prepareWithdrawDetails).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CheckIntakeParams {
  final IntakeType type;
  final int userId;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final MedicineAssignment assignment;

  /// Ordered akışta servis tarafından önceden çözülmüş hedef stok — varsa
  /// FIFO'ya hiç girilmez, doğrudan bu stoktan dosePiece kadar istek kurulur.
  final CabinStock? resolvedStock;

  final double dosePiece;

  CheckIntakeParams({
    required this.type,
    required this.userId,
    this.hospitalizationId,
    this.prescriptionDetailId,
    required this.assignment,
    this.resolvedStock,
    required this.dosePiece,
  });
}

class IntakeBatchCheckResult {
  const IntakeBatchCheckResult({required this.targets, required this.statuses});
  final List<IntakeTarget> targets;
  final Map<int, IntakeCheckStatus> statuses;
}

class CheckIntakeUseCase {
  final IIntakeRepository _repository;

  CheckIntakeUseCase(this._repository);

  Future<Result<List<IntakeDetail>>> call(CheckIntakeParams params) async {
    final details = _resolveDetails(params);

    final withdrawParams = IntakeParams(
      type: params.type,
      details: details,
      prescriptionDetailId: params.prescriptionDetailId,
      hospitalizationId: params.hospitalizationId,
      userId: params.userId,
    );

    final result = switch (params.type) {
      IntakeType.ordered => await _repository.checkOrderedIntake(withdrawParams.toJson()),
      IntakeType.orderless || IntakeType.urgent => await _repository.checkOrderlessIntake(withdrawParams.toJson()),
      IntakeType.free => await _repository.checkFreeIntake(withdrawParams.toJson()),
    };

    // Sunucu yalnızca doğrulama sonucu döner, tahsis bilgisi taşımaz — bu
    // yüzden dönüş değeri bilerek kullanılmıyor, yukarıda hesaplanan
    // `details` döndürülüyor.
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  /// Seçili tüm item'ları sırayla check eder. Ordered akışta her item kendi
  /// `resolvedStock`'unu taşıdığı için item'lar arası bir tüketim takibine
  /// GEREK YOKTUR — servis zaten farklı item'ları farklı stoklara dağıtmış
  /// olarak döner.
  Future<IntakeBatchCheckResult> callBatch({
    required IntakeType type,
    required int userId,
    int? hospitalizationId,
    required List<IntakeItem> items,
    void Function(int itemId, IntakeCheckStatus status)? onItemStatusChanged,
  }) async {
    final targets = <IntakeTarget>[];
    final statuses = <int, IntakeCheckStatus>{};

    for (final item in items) {
      onItemStatusChanged?.call(item.id, const CheckLoading());

      // resolvedStock yoksa (orderless/free) assignment ZORUNLU — FIFO
      // tahsisi assignment.stocks üzerinden yapılıyor. İkisi de yoksa hedef
      // hiç çözülememiş demektir, sessizce boş istek göndermek yerine
      // burada hata üret.
      if (item.stock == null && item.assignment == null) {
        const failure = CheckFailed(message: 'Hedef çekmece/göz bulunamadı');
        statuses[item.id] = failure;
        onItemStatusChanged?.call(item.id, failure);
        continue;
      }

      final result = await call(
        CheckIntakeParams(
          type: type,
          userId: userId,
          hospitalizationId: hospitalizationId,
          prescriptionDetailId: item.prescriptionItem?.id,
          assignment: item.assignment ?? MedicineAssignment(),
          resolvedStock: item.stock,
          dosePiece: item.dosePiece ?? 0,
        ),
      );

      result.when(
        ok: (details) {
          statuses[item.id] = const CheckSuccess();
          targets.add(IntakeTarget(item: item, details: _prepareCounting(item, details)));
          onItemStatusChanged?.call(item.id, const CheckSuccess());
        },
        error: (e) {
          statuses[item.id] = CheckFailed(message: e.message);
          onItemStatusChanged?.call(item.id, CheckFailed(message: e.message));
        },
      );
    }

    return IntakeBatchCheckResult(targets: targets, statuses: statuses);
  }

  List<IntakeDetail> _resolveDetails(CheckIntakeParams params) {
    // Servis hedef stoğu önceden çözmüşse (ordered akış) DOĞRUDAN onu kullan
    // — FIFO'ya hiç girme, tekrar hesaplama.
    final resolved = params.resolvedStock;
    if (resolved != null) {
      return [IntakeDetail(stockId: resolved.id ?? 0, dosePiece: params.dosePiece)];
    }

    // orderless/free: servis stok çözmedi, client FIFO ile tahsis eder.
    return _prepareWithdrawDetails(params.assignment, params.dosePiece);
  }

  List<IntakeDetail> _prepareWithdrawDetails(MedicineAssignment assignment, double amount) {
    final List<IntakeDetail> requestList = [];
    double remainingQty = amount;

    final sortedDetails = List.from(assignment.cabinDrawerDetail ?? [])
      ..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));

    for (var detail in sortedDetails) {
      if (remainingQty <= 0) break;

      final stocksInCell = (assignment.stocks ?? []).where((s) => s.cabinDrawerDetailId == detail.id).toList();
      if (stocksInCell.isEmpty) continue;

      for (var stock in stocksInCell) {
        if (remainingQty <= 0) break;
        final double currentStockQty = (stock.quantity ?? 0).toDouble();
        if (currentStockQty <= 0) continue;

        final double takeFromThisStock = currentStockQty < remainingQty ? currentStockQty : remainingQty;
        requestList.add(IntakeDetail(stockId: stock.id ?? 0, dosePiece: takeFromThisStock));
        remainingQty -= takeFromThisStock;
      }
    }

    return requestList;
  }

  List<IntakeDetail> _prepareCounting(IntakeItem item, List<IntakeDetail> details) {
    final drug = item.medicine as Drug?;
    final countType = drug?.countType;

    for (final detail in details) {
      if (countType == CountType.normalCount) {
        final rawStock =
            item.assignment?.stocks?.where((s) => s.id == detail.stockId).firstOrNull?.quantity?.toDouble() ?? 0.0;
        detail.censusQuantity = item.assignment?.toDisplayQuantity(rawStock) ?? rawStock;
      } else {
        detail.censusQuantity = null;
      }
    }
    return details;
  }
}
