part of 'user_screen.dart';

class UserTableView extends StatelessWidget {
  const UserTableView({super.key, required this.onEdit});

  final Function(User user) onEdit;

  List<TableColumnDef<User>> _buildColumnDefs(BuildContext context, UserType type) {
    final isNormalOrAll = type == UserType.normal;

    return [
      TableColumnDef<User>(
        title: type == UserType.normal
            ? context.l10n.user_nationalIdColumnHeader
            : context.l10n.user_registrationNumberLabel,
        displayValue: (u) => u.registrationNumber ?? '-',
      ),
      TableColumnDef<User>(title: context.l10n.user_nameLabel, displayValue: (u) => u.name ?? '-'),
      TableColumnDef<User>(title: context.l10n.user_surnameLabel, displayValue: (u) => u.surname ?? '-'),
      if (isNormalOrAll)
        TableColumnDef<User>(title: context.l10n.user_roleTypeLabel, displayValue: (u) => u.role?.name ?? '-')
      else
        TableColumnDef<User>(
          title: context.l10n.user_validUntilLabel,
          displayValue: (u) => u.validUntil.formattedDate,
          sortValue: (u) => u.validUntil,
        ),
      TableColumnDef<User>(title: context.l10n.common_statusLabel, flex: 0.8, displayValue: (u) => u.status.label),
    ];
  }

  Widget? _buildCell(User user, int colIndex, UserType type) {
    final isNormalOrAll = type == UserType.normal;

    switch (colIndex) {
      case 0: // Kurum Sicil No / T.C Kimlik No
        return Text(
          user.registrationNumber ?? '-',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
        );

      case 1: // Adı
        return Text(
          user.name ?? '-',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        );

      case 2: // Soyadı
        return Text(
          user.surname ?? '-',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        );

      case 3: // Meslek Tipi  VEYA  Son Geçerlilik Tarihi
        if (isNormalOrAll) {
          return Text(
            user.role?.name ?? '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          );
        } else {
          final days = user.validUntil?.difference(DateTime.now()).inDays;
          return days != null
              ? RemainingDayChip(days: days)
              : const Text('-', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)));
        }

      case 4: // Durumu
        return _UserStatusBadge(status: user.status);

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, notifier, _) {
        final colDefs = _buildColumnDefs(context, notifier.selectedCategory);

        return MedTable<User>(
          data: notifier.users,
          isLoading: notifier.isFetching,
          categories: notifier.tableCategories(context),
          selectedCategoryId: notifier.selectedCategory.name.toString(),
          onCategoryChanged: (id) {
            notifier.selectCategory(UserType.values.firstWhere((type) => type.name.toString() == id));
          },
          columnDefs: colDefs,
          enableSearch: true,
          onSearchChanged: notifier.search,
          enableDateFilter: true,
          enableExcel: true,
          enablePDF: true,
          selectionMode: notifier.selectedCategory == UserType.timeBased
              ? TableSelectionMode.multi
              : TableSelectionMode.none,
          onSelectionChanged: notifier.selectUsers,

          actions: [
            TableActionItem(icon: PhosphorIcons.pen(), tooltip: context.l10n.common_editTooltip, onPressed: onEdit),
            TableActionItem(
              icon: PhosphorIcons.trashSimple(),
              tooltip: context.l10n.common_deleteTooltip,
              color: Colors.red,
              onPressed: (user) => _onDelete(context, notifier, user),
            ),
          ],

          // ── Hücre render (User alanlarına doğrudan erişim)
          cellBuilder: (user, colIndex, _) => _buildCell(user, colIndex, notifier.selectedCategory),

          // ── Server-side pagination
          enablePagination: true,
          currentPage: notifier.currentPage,
          pageSize: notifier.pageSize,
          serverTotalCount: notifier.currentTypeTotal,
          onPageChanged: (page) => notifier.setPage(page),
        );
      },
    );
  }
}

class _UserStatusBadge extends StatelessWidget {
  const _UserStatusBadge({required this.status});

  final Status status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      Status.active => (const Color(0xFF059669), const Color(0xFFD1FAE5)),
      Status.passive => (const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
