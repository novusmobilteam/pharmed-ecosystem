import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Kabin işlem ekranlarının sağ panelinde aktif sürecin hangi hasta
/// için yürütüldüğünü gösteren kart bileşeni.
///
/// [OperationPanelBase] içinde kullanılmak üzere tasarlanmıştır.
/// İlaç alım, ilaç iade, dolum gibi hasta odaklı kabin işlemlerinde
/// işlem öznesi olan hastayı özetler.
///
/// ## Değiştirilebilirlik
///
/// [onChange] callback'inin null olup olmaması kartın davranışını belirler:
///
/// - `onChange != null` — süreç henüz başlamamış; sağ üstte hasta değiştirme
///   butonu ([PhosphorIcons.userSwitch]) görünür.
/// - `onChange == null` — süreç aktif veya kilitli; buton gizlenir,
///   kart salt okunur hale gelir.
///
/// ## Örnek — değiştirilebilir hasta
///
/// ```dart
/// CabinActivePatientCard(
///   patient: state.patient,
///   room: state.room,
///   bed: state.bed,
///   onChange: () => notifier.onChangePatient(),
/// )
/// ```
///
/// ## Örnek — kilitli (süreç aktif)
///
/// ```dart
/// CabinActivePatientCard(
///   patient: state.patient,
///   room: state.room,
///   bed: state.bed,
///   onChange: null,
/// )
/// ```
///
/// ## Konum satırı davranışı
///
/// [room] ve [bed] ayrı ayrı null kontrolünden geçer.
/// İkisinden en az biri non-null olduğunda `·` ayracıyla birleştirilerek
/// konum satırı gösterilir. Her ikisi de null ise satır tamamen gizlenir.
///
/// ## Tasarım notları
///
/// - Avatar boyutu: `40×40`, zemin [MedColors.blueLight], metin [MedColors.blue]
/// - Değiştir butonunun minimum dokunmatik hedefi: `36×36`
///   ([HMI dokunmatik ekran kuralı](pharmed_design_system))
/// - Widget seçim diyaloğunu veya navigasyonu tetiklemez;
///   bu kararı [onChange] callback'i taşır.
class CabinActivePatientCard extends StatelessWidget {
  const CabinActivePatientCard({super.key, required this.patient, this.bed, this.room, this.onChange});

  /// İşlem öznesi olan hasta. Her zaman zorunludur.
  final Patient patient;

  /// Hastanın atandığı yatak.
  ///
  /// Null ise yalnızca [room] adı gösterilir; her ikisi de null ise
  /// konum satırı tamamen gizlenir.
  final Bed? bed;

  /// Hastanın bulunduğu oda.
  ///
  /// Null ise yalnızca [bed] adı gösterilir; her ikisi de null ise
  /// konum satırı tamamen gizlenir.
  final Room? room;

  /// Hasta değiştirme butonu için callback.
  ///
  /// `null` verildiğinde buton gizlenir ve kart salt okunur olur.
  /// Non-null olduğunda [PhosphorIcons.userSwitch] butonu görünür hale gelir.
  final VoidCallback? onChange;

  /// [patient.fullName] baş harflerinden avatar monogramı üretir.
  ///
  /// Tek kelimeli isimde yalnızca ilk harf, çok kelimeli isimde
  /// ilk ve son kelimenin baş harfleri büyük harfle döndürülür.
  String get _initials {
    final parts = patient.fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// [room] ve [bed] alanlarını `·` ayracıyla birleştirir.
  ///
  /// Her ikisi de null ise `null` döner ve konum satırı gizlenir.
  String? get _location {
    final parts = [if (room?.name != null) room!.name!, if (bed?.name != null) bed!.name!];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            MedAvatar(initials: _initials, palette: AvatarPalette.blue, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: _PatientInfo(fullName: patient.fullName, location: _location),
            ),
            if (onChange != null) _ChangeButton(onTap: onChange!),
          ],
        ),
      ),
    );
  }
}

class _PatientInfo extends StatelessWidget {
  const _PatientInfo({required this.fullName, this.location});

  final String fullName;

  /// Null ise konum satırı gösterilmez.
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fullName, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
        if (location != null) Text(location!, style: MedTextStyles.monoMd(color: MedColors.text3)),
      ],
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MedRectangleIconButton(
        color: MedColors.surface2,
        iconColor: MedColors.text2,
        iconData: PhosphorIcons.userSwitch(),
      ),
    );
  }
}
