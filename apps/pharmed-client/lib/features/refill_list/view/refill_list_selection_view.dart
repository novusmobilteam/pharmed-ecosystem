part of 'refill_list_view.dart';

class RefillListSelectionView extends StatelessWidget {
  const RefillListSelectionView({
    super.key,
    required this.menu,
    required this.selectionNotifier,
    required this.executionNotifier,
  });

  final MenuItem menu;
  final RefillListSelectionNotifier selectionNotifier;
  final RefillListExecutionNotifier executionNotifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(
                flex: 2,
                child: _LeftPanel(key: Key('left-panel'), notifier: selectionNotifier),
              ),
              Expanded(
                flex: 7,
                child: _RightPanel(
                  key: Key('right-panel'),
                  selectionNotifier: selectionNotifier,
                  executionNotifier: executionNotifier,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// TODO : Localization
class _LeftPanel extends StatelessWidget {
  const _LeftPanel({super.key, required this.notifier});

  final RefillListSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MedSpacing.panelInsetPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dolum Listeleri', style: MedTextStyles.titleSm()),
                SizedBox(height: 12.0),
                MedSegmentedButton(
                  selectedIndex: notifier.selectedTypeIndex,
                  onChanged: (index) => notifier.selectType(index),
                  labels: ['Bekleyen', 'Tamamlanan'],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5),

          Expanded(
            child: ListView.separated(
              padding: MedSpacing.panelInsetPadding,
              itemCount: notifier.visibleLists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final list = notifier.visibleLists[index];
                return RefillListCard(
                  refillList: list,
                  isSelected: list.id != null && list.id == notifier.selectedList?.id,
                  onTap: () => notifier.selectRefillList(list),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({super.key, required this.selectionNotifier, required this.executionNotifier});

  final RefillListSelectionNotifier selectionNotifier;
  final RefillListExecutionNotifier executionNotifier;

  @override
  Widget build(BuildContext context) {
    final item = selectionNotifier.selectedList;

    return Builder(
      builder: (context) {
        if (selectionNotifier.isDetailLoading) return Center(child: MedLoadingIndicator());
        if (selectionNotifier.selectedList == null) {
          return Center(
            child: EmptySelectionView(
              title: context.l10n.refillList_selectionEmptyTitle,
              description: context.l10n.refillList_selectionEmptyDescription,
              icon: PhosphorIcons.list(),
            ),
          );
        }
        return Column(
          children: [
            _RefillListHeaderView(key: Key('header'), item: item),
            Expanded(
              child: RefillListTableView(
                items: selectionNotifier.details,
                selectedItems: selectionNotifier.selectedItems,
                onToggle: (value) {
                  selectionNotifier.selectItem(value);
                },
              ),
            ),
            if (selectionNotifier.canStart)
              _FooterView(
                key: Key('footer'),
                selectionNotifier: selectionNotifier,
                executionNotifier: executionNotifier,
              ),
          ],
        );
      },
    );
  }
}

class _RefillListHeaderView extends StatelessWidget {
  const _RefillListHeaderView({super.key, required this.item});

  final RefillList? item;

  @override
  Widget build(BuildContext context) {
    final user = item?.user;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration,
      child: Row(
        spacing: 12.0,
        children: [
          MedAvatar(initials: user?.initials ?? '', palette: AvatarPalette.blue, size: 48, shape: BoxShape.rectangle),

          Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dolum Listesi #${item?.id}', style: MedTextStyles.titleLg()),
              Row(
                spacing: 6.0,
                children: [
                  Text(
                    '${context.l10n.enumCore_prescriptionMovementPendingApprovalActorLabel}: ${user?.fullName}',
                    style: MedTextStyles.bodyMd(),
                  ),
                  Text('-'),
                  Text(
                    context.l10n.refillList_createdDateLabel(item?.date?.formattedDateTime.toString() ?? ''),
                    style: MedTextStyles.bodyMd(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterView extends StatelessWidget {
  const _FooterView({super.key, required this.selectionNotifier, required this.executionNotifier});

  final RefillListSelectionNotifier selectionNotifier;
  final RefillListExecutionNotifier executionNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6.0),
      padding: MedSpacing.insetLg,
      alignment: Alignment.centerRight,
      decoration: MedDecoration.panelDecoration,
      child: MedButton(
        label: context.l10n.refill_action_start,
        suffixIcon: Icon(PhosphorIcons.arrowRight()),
        onPressed: () {
          selectionNotifier.startFilling(
            onQueueReady: (jobs, listId, skipped) => executionNotifier.start(
              jobs,
              fillingListId: listId,
              skippedCount: skipped,
              details: selectionNotifier.selectedItems,
            ),
            onFailed: (failure) => MessageUtils.showErrorSnackbar(context, failure.message(context)),
          );
        },
      ),
    );
  }
}
