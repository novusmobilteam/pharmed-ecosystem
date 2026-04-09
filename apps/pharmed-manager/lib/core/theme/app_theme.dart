import "package:flutter/material.dart";

class MaterialTheme {
  // --- MODERN DASHBOARD RENK PALETİ ---

  // Ana Renk (Primary): Modern, güven veren bir "Royal Blue"
  static const Color _primary = Color(0xFF2563EB);
  static const Color _onPrimary = Colors.white;

  // Arkaplanlar:
  // Dashboard'larda arka plan tam beyaz olmaz, çok hafif gri olur (Off-white).
  // Kartlar (Container) ise tam beyaz olur.
  static const Color _background = Color(0xFFF3F4F6); // Cool Gray 50
  static const Color _surface = Color(0xFFFFFFFF); // Saf Beyaz

  // Metin Renkleri (Slate Grileri):
  static const Color _textMain = Color(0xFF111827); // Neredeyse siyah
  static const Color _textBody = Color(0xFF374151); // Koyu gri

  // Çizgiler ve Kenarlıklar:
  static const Color _outline = Color(0xFFE5E7EB); // Çok hafif gri sınır

  // Hata:
  static const Color _error = Color(0xFFEF4444);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // ANA RENKLER
      primary: _primary,
      onPrimary: _onPrimary,
      primaryContainer: Color(0xFFDBEAFE), // Çok açık mavi
      onPrimaryContainer: Color(0xFF1E3A8A), // Çok koyu mavi
      // İKİNCİL RENKLER (Vurgular için)
      secondary: Color(0xFF64748B), // Slate Blue/Gray
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF1F5F9),
      onSecondaryContainer: Color(0xFF0F172A),

      // ZEMİN VE YÜZEYLER
      surface: _surface, // Kartlar, Paneller (BEYAZ)
      onSurface: _textMain, // Kart üzerindeki yazılar
      // Material 3'te 'surfaceContainerLow' genellikle Scaffold background için kullanılır
      surfaceContainerLow: _background,

      onSurfaceVariant: _textBody, // İkincil yazılar
      // HATA
      error: _error,
      onError: Colors.white,

      // ÇİZGİLER
      outline: _outline,
      outlineVariant: Color(0xFF9CA3AF),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1F2937),
      inversePrimary: Color(0xFF60A5FA),
    );
  }

  // Dark mod için "Slate" (Mavimsi Koyu Gri) tabanlı profesyonel bir görünüm
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      primary: Color(0xFF3B82F6), // Biraz daha parlak mavi
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFDBEAFE),

      secondary: Color(0xFF94A3B8),
      onSecondary: Color(0xFF0F172A),

      // Dark modda zemin tam siyah değil, koyu slate rengi olur
      surface: Color(0xFF1F2937), // Koyu Gri (Kartlar)
      onSurface: Color(0xFFF9FAFB), // Beyazımsı yazı

      surfaceContainerLow: Color(0xFF111827), // Daha koyu zemin (Background)

      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),

      outline: Color(0xFF374151),
      outlineVariant: Color(0xFF4B5563),
    );
  }

  ThemeData light() {
    return theme(lightScheme()).copyWith(
      // Scaffold rengini açık gri yapıyoruz ki beyaz kartlar öne çıksın
      scaffoldBackgroundColor: _background,
      dividerColor: _outline,
      dialogTheme: DialogThemeData(
        //barrierColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  ThemeData dark() {
    return theme(
      darkScheme(),
    ).copyWith(scaffoldBackgroundColor: const Color(0xFF111827), dividerColor: const Color(0xFF374151));
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,

    fontFamily: 'DM Sans',

    textTheme: TextTheme(
      // Başlıklar — Sora
      displayLarge: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800),
      displaySmall: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),

      // Gövde — DM Sans
      bodyLarge: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w500),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface, // Beyaz
      foregroundColor: colorScheme.onSurface, // Siyah Yazı/İkon
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: colorScheme.outline, width: 1)),

      iconTheme: IconThemeData(size: 24, color: colorScheme.onSurfaceVariant),
    ),

    // --- KART TEMASI ---
    // Kartlar beyaz, kenarlıksız ama hafif gölgeli veya ince kenarlıklı
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0, // Flat tasarım
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outline), // İnce gri çizgi
        borderRadius: BorderRadius.circular(12), // Modern köşe
      ),
    ),

    // --- INPUT (TEXTFIELD) TEMASI ---
    // Temiz, kutulu inputlar
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface, // İçi beyaz
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
      // Normal Durum
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      // Odaklanınca
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      // Hata
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
    ),

    // --- BUTON TEMASI ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // --- CHECKBOX TEMASI ---
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: colorScheme.outlineVariant, width: 2),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null; // Seçili değilse transparent (sadece border)
      }),
    ),
  );
}
