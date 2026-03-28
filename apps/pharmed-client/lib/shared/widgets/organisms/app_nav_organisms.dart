// lib/shared/widgets/organisms/app_nav_organisms.dart
//
// SubNav, LockedBanner, SessionTimeoutBanner, LoginModal,
// QuickActionsGrid, AlertsList, ActivityFeed

import 'package:flutter/material.dart';
import '../../../features/dashboard/domain/model/app_model.dart';
import '../atoms/atoms.dart';
import 'kabin_mega_menu.dart';

// ═════════════════════════════════════════════════════════════════
// AppSubNav
// [SWREQ-UI-NAV-001]
// Alt navigasyon çubuğu. Giriş yapılmamışsa menüler kilitli görünür.
// 'cabin' id'li menü öğesi tıklandığında KabinMegaMenu overlay açar.
// ═════════════════════════════════════════════════════════════════

class AppSubNav extends StatefulWidget {
  const AppSubNav({
    super.key,
    required this.items,
    required this.isLoggedIn,
    required this.shiftLabel,
    this.onItemTap,
    this.onKabinCardTap,
    this.onKabinQuickTap,
  });

  final List<MenuItem> items;
  final bool isLoggedIn;

  /// Örn: "Gündüz · 07:00–19:00"
  final String shiftLabel;

  /// Normal menü öğesi tıklandığında
  final void Function(String id)? onItemTap;

  /// Kabin mega menüsünde kart seçildiğinde
  final void Function(String id)? onKabinCardTap;

  /// Kabin mega menüsünde hızlı buton tıklandığında
  final void Function(String id)? onKabinQuickTap;

  @override
  State<AppSubNav> createState() => _AppSubNavState();
}

class _AppSubNavState extends State<AppSubNav> {
  final _kabinKey = GlobalKey();
  OverlayEntry? _overlay;
  bool _kabinMenuOpen = false;

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  void _toggleKabinMenu() {
    if (_kabinMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final kabinCtx = _kabinKey.currentContext;
    if (kabinCtx == null) return;

    final kabinBox = kabinCtx.findRenderObject() as RenderBox;
    final kabinPos = kabinBox.localToGlobal(Offset.zero);

    setState(() => _kabinMenuOpen = true);

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Şeffaf bariyer — dışarıya tıklanınca kapatır
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          // Mega menü — nav öğesinin hemen altında konumlanır
          Positioned(
            top: kabinPos.dy + kabinBox.size.height + 2,
            left: kabinPos.dx,
            child: KabinMegaMenu(
              onCardTap: (id) {
                _closeMenu();
                widget.onKabinCardTap?.call(id);
              },
              onQuickTap: (id) {
                _closeMenu();
                widget.onKabinQuickTap?.call(id);
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _closeMenu() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _kabinMenuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          ...widget.items.map((item) {
            final locked = item.requiresAuth && !widget.isLoggedIn;

            if (item.id == 'cabin') {
              return KeyedSubtree(
                key: _kabinKey,
                child: _NavItem(
                  item: item,
                  isLocked: locked,
                  isMenuOpen: _kabinMenuOpen,
                  showChevron: true,
                  onTap: locked ? null : _toggleKabinMenu,
                ),
              );
            }

            return _NavItem(
              item: item,
              isLocked: locked,
              onTap: locked ? null : () => widget.onItemTap?.call(item.id),
            );
          }),
          const Spacer(),
          // Vardiya bilgisi
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 10),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: MedFonts.mono,
                  fontSize: 10,
                  color: MedColors.text3,
                ),
                children: [
                  const TextSpan(text: 'Vardiya: '),
                  TextSpan(
                    text: widget.shiftLabel,
                    style: const TextStyle(color: MedColors.amber),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isLocked,
    this.isMenuOpen = false,
    this.showChevron = false,
    this.onTap,
  });

  final MenuItem item;
  final bool isLocked;

  /// Mega menü açıkken aktif görünüm için
  final bool isMenuOpen;

  /// Chevron ok ikonu göster (mega menü tetikleyicileri için)
  final bool showChevron;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive || isMenuOpen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isLocked ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? MedColors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 12,
                color: isActive ? MedColors.blue : MedColors.text3,
              ),
              const SizedBox(width: 5),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? MedColors.blue : MedColors.text3,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isMenuOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: isActive ? MedColors.blue : MedColors.text3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// LockedBanner
// [SWREQ-UI-NAV-002]
// Oturum zaman aşımı sonrası gösterilir.
// ═════════════════════════════════════════════════════════════════

class LockedBanner extends StatelessWidget {
  const LockedBanner({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFEF9EC), Color(0xFFFFFDF7), Color(0xFFFEF9EC)]),
        border: Border(bottom: BorderSide(color: const Color(0xFFF5D79E))),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 14, color: MedColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: MedTextStyles.bodySm(color: MedColors.text2),
                children: [
                  TextSpan(
                    text: 'Oturumunuz ',
                    style: TextStyle(color: MedColors.text2),
                  ),
                  const TextSpan(
                    text: 'zaman aşımı',
                    style: TextStyle(color: MedColors.amber, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' nedeniyle kapatıldı. İşlem yapmak için giriş yapın.',
                    style: TextStyle(color: MedColors.text2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onLoginTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: MedColors.amber, borderRadius: MedRadius.smAll),
              child: Text(
                'Giriş Yap',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// SessionTimeoutBanner
// [SWREQ-UI-AUTH-002] [HAZ-009]
// Oturum dolmak üzere — sağ alt köşede floating banner.
// ═════════════════════════════════════════════════════════════════

class SessionTimeoutBanner extends StatelessWidget {
  const SessionTimeoutBanner({super.key, required this.secondsRemaining, required this.onExtend});

  final int secondsRemaining;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: const Color(0xFFF5D79E)),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 20, color: MedColors.amber),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Oturum süreniz dolmak üzere.',
                style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  style: MedTextStyles.bodySm(color: MedColors.text2),
                  children: [
                    const TextSpan(text: 'Oturumunuz '),
                    TextSpan(
                      text: '$secondsRemaining',
                      style: TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MedColors.red,
                      ),
                    ),
                    const TextSpan(text: ' saniye içinde kapanacak.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onExtend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
              child: Text(
                'Devam Et',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// LoginModal
// [SWREQ-UI-AUTH-003]
// Giriş formu. Dışarıya tıklayarak kapatılamaz.
// ═════════════════════════════════════════════════════════════════

class LoginModal extends StatefulWidget {
  const LoginModal({super.key, required this.cabinCode, required this.onLogin, required this.onCancel});

  final String cabinCode;

  /// username, password → hata mesajı veya null (başarılı)
  final String? Function(String username, String password) onLogin;
  final VoidCallback onCancel;

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final error = widget.onLogin(_userCtrl.text, _passCtrl.text);

    setState(() {
      _loading = false;
      _errorMessage = error;
    });

    if (error == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      backgroundColor: MedColors.surface,
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [MedColors.surface2, MedColors.surface],
                ),
                border: Border(bottom: BorderSide(color: MedColors.border2)),
                borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [MedColors.blue, Color(0xFF5BA3EC)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sisteme Giriş',
                        style: TextStyle(
                          fontFamily: MedFonts.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MedColors.text,
                        ),
                      ),
                      Text('MediCab HMI · Kabin #${widget.cabinCode}', style: MedTextStyles.monoXs()),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _FormField(
                    label: 'Kullanıcı Adı',
                    controller: _userCtrl,
                    placeholder: 'kullanici.adi',
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Şifre',
                    controller: _passCtrl,
                    placeholder: '••••••••',
                    obscure: true,
                    onSubmit: _submit,
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MedColors.redLight,
                        border: Border.all(color: const Color(0xFFF2B3AE)),
                        borderRadius: MedRadius.smAll,
                      ),
                      child: Text(_errorMessage!, style: MedTextStyles.bodySm(color: MedColors.red)),
                    ),
                  ],
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _loading ? MedColors.blue.withOpacity(0.6) : MedColors.blue,
                        borderRadius: MedRadius.mdAll,
                        boxShadow: const [BoxShadow(color: Color(0x4D1A6BD8), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 7),
                                Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontFamily: MedFonts.sans,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: MedColors.border),
                        borderRadius: MedRadius.mdAll,
                      ),
                      alignment: Alignment.center,
                      child: Text('İptal', style: MedTextStyles.bodySm(color: MedColors.text3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.onSubmit,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: MedColors.text2,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          onSubmitted: (_) => onSubmit?.call(),
          style: MedTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: MedTextStyles.bodyMd(color: MedColors.text4),
            filled: true,
            fillColor: MedColors.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MedColors.border, width: 1.5),
              borderRadius: MedRadius.smAll,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MedColors.blue, width: 1.5),
              borderRadius: MedRadius.smAll,
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// QuickActionsGrid
// [SWREQ-UI-QUICK-001]
// 2x2 hızlı işlem grid'i. Giriş gerekenler kilitli görünür.
// ═════════════════════════════════════════════════════════════════

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions, required this.isLoggedIn, this.onActionTap});

  final List<QuickAction> actions;
  final bool isLoggedIn;
  final void Function(String id)? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _WidgetHeader(title: 'HIZLI İŞLEMLER', dotColor: MedColors.amber),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: actions.map((action) {
                final locked = action.requiresAuth && !isLoggedIn;
                return _QuickActionButton(
                  action: action,
                  isLocked: locked,
                  onTap: locked ? null : () => onActionTap?.call(action.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.isLocked, this.onTap});

  final QuickAction action;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border, width: 1.5),
          borderRadius: MedRadius.mdAll,
        ),
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 18, color: MedColors.text3),
              const SizedBox(height: 6),
              Text(
                action.label.toUpperCase(),
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: MedColors.text3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// AlertsList
// [SWREQ-UI-ALERT-001] [HAZ-008]
// Kritik/uyarı/bilgi tipi uyarılar listesi.
// ═════════════════════════════════════════════════════════════════

class AlertsList extends StatelessWidget {
  const AlertsList({super.key, required this.alerts});

  final List<AlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    final criticalCount = alerts.where((a) => a.severity == AlertSeverity.critical).length;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _WidgetHeader(
            title: 'UYARILAR',
            dotColor: MedColors.red,
            badge: MedBadge(label: '$criticalCount kritik', variant: MedBadgeVariant.red),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: alerts.map((a) => _AlertRow(item: a)).toList()),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.item});

  final AlertItem item;

  @override
  Widget build(BuildContext context) {
    final (bg, border, iconColor) = switch (item.severity) {
      AlertSeverity.critical => (MedColors.redLight, const Color(0xFFF2B3AE), MedColors.red),
      AlertSeverity.warning => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
      AlertSeverity.info => (MedColors.blueLight, const Color(0xFFC4D9F5), MedColors.blue),
    };

    final icon = switch (item.severity) {
      AlertSeverity.critical => Icons.warning_amber_rounded,
      AlertSeverity.warning => Icons.info_outline_rounded,
      AlertSeverity.info => Icons.info_outline_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.message, style: MedTextStyles.bodySm(color: MedColors.text)),
                if (item.detail != null) ...[
                  const SizedBox(height: 2),
                  MedLabel(text: item.detail!, variant: MedLabelVariant.monoDetail),
                ],
                const SizedBox(height: 2),
                MedLabel(text: item.time, variant: MedLabelVariant.monoDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// ActivityFeed
// [SWREQ-UI-ACT-001]
// Son aktiviteler zaman çizelgesi.
// ═════════════════════════════════════════════════════════════════

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _WidgetHeader(
            title: 'SON AKTİVİTELER',
            dotColor: MedColors.green,
            badge: const MedBadge(label: 'Canlı', variant: MedBadgeVariant.green),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (int i = 0; i < activities.length; i++)
                  _ActivityRow(item: activities[i], isLast: i == activities.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.isLast});

  final ActivityItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (dotBg, dotBorder, dotColor) = switch (item.type) {
      ActivityType.distribution => (MedColors.greenLight, const Color(0xFFB5DDD4), MedColors.green),
      ActivityType.cabinOpen => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
      ActivityType.prescription => (MedColors.blueLight, const Color(0xFFC4D9F5), MedColors.blue),
      ActivityType.return_ => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
      ActivityType.fill => (MedColors.greenLight, const Color(0xFFB5DDD4), MedColors.green),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dotBg,
                    border: Border.all(color: dotBorder),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconFor(item.type), size: 8, color: dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(child: Container(width: 1, color: MedColors.border2)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.message, style: MedTextStyles.bodySm(color: MedColors.text)),
                  const SizedBox(height: 1),
                  MedLabel(text: item.meta, variant: MedLabelVariant.monoDetail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ActivityType type) => switch (type) {
    ActivityType.distribution => Icons.check_rounded,
    ActivityType.cabinOpen => Icons.lock_open_rounded,
    ActivityType.prescription => Icons.add,
    ActivityType.return_ => Icons.replay_rounded,
    ActivityType.fill => Icons.inventory_2_outlined,
  };
}

// ─────────────────────────────────────────────────────────────────
// _WidgetHeader — paylaşılan header (bu dosya içinde)
// ─────────────────────────────────────────────────────────────────

class _WidgetHeader extends StatelessWidget {
  const _WidgetHeader({required this.title, required this.dotColor, this.badge});

  final String title;
  final Color dotColor;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
      ),
      child: Row(
        children: [
          StatusDot(color: dotColor, size: 7),
          const SizedBox(width: 7),
          Text(title, style: MedTextStyles.titleSm()),
          if (badge != null) ...[const Spacer(), badge!],
        ],
      ),
    );
  }
}
