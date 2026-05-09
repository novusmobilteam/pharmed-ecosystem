part of '../view/mobile_refill_panel.dart';

class _RefillActionBar extends StatelessWidget {
  const _RefillActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.allSelectedRfidRead,
    required this.rfidReadCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;
  final bool allSelectedRfidRead;
  final int rfidReadCount;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  bool get _showCancel {
    if (isSaving) return false;
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      return rfidReadCount == 0;
    }
    if (drawerStage is MobileDrawerClosed) return rfidReadCount == 0;
    if (drawerStage is MobileDrawerIdle) return hasSelection;
    if (drawerStage is MobileDrawerFailed) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_showCancel) _CancelButton(onTap: onCancel) else const Spacer(),
        Spacer(),
        _buildAction(),
      ],
    );
  }

  Widget _buildAction() {
    if (isSaving) {
      return _ActionButton(label: 'Kaydediliyor', enabled: false, loading: true, onTap: () {});
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => _ActionButton(label: 'Çekmece açılıyor', enabled: false, loading: true, onTap: () {}),
      MobileDrawerOpened() => _ActionButton(label: 'İlaçları yerleştirin', enabled: false, onTap: () {}),
      MobileDrawerClosed() =>
        allSelectedRfidRead
            ? _ActionButton(label: 'Dolumu tamamla', onTap: onComplete)
            : _ActionButton(label: 'Doluma devam et', onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: 'Tekrar dene', onTap: onStart),
      MobileDrawerIdle() => _ActionButton(label: 'Doluma başla', enabled: hasSelection, onTap: onStart),
    };
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true, this.loading = false});

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: label,
      size: MedButtonSize.sm,
      isLoading: loading,
      onPressed: enabled && !loading ? onTap : null,
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedButton(label: 'İptal', size: MedButtonSize.sm, variant: MedButtonVariant.danger, onPressed: onTap);
  }
}
