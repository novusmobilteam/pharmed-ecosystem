// lib/shared/widgets/organisms/kabin_mega_menu.dart
//
// [SWREQ-UI-NAV-KABIN-001]
// "Kabin Yönetimi" menü öğesine tıklandığında açılan mega menü paneli.
// Sol sidebar → kategori seçimi  |  Sağ → 2×2 kart grid + hızlı butonlar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// Dahili enum: sidebar kategorileri
// ─────────────────────────────────────────────────────────────────

enum _KabinCategory { dizayn, ariza, erisim, baglanti }

// ─────────────────────────────────────────────────────────────────
// KabinMegaMenu
// ─────────────────────────────────────────────────────────────────

class KabinMegaMenu extends StatefulWidget {
  const KabinMegaMenu({super.key, this.onCardTap, this.onQuickTap});

  /// Alt menü kartına tıklandığında — id: 'kabin_yapisi', 'cekmece_atamalari' vb.
  final void Function(String id)? onCardTap;

  /// Hızlı işlem butonuna tıklandığında — id: 'dizayn_kaydet', 'acil_ariza' vb.
  final void Function(String id)? onQuickTap;

  @override
  State<KabinMegaMenu> createState() => _KabinMegaMenuState();
}

class _KabinMegaMenuState extends State<KabinMegaMenu> {
  _KabinCategory _active = _KabinCategory.dizayn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 680,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: const BorderRadius.only(
          topRight: MedRadius.lg,
          bottomLeft: MedRadius.lg,
          bottomRight: MedRadius.lg,
        ),
        boxShadow: MedShadows.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Sidebar(active: _active, onSelect: (cat) => setState(() => _active = cat)),
            Expanded(
              child: _ContentPanel(category: _active, onCardTap: widget.onCardTap, onQuickTap: widget.onQuickTap),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _Sidebar
// ─────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.active, required this.onSelect});

  final _KabinCategory active;
  final void Function(_KabinCategory) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(right: BorderSide(color: MedColors.border2)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Text(
              'KATEGORİLER',
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: MedColors.text3,
              ),
            ),
          ),
          _SideItem(
            icon: Icons.table_chart_outlined,
            label: 'Kabin Dizayn',
            isActive: active == _KabinCategory.dizayn,
            onTap: () => onSelect(_KabinCategory.dizayn),
          ),
          _SideItem(
            icon: Icons.warning_amber_rounded,
            label: 'Arıza & Bakım',
            isActive: active == _KabinCategory.ariza,
            onTap: () => onSelect(_KabinCategory.ariza),
          ),
          _SideItem(
            icon: Icons.lock_outline_rounded,
            label: 'Erişim & Yetkiler',
            isActive: active == _KabinCategory.erisim,
            onTap: () => onSelect(_KabinCategory.erisim),
          ),
          _SideItem(
            icon: Icons.lan_outlined,
            label: 'Bağlantı & Ağ',
            isActive: active == _KabinCategory.baglanti,
            onTap: () => onSelect(_KabinCategory.baglanti),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: isActive ? MedColors.blue : Colors.transparent, borderRadius: MedRadius.mdAll),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.2) : MedColors.surface3,
                borderRadius: MedRadius.smAll,
              ),
              child: Icon(icon, size: 15, color: isActive ? Colors.white : MedColors.text3),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : MedColors.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _ContentPanel — aktif kategoriye göre panel gösterir
// ─────────────────────────────────────────────────────────────────

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({required this.category, this.onCardTap, this.onQuickTap});

  final _KabinCategory category;
  final void Function(String)? onCardTap;
  final void Function(String)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: switch (category) {
        _KabinCategory.dizayn => _DizaynPanel(onCardTap: onCardTap, onQuickTap: onQuickTap),
        _KabinCategory.ariza => _ArizaPanel(onCardTap: onCardTap, onQuickTap: onQuickTap),
        _KabinCategory.erisim => _ErisimPanel(onCardTap: onCardTap, onQuickTap: onQuickTap),
        _KabinCategory.baglanti => _BaglantiPanel(onCardTap: onCardTap, onQuickTap: onQuickTap),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _Panel — paylaşılan panel yapısı: başlık + 2×2 grid + hızlı butonlar
// ─────────────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.cards, this.quickActions = const []});

  final String title;
  final List<_CardData> cards;
  final List<Widget> quickActions;

  @override
  Widget build(BuildContext context) {
    assert(cards.length == 4, '_Panel her zaman 4 kart alır');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Başlık + yatay çizgi
        Row(
          children: [
            Text(title, style: MedTextStyles.titleSm()),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: MedColors.border2)),
          ],
        ),
        const SizedBox(height: 12),

        // 2×2 kart grid
        Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _SubCard(data: cards[0])),
                  const SizedBox(width: 8),
                  Expanded(child: _SubCard(data: cards[1])),
                ],
              ),
            ),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _SubCard(data: cards[2])),
                  const SizedBox(width: 8),
                  Expanded(child: _SubCard(data: cards[3])),
                ],
              ),
            ),
          ],
        ),

        // Hızlı butonlar
        if (quickActions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(height: 1, color: MedColors.border2),
          const SizedBox(height: 12),
          Row(children: quickActions),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _CardData — kart verisi (saf veri, callback dışarıdan)
// ─────────────────────────────────────────────────────────────────

class _CardData {
  const _CardData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.onTap,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final void Function(String)? onTap;
}

// ─────────────────────────────────────────────────────────────────
// _SubCard — alt menü kartı (hover animasyonlu)
// ─────────────────────────────────────────────────────────────────

class _SubCard extends StatefulWidget {
  const _SubCard({required this.data});

  final _CardData data;

  @override
  State<_SubCard> createState() => _SubCardState();
}

class _SubCardState extends State<_SubCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.data.onTap?.call(widget.data.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? MedColors.blueLight : MedColors.surface2,
            border: Border.all(color: _hovered ? MedColors.blue.withOpacity(0.3) : MedColors.border2),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _hovered ? MedColors.blue : widget.data.iconBg,
                  borderRadius: MedRadius.smAll,
                ),
                child: Icon(widget.data.icon, size: 18, color: _hovered ? Colors.white : widget.data.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data.name,
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _hovered ? MedColors.blue : MedColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.data.description,
                      style: MedTextStyles.bodySm(color: _hovered ? MedColors.text2 : MedColors.text3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _QuickBtn — hızlı işlem butonu
// ─────────────────────────────────────────────────────────────────

enum _QuickBtnVariant { normal, primary, danger }

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({required this.label, required this.icon, this.variant = _QuickBtnVariant.normal, this.onTap});

  final String label;
  final IconData icon;
  final _QuickBtnVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, borderColor, textColor) = switch (variant) {
      _QuickBtnVariant.normal => (MedColors.surface, MedColors.border, MedColors.text2),
      _QuickBtnVariant.primary => (MedColors.blue, MedColors.blue, Colors.white),
      _QuickBtnVariant.danger => (MedColors.red, MedColors.red, Colors.white),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
          borderRadius: MedRadius.mdAll,
          boxShadow: variant != _QuickBtnVariant.normal
              ? [BoxShadow(color: bg.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Panel implementasyonları (4 kategori)
// ═════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────
// Kabin Dizayn
// ─────────────────────────────────────────────────────────────────

class _DizaynPanel extends StatelessWidget {
  const _DizaynPanel({this.onCardTap, this.onQuickTap});

  final void Function(String)? onCardTap;
  final void Function(String)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'KABİN DİZAYN',
      cards: [
        _CardData(
          id: 'kabin_yapisi',
          name: 'Kabin Yapısı',
          description: 'Bölüm ve çekmece düzenini yapılandır',
          icon: Icons.view_column_outlined,
          iconColor: MedColors.blue,
          iconBg: MedColors.blueLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'cekmece_atamalari',
          name: 'Çekmece Atamaları',
          description: 'İlaç–çekmece eşleştirmelerini düzenle',
          icon: Icons.dns_outlined,
          iconColor: MedColors.blue,
          iconBg: MedColors.blueLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'kabin_ad_konum',
          name: 'Kabin Adı & Konum',
          description: 'Tanımlayıcı bilgileri güncelle',
          icon: Icons.settings_outlined,
          iconColor: MedColors.text2,
          iconBg: MedColors.surface3,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'sablon_uygula',
          name: 'Şablon Uygula',
          description: 'Hazır kabin konfigürasyonu yükle',
          icon: Icons.file_copy_outlined,
          iconColor: MedColors.green,
          iconBg: MedColors.greenLight,
          onTap: onCardTap,
        ),
      ],
      quickActions: [
        _QuickBtn(label: 'Önizle', icon: Icons.visibility_outlined, onTap: () => onQuickTap?.call('dizayn_onizle')),
        const SizedBox(width: 8),
        _QuickBtn(label: 'Sıfırla', icon: Icons.refresh_rounded, onTap: () => onQuickTap?.call('dizayn_sifirla')),
        const Spacer(),
        _QuickBtn(
          label: 'Kaydet',
          icon: Icons.check_rounded,
          variant: _QuickBtnVariant.primary,
          onTap: () => onQuickTap?.call('dizayn_kaydet'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Arıza & Bakım
// ─────────────────────────────────────────────────────────────────

class _ArizaPanel extends StatelessWidget {
  const _ArizaPanel({this.onCardTap, this.onQuickTap});

  final void Function(String)? onCardTap;
  final void Function(String)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'ARIZA & BAKIM',
      cards: [
        _CardData(
          id: 'ariza_bildir',
          name: 'Arıza Bildir',
          description: 'Yeni arıza kaydı oluştur ve öncelik ata',
          icon: Icons.report_problem_outlined,
          iconColor: MedColors.red,
          iconBg: MedColors.redLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'bakim_takvimi',
          name: 'Bakım Takvimi',
          description: 'Periyodik bakım planlaması ve takibi',
          icon: Icons.build_outlined,
          iconColor: MedColors.amber,
          iconBg: MedColors.amberLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'ariza_gecmisi',
          name: 'Arıza Geçmişi',
          description: 'Önceki kayıtları incele ve filtrele',
          icon: Icons.history_outlined,
          iconColor: MedColors.text2,
          iconBg: MedColors.surface3,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'sensor_testleri',
          name: 'Sensör Testleri',
          description: 'Kilit, sensör ve donanım tanılamaları',
          icon: Icons.sensors_outlined,
          iconColor: MedColors.green,
          iconBg: MedColors.greenLight,
          onTap: onCardTap,
        ),
      ],
      quickActions: [
        _QuickBtn(
          label: 'Acil Arıza Bildir',
          icon: Icons.warning_amber_rounded,
          variant: _QuickBtnVariant.danger,
          onTap: () => onQuickTap?.call('acil_ariza'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Erişim & Yetkiler
// ─────────────────────────────────────────────────────────────────

class _ErisimPanel extends StatelessWidget {
  const _ErisimPanel({this.onCardTap, this.onQuickTap});

  final void Function(String)? onCardTap;
  final void Function(String)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'ERİŞİM & YETKİLER',
      cards: [
        _CardData(
          id: 'kullanici_rolleri',
          name: 'Kullanıcı Rolleri',
          description: 'Hemşire, eczacı, yönetici yetki tanımla',
          icon: Icons.people_outline_rounded,
          iconColor: MedColors.blue,
          iconBg: MedColors.blueLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'erisim_yontemleri',
          name: 'Erişim Yöntemleri',
          description: 'PIN, kart, parmak izi yapılandır',
          icon: Icons.lock_outline_rounded,
          iconColor: MedColors.text2,
          iconBg: MedColors.surface3,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'oturum_politikasi',
          name: 'Oturum Politikası',
          description: 'Zaman aşımı ve kilit sürelerini ayarla',
          icon: Icons.access_time_rounded,
          iconColor: MedColors.amber,
          iconBg: MedColors.amberLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'denetim_kaydi',
          name: 'Denetim Kaydı',
          description: 'Tüm erişim log\'larını görüntüle ve dışa aktar',
          icon: Icons.security_outlined,
          iconColor: MedColors.green,
          iconBg: MedColors.greenLight,
          onTap: onCardTap,
        ),
      ],
      quickActions: [
        _QuickBtn(
          label: 'Kullanıcı Ekle',
          icon: Icons.person_add_outlined,
          variant: _QuickBtnVariant.primary,
          onTap: () => onQuickTap?.call('kullanici_ekle'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bağlantı & Ağ
// ─────────────────────────────────────────────────────────────────

class _BaglantiPanel extends StatelessWidget {
  const _BaglantiPanel({this.onCardTap, this.onQuickTap});

  final void Function(String)? onCardTap;
  final void Function(String)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'BAĞLANTI & AĞ',
      cards: [
        _CardData(
          id: 'ag_ayarlari',
          name: 'Ağ Ayarları',
          description: 'IP, Wi-Fi ve ağ yapılandırması',
          icon: Icons.wifi_outlined,
          iconColor: MedColors.green,
          iconBg: MedColors.greenLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'sunucu_baglantisi',
          name: 'Sunucu Bağlantısı',
          description: 'HIS/HBS entegrasyon durumunu kontrol et',
          icon: Icons.storage_outlined,
          iconColor: MedColors.blue,
          iconBg: MedColors.blueLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'yazilim_guncelleme',
          name: 'Yazılım Güncelleme',
          description: 'Firmware ve uygulama güncellemelerini yönet',
          icon: Icons.system_update_outlined,
          iconColor: MedColors.amber,
          iconBg: MedColors.amberLight,
          onTap: onCardTap,
        ),
        _CardData(
          id: 'baglanti_tanilama',
          name: 'Bağlantı Tanılaması',
          description: 'Ping, gecikme ve hata raporları',
          icon: Icons.monitor_heart_outlined,
          iconColor: MedColors.text2,
          iconBg: MedColors.surface3,
          onTap: onCardTap,
        ),
      ],
      quickActions: [
        _QuickBtn(
          label: 'Bağlantıyı Test Et',
          icon: Icons.network_check_rounded,
          onTap: () => onQuickTap?.call('baglanti_test'),
        ),
        const Spacer(),
        _QuickBtn(
          label: 'Yeniden Bağlan',
          icon: Icons.refresh_rounded,
          variant: _QuickBtnVariant.primary,
          onTap: () => onQuickTap?.call('yeniden_baglan'),
        ),
      ],
    );
  }
}
