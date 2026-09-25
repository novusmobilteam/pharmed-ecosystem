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
//   - QR zorunlu ilaçlarda job tamamlanırken kuyruk askıya alınır.
//
// Sınıf: Class B

final masterIntakeExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterIntakeExecutionNotifier>((ref) {
  return MasterIntakeExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
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
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  MasterIntakeExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required CompleteIntakeUseCase completeIntake,
    required CompleteEquivalentIntakeUseCase completeEquivalentIntake,
    required CompleteRedirectedIntakeUseCase completeRedirectedIntake,
    required SubmitIntakeQrCodesUseCase submitIntakeQrCodes,
  }) : _drawerSession = drawerSession,
       _completeIntake = completeIntake,
       _completeEquivalentIntake = completeEquivalentIntake,
       _completeRedirectedIntake = completeRedirectedIntake,
       _submitIntakeQrCodes = submitIntakeQrCodes {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final CompleteIntakeUseCase _completeIntake;
  final CompleteEquivalentIntakeUseCase _completeEquivalentIntake;
  final CompleteRedirectedIntakeUseCase _completeRedirectedIntake;
  final SubmitIntakeQrCodesUseCase _submitIntakeQrCodes;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// Alımda SKT girilmez (CabinOperationMode.intake.requiresMiad == false)
  /// — alan hiç çizilmediği için değeri anlamsız.
  @override
  bool get isPerCellMiadEnabled => true;

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

  /// Aktif job'ın QR kod zorunluluğu varsa dolu — View bunu görüp dialog açar.
  CabinOperationDrawerJob? _qrCodeJob;
  CabinOperationDrawerJob? get qrCodeJob => _qrCodeJob;

  bool _isSubmittingQrCodes = false;
  bool get isSubmittingQrCodes => _isSubmittingQrCodes;

  Map<int, String> _qrCodeErrors = const {};
  Map<int, String> get qrCodeErrors => _qrCodeErrors;

  List<IntakeQrCodeRequirement> get qrCodeRequirements {
    final job = _qrCodeJob;
    return job == null ? const [] : _qrCodeRequirementsOf(job);
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
  }) {
    _plans = {for (final p in plans) p.item.id: p};
    _intakeType = intakeType;
    _hospitalizationId = hospitalizationId;
    return startQueue(jobs);
  }

  @override
  Future<void> confirmCurrent() async {
    final target = currentTarget;
    if (isStopping || target == null || !target.isValid) return;
    await confirmSingleTarget(saveTarget: _saveTarget);
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

  /// Job tamamlanmaya hazır olduğu an (kübikte her zaman, birim dozda
  /// SADECE son target kapandığında) QR zorunluluğunu kontrol eder. Zorunlu
  /// hedef varsa kuyruğu askıya alır — View qrCodeJob'ı görüp dialog açar.
  @override
  Future<bool> onBeforeAdvanceAfterClose(CabinOperationTarget? target) async {
    final job = currentJob;
    if (job == null) return true;

    final isJobCompleting = job.staysOpenAcrossTargets || (currentTargetIndex + 1 >= job.targets.length);
    if (!isJobCompleting) return true;

    if (_qrCodeRequirementsOf(job).isEmpty) return true;

    _qrCodeJob = job;
    notifyListeners();
    return false;
  }

  /// Job'daki QR zorunlu (Drug.isQrCode) kalemleri, kalem bazında gruplanmış
  /// gereksinim olarak döner. Miktar ADET — her kutu için bir kod.
  List<IntakeQrCodeRequirement> _qrCodeRequirementsOf(CabinOperationDrawerJob job) {
    final byItemId = <int, IntakeQrCodeRequirement>{};

    for (final target in job.targets) {
      final plan = _planOf(target);
      if (plan == null) continue;

      final medicine = plan.item.medicine;
      if (medicine is! Drug || !medicine.isQrCode) continue;

      final requiredCount = plan.details.fold<double>(0, (sum, d) => sum + d.dosePiece).ceil();
      if (requiredCount <= 0) continue;

      final existing = byItemId[plan.item.id];
      byItemId[plan.item.id] = IntakeQrCodeRequirement(
        prescriptionDetailId: plan.item.id,
        medicineName: medicine.name ?? existing?.medicineName ?? '—',
        requiredCount: (existing?.requiredCount ?? 0) + requiredCount,
      );
    }

    return byItemId.values.toList();
  }

  /// "İşlemi Tamamla" — yalnızca dolu girilen hedefler için istek atar; boş
  /// bırakılanlar backend'de otomatik "okutulmadı" sayılır. Hata alan hedef
  /// olsa dahi kuyruk İLERLER — hata yalnızca dialog'da gösterilir.
  Future<void> submitQrCodesAndContinue(Map<int, List<String>> codesByPrescriptionDetailId) async {
    if (_qrCodeJob == null) return;

    final toSubmit = qrCodeRequirements
        .where((r) => (codesByPrescriptionDetailId[r.prescriptionDetailId] ?? const []).isNotEmpty)
        .toList();

    if (toSubmit.isEmpty) {
      await _finishQrDialog();
      return;
    }

    _isSubmittingQrCodes = true;
    notifyListeners();

    final errors = <int, String>{};
    for (final req in toSubmit) {
      final codes = codesByPrescriptionDetailId[req.prescriptionDetailId]!;
      final result = await _submitIntakeQrCodes(
        SubmitIntakeQrCodesParams(
          details: [IntakeQrCodeDetail(prescriptionDetailId: req.prescriptionDetailId, qrCode: codes)],
        ),
      );
      result.when(ok: (_) {}, error: (e) => errors[req.prescriptionDetailId] = e.message);
    }

    if (errors.isEmpty) {
      await _finishQrDialog();
    } else {
      _isSubmittingQrCodes = false;
      _qrCodeErrors = errors;
      notifyListeners();
    }
  }

  /// "Karekod Okutmadan Devam Et" — tüm girdileri yok sayar.
  Future<void> skipQrCodesAndContinue() => _finishQrDialog();

  Future<void> acknowledgeQrCodeErrorsAndContinue() => skipQrCodesAndContinue();

  Future<void> _finishQrDialog() async {
    _qrCodeJob = null;
    _isSubmittingQrCodes = false;
    _qrCodeErrors = const {};
    notifyListeners();
    await resumeAfterBlockedAdvance();
  }

  // ── Konum rehberi ─────────────────────────────────────────────────────

  @override
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => locationItemsUsing(
    allGroups: allGroups,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    stockIdAt: (job, i) => _planOf(job.targets[i])?.details.firstOrNull?.stockId,
    stockIdsAt: (job, i) => [...?_planOf(job.targets[i])?.details.map((d) => d.stockId)],
  );
}
