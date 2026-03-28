part of 'dialog_input_field.dart';

class SelectionDialog<T extends Selectable> extends StatefulWidget {
  const SelectionDialog.single({
    super.key,
    required this.dialogTitle,
    this.future,
    this.selected,
    this.width = 600,
    this.maxHeight = 650,
    this.actions,
    this.futureNotifier,
  })  : multi = false,
        initiallySelected = null,
        labelBuilder = _defaultLabelBuilder;

  const SelectionDialog.multi({
    super.key,
    required this.dialogTitle,
    this.future,
    this.initiallySelected,
    required this.labelBuilder,
    this.width = 600,
    this.maxHeight = 650,
    this.actions,
    this.futureNotifier,
  })  : multi = true,
        selected = null;

  final String dialogTitle;
  final DialogFuture<T>? future;
  final ValueNotifier<DialogFuture<T>>? futureNotifier;
  final bool multi;
  final T? selected;
  final List<T>? initiallySelected;
  final String? Function(T?) labelBuilder;
  final double width;
  final double maxHeight;
  final List<Widget>? actions;

  static String? _defaultLabelBuilder<T extends Selectable>(T? item) => item?.title;

  @override
  State<SelectionDialog<T>> createState() => _SelectionDialogState<T>();
}

class _SelectionDialogState<T extends Selectable> extends State<SelectionDialog<T>> {
  List<T> _items = const [];
  late Set<Object?> _selectedIds;

  late Future _activeFuture;

  @override
  void initState() {
    super.initState();

    _activeFuture = (widget.futureNotifier?.value ?? widget.future)!.call();
    widget.futureNotifier?.addListener(_onFutureChanged);

    if (widget.multi) {
      _selectedIds = {for (final e in (widget.initiallySelected ?? List<T>.empty())) e.id};
    } else {
      _selectedIds = {widget.selected?.id};
    }
  }

  @override
  void dispose() {
    widget.futureNotifier?.removeListener(_onFutureChanged);
    super.dispose();
  }

  void _onFutureChanged() {
    setState(() {
      _activeFuture = widget.futureNotifier!.value.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    //final hasSelection = _selectedIds.isNotEmpty;

    return RegistrationDialog(
      title: widget.dialogTitle,
      saveButtonText: 'Tamam',
      onSave: () {
        if (context.mounted) {
          _onConfirm(context);
        }
      },
      actions: [
        if (widget.multi) _selectAllButton(),
        if (widget.actions != null) ...widget.actions!,
      ],
      child: _buildContent(context),
    );
  }

  TextButton _selectAllButton() {
    final allSelected = _selectedIds.length == _items.length && _selectedIds.isNotEmpty;
    final text = allSelected ? 'Seçimleri İptal Et' : 'Tümünü Seç';
    return TextButton(
      key: ValueKey(allSelected),
      onPressed: () {
        if (widget.multi && !allSelected) {
          setState(() {
            _selectedIds.addAll(_items.map((i) => i.id));
          });
        } else if (widget.multi && allSelected) {
          setState(() {
            _selectedIds.removeAll(_items.map((i) => i.id));
          });
        }
      },
      child: Text(text),
    );
  }

  Widget _buildContent(BuildContext context) {
    return FutureBuilder(
      future: _activeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data is Error<List<T>>) {
          return CommonEmptyStates.noData();
        }

        final response = (snapshot.data as Ok<ApiResponse<List<T>>>).value;
        _items = response.data ?? [];

        if (_items.isEmpty) {
          return CommonEmptyStates.noData();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isSelected = _selectedIds.contains(item.id);
            return SelectableListTile(
              item: item,
              onTap: _onTap,
              onDoubleTap: _onDoubleTap,
              isSelected: isSelected,
            );
          },
        );
      },
    );
  }

  void _onTap(T item) {
    setState(() {
      if (widget.multi) {
        if (_selectedIds.contains(item.id)) {
          _selectedIds.remove(item.id);
        } else {
          _selectedIds.add(item.id);
        }
      } else {
        _selectedIds = {item.id};
      }
    });
  }

  void _onDoubleTap(T item, BuildContext context) {
    if (widget.multi) return; // Multi seçimde double tap mantıklı olmayabilir
    setState(() {
      _selectedIds = {item.id};
    });
    _onConfirm(context);
  }

  void _onConfirm(BuildContext context) {
    final filteredIds = _selectedIds.where((e) => e != null).toSet();

    if (widget.multi) {
      final selectedItems = _items.where((e) => filteredIds.contains(e.id)).toList();
      context.pop(selectedItems);
    } else {
      T selectedItem;
      try {
        selectedItem = _items.firstWhere((e) => filteredIds.contains(e.id));
      } catch (_) {
        if (_items.isNotEmpty) {
          selectedItem = _items.first;
        } else {
          return;
        }
      }
      context.pop(selectedItem);
    }
  }
}
