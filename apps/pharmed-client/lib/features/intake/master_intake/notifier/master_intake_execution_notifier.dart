import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';

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
  );
});

class MasterIntakeExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin,
        CabinOperationRecordingMixin<CabinOperationDrawerJob, CabinOperationTarget>
    implements CabinOperationExecutionController {
  MasterIntakeExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required OperationRecordingCoordinator recordingCoordinator,
    required CompleteIntakeUseCase completeIntake,
    required CompleteEquivalentIntakeUseCase completeEquivalentIntake,
    required CompleteRedirectedIntakeUseCase completeRedirectedIntake,
    required SubmitIntakeQrCodesUseCase submitIntakeQrCodes,
  }) : _drawerSession = drawerSession,
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

  /// start() ile selection'dan devralınır — IntakeParams'ta gerekiyor.
  IntakeType _intakeType = IntakeType.ordered;
  int? _hospitalizationId;

  /// Kuyruğa alınan planlar — kalem id'sine (target.sourceId) göre.
  Map<int, IntakePlan> _plans = const {};

  IntakePlan? _planOf(CabinOperationTarget target) {
    final id = target.sourceId;
    return id == null ? null : _plans[id];
  }

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
    Map<int, String> overdueDescriptions = const {},
  }) {
    _plans = {for (final p in plans) p.item.id: p};
    _intakeType = intakeType;
    _hospitalizationId = hospitalizationId;
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
    final plan = _planOf(target);
    if (plan == null) {
      // Planı olmayan hedef kuyruğa girmemeliydi — sessizce geçmek alımı
      // kaydetmeden çekmeceyi kapatırdı.
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets), isQueueError: true);
      return false;
    }

    final item = plan.item;
    final details = _detailsWithCounts(target, plan);
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
      ok: (_) => true,
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

  /// Hedefin QR zorunlu (Drug.isQrCode) kalemi için gereksinim. Miktar ADET
  /// — her kutu için bir kod.
  List<IntakeQrCodeRequirement> _qrCodeRequirementsOf(CabinOperationTarget target) {
    final plan = _planOf(target);
    if (plan == null) return const [];

    final medicine = plan.item.medicine;
    if (medicine is! Drug || !medicine.isQrCode) return const [];

    final totalAmount = plan.details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    final requiredCount = medicine.boxCountOf(totalAmount);
    if (requiredCount <= 0) return const [];

    return [
      IntakeQrCodeRequirement(
        prescriptionDetailId: plan.item.id,
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
    // Hedef başına tek ilaç → en fazla bir gereksinim.
    final requirement = qrCodeRequirements.firstOrNull;
    if (requirement == null || codes.isEmpty) return const Result.ok(null);

    final result = await _submitIntakeQrCodes(
      SubmitIntakeQrCodesParams(
        details: [
          IntakeQrCodeDetail(
            prescriptionDetailId: requirement.prescriptionDetailId,
            qrCode: [for (final c in codes) c.raw],
          ),
        ],
      ),
    );
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
