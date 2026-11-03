// [SWREQ-MGR-RX-004] [IEC 62304 §5.5]
// Hastaya ait reçeteleri SidePanel içinde GÜN bazında listeler (reçete
// onaylama). Üstte hasta bilgisi, tarih aralığı (hızlı seçimler + özel) ve
// sayılı durum filtreleri; altında her gün için bir kart. Reçete numarası
// kalem satırında görünür; onay/iptal/red seçili kalemlerin reçetelerine
// bölünerek yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../auth/notifier/auth_notifier.dart';
import '../../prescription.dart';

class PrescriptionDetailPanel extends StatefulWidget {
  const PrescriptionDetailPanel({super.key});

  @override
  State<PrescriptionDetailPanel> createState() => _PrescriptionDetailPanelState();
}

class _PrescriptionDetailPanelState extends State<PrescriptionDetailPanel> {
  @override
  void initState() {
    super.initState();
    // Panel açılınca seçili hospitalization'ı detay notifier'a yükle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hosp = context.read<PrescriptionNotifier>().selectedHospitalization;
      final range = context.read<PrescriptionNotifier>().dateRange;
      if (hosp != null) {
        context.read<PrescriptionDetailNotifier>().load(hosp, range: range);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listNotifier = context.watch<PrescriptionNotifier>();
    final detailNotifier = context.watch<PrescriptionDetailNotifier>();
    final hosp = listNotifier.selectedHospitalization;
    final patientName = hosp?.patient?.fullName ?? context.l10n.prescription_detailPanelPatientFallback;

    return SidePanel(
      title: patientName,
      disableScroll: true,
      subtitle: context.l10n.prescription_detailPanelSubtitle,
      onClose: listNotifier.closePanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hosp != null) _PatientInfoStrip(hosp: hosp),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                _DateRangeBar(notifier: detailNotifier),
                _StatusFilterBar(notifier: detailNotifier),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(child: _buildContent(context, detailNotifier)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrescriptionDetailNotifier notifier) {
    if (notifier.isLoading(notifier.fetchOp) && notifier.items.isEmpty) {
      return const Center(child: MedLoadingIndicator());
    }

    final days = notifier.dayGroups;
    if (days.isEmpty) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults));
    }

    final currentUser = context.watch<AuthNotifier>().currentUser;
    final permissions = PrescriptionActionPermissions.fromRole(currentUser?.roleType);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final group = days[index];
        return RxGroupCard.day(
          // Gün değişirse (filtre/aralık) seçim sıfırlansın.
          key: ValueKey('day-${group.day}-${notifier.type}'),
          day: group.day,
          items: group.items,
          permissions: permissions,
          canOverrideRfidLock: currentUser?.roleType?.canOverrideRfidLock ?? false,
          onRfidTap: (item) async {
            await notifier.assignRfidTag(
              item,
              onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
            );
          },
          onRfidDelete: (item) async {
            await notifier.deleteRfidTag(item);
          },
          onApprove: (items) => _approve(context, notifier, items),
          onCancel: (items) => _submit(context, notifier, items, PrescriptionActionType.cancel),
          onReject: (items) => _submit(context, notifier, items, PrescriptionActionType.reject),
          onRejectAfterApprove: (items) =>
              _submit(context, notifier, items, PrescriptionActionType.rejectAfterApprove),
        );
      },
    );
  }

  /// Onay reçete bazında: seçili kalemler reçetelerine bölünür, her reçete
  /// için check + approve çalışır (uyarı çıkarsa kullanıcıya sorulur).
  Future<void> _approve(BuildContext context, PrescriptionDetailNotifier notifier, List<PrescriptionItem> items) async {
    for (final entry in notifier.byPrescription(items).entries) {
      await notifier.checkAndApprove(
        entry.key,
        entry.value,
        onCheckWarning: (message, onContinue) {
          MessageUtils.showConfirmDialog(
            context: context,
            action: ConfirmAction.custom,
            customTitle: context.l10n.prescription_checkWarningDialogTitle,
            customMessage: message,
            confirmButtonText: context.l10n.session_timeout_continueButton,
            cancelButtonText: context.l10n.common_dismissButton,
            iconData: PhosphorIcons.warning(PhosphorIconsStyle.fill),
            color: MedColors.amber,
            onConfirm: onContinue,
          );
        },
        onSuccess: (message) {
          MessageUtils.showSuccessSnackbar(context, message ?? context.l10n.prescription_approvedSuccess);
        },
        onFailed: (message) {
          MessageUtils.showErrorSnackbar(context, message);
        },
      );
    }
  }

  Future<void> _submit(
    BuildContext context,
    PrescriptionDetailNotifier notifier,
    List<PrescriptionItem> items,
    PrescriptionActionType type,
  ) async {
    final groups = notifier.byPrescription(items);
    if (groups.isEmpty) return;

    showLoading(context);
    String? error;
    for (final entry in groups.entries) {
      await notifier.submit(type, entry.key, entry.value, onFailed: (message) => error ??= message);
    }
    if (!context.mounted) return;
    hideLoading(context);

    if (error != null) {
      MessageUtils.showErrorSnackbar(context, error);
    } else {
      MessageUtils.showSuccessSnackbar(context, context.l10n.prescription_actionCompletedSuccess);
    }
  }
}

// ── Hasta bilgisi ───────────────────────────────────────────────────────────

class _PatientInfoStrip extends StatelessWidget {
  const _PatientInfoStrip({required this.hosp});

  final Hospitalization hosp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final room = hosp.bed?.room?.name ?? hosp.room?.name;
    final bed = hosp.bed?.name;
    final entries = <(IconData, String, String)>[
      if (hosp.patient?.protocolNo != null)
        (PhosphorIcons.identificationCard(), l10n.patient_fieldProtocolNo, hosp.patient!.protocolNo!),
      if (hosp.physicalService?.name != null)
        (PhosphorIcons.buildings(), l10n.tableCore_serviceColumn, hosp.physicalService!.name!),
      if (room != null || bed != null)
        (
          PhosphorIcons.bed(),
          '${l10n.unappliedPrescription_table_roomColumn} / ${l10n.unappliedPrescription_table_bedColumn}',
          [room ?? '—', bed ?? '—'].join(' / '),
        ),
      if (hosp.admissionDate != null)
        (PhosphorIcons.calendarCheck(), l10n.hospitalization_fieldAdmissionDate, hosp.admissionDate!.formattedDate),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        children: [
          for (final (icon, label, value) in entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(icon, size: 16, color: MedColors.text3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: MedTextStyles.monoXs(color: MedColors.text3)),
                    Text(value, style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tarih aralığı ──────────────────────────────────────────────────────────

class _DateRangeBar extends StatelessWidget {
  const _DateRangeBar({required this.notifier});

  final PrescriptionDetailNotifier notifier;

  /// Seçili hızlı aralık (gün sayısı); özel aralıkta null, tümünde 0.
  int? get _activePreset {
    final s = notifier.startDate, e = notifier.endDate;
    if (s == null && e == null) return 0;
    if (s == null || e == null) return null;
    final today = DateTime.now();
    if (e.year != today.year || e.month != today.month || e.day != today.day) return null;
    final sDay = DateTime(s.year, s.month, s.day);
    final tDay = DateTime(today.year, today.month, today.day);
    final days = tDay.difference(sDay).inDays + 1;
    return const [1, 7, 30].contains(days) ? days : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = _activePreset;
    final presets = <(int, String)>[
      (1, l10n.dateFilter_todayPreset),
      (7, l10n.dateFilter_last7DaysPreset),
      (30, l10n.dateFilter_last30Days),
      (0, l10n.dateFilter_allPreset),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (days, label) in presets)
              MedChip(
                label: label,
                size: MedChipSize.sm,
                mono: false,
                style: active == days ? MedChipStyle.info : MedChipStyle.neutral,
                onTap: () => notifier.selectQuickRange(days == 0 ? null : days),
              ),
          ],
        ),
        Row(
          spacing: 12.0,
          children: [
            Expanded(
              child: MedDateInputField(
                key: ValueKey(notifier.startDate),
                label: l10n.prescription_detailStartDateLabel,
                initialValue: notifier.startDate,
                onDateSelected: notifier.selectStartDate,
              ),
            ),
            Expanded(
              child: MedDateInputField(
                key: ValueKey(notifier.endDate),
                label: l10n.prescription_detailEndDateLabel,
                initialValue: notifier.endDate,
                onDateSelected: notifier.selectEndDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Durum filtresi ─────────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.notifier});

  final PrescriptionDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final counts = notifier.statusCounts;
    final selected = notifier.type;
    // Sayısı olan durumlar + seçili durum (sayısı 0 olsa da seçili görünsün).
    final statuses = [
      for (final s in PrescriptionMovementType.values)
        if ((counts[s] ?? 0) > 0 || s == selected) s,
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        MedChip(
          label: context.l10n.filter_all,
          count: notifier.items.length,
          size: MedChipSize.sm,
          mono: false,
          style: selected == null ? MedChipStyle.info : MedChipStyle.neutral,
          onTap: () => notifier.selectPrescriptionType(null),
        ),
        for (final s in statuses)
          MedChip(
            label: s.label(context),
            count: counts[s] ?? 0,
            size: MedChipSize.sm,
            mono: false,
            background: selected == s ? s.backgroundColor : MedColors.surface,
            foreground: selected == s ? s.foregroundColor : MedColors.text2,
            border: selected == s ? s.foregroundColor : MedColors.border,
            onTap: () => notifier.selectPrescriptionType(selected == s ? null : s),
          ),
      ],
    );
  }
}
