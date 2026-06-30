part of 'mobile_refill_dialog.dart';

class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: MedColors.bg,
        border: Border(top: BorderSide(color: MedColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(_hint(state, drawerStage, ready), style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          ..._actions(state, drawerStage, ready, notifier),
        ],
      ),
    );
  }

  /// Hint metni — state + drawerStage'e göre tek noktada belirlenir.
  String _hint(MobileRefillState state, MobileDrawerStage stage, MobileRefillReady ready) {
    if (state is MobileRefillFatalError) {
      return 'Kritik bir hata oluştu: ${state.message}';
    }

    if (state is MobileRefillSaving) return 'Kaydediliyor...';

    if (state is MobileRefillError) {
      return 'Hata oluştu — tekrar deneyebilir veya çekmeceyi açıp ilaçları çıkartabilirsiniz';
    }

    if (state is MobileRefillRollbackInProgress) {
      if (stage is MobileDrawerOpening) return 'Çekmece açılıyor, lütfen bekleyin...';
      if (stage is MobileDrawerOpened) {
        return 'Yerleştirdiğiniz ilaçları kabinden çıkartın, ardından çekmeceyi kapatın.';
      }
      if (stage is MobileDrawerClosed) {
        return ready.rfidReadEpcs.isEmpty
            ? 'İlaçları çıkardınız. İşlem sonlandırılıyor...'
            : 'İlaçlar hâlâ kabinde. Tekrar denemek için "Tekrar Dene" veya çekmeceyi açmak için ilgili butonu kullanın.';
      }
      return 'İşlem geri alınıyor...';
    }

    if (stage is MobileDrawerOpening) return 'Çekmece açılıyor...';

    if (stage is MobileDrawerClosed) {
      if (ready.canComplete) return 'İşlemi bitirmek için tamamla butonuna basın';
      if (ready.isBlockedByUnexpected) {
        return 'Kabine ait olmayan etiket(ler) var, çekmeceyi tekrar açıp çıkartın';
      }
      if (ready.hasExtraPlacement) {
        return 'Seçili ilaçlar dışında etiket kondu, çekmeceyi tekrar açıp çıkartın';
      }
      return 'Eksik etiketler var, çekmeceyi tekrar açıp yerleştirmeye devam edin';
    }

    // Drawer Opened
    if (!ready.baselineCompleted) return 'Kabin taranıyor, lütfen bekleyin';
    return 'İlaçları yerleştirin, ardından çekmeceyi kapatın';
  }

  /// Buton grubu — state + drawerStage'e göre tek noktada belirlenir.
  List<Widget> _actions(
    MobileRefillState state,
    MobileDrawerStage stage,
    MobileRefillReady ready,
    MobileRefillNotifier notifier,
  ) {
    // ── FatalError: kurtarılamaz, sadece dismiss ───────────────────────
    if (state is MobileRefillFatalError) {
      return [
        MedButton(
          label: 'Tamam',
          size: MedButtonSize.sm,
          variant: MedButtonVariant.danger,
          onPressed: notifier.dismissError,
        ),
      ];
    }

    // ── Error: Tekrar Dene + Aç ve Düzelt ──────────────────────────────
    if (state is MobileRefillError) {
      return [MedButton(label: 'Tekrar Dene', size: MedButtonSize.sm, onPressed: notifier.retryComplete)];
    }

    if (state is MobileRefillRollbackInProgress) {
      return const [];
    }
    // ── Saving: loading butonu ─────────────────────────────────────────
    if (state is MobileRefillSaving) {
      return [MedButton(label: 'Kaydediliyor...', size: MedButtonSize.sm, isLoading: true, onPressed: null)];
    }

    // ── Ready ailesi ───────────────────────────────────────────────────
    if (stage is MobileDrawerClosed) {
      if (ready.canComplete) {
        return [MedButton(label: 'İşlemi tamamla', size: MedButtonSize.sm, onPressed: notifier.completeRefill)];
      }
      return [MedButton(label: 'Doluma Devam Et', size: MedButtonSize.sm, onPressed: notifier.reopenDrawer)];
    }

    // Drawer Opening/Opened — primary buton disabled
    return [MedButton(label: 'İşlemi tamamla', size: MedButtonSize.sm, onPressed: null)];
  }
}
