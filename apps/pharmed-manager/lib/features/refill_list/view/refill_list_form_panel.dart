part of 'refill_list_screen.dart';

class RefillListFormPanel extends StatelessWidget {
  const RefillListFormPanel({super.key, this.station, this.refillList, this.user});

  final Station? station;
  final User? user;
  final RefillList? refillList;

  @override
  Widget build(BuildContext context) {
    final refillNotifier = context.watch<RefillListNotifier>();
    return ChangeNotifierProvider(
      create: (BuildContext context) => RefillListFormNotifier(
        auth: context.read(),
        station: station,
        user: user,
        initial: refillList,
        getRefillCandidates: context.read(),
        createRefillList: context.read(),
        getRefillListDetail: context.read(),
        updateRefillList: context.read(),
      )..initalize(),
      child: Consumer<RefillListFormNotifier>(
        builder: (context, notifier, _) {
          String title = notifier.isCreate
              ? context.l10n.refillList_formTitleCreate
              : context.l10n.refillList_formTitleUpdate;
          return SidePanel(
            disableScroll: true,
            title: title,
            onSave: () {
              notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                  refillNotifier.getRefillLists();
                  refillNotifier.closePanel();
                },
              );
            },
            isLoading: notifier.isLoading(notifier.submitOp),
            onClose: refillNotifier.closePanel,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  Row(
                    spacing: 15,
                    children: List.generate(RefillType.values.length, (index) {
                      RefillType type = RefillType.values.elementAt(index);
                      return MedCheckbox(
                        label: type.label,
                        value: type == notifier.fillingType,
                        onChanged: (_) => notifier.selectFillingType(type),
                      );
                    }),
                  ),
                  _UserField(),
                  Expanded(child: _RefillListView(notifier: notifier)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildContent(BuildContext context, NewRefillListNotifier notifier) {
  //   return RegistrationDialog(
  //     onClose: () => _onClose(context, notifier),
  //     isLoading: notifier.isLoading(notifier.submitOp),
  //     isButtonActive: notifier.objects.isNotEmpty,
  //     saveButtonText: notifier.isCreate ? 'Oluştur' : 'Güncelle',
  //     showSearch: true,
  //     onSearchChanged: notifier.search,
  //     onSave: () {
  //       notifier.submit(
  //         onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
  //         onSuccess: (msg) {
  //           MessageUtils.showSuccessSnackbar(context, msg);
  //           context.pop(true);
  //         },
  //       );
  //     },
  //     actions: [
  //       if (notifier.fillingType != FillingType.all)
  //         RectangleIconButton(
  //           iconData: PhosphorIcons.upload(),
  //           tooltip: 'Seçime Göre Otomatik Hazırla',
  //           onPressed: notifier.autoFill,
  //         ),
  //     ],
  //     child: ,
  //   );
  // }
}

class _UserField extends StatelessWidget {
  const _UserField();

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<RefillListFormNotifier>();
    final label = context.l10n.refillList_fieldAssignedUser;

    return MedSelectionField<User>(
      label: label,
      title: label,
      dataSource: (skip, take, search) =>
          context.read<GetUsersUseCase>().call(GetUsersParams(skip: skip, take: take, search: search)),
      initialValue: notifier.user,
      labelBuilder: (value) => value.fullName,
      onSelected: (value) => notifier.selectUser(value),
    );
  }
}

class _RefillListView extends StatelessWidget {
  const _RefillListView({required this.notifier});

  final RefillListFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isLoading(notifier.fetchOp)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.objects.isEmpty) {
      return EmptyStateWidget(variant: EmptyStateVariant.noData, size: EmptyStateSize.compact);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: notifier.objects.length,
      itemBuilder: (BuildContext context, int index) {
        final item = notifier.objects[index];

        return RefillObjectCard(
          object: item,
          selectedQuantity: notifier.selectedQuantity(item),
          onQuantityChanged: (newVal) => notifier.updateSelectedQuantity(item, newVal),
          onTap: () => notifier.toggleSelection(item),
        );
      },
    );
  }
}
