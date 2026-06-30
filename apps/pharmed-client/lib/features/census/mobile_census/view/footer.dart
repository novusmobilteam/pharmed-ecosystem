part of 'mobile_census_dialog.dart';

class _CensusDialogFooter extends ConsumerWidget {
  const _CensusDialogFooter({required this.state, required this.drawerStage, required this.ready});

  final MobileCensusState state;
  final MobileDrawerStage drawerStage;
  final MobileCensusReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(mobileCensusNotifierProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: Text(_hint(context), style: MedTextStyles.bodySm(color: MedColors.text3)),
        ),
        const SizedBox(width: MedSpacing.sm),
        ..._actions(context, notifier),
      ],
    );
  }

  String _hint(BuildContext context) {
    if (state is MobileCensusSaving) return 'Kaydediliyor...';
    if (state is MobileCensusError) return 'Hata oluştu — tekrar deneyebilirsiniz';
    if (drawerStage is MobileDrawerOpening) return 'Çekmece açılıyor...';
    if (drawerStage is MobileDrawerOpened) {
      if (!ready.baselineCompleted) return 'Kabin taranıyor, lütfen bekleyin';
      return 'Sayımı bitirmek için çekmeceyi kapatın';
    }
    if (drawerStage is MobileDrawerClosed) {
      return ready.canComplete ? 'Sayımı tamamlamak için butona basın' : 'Tarama tamamlanmadı, lütfen bekleyin';
    }
    return '';
  }

  List<Widget> _actions(BuildContext context, MobileCensusNotifier notifier) {
    if (state is MobileCensusSaving) {
      return [MedButton(label: 'Kaydediliyor...', size: MedButtonSize.sm, isLoading: true, onPressed: null)];
    }
    if (state is MobileCensusError) {
      return [MedButton(label: 'Tekrar Dene', size: MedButtonSize.sm, onPressed: notifier.retryComplete)];
    }
    if (drawerStage is MobileDrawerClosed && ready.canComplete) {
      return [MedButton(label: 'Sayımı Tamamla', size: MedButtonSize.sm, onPressed: notifier.completeCensus)];
    }
    return [MedButton(label: 'Sayımı Tamamla', size: MedButtonSize.sm, onPressed: null)];
  }
}
