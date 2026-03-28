import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/info_chip.dart';
import '../notifier/filling_list_view_notifier.dart';
import 'filling_list_refill_view.dart';

class FillingListView extends StatelessWidget {
  const FillingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FillingListViewNotifier(
        getCurrentStationFillingListsUseCase: context.read(),
        refillUseCase: context.read(),
        getFillingListDetailUseCase: context.read(),
      )..getFillingLists(),
      child: Consumer<FillingListViewNotifier>(
        builder: (context, notifier, child) {
          return CustomDialog(
            title: 'İlaç Dolum Listesi',
            isLoading: notifier.isLoading(notifier.fetchDetailOp),
            showSearch: true,
            onSearchChanged: notifier.search,
            child: _buildChild(),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<FillingListViewNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading(notifier.fetchOp)) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (notifier.isEmpty || notifier.hasNoSearchResults) {
          return Center(
            child: CommonEmptyStates.noData(),
          );
        }

        return ListView.builder(
          itemCount: notifier.filteredItems.length,
          itemBuilder: (context, index) {
            final item = notifier.filteredItems.elementAt(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  notifier.selectFillingList(
                    item,
                    onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                    onSuccess: () => _showRefillView(context),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dolum Kayıt No: ${item.id}',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Oluşturulma Tarihi: ${item.date?.formattedDateTime}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Dolum Yapacak Kişi: ${item.user?.fullName}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          InfoChip(info: item.status?.label),
                        ],
                      ),
                      Icon(PhosphorIcons.caretRight()),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showRefillView(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<FillingListViewNotifier>(),
      child: FillingListRefillView(),
    ),
  );
}
