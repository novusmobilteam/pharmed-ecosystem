// Hangi opsiyonel hasta-seçim özelliklerinin açık olduğunu belirleyen
// immutable config. NotifierProvider.family'nin key'i olduğu için eşitlik
// (==) ÖNEMLİDİR — aynı ekranın aynı config'le her çağrılışı AYNI notifier
// instance'ını paylaşmalı.
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';

@immutable
class PatientSelectionConfig {
  const PatientSelectionConfig({
    this.showFilters = true,
    this.enableTabs = false,
    this.enableUrgentPatient = false,
    this.enableOrderlessToggle = false,
  });

  /// false → servis/durum/"Hastalarım" filtreleri hiç gösterilmez, liste
  /// her zaman GetActiveHospitalizationsUseCase (basit, filtresiz) ile
  /// çekilir.
  final bool showFilters;

  /// true → Reçeteler/Yönlendirilmiş Siparişler sekmesi gösterilir.
  final bool enableTabs;

  /// true → "Acil" segmenti + acil hasta oluşturma modu/sheet akışı aktif.
  final bool enableUrgentPatient;

  /// false → ordered/orderless toggle hiç gösterilmez, ekran sadece istasyon/
  /// hesaplanan varsayılan modda kalır (kullanıcı elle değiştiremez).
  /// true iken bile toggle'ın FİİLEN görünmesi state.isStatusToggleVisible'a
  /// (kullanıcının orderless yetkisi var mı) bağlıdır — config sadece üst
  /// bir kapatma anahtarı, mevcut yetki mantığını EZMEZ.
  final bool enableOrderlessToggle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientSelectionConfig &&
          runtimeType == other.runtimeType &&
          showFilters == other.showFilters &&
          enableTabs == other.enableTabs &&
          enableUrgentPatient == other.enableUrgentPatient &&
          enableOrderlessToggle == other.enableOrderlessToggle;

  @override
  int get hashCode => Object.hash(showFilters, enableTabs, enableUrgentPatient, enableOrderlessToggle);
}

abstract final class PatientSelectionConfigs {
  static const intake = PatientSelectionConfig(
    showFilters: true,
    enableTabs: true,
    enableUrgentPatient: true,
    enableOrderlessToggle: true,
  );
}
