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
//     prescriptionDetail için hedef stoğu ÇÖZMÜŞ olarak döner. Client önce
//     o kayıttan, kaydın miktarı kadar alır. Kayıt dozu tek başına
//     karşılamıyorsa kalan miktar aynı atamanın diğer kayıtlarından FIFO ile
//     tamamlanır (#123) — seçim ekranı atamanın TOPLAM stoğuna göre izin
//     verdiği için dozun tamamı tek kayda yazılırsa kayıt bazlı kontrol
//     reddediyordu.
//   - ORDERLESS/FREE akış: servis önceden bir stok çözmez — client
//     assignment.stocks üzerinden FIFO ile (önden arkaya) tahsis yapar.
//
// Toplu kontrolde aynı kayıtları paylaşan kalemler için önceki kalemlerin
// planladığı miktar düşülür (CheckIntakeParams.alreadyPlanned).
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
    this.overdueDescription,
    this.alreadyPlanned = const {},
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
  final String? overdueDescription;

  /// Aynı toplu kontrolde önceki kalemlerin planladığı miktar: stokId → adet.
  final Map<int, double> alreadyPlanned;
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

  static const _unit = 'SW-UNIT-INTAKE';
  static const _swreq = 'SWREQ-DATA-INTAKE-002';

  /// Kalemin log bağlamı — hangi kalem, hangi stok/atama, ne kadar.
  static Map<String, dynamic> _paramsLog(CheckIntakeParams p) => {
    'type': p.type.name,
    'prescriptionDetailId': p.prescriptionDetailId,
    'hospitalizationId': p.hospitalizationId,
    'dose': p.dosePiece,
    'resolvedStockId': p.resolvedStock?.id,
    'resolvedStockQty': p.resolvedStock?.quantity,
    'assignmentId': p.assignment.id,
    'assignmentStocks': [
      for (final st in p.assignment.stocks ?? const <CabinStock>[]) '${st.id}:${st.quantity}',
    ],
  };

  Future<Result<List<IntakeDetail>>> call(CheckIntakeParams params) async {
    final details = _resolveDetails(params);

    // Plan istenen miktarı karşılamıyorsa (FIFO'da gözlerde yeterli stok
    // yok) kontrol GÖNDERİLMEZ — eksik planla alım yapılmamalı.
    final planned = details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    if (details.isEmpty || planned < params.dosePiece) {
      // [SWREQ-CORE-LOG-004] Servise GİDİLMEDİ — client planı yetersiz.
      MedLogger.ruleRejected(
        unit: _unit,
        swreq: _swreq,
        rule: 'INTAKE_PLAN_INSUFFICIENT',
        message: 'Alım planı istenen miktarı karşılamıyor, check gönderilmedi',
        context: {
          ..._paramsLog(params),
          'planned': planned,
          'plan': [for (final d in details) '${d.stockId}:${d.dosePiece}'],
        },
      );
      return Result.error(CustomException(message: contextlessL10n().intake_hint_noStock));
    }

    final withdrawParams = IntakeParams(
      type: params.type,
      details: details,
      prescriptionDetailId: params.prescriptionDetailId,
      hospitalizationId: params.hospitalizationId,
      userId: params.userId,
      overdueDescription: params.overdueDescription,
    );

    final result = switch (params.type) {
      IntakeType.ordered => await _repository.checkOrderedIntake(withdrawParams.toJson()),
      IntakeType.orderless => await _repository.checkOrderlessIntake(withdrawParams.toJson()),
      IntakeType.free => await _repository.checkFreeIntake(withdrawParams.toJson()),
      IntakeType.urgent => await _repository.checkUrgentIntake(withdrawParams.toJson()),
    };

    // Sunucu yalnızca doğrulama sonucu döner, tahsis bilgisi taşımaz —
    // dönüş değeri bilerek kullanılmıyor, yukarıda hesaplanan plan döner.
    return result.when(
      ok: (_) => Result.ok(details),
      error: (e) {
        // İstek/yanıt ayrıntısı NetworkLogInterceptor'da; burada kalemle eşlenir.
        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: 'Alım check servisi kalemi reddetti',
          context: {..._paramsLog(params), 'plan': [for (final d in details) '${d.stockId}:${d.dosePiece}'], ...e.logContext},
        );
        return Result.error(e);
      },
    );
  }

  /// Seçili kalemleri sırayla kontrol eder ve başarılı olanların planını
  /// döner. Başarılı kalemlerin planladığı miktar sonraki kalemlerin
  /// planından düşülür: aynı gözden alınan order'lar aynı stok kayıtlarını
  /// paylaşabilir (ör. ikisinin resolvedStock'u aynı kayıt).
  Future<IntakeBatchCheckResult> callBatch({
    required IntakeType type,
    required int userId,
    int? hospitalizationId,
    required List<IntakeItem> items,
    Map<int, String> overdueDescriptions = const {},
    void Function(int itemId, IntakeCheckState status)? onItemStatusChanged,
  }) async {
    final plans = <IntakePlan>[];
    final statuses = <int, IntakeCheckState>{};
    // Başarılı kontrollerin planladığı miktar — sonraki kalemler aynı
    // kayıttan bunu düşerek planlar.
    final planned = <int, double>{};

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
        MedLogger.ruleRejected(
          unit: _unit,
          swreq: _swreq,
          rule: 'INTAKE_TARGET_UNRESOLVED',
          message: 'Kalemin stoğu ve ataması yok, check gönderilmedi',
          context: {'itemId': item.id, 'type': type.name, 'medicineId': item.medicine?.id},
        );
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
          overdueDescription: overdueDescriptions[item.id],
          alreadyPlanned: Map.unmodifiable(planned),
        ),
      );

      result.when(
        ok: (details) {
          for (final d in details) {
            planned.update(d.stockId, (v) => v + d.dosePiece, ifAbsent: () => d.dosePiece);
          }
          plans.add((item: item, details: details));
          report(item.id, const CheckSuccess());
        },
        error: (e) => report(item.id, CheckFailed(message: e.message)),
      );
    }

    return IntakeBatchCheckResult(plans: plans, statuses: statuses);
  }

  List<IntakeDetail> _resolveDetails(CheckIntakeParams params) {
    final resolved = params.resolvedStock;
    if (resolved != null) return _planFromResolved(params, resolved);

    // Orderless/free: servis stok çözmedi, client FIFO ile tahsis eder.
    return _prepareWithdrawDetails(params.assignment, params.dosePiece, used: params.alreadyPlanned);
  }

  /// Ordered: önce servisin çözdüğü kayıt, kaydın miktarı kadar; kalan
  /// miktar aynı atamanın diğer kayıtlarından FIFO.
  List<IntakeDetail> _planFromResolved(CheckIntakeParams params, CabinStock resolved) {
    final id = resolved.id;
    if (id == null) return const [];

    // Kaydın miktarı: ekrandaki atama listesi (kayıt bazlı kontrolün de
    // kullandığı kaynak), yoksa servisin döndürdüğü kayıt.
    num? known;
    for (final s in params.assignment.stocks ?? const <CabinStock>[]) {
      if (s.id == id) known = s.quantity;
    }
    known ??= resolved.quantity;
    // Miktar bilinmiyorsa servisin kararı geçerli — dozun tamamı bu kayıttan.
    if (known == null) return [IntakeDetail(stockId: id, dosePiece: params.dosePiece)];

    final available = known.toDouble() - (params.alreadyPlanned[id] ?? 0);
    if (available >= params.dosePiece) return [IntakeDetail(stockId: id, dosePiece: params.dosePiece)];

    final fromResolved = available > 0 ? available : 0.0;
    return [
      if (fromResolved > 0) IntakeDetail(stockId: id, dosePiece: fromResolved),
      ..._prepareWithdrawDetails(
        params.assignment,
        params.dosePiece - fromResolved,
        used: params.alreadyPlanned,
        exclude: {id},
      ),
    ];
  }

  /// FIFO: gözler önden arkaya (stepNo artan) dolaşılır, her gözdeki
  /// stoktan istenen miktar dolana kadar alınır. [used]: önceki kalemlerin
  /// planladığı miktar düşülür; [exclude]: zaten planlanmış kayıtlar.
  List<IntakeDetail> _prepareWithdrawDetails(
    MedicineAssignment assignment,
    double amount, {
    Map<int, double> used = const {},
    Set<int> exclude = const {},
  }) {
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
        if (id == null || exclude.contains(id)) continue;
        final available = (stock.quantity ?? 0).toDouble() - (used[id] ?? 0);
        if (available <= 0) continue;

        final take = available < remaining ? available : remaining;
        requestList.add(IntakeDetail(stockId: id, dosePiece: take));
        remaining -= take;
      }
    }

    return requestList;
  }
}
