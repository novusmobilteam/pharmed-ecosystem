part of 'mobile_intake_dialog.dart';

class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
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
  String _hint(MobileIntakeState state, MobileDrawerStage stage, MobileIntakeReady ready) {
    if (state is MobileIntakeFatalError) {
      return 'Kritik bir hata oluştu: ${state.message}';
    }

    if (state is MobileIntakeSaving) return 'Kaydediliyor...';

    if (state is MobileIntakeError) {
      return 'Hata oluştu — tekrar deneyebilirsiniz';
    }

    if (state is MobileIntakeRollbackInProgress) {
      if (stage is MobileDrawerOpening) return 'Çekmece açılıyor, lütfen bekleyin...';
      if (stage is MobileDrawerOpened) {
        return 'Çıkardığınız ilaçları kabine geri koyun, ardından çekmeceyi kapatın.';
      }
      if (stage is MobileDrawerClosed) {
        return ready.isRollbackComplete
            ? 'İlaçları geri koydunuz. İşlem sonlandırılıyor...'
            : 'Bazı ilaçlar hâlâ eksik. Çekmeceyi açıp kalan ilaçları geri koyun.';
      }
      return 'İşlem geri alınıyor...';
    }

    if (stage is MobileDrawerOpening) return 'Çekmece açılıyor...';

    // Drawer Opened — alımda asıl işlem burada yapılır
    if (stage is MobileDrawerOpened) {
      if (!ready.baselineCompleted) return 'Kabin taranıyor, lütfen bekleyin';
      return 'Almak istediğiniz ilaçları çekmeceden çıkartın, ardından çekmeceyi kapatın';
    }

    // Drawer Closed — alımda complete sonrası veya henüz açılmadan
    if (stage is MobileDrawerClosed) {
      if (ready.canComplete) return 'İşlemi bitirmek için tamamla butonuna basın';
      return 'Henüz ilaç alınmadı. Çekmeceyi açıp ilaçları çıkartın.';
    }

    return 'İlaçları çekmeceden çıkartın, ardından çekmeceyi kapatın';
  }

  /// Buton grubu — state + drawerStage'e göre tek noktada belirlenir.
  List<Widget> _actions(
    MobileIntakeState state,
    MobileDrawerStage stage,
    MobileIntakeReady ready,
    MobileIntakeNotifier notifier,
  ) {
    // ── FatalError: kurtarılamaz, sadece dismiss ───────────────────────
    if (state is MobileIntakeFatalError) {
      return [
        MedButton(
          label: 'Tamam',
          size: MedButtonSize.sm,
          variant: MedButtonVariant.danger,
          onPressed: notifier.dismissError,
        ),
      ];
    }

    // ── Error: Tekrar Dene ─────────────────────────────────────────────
    if (state is MobileIntakeError) {
      return [MedButton(label: 'Tekrar Dene', size: MedButtonSize.sm, onPressed: notifier.retryComplete)];
    }

    if (stage is MobileDrawerClosed) {
      if (ready.canComplete) {
        return [MedButton(label: 'İşlemi tamamla', size: MedButtonSize.sm, onPressed: notifier.completeIntake)];
      }
      // Çekmece kapandı ama henüz alınmadı → tekrar aç
      return [MedButton(label: 'Almaya Devam Et', size: MedButtonSize.sm, onPressed: notifier.reopenDrawer)];
    }

    return [MedButton(label: 'İşlemi tamamla', size: MedButtonSize.sm, onPressed: null)];
  }
}
