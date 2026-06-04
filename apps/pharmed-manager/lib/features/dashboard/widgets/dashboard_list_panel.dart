import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard.dart';

// [SWREQ-MGR-DASH-009]
// Dashboard kompakt liste panelleri için ortak kabuk.
// Başlık + sayı + stale rozeti + loading/error/empty/list durumları.
// Sınıf: Class A
class DashboardListPanel<T> extends StatelessWidget {
  const DashboardListPanel({
    super.key,
    required this.title,
    required this.count,
    required this.countColor,
    required this.countBg,
    required this.section,
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyTitle,
    this.onRetry,
  });

  final String title;
  final int count;
  final Color countColor;
  final Color countBg;
  final DashboardSection<T> section;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final String emptyTitle;
  final VoidCallback? onRetry;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: MedSpacing.insetXl,
            decoration: BoxDecoration(
              color: countColor,
              borderRadius: BorderRadius.only(topLeft: MedRadius.lgAll.topLeft, topRight: MedRadius.lgAll.topRight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: MedTextStyles.titleSm().copyWith(letterSpacing: 0.5, color: MedColors.surface)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: MedColors.surface, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '$count',
                    style: MedTextStyles.monoMd(color: countColor, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(padding: MedSpacing.insetSm, child: _buildBody(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (section.isInitialLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (section.showError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              section.error ?? 'Yüklenemedi',
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: MedButton(
                  label: 'Tekrar Dene',
                  size: MedButtonSize.sm,
                  variant: MedButtonVariant.secondary,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      );
    }
    if (itemCount == 0) {
      return EmptyStateWidget(variant: EmptyStateVariant.noData, size: EmptyStateSize.compact);
    }
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: itemBuilder,
    );
  }
}
