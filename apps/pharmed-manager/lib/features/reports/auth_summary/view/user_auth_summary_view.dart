part of 'auth_summary_report_screen.dart';

class UserAuthSummaryView extends StatelessWidget {
  const UserAuthSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthSummaryReportNotifier>(
      builder: (context, notifier, _) {
        final auth = notifier.userAuth;
        return CustomDialog(
          title: 'Kullanıcı Yetki Özeti',
          maxHeight: 700,
          height: 700,
          isLoading: notifier.isLoading(notifier.fetchDetailOp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MenuColumn(
                  title: 'Rol Bazlı Yetkili Menüler',
                  icon: PhosphorIcons.shieldCheck(),
                  accent: MedColors.blue,
                  accentLight: MedColors.blueLight,
                  items: auth?.roleAuthorizations ?? const [],
                  emptyLabel: 'Rol bazlı yetki bulunmuyor',
                ),
              ),
              const SizedBox(width: MedSpacing.xl),
              Expanded(
                child: _MenuColumn(
                  title: 'Yetki Dışı Menüler',
                  icon: PhosphorIcons.plusCircle(),
                  accent: MedColors.amber,
                  accentLight: MedColors.amberLight,
                  items: auth?.extraAuthorizations ?? const [],
                  emptyLabel: 'Ek yetki bulunmuyor',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuColumn extends StatelessWidget {
  const _MenuColumn({
    required this.title,
    required this.icon,
    required this.accent,
    required this.accentLight,
    required this.items,
    required this.emptyLabel,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Color accentLight;
  final List<MenuItem> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Expanded(
            child: items.isEmpty
                ? _empty()
                : ListView.separated(
                    padding: MedSpacing.insetMd,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.xs),
                    itemBuilder: (context, index) => _MenuTile(name: items[index].name ?? '-', accent: accent),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
        border: const Border(bottom: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: MedSpacing.sm),
          Expanded(
            child: Text(title, style: MedTextStyles.titleSm().copyWith(color: MedColors.text)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: MedRadius.smAll,
              border: Border.all(color: MedColors.border),
            ),
            child: Text('${items.length}', style: MedTextStyles.monoSm().copyWith(color: accent)),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: MedSpacing.insetLg,
        child: Text(
          emptyLabel,
          textAlign: TextAlign.center,
          style: MedTextStyles.bodySm().copyWith(color: MedColors.text3),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.name, required this.accent});

  final String name;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              name,
              style: MedTextStyles.bodyMd().copyWith(color: MedColors.text2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
