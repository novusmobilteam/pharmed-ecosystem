import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// MedColors — Tüm renk sabitleri
// Hiçbir widget bu dosya dışında renk tanımlamaz.
// ─────────────────────────────────────────────────────────────────
abstract final class MedColors {
  // Surface
  static const Color bg = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF7F9FC);
  static const Color surface3 = Color(0xFFF0F3F8);

  // Border
  static const Color border = Color(0xFFDDE3EC);
  static const Color border2 = Color(0xFFE8ECF3);

  // Semantic — ana ton
  static const Color blue = Color(0xFF1A6FD8);
  static const Color blueLight = Color(0xFFE8F1FC);
  static const Color green = Color(0xFF0D9E6C);
  static const Color greenLight = Color(0xFFE6F7F2);
  static const Color amber = Color(0xFFD97006);
  static const Color purple = Color(0xFF340068);
  static const Color amberLight = Color(0xFFFEF3E2);
  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redDark = Color(0xFF991B1B);

  // Text
  static const Color text = Color(0xFF1A2332);
  static const Color text2 = Color(0xFF3D4F66);
  static const Color text3 = Color(0xFF7A8FA8);
  static const Color text4 = Color(0xFFB0BFCC);

  // LED renkleri (native CSS'ten türetildi)
  static const Color ledGreen = Color(0xFF22C55E);
  static const Color ledAmber = Color(0xFFF59E0B);
  static const Color ledRed = Color(0xFFEF4444);

  // ── Gölge overlay'leri ──────────────────────────────────────────
  /// Genel koyu gölge — kutu gölgeleri için temel renk.
  static const Color shadowDark = Color(0x1F1E3259);

  /// Mavi tonlu gölge — input focus halkası ve mavi buton gölgesi.
  static const Color shadowBlue = Color(0x1F1A6FD8);

  /// Kırmızı tonlu gölge — hata durumu input gölgesi.
  static const Color shadowRed = Color(0x1FDC2626);

  /// Mavi baskı overlay'i — birincil ve ikon butonlar üzerinde.
  static const Color overlayBlue = Color(0x4D1A6FD8);

  /// Kırmızı baskı overlay'i — tehlikeli aksiyon butonları üzerinde.
  static const Color overlayRed = Color(0x4DDC2626);

  /// Yeşil baskı overlay'i — başarı durumu butonları üzerinde.
  static const Color overlayGreen = Color(0x4D0D9E6C);

  // ── Mavi skalası ────────────────────────────────────────────────
  /// Koyu mavi — kabin metin etiketleri ve başlık vurguları.
  static const Color blueDark = Color(0xFF1256AA);

  /// Açık mavi 2 — gradient başlangıçları ve hover arka planları.
  static const Color blueLight2 = Color(0xFF5BA3EC);

  /// Orta mavi — kenarlık vurgusu ve odak halkası dolgusu.
  static const Color blueMid = Color(0xFFC4D9F5);

  // ── Amber skalası ───────────────────────────────────────────────
  /// Amber kenarlık — SessionTimeoutBanner ve uyarı banner kenarlığı.
  static const Color amberBorder = Color(0xFFF5D79E);

  /// Güçlü amber — yüksek kontrast uyarı vurguları.
  static const Color amberStrong = Color(0xFFFCD34D);

  // ── Kabin renkleri ──────────────────────────────────────────────
  /// Kabin konteyner arka planı — master ve mobil kabin dış kutusu.
  static const Color cabinBg = Color(0xFFDCE8F5);

  /// Kabin konteyner kenarlığı.
  static const Color cabinBorder = Color(0xFFA8BEDB);

  /// Kabin iç panel arka planı — genel panel zemin.
  static const Color cabinInner = Color(0xFFD8E0EC);

  /// Kabin başlık gradienti başlangıç rengi.
  static const Color cabinGradient1 = Color(0xFFC4CEDF);

  /// Kabin başlık gradienti bitiş rengi.
  static const Color cabinGradient2 = Color(0xFFB4C0D4);

  // ── Nötr / UI yapısal renkler ───────────────────────────────────
  /// Side panel kenarlık rengi — SidePanel ve benzeri kayan paneller.
  static const Color uiBorder = Color(0xFFDDE3EC);

  /// Side panel başlık arka planı — gradient başlangıcı.
  static const Color uiPanelBg = Color(0xFFF4F7FF);

  /// Tablo satır ayraç rengi — UnifiedTableView iç divider.
  static const Color tableDivider = Color(0xFFEEF0F4);
}

// ─────────────────────────────────────────────────────────────────
// MedFonts — Tipografi sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedFonts {
  /// Başlık, büyük sayısal değer (KPI, istatistik)
  static const String title = 'Sora';

  /// Genel UI metni
  static const String sans = 'DM Sans';

  /// Teknik değer: ID, tarih, lot no, badge içi
  static const String mono = 'JetBrains Mono';
}

// ─────────────────────────────────────────────────────────────────
// MedRadius — Border radius sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedRadius {
  /// 3px — kabin hücreleri ve çok küçük elementler.
  static const Radius xs = Radius.circular(3);

  /// 4px — manager input alanları, sıkı yerleşim elementleri.
  static const Radius sm = Radius.circular(5);

  /// 8px — butonlar, input alanları, kart köşeleri (genel).
  static const Radius md = Radius.circular(8);

  /// 10px — segmented control, sayısal stepper, orta kartlar.
  static const Radius mid = Radius.circular(10);

  /// 12px — büyük kartlar, organism konteynerler.
  static const Radius lg = Radius.circular(12);

  /// 16px — dialog ve modal köşeleri.
  static const Radius xl2 = Radius.circular(16);

  /// 20px — badge ve chip (tam oval görünüm).
  static const Radius xl = Radius.circular(20);

  /// 24px — numpad dialog ve büyük kayan paneller.
  static const Radius xl3 = Radius.circular(24);

  static const BorderRadius xsAll = BorderRadius.all(xs);
  static const BorderRadius smAll = BorderRadius.all(sm);
  static const BorderRadius mdAll = BorderRadius.all(md);
  static const BorderRadius midAll = BorderRadius.all(mid);
  static const BorderRadius lgAll = BorderRadius.all(lg);
  static const BorderRadius xl2All = BorderRadius.all(xl2);
  static const BorderRadius xlAll = BorderRadius.all(xl);
  static const BorderRadius xl3All = BorderRadius.all(xl3);
}

// ─────────────────────────────────────────────────────────────────
// MedShadows — Gölge sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedShadows {
  /// Hafif gölge — kart, chip ve küçük yükseltilmiş elementler.
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x121E3259), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1E3259), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Orta gölge — modal, panel ve ana kart elementleri.
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x171E3259), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A1E3259), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// Yan panel gölgesi — soldan açılan SidePanel ve overlay paneller.
  static const List<BoxShadow> side = [
    BoxShadow(color: Color(0x140F192D), blurRadius: 24, offset: Offset(-4, 0)),
    BoxShadow(color: Color(0x0A0F192D), blurRadius: 6, offset: Offset(-1, 0)),
  ];
}

// ─────────────────────────────────────────────────────────────────
// MedTextStyles — TextStyle fabrikası
// ─────────────────────────────────────────────────────────────────
abstract final class MedTextStyles {
  // Title ailesi
  static TextStyle titleXl({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleLg({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleMd({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleSm({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: color ?? MedColors.text2,
  );

  // Sans ailesi
  static TextStyle bodyMd({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.sans,
    fontSize: 12,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? MedColors.text,
  );

  static TextStyle bodyLg({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.sans,
    fontSize: 14,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? MedColors.text,
  );

  static TextStyle bodySm({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.sans,
    fontSize: 11,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? MedColors.text2,
  );

  // Mono ailesi
  static TextStyle monoMd({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.mono,
    fontSize: 11,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? MedColors.text2,
  );

  static TextStyle monoSm({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.mono,
    fontSize: 10,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? MedColors.text3,
  );

  static TextStyle monoXs({Color? color}) =>
      TextStyle(fontFamily: MedFonts.mono, fontSize: 9, fontWeight: FontWeight.w400, color: color ?? MedColors.text3);

  static TextStyle numericMd({Color? color}) =>
      TextStyle(fontFamily: MedFonts.sans, fontSize: 14, fontWeight: FontWeight.w600, color: color ?? MedColors.text2);

  /// Sayısal gösterim — stepper değeri, doz miktarı (18px).
  static TextStyle numericLg({Color? color}) =>
      TextStyle(fontFamily: MedFonts.sans, fontSize: 18, fontWeight: FontWeight.w600, color: color ?? MedColors.text);

  /// Büyük sayısal gösterim — numpad değer ekranı (22px).
  static TextStyle numericXl({Color? color}) =>
      TextStyle(fontFamily: MedFonts.sans, fontSize: 22, fontWeight: FontWeight.w600, color: color ?? MedColors.text);
}

// ─────────────────────────────────────────────────────────────────
// MedSpacing — Boşluk ve boyut sabitleri
// Tüm padding, margin, gap ve boyut değerleri buradan gelir.
// ─────────────────────────────────────────────────────────────────
abstract final class MedSpacing {
  // ── Temel ölçek (4pt grid) ──────────────────────────────────────
  /// 4px — en sıkı iç boşluk (chip, ikon butonu).
  static const double xs = 4.0;

  /// 6px — yakın elementler arası boşluk (chip runSpacing).
  static const double sm = 6.0;

  /// 8px — standart iç boşluk ve element arası gap.
  static const double md = 8.0;

  /// 12px — orta iç boşluk ve kart içi gap.
  static const double lg = 12.0;

  /// 16px — büyük iç boşluk ve sayfa kenar boşluğu.
  static const double xl = 16.0;

  /// 20px — geniş alan iç boşluğu (kabin paneli padding).
  static const double xl2 = 20.0;

  /// 24px — sayfa padding ve dialog iç boşluğu.
  static const double xl3 = 24.0;

  /// 32px — büyük boşluk (başarı ekranı, wizard alanları).
  static const double xl4 = 32.0;

  // ── Semantik EdgeInsets kısayolları ────────────────────────────
  /// Tüm kenarlardan 4px.
  static const EdgeInsets insetXs = EdgeInsets.all(xs);

  /// Tüm kenarlardan 6px.
  static const EdgeInsets insetSm = EdgeInsets.all(sm);

  /// Tüm kenarlardan 8px.
  static const EdgeInsets insetMd = EdgeInsets.all(md);

  /// Tüm kenarlardan 12px.
  static const EdgeInsets insetLg = EdgeInsets.all(lg);

  /// Tüm kenarlardan 16px.
  static const EdgeInsets insetXl = EdgeInsets.all(xl);

  // ── Input alanı özel değerleri ──────────────────────────────────
  /// Manager input padding — sıkı, fare dostu yerleşim.
  static const EdgeInsets inputPaddingManager = EdgeInsets.symmetric(horizontal: 9);

  /// Client input padding — geniş, dokunmatik dostu yerleşim.
  static const EdgeInsets inputPaddingClient = EdgeInsets.symmetric(horizontal: 14);

  /// Manager input minimum yüksekliği.
  static const double inputMinHeightManager = 44.0;

  /// Client input minimum yüksekliği — dokunmatik hedef boyutu.
  static const double inputMinHeightClient = 44.0;

  // ── Label tipografi değerleri ───────────────────────────────────
  /// Manager label font boyutu — sıkı mono etiket.
  static const double labelFontSizeManager = 9.0;

  /// Client label font boyutu — geniş Sora etiket.
  static const double labelFontSizeClient = 11.0;

  /// Manager label harf aralığı.
  static const double labelLetterSpacingManager = 0.8;

  /// Client label harf aralığı.
  static const double labelLetterSpacingClient = 0.5;

  // ── Dokunma hedefi boyutları ────────────────────────────────────
  /// Minimum dokunma hedefi — WCAG 2.5.5 ve iOS/Android rehberi.
  static const double touchTarget = 44.0;

  /// Stepper buton boyutu — MedNumericStepper +/- düğmeleri.
  static const double stepperButton = 48.0;

  // ── Chip / badge padding ────────────────────────────────────────
  /// Küçük chip iç boşluğu — DoseChip, TimeChip.
  static const EdgeInsets chipPaddingSm = EdgeInsets.symmetric(horizontal: 6, vertical: 3);

  /// Orta chip iç boşluğu — MedInfoChip, MedBadge.
  static const EdgeInsets chipPaddingMd = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  /// Büyük chip iç boşluğu — RxStatusChip, MedBadge large.
  static const EdgeInsets chipPaddingLg = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

  static const EdgeInsets panelInsetPadding = EdgeInsets.all(xl);
}

abstract final class MedDecoration {
  static const BoxDecoration panelDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: MedRadius.lgAll,
    boxShadow: MedShadows.md,
  );
}
