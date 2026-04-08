part of 'cabin_temperature_screen.dart';

class CabinTemperatureFormView extends StatelessWidget {
  const CabinTemperatureFormView({super.key, this.initial});

  final CabinTemperatureDetail? initial;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CabinTemperatureControlFormViewModel(cabinTemperatureRepository: context.read(), initial: initial),
      child: CabinTemperatureFormDialogBody(),
    );
  }
}

class CabinTemperatureFormDialogBody extends StatefulWidget {
  const CabinTemperatureFormDialogBody({super.key});

  @override
  State<CabinTemperatureFormDialogBody> createState() => _CabinTemperatureFormDialogBodyState();
}

class _CabinTemperatureFormDialogBodyState extends State<CabinTemperatureFormDialogBody> {
  final formKey = GlobalKey<FormState>();
  late CabinTemperatureControlFormViewModel vm;
  APIRequestStatus? _deleteStatus;

  void _onStatusChanged() {
    if (vm.submitStatus == _deleteStatus) return;
    _deleteStatus = vm.submitStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (vm.submitStatus) {
        case APIRequestStatus.initial:
          break;
        case APIRequestStatus.loading:
          showLoading(context);
          break;
        case APIRequestStatus.success:
          hideLoading(context);
          MessageUtils.showSuccessSnackbar(context, vm.statusMessage.toString());
          break;
        case APIRequestStatus.failed:
          hideLoading(context);
          MessageUtils.showErrorDialog(context, vm.statusMessage);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    vm = context.read<CabinTemperatureControlFormViewModel>();
    _deleteStatus = vm.submitStatus;
    vm.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    vm.removeListener(_onStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationDialog(
      title: 'Kabin Düzenleme',
      onClose: () => context.pop(true),
      onSave: () {
        if (formKey.currentState!.validate()) {
          context.read<CabinTemperatureControlFormViewModel>().submit();
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(child: _StationField()),
                //Expanded(child: _CabinField()),
              ],
            ),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  child: Column(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [_InsideBottomTempField(), _InsideTopTempField()],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [_OutsideBottomTempField(), _OutsideTopTempField()],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [_BottomHumidityField(), _TopHumidityField()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StationField extends StatelessWidget {
  const _StationField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return SelectionField<Station>(
          key: key,
          label: 'İstasyon',
          title: 'İstasyon',
          initialValue: vm.form?.station,
          dataSource: (skip, take, search) => context.read<IStationRepository>().getStations(),
          labelBuilder: (value) => value.name ?? '',
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          onSelected: (value) => context.read<CabinTemperatureControlFormViewModel>().setStation(value),
        );
      },
    );
  }
}

// TODO : Muhakkak Düzelt
// class _CabinField extends StatelessWidget {
//   const _CabinField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CabinTemperatureControlFormViewModel>(
//       builder: (context, vm, _) {
//         return DialogInputField<Cabin>(
//           key: key,
//           label: 'Kabin',
//           initialValue: vm.form?.cabin,
//           future: () => context.read<ICabinRepository>().getCabinsByStation(vm.form?.station?.id ?? 0),
//           labelBuilder: (value) => value?.name,
//           validator: (value) => Validators.cannotBlankValidator(value?.name),
//           onSelected: (value) => context.read<CabinTemperatureControlFormViewModel>().setCabin(value),
//         );
//       },
//     );
//   }
// }

class _InsideBottomTempField extends StatelessWidget {
  const _InsideBottomTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'İç Alt Sıcaklık',
          initialValue: vm.form?.topTemperatureInside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setInsideBottomTemp(value),
        );
      },
    );
  }
}

class _InsideTopTempField extends StatelessWidget {
  const _InsideTopTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'İç Üst Sıcaklık',
          initialValue: vm.form?.topTemperatureInside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setInsideTopTemp(value),
        );
      },
    );
  }
}

class _OutsideBottomTempField extends StatelessWidget {
  const _OutsideBottomTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'Dış Alt Sıcaklık',
          initialValue: vm.form?.bottomTemperatureOutside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setOutsideBottomTemp(value),
        );
      },
    );
  }
}

class _OutsideTopTempField extends StatelessWidget {
  const _OutsideTopTempField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'Dış Üst Sıcaklık',
          initialValue: vm.form?.topTemperatureOutside?.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setOutsideTopTemp(value),
        );
      },
    );
  }
}

class _BottomHumidityField extends StatelessWidget {
  const _BottomHumidityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'Nem Alt Sınır',
          initialValue: vm.form?.bottomLimitHumidity.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setBottomHumidity(value),
        );
      },
    );
  }
}

class _TopHumidityField extends StatelessWidget {
  const _TopHumidityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureControlFormViewModel>(
      builder: (context, vm, _) {
        return TextInputField(
          key: key,
          label: 'Nem Üst Sınır',
          initialValue: vm.form?.topLimitHumidity.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<CabinTemperatureControlFormViewModel>().setTopHumidity(value),
        );
      },
    );
  }
}
