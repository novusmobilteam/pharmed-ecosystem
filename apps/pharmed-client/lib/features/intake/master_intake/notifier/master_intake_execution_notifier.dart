import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_client/core/mixins/master_drawer_execution_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/cabin_drawer_queue_mixin.dart';
import '../../../../core/providers/providers.dart';

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
    with MasterDrawerExecutionMixin, CabinDrawerQueueMixin<IntakeDrawerJob, IntakeTarget> {
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

  /// start() ile selection'dan devralınır — IntakeParams'ta gerekiyor.
  IntakeType _intakeType = IntakeType.ordered;
  int? _hospitalizationId;

  /// Aktif job'ın QR kod zorunluluğu varsa dolu — View bunu görüp dialog açar.
  IntakeDrawerJob? _qrCodeJob;
  IntakeDrawerJob? get qrCodeJob => _qrCodeJob;

  bool _isSubmittingQrCodes = false;
  bool get isSubmittingQrCodes => _isSubmittingQrCodes;

  Map<int, String> _qrCodeErrors = const {};
  Map<int, String> get qrCodeErrors => _qrCodeErrors;

  List<IntakeQrCodeRequirement> get qrCodeRequirements =>
      _qrCodeJob != null ? intakeQrCodeRequirementsOf(_qrCodeJob!) : const [];

  IntakeTarget? _lastCompletedTarget;
  IntakeTarget? get lastCompletedTarget => _lastCompletedTarget;

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  Future<void> start(List<IntakeDrawerJob> jobs, {required IntakeType intakeType, required int? hospitalizationId}) {
    _intakeType = intakeType;
    _hospitalizationId = hospitalizationId;
    return startQueue(jobs);
  }

  /// Aktif target'ın belirli bir detayının sayımını günceller.
  void updateCurrentTargetCount(int detailIndex, double? value) {
    final target = currentTarget;
    if (target == null) return;

    final job = currentJob;
    if (job == null) return;

    final updatedTarget = target.withCountAt(detailIndex, value);
    final newTargets = List<IntakeTarget>.from(job.targets);
    newTargets[currentTargetIndex] = updatedTarget;

    replaceCurrentJobTargets(newTargets);
  }

  Future<void> confirmCurrent() async {
    final target = currentTarget;
    await confirmSingleTarget(
      saveTarget: (t) async {
        final ok = await _completeTarget(t);
        if (ok) _lastCompletedTarget = target;
        return ok;
      },
    );
  }

  Future<bool> _completeTarget(IntakeTarget target) async {
    final item = target.item;

    final result = item.isRedirectedIntake
        ? await _completeRedirectedIntake.call(
            referralId: item.redirectedOrder!.id,
            censusQuantity: target.details.firstOrNull?.censusQuantity,
          )
        : item.isEquivalentIntake
        ? await _completeEquivalentIntake.call(
            EquivalentIntakeParams(
              prescriptionDetailId: item.id,
              materialId: item.selectedEquivalent!.materialId ?? 0,
              censusQuantity: target.details.firstOrNull?.censusQuantity ?? target.details.firstOrNull?.dosePiece,
            ),
          )
        : await _completeIntake.call(
            IntakeParams(
              type: _intakeType,
              prescriptionDetailId: item.id,
              hospitalizationId: _hospitalizationId,
              userId: item.witnessContext.witness?.id,
              details: target.details,
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

  /// Job tamamlanmaya hazır olduğu an (kübikte her zaman, birim dozda
  /// SADECE son target kapandığında) QR zorunluluğunu kontrol eder. Zorunlu
  /// hedef varsa kuyruğu askıya alır — View qrCodeJob'ı görüp dialog açar.
  @override
  Future<bool> onBeforeAdvanceAfterClose(IntakeTarget? target) async {
    final job = currentJob;
    if (job == null) return true;

    final isJobCompleting = job.staysOpenAcrossTargets || (currentTargetIndex + 1 >= job.targets.length);
    debugPrint(
      'onBeforeAdvanceAfterClose: isJobCompleting=$isJobCompleting, currentIndex=$currentTargetIndex, totalJobs=${jobs.length}',
    );
    if (!isJobCompleting) return true;

    final requirements = intakeQrCodeRequirementsOf(job);
    debugPrint('QR requirements: ${requirements.length}');
    if (requirements.isEmpty) return true;

    _qrCodeJob = job;
    notifyListeners();
    return false;
  }

  /// "İşlemi Tamamla" — yalnızca dolu girilen hedefler için istek atar; boş
  /// bırakılanlar backend'de otomatik "okutulmadı" sayılır. Hata alan hedef
  /// olsa dahi kuyruk İLERLER — hata yalnızca dialog'da gösterilir.
  Future<void> submitQrCodesAndContinue(Map<int, List<String>> codesByPrescriptionDetailId) async {
    final job = _qrCodeJob;
    if (job == null) return;

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

  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => locationItemsUsing(
    allGroups: allGroups,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    stockIdAt: (job, i) => job.targets[i].details.firstOrNull?.stockId,
    stockIdsAt: (job, i) => job.targets[i].details.map((d) => d.stockId).toList(),
  );
}
