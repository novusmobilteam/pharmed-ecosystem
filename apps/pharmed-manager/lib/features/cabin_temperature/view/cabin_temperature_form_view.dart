part of 'cabin_temperature_screen.dart';

class CabinTemperatureFormView extends StatelessWidget {
  const CabinTemperatureFormView({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    // Seçili kabin değişince tüm form alt ağacı yeniden kurulur,
    // böylece initialValue'lar yeni CabinTemperature'dan okunur.
    final cabinId = context.select<CabinTemperatureNotifier, int?>((n) => n.selectedCabin?.id);

    return Container(
      padding: MedSpacing.insetXl,
      child: Form(
        key: formKey,
        child: Column(
          key: ValueKey('cabin_temp_form_$cabinId'),
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            _CabinField(),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(child: _InsideBottomTempField()),
                Expanded(child: _InsideTopTempField()),
              ],
            ),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(child: _OutsideBottomTempField()),
                Expanded(child: _OutsideTopTempField()),
              ],
            ),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(child: _BottomHumidityField()),
                Expanded(child: _TopHumidityField()),
              ],
            ),
            _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class _CabinField extends StatelessWidget {
  const _CabinField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedDropdownInputField<Cabin>(
          key: key,
          label: context.l10n.tableCore_inconsistencyCabinColumn,
          initialValue: notifier.temperature.cabin,
          labelBuilder: (value) => value?.name,
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          options: notifier.cabins,
          onChanged: (Cabin? value) => notifier.selectCabin(value),
        );
      },
    );
  }
}

class _InsideBottomTempField extends StatelessWidget {
  const _InsideBottomTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureInsideBottomLabel,
          initialValue: notifier.temperature.bottomTemperatureInside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateInsideBottomTemp(value),
        );
      },
    );
  }
}

class _InsideTopTempField extends StatelessWidget {
  const _InsideTopTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureInsideTopLabel,
          initialValue: notifier.temperature.topTemperatureInside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateInsideTopTemp(value),
        );
      },
    );
  }
}

class _OutsideBottomTempField extends StatelessWidget {
  const _OutsideBottomTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureOutsideBottomLabel,
          initialValue: notifier.temperature.bottomTemperatureOutside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateOutsideBottomTemp(value),
        );
      },
    );
  }
}

class _OutsideTopTempField extends StatelessWidget {
  const _OutsideTopTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureOutsideTopLabel,
          initialValue: notifier.temperature.topTemperatureOutside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateOutsideTopTemp(value),
        );
      },
    );
  }
}

class _BottomHumidityField extends StatelessWidget {
  const _BottomHumidityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureHumidityBottomLabel,
          initialValue: notifier.temperature.bottomLimitHumidity.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateBottomHumidity(value),
        );
      },
    );
  }
}

class _TopHumidityField extends StatelessWidget {
  const _TopHumidityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.cabinTemperatureHumidityTopLabel,
          initialValue: notifier.temperature.topLimitHumidity.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureNotifier>().updateTopHumidity(value),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureNotifier>(
      builder: (context, notifier, _) {
        return MedButton(
          label: context.l10n.common_saveButton,
          size: MedButtonSize.sm,
          onPressed: () => notifier.submit(
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: () => MessageUtils.showSuccessSnackbar(context, context.l10n.common_defaultSuccessMessage),
          ),
          isLoading: notifier.isLoading(notifier.submitOp),
        );
      },
    );
  }
}
