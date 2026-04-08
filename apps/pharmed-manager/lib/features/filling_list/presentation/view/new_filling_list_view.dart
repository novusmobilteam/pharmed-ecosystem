part of 'filling_list_screen.dart';

class NewFillingListView extends StatelessWidget {
  const NewFillingListView({super.key, required this.station, this.fillingList, this.user});

  final Station station;
  final User? user;
  final FillingList? fillingList;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => NewFillingListNotifier(
        auth: context.read(),
        station: station,
        user: user,
        initial: fillingList,
        getRefillCandidatesUseCase: context.read(),
        createFillingListUseCase: context.read(),
        getFillingListDetailUseCase: context.read(),
        updateFillingListUseCase: context.read(),
      )..initalize(),
      child: Consumer<NewFillingListNotifier>(
        builder: (context, notifier, _) {
          return _buildContent(context, notifier);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NewFillingListNotifier notifier) {
    return RegistrationDialog(
      title: notifier.isCreate ? 'Dolum Listesi Oluşturma' : 'Dolum Listesi Güncelleme',
      onClose: () => _onClose(context, notifier),
      isLoading: notifier.isLoading(notifier.submitOp),
      isButtonActive: notifier.objects.isNotEmpty,
      saveButtonText: notifier.isCreate ? 'Oluştur' : 'Güncelle',
      showSearch: true,
      onSearchChanged: notifier.search,
      onSave: () {
        notifier.submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) {
            MessageUtils.showSuccessSnackbar(context, msg);
            context.pop(true);
          },
        );
      },
      actions: [
        if (notifier.fillingType != FillingType.all)
          RectangleIconButton(
            iconData: PhosphorIcons.upload(),
            tooltip: 'Seçime Göre Otomatik Hazırla',
            onPressed: notifier.autoFill,
          ),
      ],
      child: Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Row(
            spacing: 15,
            children: List.generate(FillingType.values.length, (index) {
              FillingType type = FillingType.values.elementAt(index);
              return CustomCheckboxTile(
                label: type.label,
                value: type == notifier.fillingType,
                onTap: () => notifier.selectFillingType(type),
              );
            }),
          ),
          _UserField(),
          Expanded(child: _FillingListView(notifier: notifier)),
        ],
      ),
    );
  }

  void _onClose(BuildContext context, NewFillingListNotifier notifier) {
    if (notifier.objects.isNotEmpty) {
      MessageUtils.showConfirmExitDialog(context: context, onConfirm: () => context.pop(false));
    } else {
      context.pop(false);
    }
  }
}

class _UserField extends StatelessWidget {
  const _UserField();

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<NewFillingListNotifier>();

    return SelectionField<User>(
      label: 'Dolum Yapacak Kullanıcı',
      title: 'Dolum Yapacak Kullanıcı',
      dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(const GetUsersParams()),
      initialValue: notifier.user,
      labelBuilder: (value) => value.fullName,
      onSelected: (value) => notifier.selectUser(value),
    );
  }
}

class _FillingListView extends StatelessWidget {
  const _FillingListView({required this.notifier});

  final NewFillingListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isLoading(notifier.fetchOp)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.allItems.isEmpty) {
      return CommonEmptyStates.noData();
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
          orElse: () => FillingObject(quantity: 0),
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
