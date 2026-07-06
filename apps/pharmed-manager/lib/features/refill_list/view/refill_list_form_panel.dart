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
      create: (BuildContext context) => NewRefillListNotifier(
        auth: context.read(),
        station: station,
        user: user,
        initial: refillList,
        getRefillCandidates: context.read(),
        createRefillList: context.read(),
        getRefillListDetail: context.read(),
        updateRefillList: context.read(),
      )..initalize(),
      child: Consumer<NewRefillListNotifier>(
        builder: (context, notifier, _) {
          String title = notifier.isCreate ? 'Dolum Listesi Oluşturma' : 'Dolum Listesi Güncelleme';
          return SidePanel(
            title: title,
            onClose: refillNotifier.closePanel,
            child: Column(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Row(
                  spacing: 15,
                  children: List.generate(FillingType.values.length, (index) {
                    FillingType type = FillingType.values.elementAt(index);
                    return MedCheckbox(
                      label: type.label,
                      value: type == notifier.fillingType,
                      onChanged: (_) => notifier.selectFillingType(type),
                    );
                  }),
                ),
                _UserField(),
                _RefillListView(notifier: notifier),
              ],
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
    final notifier = context.read<NewRefillListNotifier>();

    return MedSelectionField<User>(
      label: 'Dolum Yapacak Kullanıcı',
      title: 'Dolum Yapacak Kullanıcı',
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

  final NewRefillListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isLoading(notifier.fetchOp)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.allItems.isEmpty) {
      return EmptyStateWidget(variant: EmptyStateVariant.noData, size: EmptyStateSize.compact);
    }

    return ListView.separated(
      itemCount: notifier.allItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = notifier.allItems[index];

        // Sepette bu ilaçtan ne kadar var?
        // autoFill çalışınca buradaki değer 0'dan hedef rakama çıkacak.
        final selectedItem = notifier.objects.firstWhere(
          (m) => m.medicine?.id == item.medicine?.id,
          orElse: () => RefillObject(quantity: 0),
        );
        return MedicineFillingCard(
          object: item,
          selectedQuantity: (selectedItem.quantity).toDouble(),
          onQuantityChanged: (newVal) => notifier.updateSelectedQuantity(item, newVal),
          onTap: () => notifier.toggleSelection(item),
        );
      },
    );
  }
}
