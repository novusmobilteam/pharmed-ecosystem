part of 'refill_list_screen.dart';

// [SWREQ-MGR-REFILLLIST-002]
// Dolum listesi oluşturma / düzenleme penceresi (yan panelin yerine geçti).
// Solda aday ilaçlar (tip + arama + toplu seçim → "Ekle"), sağda listedeki
// ilaçlar (miktar, sil). Düzenlemede sağ taraf kayıtlı ilaçlarla açılır.

/// true → liste kaydedildi.
Future<bool> showRefillListFormDialog(BuildContext context, {required Station? station, RefillList? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RefillListFormNotifier(
        auth: context.read(),
        station: station,
        initial: initial,
        getRefillCandidates: context.read(),
        createRefillList: context.read(),
        getRefillListDetail: context.read(),
        updateRefillList: context.read(),
      )..initialize(),
      child: const RefillListFormDialog(),
    ),
  );
  return result ?? false;
}

class RefillListFormDialog extends StatelessWidget {
  const RefillListFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RefillListFormNotifier>(
      builder: (context, notifier, _) {
        final size = MediaQuery.sizeOf(context);
        return RegistrationDialog(
          title: notifier.isCreate ? context.l10n.refillList_formTitleCreate : context.l10n.refillList_formTitleUpdate,
          width: math.min(1180, size.width * 0.92),
          height: size.height * 0.86,
          maxHeight: size.height * 0.86,
          isLoading: notifier.isSubmitting,
          isButtonActive: notifier.canSave,
          onSave: () => notifier.submit(
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (_) {
              MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
              Navigator.of(context).pop(true);
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: MedSpacing.xl,
            children: [
              SizedBox(
                width: 420,
                child: _UserField(initial: notifier.user, onSelected: notifier.selectUser),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 11, child: _CandidatePane(notifier: notifier)),
                    const VerticalDivider(width: 32, color: MedColors.border),
                    Expanded(flex: 9, child: _SelectionPane(notifier: notifier)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserField extends StatelessWidget {
  const _UserField({required this.initial, required this.onSelected});

  final User? initial;
  final ValueChanged<User?> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.refillList_fieldAssignedUser;
    return MedSelectionField<User>(
      label: label,
      title: label,
      dataSource: (skip, take, search) =>
          context.read<GetUsersUseCase>().call(GetUsersParams(skip: skip, take: take, search: search)),
      initialValue: initial,
      labelBuilder: (value) => value.fullName,
      onSelected: onSelected,
    );
  }
}

class _PaneTitle extends StatelessWidget {
  const _PaneTitle({required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: MedTextStyles.titleMd(color: MedColors.text)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ── Sol: aday ilaçlar ─────────────────────────────────────────────────────

class _CandidatePane extends StatelessWidget {
  const _CandidatePane({required this.notifier});

  final RefillListFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = notifier.visibleCandidates;
    final checkedCount = notifier.checkedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MedSpacing.lg,
      children: [
        _PaneTitle(text: l10n.refillList_form_addSectionTitle),
        MedSegmentedButton(
          labels: [for (final t in _typeOrder) t.label],
          selectedIndex: _typeOrder.indexOf(notifier.fillingType),
          onChanged: (i) => notifier.selectFillingType(_typeOrder[i]),
        ),
        MedTextInputField(
          hintText: l10n.refillList_form_searchHint,
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
          onChanged: (value) => notifier.onSearchChanged(value ?? ''),
        ),
        Row(
          children: [
            MedCheckbox(
              value: notifier.allVisibleChecked,
              partial: !notifier.allVisibleChecked && checkedCount > 0,
              label: l10n.refillList_form_selectAll,
              onChanged: items.isEmpty ? null : (_) => notifier.toggleAllVisible(),
            ),
            const Spacer(),
            MedButton(
              label: l10n.refillList_form_addSelectedButton(checkedCount),
              prefixIcon: Icon(PhosphorIcons.arrowRight(), size: 16),
              size: MedButtonSize.sm,
              onPressed: checkedCount > 0 ? notifier.addChecked : null,
            ),
          ],
        ),
        Expanded(
          child: notifier.isLoadingCandidates
              ? const Center(child: CircularProgressIndicator.adaptive())
              : items.isEmpty
              ? Center(
                  child: EmptyStateWidget(
                    variant: EmptyStateVariant.noData,
                    size: EmptyStateSize.compact,
                    title: l10n.refillList_form_noCandidates,
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return RefillCandidateRow(
                      object: item,
                      suggestedQuantity: notifier.suggestedQuantity(item),
                      isChecked: notifier.isChecked(item),
                      isInList: notifier.isInList(item),
                      onToggle: () => notifier.toggleChecked(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Segment sırası: en sık kullanılan "Maksimum" başta.
const _typeOrder = [RefillType.max, RefillType.min, RefillType.critic, RefillType.all];

// ── Sağ: listedeki ilaçlar ────────────────────────────────────────────────

class _SelectionPane extends StatelessWidget {
  const _SelectionPane({required this.notifier});

  final RefillListFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = notifier.selections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MedSpacing.lg,
      children: [
        _PaneTitle(
          text: l10n.refillList_form_listSectionTitle(items.length),
          trailing: items.isEmpty
              ? null
              : TextButton.icon(
                  onPressed: notifier.clearList,
                  icon: Icon(PhosphorIcons.broom(), size: 16, color: MedColors.red),
                  label: Text(l10n.refillList_form_clearListButton, style: MedTextStyles.bodySm(color: MedColors.red)),
                ),
        ),
        Expanded(
          child: notifier.isLoadingDetail
              ? const Center(child: CircularProgressIndicator.adaptive())
              : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.refillList_form_emptyListHint,
                      textAlign: TextAlign.center,
                      style: MedTextStyles.bodyMd(color: MedColors.text3),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return RefillSelectionRow(
                      key: ValueKey(item.medicine?.id),
                      object: item,
                      currentStock: notifier.currentStockOf(item),
                      onQuantityChanged: (q) => notifier.updateQuantity(item, q),
                      onRemove: () => notifier.remove(item),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
          child: Text(
            l10n.refillList_form_totalLabel(items.length, notifier.totalQuantity.formatFractional),
            textAlign: TextAlign.right,
            style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
