part of 'dashboard_screen.dart';

class CabinTelemetryPanel extends ConsumerWidget {
  const CabinTelemetryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cabinSensorProvider);
    final thresholds = state.thresholds;
    final reading = state.reading;

    final tempStatus = thresholds.temperatureStatus(reading?.temperature);
    final humidityStatus = thresholds.humidityStatus(reading?.humidity);
    final isBatteryCritical = reading?.isBatteryCritical ?? false;

    final hasAlert =
        tempStatus == SensorStatus.outOfRange || humidityStatus == SensorStatus.outOfRange || isBatteryCritical;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: hasAlert ? MedColors.red : MedColors.border, width: hasAlert ? 1.5 : 1),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TelemetryHeader(isPaused: state.isPaused, hasAlert: hasAlert),
          Padding(
            padding: const EdgeInsets.all(MedSpacing.xl),
            child: Column(
              children: [
                _SensorMetric(
                  icon: PhosphorIcons.thermometerSimple(),
                  value: reading?.temperature,
                  fractionDigits: 1,
                  unit: '°C',
                  label: context.l10n.dashboard_sensor_temperature,
                  status: tempStatus,
                  normalColor: MedColors.amber,
                  history: state.tempHistory,
                  rangeText:
                      '${thresholds.tempMin?.toStringAsFixed(0)}–'
                      '${thresholds.tempMax?.toStringAsFixed(0)} °C',
                ),
                const SizedBox(height: MedSpacing.xl),
                const Divider(height: 1, color: MedColors.border),
                const SizedBox(height: MedSpacing.xl),

                _SensorMetric(
                  icon: PhosphorIcons.drop(),
                  value: reading?.humidity,
                  fractionDigits: 0,
                  unit: '%',
                  label: context.l10n.dashboard_sensor_humidity,
                  status: humidityStatus,
                  normalColor: MedColors.blue,
                  history: state.humidityHistory,
                  rangeText:
                      '%${thresholds.humidityMin?.toStringAsFixed(0)}–'
                      '${thresholds.humidityMax?.toStringAsFixed(0)}',
                ),
                const SizedBox(height: MedSpacing.xl),
                const Divider(height: 1, color: MedColors.border),
                const SizedBox(height: MedSpacing.xl),

                _BatteryRow(
                  percent: reading?.batteryPercent,
                  volts: reading?.batteryVolts,
                  isCritical: isBatteryCritical,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryHeader extends StatelessWidget {
  const _TelemetryHeader({required this.isPaused, required this.hasAlert});

  final bool isPaused;
  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
      ),
      child: Row(
        children: [
          StatusDot(color: isPaused ? MedColors.text4 : MedColors.green, size: 7),
          const SizedBox(width: MedSpacing.sm),
          Text(context.l10n.dashboard_climate_title, style: MedTextStyles.titleSm()),
          const Spacer(),
          if (isPaused)
            Text('context.l10n.dashboard_sensor_paused', style: MedTextStyles.bodySm(color: MedColors.text4))
          else if (hasAlert)
            Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill), size: 16, color: MedColors.red),
        ],
      ),
    );
  }
}

class _SensorMetric extends StatelessWidget {
  const _SensorMetric({
    required this.icon,
    required this.value,
    required this.fractionDigits,
    required this.unit,
    required this.label,
    required this.status,
    required this.normalColor,
    required this.history,
    required this.rangeText,
  });

  final IconData icon;
  final double? value;
  final int fractionDigits;
  final String unit;
  final String label;
  final SensorStatus status;
  final Color normalColor;
  final List<double> history;
  final String rangeText;

  @override
  Widget build(BuildContext context) {
    final isAlert = status == SensorStatus.outOfRange;
    final color = isAlert ? MedColors.red : normalColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: MedColors.text3),
            const SizedBox(width: MedSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value?.toStringAsFixed(fractionDigits) ?? '—', style: MedTextStyles.numericLg(color: color)),
                const SizedBox(width: 2),
                Text(unit, style: MedTextStyles.bodySm(color: MedColors.text3)),
              ],
            ),

            const Spacer(),
            Text(
              isAlert ? context.l10n.dashboard_sensor_outOfRange : rangeText,
              style: MedTextStyles.monoXs(color: isAlert ? MedColors.red : MedColors.text4),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.sm),

        SizedBox(
          height: 28,
          width: double.infinity,
          child: CustomPaint(
            painter: SparklinePainter(points: history, color: color),
          ),
        ),
        const SizedBox(height: MedSpacing.xs),

        Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
      ],
    );
  }
}

class _BatteryRow extends StatelessWidget {
  const _BatteryRow({required this.percent, required this.volts, required this.isCritical});

  final double? percent;
  final double? volts;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final color = isCritical ? MedColors.red : MedColors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_batteryIcon(percent), size: 18, color: MedColors.text3),
            const SizedBox(width: MedSpacing.md),
            Text(context.l10n.dashboard_sensor_battery, style: MedTextStyles.bodySm(color: MedColors.text3)),
            const Spacer(),

            if (volts != null) ...[
              Text('${volts!.toStringAsFixed(1)} V', style: MedTextStyles.monoSm(color: MedColors.text4)),
              const SizedBox(width: MedSpacing.md),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(percent?.toStringAsFixed(0) ?? '—', style: MedTextStyles.numericLg(color: color)),
                const SizedBox(width: 2),
                Text('%', style: MedTextStyles.bodySm(color: color)),
              ],
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.md),

        ClipRRect(
          borderRadius: MedRadius.smAll,
          child: LinearProgressIndicator(
            value: percent != null ? percent!.clamp(0, 100) / 100 : 0,
            minHeight: 6,
            backgroundColor: MedColors.surface3,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
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
