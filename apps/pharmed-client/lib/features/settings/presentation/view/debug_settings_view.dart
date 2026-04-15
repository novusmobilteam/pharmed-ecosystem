// lib/features/settings/presentation/view/debug_settings_view.dart
//
// [DEBUG ONLY] Geliştirici ayarları ekranı.
// Kabin listesi SettingsNotifier üzerinden yönetilir.
//
// Sınıf: Class A

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/settings_notifier.dart';

class DebugSettingsView extends ConsumerStatefulWidget {
  const DebugSettingsView({super.key});

  @override
  ConsumerState<DebugSettingsView> createState() => _DebugSettingsViewState();
}

class _DebugSettingsViewState extends ConsumerState<DebugSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(settingsNotifierProvider).cabins.isEmpty) {
        ref.read(settingsNotifierProvider.notifier).loadCabins();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(kDebugMode, 'DebugSettingsView sadece debug modda kullanılabilir');

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

          // ── Kabin seçimi ────────────────────────────────────
          _SettingRow(
            label: 'Aktif Kabin',
            description: 'Seçilen kabin dashboard\'da gösterilir — cache değişmez',
            trailing: _CabinSelector(
              cabins: state.cabins,
              isLoading: state.isLoadingCabins,
              error: state.cabinsError,
              selected: state.debugCabin,
              onSelected: (cabin) => notifier.setDebugCabin(cabin),
              onRetry: () => notifier.loadCabins(),
            ),
          ),

          // ── Placeholder'lar ─────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────
// _CabinSelector — state'ten okur, kendi içinde fetch yapmaz
// ─────────────────────────────────────────────────────────────────

class _CabinSelector extends StatelessWidget {
  const _CabinSelector({
    required this.cabins,
    required this.isLoading,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
    this.error,
  });

  final List<Cabin> cabins;
  final bool isLoading;
  final String? error;
  final Cabin? selected;
  final ValueChanged<Cabin?> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MedColors.blue));
    }

    if (error != null) {
      return GestureDetector(
        onTap: onRetry,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 14, color: MedColors.red),
            const SizedBox(width: 4),
            Text(
              'Yenile',
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.red),
            ),
          ],
        ),
      );
    }

    if (cabins.isEmpty) {
      return Text(
        'Kabin bulunamadı',
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
      );
    }

    return _CabinDropdown(cabins: cabins, selected: selected, onSelected: onSelected);
  }
}

// ─────────────────────────────────────────────────────────────────
// _CabinDropdown
// ─────────────────────────────────────────────────────────────────

class _CabinDropdown extends StatelessWidget {
  const _CabinDropdown({required this.cabins, required this.selected, required this.onSelected});

  final List<Cabin> cabins;
  final Cabin? selected;
  final ValueChanged<Cabin?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.smAll,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Cabin?>(
          value: selected,
          isDense: true,
          hint: Text(
            'Kabin seç...',
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
          ),
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text),
          items: [
            DropdownMenuItem<Cabin?>(
              value: null,
              child: Text(
                'Cache\'deki kabin',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 12,
                  color: MedColors.text3,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            ...cabins.map((cabin) {
              final typeLabel = cabin.type == CabinType.mobile ? 'Mobil' : 'Master';
              return DropdownMenuItem<Cabin?>(
                value: cabin,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cabin.name ?? '—'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: cabin.type == CabinType.mobile ? MedColors.amberLight : MedColors.blueLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontFamily: MedFonts.mono,
                          fontSize: 9,
                          color: cabin.type == CabinType.mobile ? MedColors.amber : MedColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Yardımcı widget'lar
// ─────────────────────────────────────────────────────────────────

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
