import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/core.dart';

import '../../../domain/entity/cabin.dart';
import '../../../../../../../../packages/pharmed_core/lib/src/cabin/domain/model/drawer_group.dart';
import '../../../domain/entity/drawer_unit.dart';

part '../cabin_drawer_view.dart';
part '../cabinet_view.dart';
part '../base_unit_cell.dart';
part '../cabin_selector_header.dart';

class CabinEditorView<T> extends StatefulWidget {
  const CabinEditorView({
    super.key,
    required this.layouts,
    required this.cabinId,
    required this.mode,
    required this.cabins,
    required this.selectedCabin,
    required this.onCabinChanged,
    required this.cellBuilder,
    this.cellData,
  });

  final int cabinId;
  final CabinViewMode mode;
  final List<Cabin> cabins;
  final Cabin? selectedCabin;
  final Function(Cabin) onCabinChanged;
  final List<DrawerGroup> layouts;

  /// Herhangi bir tipteki veri listesi (Assignment, Maintenance, Stock vb.)
  final List<T>? cellData;

  /// Hücrenin nasıl çizileceğine karar veren fonksiyon
  final Widget Function(BuildContext context, DrawerUnit unit, T? data) cellBuilder;

  @override
  State<CabinEditorView<T>> createState() => _CabinEditorViewState<T>();
}

class _CabinEditorViewState<T> extends State<CabinEditorView<T>> {
  DrawerGroup? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _updateInitialSelection();
  }

  @override
  void didUpdateWidget(covariant CabinEditorView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layouts != widget.layouts || oldWidget.selectedCabin?.id != widget.selectedCabin?.id) {
      _updateInitialSelection();
    }
  }

  void _updateInitialSelection() {
    setState(() {
      _selectedGroup = widget.layouts.isNotEmpty ? widget.layouts.first : null;
    });
  }

  void _selectDrawer(DrawerGroup group) {
    setState(() {
      _selectedGroup = group;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cabins.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.magnifyingGlass(),
        message: "Kabin Bulunamadı",
        subMessage: "Sistemde tanımlı herhangi bir kabin yok. Lütfen önce kabin ekleyiniz.",
      );
    }

    if (widget.layouts.isEmpty) {
      return _buildEmptyLayout();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOL TARAF: Header ve Detay Görünümü
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CabinSelectorHeader(
                  cabins: widget.cabins,
                  selectedCabin: widget.selectedCabin,
                  onCabinSelected: widget.onCabinChanged,
                ),
                const SizedBox(height: 20),

                // Detay Görünümü (Grid) - Jenerik tip ile çağrılıyor
                CabinDrawerView<T>(
                  mode: widget.mode,
                  cabinId: widget.cabinId,
                  group: _selectedGroup,
                  cellData: widget.cellData,
                  cellBuilder: widget.cellBuilder,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

        // SAĞ TARAF: Kabin Silüeti
        if (widget.selectedCabin?.type == CabinType.master)
          SizedBox(
            width: 300,
            child: CabinetView(selectedGroup: _selectedGroup, onDrawerTap: _selectDrawer, groups: widget.layouts),
          ),
      ],
    );
  }

  Widget _buildEmptyLayout() {
    return Column(
      children: [
        CabinSelectorHeader(
          cabins: widget.cabins,
          selectedCabin: widget.selectedCabin,
          onCabinSelected: widget.onCabinChanged,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CommonEmptyStates.generic(
            icon: PhosphorIcons.arrowsClockwise(),
            message: "Tasarım Henüz Oluşturulmadı",
            subMessage:
                "${widget.selectedCabin?.name ?? 'Seçili kabin'} için henüz bir tasarım bulunmuyor.\nLütfen tasarımı senkronize edin.",
          ),
        ),
      ],
    );
  }
}
