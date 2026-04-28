import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/role_drug_auth_notifier.dart';

class RoleDrugAuthenticationView extends StatelessWidget {
  const RoleDrugAuthenticationView({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleDrugAuthNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return _DrugTable(notifier: notifier);
      },
    );
  }
}

class _DrugTable extends StatelessWidget {
  const _DrugTable({required this.notifier});

  final RoleDrugAuthNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Colors.white.withAlpha(50)),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        child: DataTable(
          dividerThickness: 0.1,
          border: TableBorder.all(
            width: 0.5,
            borderRadius: BorderRadius.circular(12.0),
            color: context.theme.dividerColor,
          ),
          columnSpacing: 20,
          columns: [
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 2),
              label: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 1),
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                'İlaç Çeker',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 1),
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                'Dolum',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 1),
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                'İade',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 1),
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                'İmha',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              columnWidth: IntrinsicColumnWidth(flex: 1),
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                'Tümü',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          rows: [
            DataRow(
              cells: [
                const DataCell(Text('Tüm İlaçlar', style: TextStyle(fontWeight: FontWeight.bold))),
                ...DrugOp.values.map(
                  (op) => DataCell(
                    Center(
                      child: _HeaderCheckbox(notifier: notifier, operation: op),
                    ),
                  ),
                ),
                DataCell(Center(child: _HeaderAllCheckbox(notifier: notifier))),
              ],
            ),
            // İlaç rows
            ...notifier.filteredAuths.map((item) {
              return _buildDrugRow(notifier, item.medicine);
            }),
          ],
        ),
      ),
    );
  }

  DataRow _buildDrugRow(RoleDrugAuthNotifier notifier, Medicine? medicine) {
    return DataRow(
      cells: [
        DataCell(Text(medicine?.name ?? 'Bilinmeyen İlaç')),
        ...DrugOp.values.map(
          (operation) => DataCell(
            Center(
              child: _DrugOperationCheckbox(notifier: notifier, drugId: medicine?.id ?? 0, operation: operation),
            ),
          ),
        ),
        DataCell(
          Center(
            child: _DrugAllOperationsCheckbox(notifier: notifier, drugId: medicine?.id ?? 0),
          ),
        ),
      ],
    );
  }
}

/// Header - Operasyon bazlı tümünü seç/kaldır
class _HeaderCheckbox extends StatelessWidget {
  const _HeaderCheckbox({required this.notifier, required this.operation});

  final RoleDrugAuthNotifier notifier;
  final DrugOp operation;

  @override
  Widget build(BuildContext context) {
    final allSelected = notifier.allItems.every((auth) => auth.pendingOps.contains(operation));

    return Checkbox(
      value: allSelected,
      tristate: true,
      onChanged: (_) {
        notifier.toggleOperationForAllDrugs(operation);
      },
    );
  }
}

/// Header - Tüm operasyonları tüm ilaçlar için seç/kaldır
class _HeaderAllCheckbox extends StatelessWidget {
  const _HeaderAllCheckbox({required this.notifier});

  final RoleDrugAuthNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final allSelected = notifier.allItems.every((auth) => auth.pendingOps.length == DrugOp.values.length);

    return Checkbox(
      value: allSelected,
      tristate: true,
      onChanged: (_) {
        if (allSelected) {
          notifier.clearAllForAllDrugs();
        } else {
          notifier.selectAllForAllDrugs();
        }
      },
    );
  }
}

/// İlaç-operasyon checkbox'ı
class _DrugOperationCheckbox extends StatelessWidget {
  const _DrugOperationCheckbox({required this.notifier, required this.drugId, required this.operation});

  final RoleDrugAuthNotifier notifier;
  final int drugId;
  final DrugOp operation;

  @override
  Widget build(BuildContext context) {
    final isSelected = notifier.isOperationSelected(drugId, operation);

    return Checkbox(
      value: isSelected,
      onChanged: (_) {
        notifier.toggleDrugOperation(drugId, operation);
      },
    );
  }
}

/// İlaç için tüm operasyonları seç/kaldır
class _DrugAllOperationsCheckbox extends StatelessWidget {
  const _DrugAllOperationsCheckbox({required this.notifier, required this.drugId});

  final RoleDrugAuthNotifier notifier;
  final int drugId;

  @override
  Widget build(BuildContext context) {
    final allSelected = DrugOp.values.every((op) => notifier.isOperationSelected(drugId, op));

    return Checkbox(
      value: allSelected,
      tristate: true,
      onChanged: (_) {
        if (allSelected) {
          notifier.clearAllOperationsForDrug(drugId);
        } else {
          notifier.selectAllOperationsForDrug(drugId);
        }
      },
    );
  }
}
