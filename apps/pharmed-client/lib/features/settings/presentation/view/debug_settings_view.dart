// lib/features/settings/presentation/widgets/debug_settings_view.dart

part of 'settings_modal.dart';

class DebugSettingsView extends ConsumerWidget {
  const DebugSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEBUG AYARLARI',
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: MedColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // ── Kabin modu ──────────────────────────────────────
          _SettingRow(
            label: 'Kabin modu',
            description: 'Dashboard görünümünü simüle eder — sadece runtime\'da etkili',
            trailing: _SegmentedControl<DebugCabinMode>(
              value: state.debugCabinMode,
              options: const [(DebugCabinMode.master, 'Master'), (DebugCabinMode.mobile, 'Mobil')],
              onChanged: notifier.setDebugCabinMode,
            ),
          ),

          // ── Mock placeholder'lar ────────────────────────────
          _SettingRow(
            label: 'Mock veri modu',
            description: 'API istekleri yerine mock data kullanır',
            disabled: true,
            trailing: _ToggleSwitch(value: false, onChanged: null),
          ),

          _SettingRow(
            label: 'Log seviyesi',
            description: 'Konsol çıktı detayı',
            disabled: true,
            trailing: _SegmentedControl<String>(
              value: 'Info',
              options: const [('Info', 'Info'), ('Debug', 'Debug'), ('Verbose', 'Verbose')],
              onChanged: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.description, required this.trailing, this.disabled = false});

  final String label;
  final String description;
  final Widget trailing;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: MedColors.border2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MedColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({required this.value, required this.options, required this.onChanged});

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isActive = opt.$1 == value;
          return GestureDetector(
            onTap: onChanged != null ? () => onChanged!(opt.$1) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? MedColors.surface : Colors.transparent,
                border: Border.all(color: isActive ? MedColors.border : Colors.transparent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt.$2,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive ? MedColors.blue : MedColors.text2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? MedColors.blue : MedColors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
