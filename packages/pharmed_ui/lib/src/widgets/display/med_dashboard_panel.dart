import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// [SWREQ-MGR-DASH-009]
// Dashboard kompakt liste panelleri için ortak kabuk.
// Başlık + sayı + stale rozeti + loading/error/empty/list durumları.
// Sınıf: Class A
class MedDashboardPanel<T> extends StatelessWidget {
  const MedDashboardPanel({
    super.key,
    required this.title,
    required this.section,
    required this.itemCount,
    required this.itemBuilder,
    this.onRetry,
    this.useCarousel = false,
  });

  final String title;
  final DashboardSection<T> section;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback? onRetry;

  /// true → kartlar yatay PageView (tek kart + ok butonları).
  /// false → dikey ListView (varsayılan).
  final bool useCarousel;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: MedSpacing.insetXl,
            decoration: const BoxDecoration(
              color: MedColors.surface2,
              border: Border(bottom: BorderSide(color: MedColors.border2)),
              borderRadius: BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
            ),
            child: Text(title, style: MedTextStyles.titleSm()),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.right, vertical: MedSpacing.insetXl.top),
              child: _buildBody(context),
            ),
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
              section.error ?? context.l10n.dashboardListPanelLoadErrorFallback,
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: MedButton(
                  label: context.l10n.common_retryButton,
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

    if (useCarousel) {
      return _CarouselBody(itemCount: itemCount, itemBuilder: itemBuilder);
    }

    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: itemBuilder,
    );
  }
}

class _CarouselBody extends StatefulWidget {
  const _CarouselBody({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<_CarouselBody> createState() => _CarouselBodyState();
}

class _CarouselBodyState extends State<_CarouselBody> {
  static const _autoInterval = Duration(seconds: 8);

  final _controller = PageController();
  int _page = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(_CarouselBody old) {
    super.didUpdateWidget(old);
    // itemCount değişince (yenileme) timer'ı tazele; tek/sıfır kartta gereksiz
    if (old.itemCount != widget.itemCount) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    if (widget.itemCount < 2) return; // tek kart varsa otomatik geçiş anlamsız
    _autoTimer = Timer.periodic(_autoInterval, (_) => _autoAdvance());
  }

  void _autoAdvance() {
    if (!mounted || widget.itemCount < 2) return;
    final next = (_page + 1) % widget.itemCount; // döngüsel
    _animateTo(next);
  }

  /// Manuel geçiş — timer'ı sıfırdan başlatır (geçici durdurup yeniden sayar).
  void _manualGoTo(int page) {
    if (page < 0 || page >= widget.itemCount) return;
    _animateTo(page);
    _startAutoScroll(); // reset
  }

  void _animateTo(int page) {
    _controller.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final current = _page.clamp(0, widget.itemCount - 1);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.itemCount,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: widget.itemBuilder(context, index),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              enabled: widget.itemCount > 1,
              onTap: () => _manualGoTo((current - 1 + widget.itemCount) % widget.itemCount),
            ),
            const SizedBox(width: 12),
            Text('${current + 1} / ${widget.itemCount}', style: MedTextStyles.monoXs(color: MedColors.text3)),
            const SizedBox(width: 12),
            _ArrowButton(
              icon: PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              enabled: widget.itemCount > 1,
              onTap: () => _manualGoTo((current + 1) % widget.itemCount),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: MedRadius.mdAll,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? MedColors.surface2 : Colors.transparent,
          border: Border.all(color: MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Icon(icon, size: 14, color: enabled ? MedColors.text2 : MedColors.text4),
      ),
    );
  }
}
