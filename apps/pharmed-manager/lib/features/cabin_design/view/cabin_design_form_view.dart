part of 'cabin_design_view.dart';

class CabinDesignFormDialog extends StatefulWidget {
  const CabinDesignFormDialog({super.key});

  @override
  State<CabinDesignFormDialog> createState() => _CabinDesignFormDialogState();
}

class _CabinDesignFormDialogState extends State<CabinDesignFormDialog> {
  final _formKey = GlobalKey<FormState>();
  CabinDesignFormNotifier? _viewModel;

  void _setupCallbacks(BuildContext context, CabinDesignFormNotifier vm) {
    vm.setCallbacks(
      key: CabinDesignFormNotifier.submitOp,
      onError: (message) {
        MessageUtils.showErrorDialog(context, message ?? 'Bir hata oluştu');
      },
      onSuccess: (message) {
        MessageUtils.showSuccessSnackbar(context, message);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        if (_viewModel != vm) {
          _viewModel = vm;
          _setupCallbacks(context, vm);
        }
        return RegistrationDialog(
          title: 'Kabin Ekle',
          maxHeight: context.height * 0.7,
          isLoading: vm.isSubmitting,
          onSave: () {
            if (_formKey.currentState!.validate()) {
              vm.submitForm();
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _StationField(),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _NameField()),
                      Expanded(child: _TypeField()),
                    ],
                  ),
                  _StatusField(),
                  Visibility(
                    visible: vm.showDeviceSettings,
                    child: Column(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        Row(
                          spacing: AppDimensions.registrationDialogSpacing,
                          children: [
                            Expanded(child: _ComPortField()),
                            Expanded(child: _BaudRateField()),
                          ],
                        ),
                        Row(
                          spacing: AppDimensions.registrationDialogSpacing,
                          children: [
                            Expanded(child: _StopBitField()),
                            Expanded(child: _DataBitField()),
                            Expanded(child: _ParityBitField()),
                          ],
                        ),
                        Row(
                          spacing: AppDimensions.registrationDialogSpacing,
                          children: [
                            Expanded(child: _ColorField()),
                            Expanded(child: _DvrIpField()),
                            Expanded(child: _CameraField()),
                          ],
                        ),
                        Visibility(
                          visible: vm.cabin?.type == CabinType.cabinet,
                          child: Row(
                            spacing: AppDimensions.registrationDialogSpacing,
                            children: [
                              // Expanded(child: _CardTypeField()),
                              Expanded(child: _SequenceField()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StationField extends StatelessWidget {
  const _StationField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DialogInputField<Station>(
          label: 'İstasyon',
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          initialValue: vm.cabin?.station,
          onSelected: vm.updateStation,
          future: () => context.read<IStationRepository>().getStations(),
          labelBuilder: (station) => station?.name,
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Kabin Adı',
          validator: (value) => Validators.cannotBlankValidator(value),
          initialValue: vm.cabin?.name,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateName(value),
        );
      },
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<CabinType>(
          label: 'Kabin Tipi',
          initialValue: vm.cabin?.type,
          options: CabinType.values,
          labelBuilder: (value) => value?.label,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateType(value),
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: vm.cabin?.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateStatus(value),
        );
      },
    );
  }
}

// class _CardTypeField extends StatelessWidget {
//   const _CardTypeField();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CabinDesignFormNotifier>(
//       builder: (context, vm, _) {
//         return MultiDialogInputField<CabinCardType>(
//           label: 'Kart Tipi',
//           initialValue: vm.cabin?.cardTypes,
//           onSelected: (value) => context.read<CabinDesignFormNotifier>().updateCardTypes(value),
//           labelBuilder: (value) => value?.label,
//           future: () => context.read<CabinDesignFormNotifier>().getCardTypes(),
//         );
//       },
//     );
//   }
// }

class _ComPortField extends StatelessWidget {
  const _ComPortField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<ComPort>(
          label: 'COM Port',
          initialValue: vm.cabin?.comPort,
          options: ComPort.values,
          validator: (value) => Validators.cannotBlankValidator(value?.label),
          labelBuilder: (value) => value?.label,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updatePort(value),
        );
      },
    );
  }
}

class _BaudRateField extends StatelessWidget {
  const _BaudRateField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<BaudRate>(
          label: 'Baud Rate',
          initialValue: vm.cabin?.baudRate,
          options: BaudRate.values,
          labelBuilder: (value) => value?.label,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateBaudRate(value),
        );
      },
    );
  }
}

class _StopBitField extends StatelessWidget {
  const _StopBitField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<StopBit>(
          label: 'Stop Bit',
          initialValue: vm.cabin?.stopBit,
          options: StopBit.values,
          labelBuilder: (value) => value?.id.toString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateStopBit(value),
        );
      },
    );
  }
}

class _DataBitField extends StatelessWidget {
  const _DataBitField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<DataBit>(
          label: 'Data Bit',
          initialValue: vm.cabin?.dataBit,
          options: DataBit.values,
          labelBuilder: (value) => value?.id.toString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateDataBit(value),
        );
      },
    );
  }
}

class _ParityBitField extends StatelessWidget {
  const _ParityBitField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<ParityBit>(
          label: 'Parity Bit',
          initialValue: vm.cabin?.parityBit,
          options: ParityBit.values,
          labelBuilder: (value) => value?.id.toString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateParityBit(value),
        );
      },
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<CabinColor>(
          label: 'Renk',
          initialValue: vm.cabin?.color,
          options: CabinColor.values,
          labelBuilder: (value) => value?.label.toString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateColor(value),
        );
      },
    );
  }
}

class _DvrIpField extends StatelessWidget {
  const _DvrIpField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'DVR IP',
          initialValue: vm.cabin?.dvrIp,
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateDvrIp(value.toString()),
        );
      },
    );
  }
}

class _SequenceField extends StatelessWidget {
  const _SequenceField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<int>(
          label: 'Sıra No',
          initialValue: vm.cabin?.sequenceNo,
          options: List.generate(26, (i) => i + 1),
          labelBuilder: (value) => value?.toString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateSequence(value),
        );
      },
    );
  }
}

class _CameraField extends StatelessWidget {
  const _CameraField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinDesignFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Kamera No',
          initialValue: vm.cabin?.cameraNo?.toCustomString(),
          onChanged: (value) => context.read<CabinDesignFormNotifier>().updateCameraNo(value),
        );
      },
    );
  }
}
