import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconSize = 72, // Biraz daha büyük ve ferah
    this.messageStyle,
    this.subMessageStyle,
  });

  final IconData icon;
  final String message;
  final String? subMessage;
  final double iconSize;
  final TextStyle? messageStyle;
  final TextStyle? subMessageStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          Text(
            message,
            style: messageStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant, // Koyu gri tonu
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null)
            Text(
              subMessage!,
              style: subMessageStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    // Ana mesajdan daha silik
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5, // Satır arası boşluk okunabilirliği artırır
                  ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// Önceden tanımlanmış common empty state'ler
class CommonEmptyStates {
  static EmptyStateWidget drugType() => EmptyStateWidget(
        icon: PhosphorIcons.pill(),
        message: 'Henüz ilaç tipi bulunmuyor',
        subMessage: 'Yeni ilaç tipi eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget drugClass() => EmptyStateWidget(
        icon: PhosphorIcons.treeStructure(),
        message: 'Henüz ilaç sınıfı bulunmuyor',
        subMessage: 'Yeni ilaç sınıfı eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget kit() => EmptyStateWidget(
        icon: PhosphorIcons.firstAidKit(),
        message: 'Henüz kit bulunmuyor',
        subMessage: 'Yeni kit eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget kitContent() => EmptyStateWidget(
        icon: PhosphorIcons.package(),
        message: 'Henüz kit içeriği bulunmuyor',
        subMessage: 'Yeni içerik eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget branch() => EmptyStateWidget(
        icon: PhosphorIcons.briefcase(),
        message: 'Henüz branş bulunmuyor',
        subMessage: 'Yeni branş eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget patient() => EmptyStateWidget(
        icon: PhosphorIcons.user(),
        message: 'Henüz hasta kaydı bulunmuyor',
        subMessage: 'Yeni hasta kaydı eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget prescription() => EmptyStateWidget(
        icon: PhosphorIcons.receipt(),
        message: 'Kayıtlı reçete bulunamadı',
        subMessage: 'Yeni reçete oluşturmak için "+" butonuna tıklayın',
      );

  static EmptyStateWidget medicalConsumable() => EmptyStateWidget(
        icon: PhosphorIcons.thermometer(),
        message: 'Henüz tıbbi sarf bulunmuyor',
        subMessage: 'Yeni tıbbi sarf eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget drug() => EmptyStateWidget(
        icon: PhosphorIcons.pill(),
        message: 'Henüz ilaç bulunmuyor',
        subMessage: 'Yeni ilaç eklemek için "+" butonuna tıklayın',
      );

  static EmptyStateWidget searchNotFound() => EmptyStateWidget(
        icon: PhosphorIcons.magnifyingGlass(),
        message: 'Arama sonucu bulunamadı',
        subMessage: 'Farklı bir anahtar kelime deneyin veya filtreleri temizleyin',
      );

  static EmptyStateWidget dateRange() => EmptyStateWidget(
        icon: PhosphorIcons.calendarX(), // Calendar X daha uygun olabilir
        message: 'Kayıt bulunamadı',
        subMessage: 'Belirtilen tarih aralıklarında veri bulunamadı.',
      );

  static EmptyStateWidget error({String? message}) => EmptyStateWidget(
        icon: PhosphorIcons.warningCircle(),
        message: message ?? 'Bir hata oluştu',
        subMessage: 'Lütfen tekrar deneyin veya sistem yöneticinize başvurun',
      );

  static EmptyStateWidget noData() => EmptyStateWidget(
        icon: PhosphorIcons.clipboardText(),
        message: 'Veri bulunamadı',
        subMessage: 'Liste şu anda boş',
      );

  static EmptyStateWidget networkError() => EmptyStateWidget(
        icon: PhosphorIcons.wifiSlash(),
        message: 'İnternet bağlantısı yok',
        subMessage: 'Lütfen bağlantınızı kontrol edip tekrar deneyin',
      );

  static EmptyStateWidget serverError() => EmptyStateWidget(
        icon: PhosphorIcons.cloudSlash(),
        message: 'Sunucu hatası',
        subMessage: 'Sunucuya erişilemiyor, lütfen daha sonra tekrar deneyin',
      );

  static EmptyStateWidget notFound() => EmptyStateWidget(
        icon: PhosphorIcons.magnifyingGlass(),
        message: 'Kayıt bulunamadı',
        subMessage: 'Aradığınız kritere uygun kayıt mevcut değil',
      );

  static EmptyStateWidget noPatient() => EmptyStateWidget(
        icon: PhosphorIcons.userFocus(),
        message: 'Hasta seçilmedi',
        subMessage: 'İşlem yapmak için lütfen "+" butonunu kullanarak hasta seçiniz',
      );

  static EmptyStateWidget noCabin() => EmptyStateWidget(
        icon: PhosphorIcons.dresser(),
        message: 'Tanımlı kabin bulunamadı.',
        subMessage: 'İşleminize devam edebilmeniz için kabin tanımlamanız gerekmektedir.',
      );

  // Generic empty state
  static EmptyStateWidget generic({
    required IconData icon,
    required String message,
    String? subMessage,
    double iconSize = 72,
    TextStyle? messageStyle,
    TextStyle? subMessageStyle,
  }) =>
      EmptyStateWidget(
        icon: icon,
        message: message,
        subMessage: subMessage,
        iconSize: iconSize,
        messageStyle: messageStyle,
        subMessageStyle: subMessageStyle,
      );
}
