import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';

/// Kabin sensör eşik değerleri — servisten (parametre olarak) gelir.
///
/// Isı/nem için normal aralık dışına çıkıldığında UI uyarı gösterir.
/// [SWREQ-HW-SENSOR-002]
class CabinSensorThresholds {
  const CabinSensorThresholds({
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
  });

  final double tempMin;
  final double tempMax;
  final double humidityMin;
  final double humidityMax;

  /// Servis parametreleri gelene kadar kullanılacak varsayılan.
  /// İlaç saklama için tipik oda koşulları.
  static const fallback = CabinSensorThresholds(
    tempMin: 15,
    tempMax: 25,
    humidityMin: 30,
    humidityMax: 65,
  );

  SensorStatus temperatureStatus(double? value) {
    if (value == null) return SensorStatus.unknown;
    if (value < tempMin || value > tempMax) return SensorStatus.outOfRange;
    return SensorStatus.normal;
  }

  SensorStatus humidityStatus(double? value) {
    if (value == null) return SensorStatus.unknown;
    if (value < humidityMin || value > humidityMax) return SensorStatus.outOfRange;
    return SensorStatus.normal;
  }
}

enum SensorStatus { normal, outOfRange, unknown }


class CabinClimateView extends ConsumerWidget {
  const CabinClimateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cabinSensorProvider);
    final reading = state.reading;
    final thresholds = ref.watch(cabinSensorThresholdsProvider);

    final tempStatus = thresholds.temperatureStatus(reading?.temperature);
    final humidityStatus = thresholds.humidityStatus(reading?.humidity);
    final hasAlert = tempStatus == SensorStatus.outOfRange ||
        humidityStatus == SensorStatus.outOfRange;

    return Container(
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(
          color: hasAlert ? MedColors.red : MedColors.border,
          width: hasAlert ? 1.5 : 1,
        ),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: state.isPaused ? MedColors.text4 : MedColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: MedSpacing.sm),
              Text(
                context.l10n.dashboard_climate_title,
                style: MedTextStyles.titleSm(color: MedColors.text),
              ),
              const Spacer(),
              if (hasAlert)
                Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill),
                    size: 16, color: MedColors.red),
            ],
          ),
          const SizedBox(height: MedSpacing.xl),

          // Büyük değerler — yan yana, eşit ağırlık
          Row(
            children: [
              Expanded(
                child: _BigMetric(
                  icon: PhosphorIcons.thermometerSimple(),
                  value: reading?.temperature != null
                      ? reading!.temperature!.toStringAsFixed(1)
                      : '—',
                  unit: '°C',
                  label: context.l10n.dashboard_sensor_temperature,
                  status: tempStatus,
                  normalColor: MedColors.amber,
                  normalBg: MedColors.amberLight,
                  rangeText: '${thresholds.tempMin.toStringAsFixed(0)}–'
                      '${thresholds.tempMax.toStringAsFixed(0)} °C',
                ),
              ),
              Container(width: 1, height: 96, color: MedColors.border),
              Expanded(
                child: _BigMetric(
                  icon: PhosphorIcons.drop(),
                  value: reading?.humidity != null
                      ? reading!.humidity!.toStringAsFixed(0)
                      : '—',
                  unit: '%',
                  label: context.l10n.dashboard_sensor_humidity,
                  status: humidityStatus,
                  normalColor: MedColors.blue,
                  normalBg: MedColors.blueLight,
                  rangeText: '%${thresholds.humidityMin.toStringAsFixed(0)}–'
                      '${thresholds.humidityMax.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.status,
    required this.normalColor,
    required this.normalBg,
    required this.rangeText,
  });

  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final SensorStatus status;
  final Color normalColor;
  final Color normalBg;
  final String rangeText;

  @override
  Widget build(BuildContext context) {
    final isAlert = status == SensorStatus.outOfRange;
    final color = isAlert ? MedColors.red : normalColor;
    final bg = isAlert ? MedColors.redLight : normalBg;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, borderRadius: MedRadius.midAll),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: MedSpacing.md),

        // Büyük sayı — kartın ağırlık merkezi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: MedTextStyles.numericXl(color: color)),
            const SizedBox(width: 2),
            Text(unit, style: MedTextStyles.bodyMd(color: color)),
          ],
        ),
        const SizedBox(height: MedSpacing.xs),

        Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.xs),

        Text(
          isAlert
              ? context.l10n.dashboard_sensor_outOfRange
              : rangeText,
          style: MedTextStyles.monoXs(
            color: isAlert ? MedColors.red : MedColors.text4,
          ),
        ),
      ],
    );
  }
}


class CabinBatteryView extends ConsumerWidget {
  const CabinBatteryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cabinSensorProvider);
    final reading = state.reading;

    final volts = reading?.batteryVolts;
    final percent = reading?.batteryPercent;
    final isCritical = reading?.isBatteryCritical ?? false;

    final color = isCritical ? MedColors.red : MedColors.green;
    final bg = isCritical ? MedColors.redLight : MedColors.greenLight;

    return Container(
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(
          color: isCritical ? MedColors.red : MedColors.border,
          width: isCritical ? 1.5 : 1,
        ),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: state.isPaused ? MedColors.text4 : MedColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: MedSpacing.sm),
              Text(
                context.l10n.dashboard_sensor_battery,
                style: MedTextStyles.titleSm(color: MedColors.text),
              ),
              const Spacer(),
              if (isCritical)
                Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill),
                    size: 16, color: MedColors.red),
            ],
          ),
          const SizedBox(height: MedSpacing.xl),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: bg, borderRadius: MedRadius.midAll),
                child: Icon(_batteryIcon(percent), size: 24, color: color),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          percent != null ? percent.toStringAsFixed(0) : '—',
                          style: MedTextStyles.numericXl(color: color),
                        ),
                        const SizedBox(width: 2),
                        Text('%', style: MedTextStyles.bodyMd(color: color)),
                        const Spacer(),
                        // Ham voltaj — tahminî yüzdenin yanında gerçek ölçüm
                        if (volts != null)
                          Text(
                            '${volts.toStringAsFixed(1)} V',
                            style: MedTextStyles.monoSm(color: MedColors.text3),
                          ),
                      ],
                    ),
                    const SizedBox(height: MedSpacing.sm),
                    _BatteryBar(percent: percent, color: color),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _batteryIcon(double? percent) {
    if (percent == null) return PhosphorIcons.batteryWarning();
    if (percent >= 75) return PhosphorIcons.batteryFull();
    if (percent >= 50) return PhosphorIcons.batteryHigh();
    if (percent >= 25) return PhosphorIcons.batteryMedium();
    return PhosphorIcons.batteryLow();
  }
}

class _BatteryBar extends StatelessWidget {
  const _BatteryBar({required this.percent, required this.color});

  final double? percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: MedRadius.smAll,
      child: LinearProgressIndicator(
        value: percent != null ? (percent!.clamp(0, 100)) / 100 : 0,
        minHeight: 6,
        backgroundColor: MedColors.surface3,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}


final cabinSensorThresholdsProvider = Provider<CabinSensorThresholds>((ref) {
  return CabinSensorThresholds.fallback;
});