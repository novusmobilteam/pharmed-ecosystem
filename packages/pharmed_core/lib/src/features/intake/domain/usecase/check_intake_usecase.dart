import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// [SWREQ-DATA-INTAKE-002] [IEC 62304 §5.5]
// İlaç alım kalemlerinin "check" (doğrulama) use case'i.
//
// Backend check endpoint'i yalnızca DOĞRULAMA yapar (stok var mı + şahit
// uygun mu) — 200 dönüşü "evet alınabilir" demektir, tahsis bilgisi TAŞIMAZ.
//
// Fiziksel stok tahsisi (hangi cabinDrawrStockId'den ne kadar) İKİ farklı
// kaynaktan gelir:
//   - ORDERED akış: servis (GetIntakeItemsUseCase → item.stock) her
//     prescriptionDetail için hedef stoğu ZATEN ÇÖZMÜŞ olarak döner. Client
//     bunu OLDUĞU GİBİ kullanır — yeniden hesaplamaz.
//   - ORDERLESS/FREE akış: servis önceden bir stok çözmez — client
//     assignment.stocks üzerinden FIFO ile (önden arkaya) tahsis yapar.
//
// Çıktı bir PLANDIR (kalem + stok detayları). Sayım değerleri burada
// yazılmaz — ilacın sayım tipine göre CabinOperationTarget belirler, kullanıcı
// girişi kayıt anında detaylara aktarılır.
//
// Tüm miktarlar ADET cinsindendir.
//
// Sınıf: Class B

/// Bir alım kaleminin kontrol sonrası planı: hangi stoktan ne kadar alınacağı.
typedef IntakePlan = ({IntakeItem item, List<IntakeDetail> details});

class CheckIntakeParams {
  CheckIntakeParams({
    required this.type,
    required this.userId,
    this.hospitalizationId,
    this.prescriptionDetailId,
    required this.assignment,
    this.resolvedStock,
    required this.dosePiece,
  });

  final IntakeType type;
  final int userId;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final MedicineAssignment assignment;

  /// Ordered akışta servis tarafından önceden çözülmüş hedef stok — varsa
  /// FIFO'ya hiç girilmez, doğrudan bu stoktan dosePiece kadar istek kurulur.
  final CabinStock? resolvedStock;

  /// Alınacak miktar (adet).
  final double dosePiece;
}

class IntakeBatchCheckResult {
  const IntakeBatchCheckResult({required this.plans, required this.statuses});

  /// Yalnızca BAŞARILI kontroller — hatalı kalemler bu listeye girmez.
  final List<IntakePlan> plans;
  final Map<int, IntakeCheckState> statuses;
}

class CheckIntakeUseCase {
  CheckIntakeUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<List<IntakeDetail>>> call(CheckIntakeParams params) async {
    final details = _resolveDetails(params);

    // Plan istenen miktarı karşılamıyorsa (FIFO'da gözlerde yeterli stok
    // yok) kontrol GÖNDERİLMEZ — eksik planla alım yapılmamalı.
    final planned = details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    if (details.isEmpty || planned < params.dosePiece) {
      return Result.error(CustomException(message: contextlessL10n().intake_hint_noStock));
    }

    final withdrawParams = IntakeParams(
      type: params.type,
      details: details,
      prescriptionDetailId: params.prescriptionDetailId,
      hospitalizationId: params.hospitalizationId,
      userId: params.userId,
    );

    final result = switch (params.type) {
      IntakeType.ordered => await _repository.checkOrderedIntake(withdrawParams.toJson()),
      IntakeType.orderless => await _repository.checkOrderlessIntake(withdrawParams.toJson()),
      IntakeType.free => await _repository.checkFreeIntake(withdrawParams.toJson()),
      IntakeType.urgent => await _repository.checkUrgentIntake(withdrawParams.toJson()),
    };

    // Sunucu yalnızca doğrulama sonucu döner, tahsis bilgisi taşımaz —
    // dönüş değeri bilerek kullanılmıyor, yukarıda hesaplanan plan döner.
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  /// Seçili kalemleri sırayla kontrol eder ve başarılı olanların planını
  /// döner. Ordered akışta her kalem kendi `resolvedStock`'unu taşıdığı için
  /// kalemler arası tüketim takibi GEREKMEZ — servis zaten farklı kalemleri
  /// farklı stoklara dağıtmış olarak döner.
  Future<IntakeBatchCheckResult> callBatch({
    required IntakeType type,
    required int userId,
    int? hospitalizationId,
    required List<IntakeItem> items,
    void Function(int itemId, IntakeCheckState status)? onItemStatusChanged,
  }) async {
    final plans = <IntakePlan>[];
    final statuses = <int, IntakeCheckState>{};

    void report(int itemId, IntakeCheckState status) {
      statuses[itemId] = status;
      onItemStatusChanged?.call(itemId, status);
    }

    for (final item in items) {
      onItemStatusChanged?.call(item.id, const CheckLoading());

      // resolvedStock yoksa (orderless/free) assignment ZORUNLU — FIFO
      // tahsisi assignment.stocks üzerinden yapılıyor. İkisi de yoksa hedef
      // hiç çözülememiş demektir, boş istek göndermek yerine hata üret.
      final assignment = item.assignment;
      if (item.stock == null && assignment == null) {
        report(item.id, CheckFailed(message: contextlessL10n().cabinCore_targetDrawerNotFound));
        continue;
      }

      final result = await call(
        CheckIntakeParams(
          type: type,
          userId: userId,
          hospitalizationId: hospitalizationId,
          prescriptionDetailId: item.id,
          assignment: assignment ?? MedicineAssignment(),
          resolvedStock: item.stock,
          dosePiece: item.dosePiece ?? 0,
        ),
      );

      result.when(
        ok: (details) {
          plans.add((item: item, details: details));
          report(item.id, const CheckSuccess());
        },
        error: (e) => report(item.id, CheckFailed(message: e.message)),
      );
    }

    return IntakeBatchCheckResult(plans: plans, statuses: statuses);
  }

  List<IntakeDetail> _resolveDetails(CheckIntakeParams params) {
    // Servis hedef stoğu önceden çözmüşse (ordered akış) DOĞRUDAN onu kullan.
    final resolved = params.resolvedStock;
    if (resolved != null) {
      final id = resolved.id;
      return id == null ? const [] : [IntakeDetail(stockId: id, dosePiece: params.dosePiece)];
    }

    // Orderless/free: servis stok çözmedi, client FIFO ile tahsis eder.
    return _prepareWithdrawDetails(params.assignment, params.dosePiece);
  }

  /// FIFO: gözler önden arkaya (stepNo artan) dolaşılır, her gözdeki
  /// stoktan istenen miktar dolana kadar alınır.
  List<IntakeDetail> _prepareWithdrawDetails(MedicineAssignment assignment, double amount) {
    final requestList = <IntakeDetail>[];
    var remaining = amount;

    final cells = List<DrawerCell>.from(assignment.cabinDrawerDetail ?? const <DrawerCell>[])
      ..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));

    for (final cell in cells) {
      if (remaining <= 0) break;

      final stocksInCell = (assignment.stocks ?? const <CabinStock>[]).where((s) => s.cabinDrawerDetailId == cell.id);
      for (final stock in stocksInCell) {
        if (remaining <= 0) break;
        final id = stock.id;
        final available = (stock.quantity ?? 0).toDouble();
        if (id == null || available <= 0) continue;

        final take = available < remaining ? available : remaining;
        requestList.add(IntakeDetail(stockId: id, dosePiece: take));
        remaining -= take;
      }
    }

    return requestList;
  }
}
