import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import 'intake_plan_merger.dart';

// [SWREQ-CLI-MINTAKE-002] [IEC 62304 §5.5]
// Master kabin alımının donanım yürütme fazı. Kuyruk, durdurma, hata
// kurtarma ve giriş güncellemeleri ortak mixin'lerden gelir. Alıma özgü:
//   - Kayıt, target'ın kaynak kalemine (plan) göre üç yoldan gider:
//     yönlendirilmiş, muadil, normal.
//   - Kullanıcının sayımı kayıt anında plan detaylarına aktarılır.
//   - Hedef, "Tamamla" butonuyla YA DA fiziksel kapanışla tamamlanır:
//     kübikte gözün kapağı, birim dozda çekmece kapanınca
//     (completesOnPhysicalClose). Sıradaki kübik kapak, önceki kapak
//     kapanmadan açılmaz.
//   - QR zorunlu ilaçta, hedef tamamlanır tamamlanmaz (sıradaki ilaca
//     geçmeden) kuyruk askıya alınır ve QR dialog'u açılır.
//   - [SWREQ-CLI-MINTAKE-003] Aynı ilacın aynı gözden alınan kalemleri
//     (farklı order saatleri) tek hedeftir; kayıt yine kalem bazında atılır
//     (bkz. IntakePlanMerger).
//
// Sınıf: Class B

final masterIntakeExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterIntakeExecutionNotifier>((ref) {
  return MasterIntakeExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    recordingCoordinator: ref.read(operationRecordingCoordinatorProvider),
    completeIntake: ref.read(completeIntakeUseCaseProvider),
    completeEquivalentIntake: ref.read(completeEquivalentIntakeUseCaseProvider),
    completeRedirectedIntake: ref.read(completeRedirectedIntakeUseCaseProvider),
    submitIntakeQrCodes: ref.read(submitIntakeQrCodesUseCaseProvider),
    receiptService: ref.read(operationReceiptServiceProvider),
  );
});

class MasterIntakeExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin,
        CabinOperationRecordingMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationReceiptMixin<CabinOperationDrawerJob, CabinOperationTarget>
    implements CabinOperationExecutionController {
  MasterIntakeExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required OperationRecordingCoordinator recordingCoordinator,
    required CompleteIntakeUseCase completeIntake,
    required CompleteEquivalentIntakeUseCase completeEquivalentIntake,
    required CompleteRedirectedIntakeUseCase completeRedirectedIntake,
    required SubmitIntakeQrCodesUseCase submitIntakeQrCodes,
    required OperationReceiptService receiptService,
  }) : _drawerSession = drawerSession,
       _receiptService = receiptService,
       _completeIntake = completeIntake,
       _recordingCoordinator = recordingCoordinator,
       _completeEquivalentIntake = completeEquivalentIntake,
       _completeRedirectedIntake = completeRedirectedIntake,
       _submitIntakeQrCodes = submitIntakeQrCodes {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final OperationRecordingCoordinator _recordingCoordinator;
  final CompleteIntakeUseCase _completeIntake;
  final CompleteEquivalentIntakeUseCase _completeEquivalentIntake;
  final CompleteRedirectedIntakeUseCase _completeRedirectedIntake;
  final SubmitIntakeQrCodesUseCase _submitIntakeQrCodes;
  final OperationReceiptService _receiptService;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// Alımda miktar reçeteden gelir — kapanışta otomatik kayıt güvenlidir.
  @override
  bool get completesOnPhysicalClose => true;

  /// Alımda SKT girilmez (CabinOperationMode.intake.requiresMiad == false)
  /// — alan hiç çizilmediği için değeri anlamsız.
  @override
  bool get isPerCellMiadEnabled => true;

  @override
  OperationRecordingCoordinator get recordingCoordinator => _recordingCoordinator;

  @override
  RecordedOperationType get recordedOperationType => RecordedOperationType.intake;

  // ── Fiş [SWREQ-PRN-093] ───────────────────────────────────────────────

  @override
  OperationReceiptService get receiptService => _receiptService;

  @override
  OperationReceiptKind get receiptKind => OperationReceiptKind.intake;

  /// Fişte basılan hasta — start() ile selection'dan devralınır.
  Hospitalization? _hospitalization;

  /// Alınan ilaç gözdeki atamadan okunur (muadil alımda da fiziksel olarak
  /// alınan ilaç budur); miktar plandaki dozların toplamıdır.
  @override
  List<OperationReceiptLine> receiptLinesOf(CabinOperationTarget target) {
    final plan = _planOf(target);
    if (plan == null) return const [];
    final assignment = target.assignment;
    final medicine = assignment.medicine ?? plan.item.medicine;
    final quantity = plan.details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    return [
      OperationReceiptLine(
        medicineName: medicine?.name ?? '—',
        quantityLabel: intakeQuantityLabel(assignment, quantity),
        hospitalization: _hospitalization,
        location: receiptLocationOf(assignment),
        barcode: medicine?.barcode,
      ),
    ];
  }

  /// start() ile selection'dan devralınır — IntakeParams'ta gerekiyor.
  IntakeType _intakeType = IntakeType.ordered;
  int? _hospitalizationId;

  /// Kuyruğa alınan plan grupları — temsilci kalem id'sine (target.sourceId)
  /// göre. Tek kalemli grupta merged == members.first.
  Map<int, IntakePlanGroup> _groups = const {};

  /// Kaydı backend'e başarıyla gitmiş kalemler — birleşik hedefin kaydı
  /// yarıda hata verip tekrar denenirse aynı kalem ikinci kez kaydedilmez.
  final Set<int> _savedItemIds = {};

  IntakePlanGroup? _groupOf(CabinOperationTarget target) {
    final id = target.sourceId;
    return id == null ? null : _groups[id];
  }

  /// Hedefin (birleşik) planı — gösterim, fiş ve konum için.
  IntakePlan? _planOf(CabinOperationTarget target) => _groupOf(target)?.merged;

  // ── QR kodu ───────────────────────────────────────────────────────────

  /// QR okutması beklenen hedef — dolu olduğu sürece kuyruk askıda,
  /// View bunu görüp dialog açar.
  CabinOperationTarget? _qrCodeTarget;
  CabinOperationTarget? get qrCodeTarget => _qrCodeTarget;

  /// Zamanı geçmiş kalemler için alım öncesi girilen açıklamalar (itemId → metin).
  /// Kalemler yeniden çekildiğinde sıfırlanır.
  Map<int, String> _overdueDescriptions = const {};

  List<IntakeQrCodeRequirement> get qrCodeRequirements {
    final target = _qrCodeTarget;
    return target == null ? const [] : _qrCodeRequirementsOf(target);
  }

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  Future<void> start(
    List<CabinOperationDrawerJob> jobs, {
    required List<IntakePlan> plans,
    required IntakeType intakeType,
    required int? hospitalizationId,
    Hospitalization? hospitalization,
    Map<int, String> overdueDescriptions = const {},
  }) {
    _groups = {for (final g in IntakePlanMerger.group(plans)) g.merged.item.id: g};
    _savedItemIds.clear();
    _intakeType = intakeType;
    _hospitalizationId = hospitalizationId;
    _hospitalization = hospitalization;
    _overdueDescriptions = Map.unmodifiable(overdueDescriptions);
    _qrCodeTarget = null;
    return startQueue(jobs);
  }

  /// "Tamamla" yolu — kayıt hemen atılır, tamamlama fiziksel kapanışta.
  @override
  Future<void> confirmCurrent() async {
    final target = currentTarget;
    if (isStopping || target == null || !target.isValid) return;
    await confirmSingleTarget(saveTarget: _saveTarget);
  }

  /// "Tamamla"ya basılmadan kapak/çekmece kapandı — kayıt burada atılır.
  @override
  Future<bool> saveTargetOnPhysicalClose(CabinOperationTarget target) async {
    if (!target.isValid) {
      // Fiziksel kapanış geri alınamaz; geçersiz girdiyle (örn. zorunlu
      // sayım girilmeden) kayıt atmak yanlış stok üretir. Kullanıcıya kuyruk
      // hatası olarak gösterilir: devam et (hedef kaydedilmez) / sonlandır.
      setQueueFailure(
        const CabinValidationFailure(reason: CabinValidationReason.closedWithInvalidEntry),
        isQueueError: true,
      );
      return false;
    }
    return _saveTarget(target);
  }

  // ── Kayıt ─────────────────────────────────────────────────────────────

  Future<bool> _saveTarget(CabinOperationTarget target) async {
    final group = _groupOf(target);
    if (group == null) {
      // Planı olmayan hedef kuyruğa girmemeliydi — sessizce geçmek alımı
      // kaydetmeden çekmeceyi kapatırdı.
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets), isQueueError: true);
      return false;
    }

    // Sayım göz bazında bir kez girilir (alım öncesi gözdeki miktar). Birleşik
    // hedefte aynı stoğun sayımı yalnızca o stoğu içeren İLK kayıtla gider;
    // sonraki kayıtlar sayımsız gider ve backend kalan stoktan düşer.
    final countByStock = {for (final d in _detailsWithCounts(target, group.merged)) d.stockId: d.censusQuantity};
    final countedStocks = <int>{
      for (final m in group.members)
        if (_savedItemIds.contains(m.item.id)) ...m.details.map((d) => d.stockId),
    };

    for (final plan in group.members) {
      if (_savedItemIds.contains(plan.item.id)) continue;
      final details = [
        for (final d in plan.details)
          IntakeDetail(
            stockId: d.stockId,
            dosePiece: d.dosePiece,
            censusQuantity: countedStocks.add(d.stockId) ? countByStock[d.stockId] : null,
          ),
      ];
      if (!await _savePlan(plan, details)) return false;
      _savedItemIds.add(plan.item.id);
    }
    return true;
  }

  /// Tek kalemin kaydı — kaynak kaleme göre üç yoldan biri.
  Future<bool> _savePlan(IntakePlan plan, List<IntakeDetail> details) async {
    final item = plan.item;
    final firstCount = details.firstOrNull?.censusQuantity;

    final result = item.isRedirectedIntake
        ? await _completeRedirectedIntake.call(referralId: item.redirectedOrder!.id, censusQuantity: firstCount)
        : item.isEquivalentIntake
        ? await _completeEquivalentIntake.call(
            EquivalentIntakeParams(
              prescriptionDetailId: item.id,
              materialId: item.selectedEquivalent!.materialId ?? 0,
              censusQuantity: firstCount ?? details.firstOrNull?.dosePiece,
            ),
          )
        : await _completeIntake.call(
            IntakeParams(
              type: _intakeType,
              prescriptionDetailId: item.id,
              hospitalizationId: _hospitalizationId,
              userId: item.activeWitnessContext.witness?.id,
              details: details,
              overdueDescription: _overdueDescriptions[item.id],
            ),
          );

    return result.when(
      ok: (operationId) {
        recordServerOperationId(operationId); // [SWREQ-CAM-024] video ↔ sunucu işlemi
        return true;
      },
      error: (e) {
        setQueueFailure(CabinApiFailure(message: e.message), isQueueError: true);
        return false;
      },
    );
  }

  /// Kullanıcının sayımını plan detaylarına yazar. Sayım göz bazında
  /// girilir; her detay kendi stoğunun bulunduğu gözün sayımını alır.
  /// Sayım gösterilmeyen ilaçta (noCount) detaylara sayım gitmez.
  List<IntakeDetail> _detailsWithCounts(CabinOperationTarget target, IntakePlan plan) {
    double? countFor(IntakeDetail detail) {
      if (!target.showsCount) return null;
      if (target.isKubik) return target.cubicCount;
      final stepNo = IntakeTargetMapper.stepNoOf(plan.item, detail.stockId);
      if (stepNo == null || stepNo < 1 || stepNo > target.steps.length) return null;
      return target.steps[stepNo - 1].countQuantity;
    }

    return [
      for (final d in plan.details)
        IntakeDetail(stockId: d.stockId, dosePiece: d.dosePiece, censusQuantity: countFor(d)),
    ];
  }

  // ── QR kodu akışı ─────────────────────────────────────────────────────

  /// Hedef tamamlandı (kayıt + kapak/çekmece kapanışı). Karekodlu ilaçsa
  /// kuyruğu askıya alır — View qrCodeTarget'ı görüp dialog açar.
  @override
  Future<bool> onTargetCompleted(CabinOperationTarget target) async {
    if (_qrCodeRequirementsOf(target).isEmpty) return true;

    _qrCodeTarget = target;
    notifyListeners();
    return false;
  }

  /// Bir kalemin okutması gereken kutu sayısı. Miktar ADET — her kutu için
  /// bir kod. QR zorunlu olmayan ilaçta 0.
  int _qrBoxCountOf(IntakePlan plan) {
    final medicine = plan.item.medicine;
    if (medicine is! Drug || !medicine.isQrCode) return 0;
    final amount = plan.details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    return medicine.boxCountOf(amount);
  }

  /// Hedefin QR zorunlu (Drug.isQrCode) ilacı için TEK gereksinim. Birleşik
  /// hedefte kutu sayısı kalemlerin toplamıdır — kullanıcı ilacı bir kez
  /// okutur, kodlar gönderimde kalemlere dağıtılır ([submitQrCodes]).
  List<IntakeQrCodeRequirement> _qrCodeRequirementsOf(CabinOperationTarget target) {
    final group = _groupOf(target);
    if (group == null) return const [];

    final medicine = group.merged.item.medicine;
    if (medicine is! Drug || !medicine.isQrCode) return const [];

    final requiredCount = group.members.fold<int>(0, (sum, p) => sum + _qrBoxCountOf(p));
    if (requiredCount <= 0) return const [];

    return [
      IntakeQrCodeRequirement(
        prescriptionDetailId: group.merged.item.id,
        medicineName: medicine.name ?? '—',
        requiredCount: requiredCount,
        expectedGtin: medicine.barcode,
      ),
    ];
  }

  /// QrScanDialog'un onSubmit'i — askıdaki hedefin kodlarını gönderir.
  /// Kuyruğu İLERLETMEZ: hata dönerse dialog açık kalır, kullanıcı tekrar
  /// gönderebilir ya da iptal edebilir. Devam [finishQrCodes] ile.
  Future<Result<void>> submitQrCodes(List<Gs1Code> codes) async {
    final target = _qrCodeTarget;
    final group = target == null ? null : _groupOf(target);
    if (group == null || codes.isEmpty) return const Result.ok(null);

    // Kodlar okutma sırasıyla kalemlere, her kalemin kutu sayısı kadar dağıtılır.
    // Eksik okutulan kutular backend'de "okutulmadı" kalır.
    final details = <IntakeQrCodeDetail>[];
    var offset = 0;
    for (final plan in group.members) {
      final count = _qrBoxCountOf(plan);
      if (count <= 0 || offset >= codes.length) continue;
      final slice = codes.skip(offset).take(count);
      offset += count;
      details.add(IntakeQrCodeDetail(prescriptionDetailId: plan.item.id, qrCode: [for (final c in slice) c.raw]));
    }
    if (details.isEmpty) return const Result.ok(null);

    final result = await _submitIntakeQrCodes(SubmitIntakeQrCodesParams(details: details));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  /// Dialog kapandı (gönderildi ya da iptal edildi) — kuyruk devam eder.
  /// İptalde kutular backend'de "okutulmadı" sayılır ve Okutulmayan
  /// Karekodlar ekranından sonradan okutulabilir.
  Future<void> finishQrCodes() async {
    if (_qrCodeTarget == null) return;
    _qrCodeTarget = null;
    notifyListeners();
    await resumeAfterTargetCompleted();
  }

  @override
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => locationItemsUsing(
    allGroups: allGroups,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    stockIdAt: (job, i) => _planOf(job.targets[i])?.details.firstOrNull?.stockId,
    stockIdsAt: (job, i) => [...?_planOf(job.targets[i])?.details.map((d) => d.stockId)],
  );
}

/// Alım miktarı gösterimi. Ölçü birimli ilaçta toplam hacim öne alınır:
/// "100 ml (1 Adet × 100 ml)"; diğerlerinde atamanın standart etiketi.
String intakeQuantityLabel(MedicineAssignment assignment, num quantity) {
  final base = assignment.quantityLabel(quantity);
  final total = assignment.medicine?.stockTotalText(quantity);
  return total == null ? base : '$total ($base)';
}
