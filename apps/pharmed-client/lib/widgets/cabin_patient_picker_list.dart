import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Kabin işlem ekranlarında hasta seçimi için kullanılan arama destekli
/// liste bileşeni.
///
/// [CabinActivePatientCard] üzerindeki değiştir butonu tetiklendiğinde
/// gösterilmek üzere tasarlanmıştır. İlaç alım, ilaç iade ve fire/imha
/// gibi hasta odaklı kabin işlemlerinde ortak kullanılır.
///
/// ## Davranış
///
/// - [assignments] boş gelirse [EmptyStateWidget] gösterilir.
/// - [assignments] dolu ama arama sonucu boşsa "eşleşen hasta bulunamadı"
///   mesajı gösterilir.
/// - Arama; hasta adı, oda, yatak ve servis alanlarını kapsar
///   (büyük/küçük harf duyarsız, kısmi eşleşme).
/// - Bir ögeye dokunulduğunda [onSelected] tetiklenir ve karar
///   tamamen çağıran tarafa bırakılır.
///
/// ## Örnek
///
/// ```dart
/// CabinPatientPickerList(
///   assignments: state.assignments,
///   onSelected: (assignment) {
///     notifier.onPatientSelected(assignment);
///     Navigator.of(context).pop();
///   },
/// )
/// ```

class CabinPatientPickerList extends StatefulWidget {
  const CabinPatientPickerList({super.key, required this.assignments, required this.onSelected});

  /// Seçilebilir hasta-yatak atamalarının listesi.
  ///
  /// Boş gelirse [EmptyStateWidget] gösterilir.
  final List<BedAssignment> assignments;

  /// Kullanıcı bir hastaya dokunduğunda tetiklenir.
  ///
  /// Seçim sonrası navigasyon veya state güncellemesi
  /// bu callback üzerinden yönetilir.
  final ValueChanged<BedAssignment> onSelected;

  @override
  State<CabinPatientPickerList> createState() => _CabinPatientPickerListState();
}

class _CabinPatientPickerListState extends State<CabinPatientPickerList> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hasta adı, oda, yatak ve servis alanlarında kısmi eşleşme uygular.
  ///
  /// Sorgu boşsa tüm liste döner. Büyük/küçük harf duyarsızdır.
  List<BedAssignment> get _filtered {
    if (_query.trim().isEmpty) return widget.assignments;
    final q = _query.trim().toLowerCase();

    return widget.assignments.where((a) {
      final patient = a.hospitalization?.patient;
      final room = a.bed?.room;
      final serviceName = a.hospitalization?.physicalService?.name;

      final haystack = [
        patient?.fullName,
        patient?.name,
        patient?.surname,
        room?.name,
        a.bed?.name,
        serviceName,
      ].whereType<String>().join(' ').toLowerCase();

      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assignments.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatient);
    }

    final filtered = _filtered;

    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.common_search_noPatientResults,
                      style: MedTextStyles.bodyMd(color: MedColors.text3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      CabinPatientPickerItem(assignment: filtered[i], onTap: () => widget.onSelected(filtered[i])),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return MedTextInputField(
      controller: _searchController,
      //prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
      hintText: 'Hasta, oda, yatak veya servis ara...',
      onChanged: (v) => setState(() => _query = v ?? ''),
    );
  }
}

/// [CabinPatientPickerList] içindeki tek hasta satırı.
///
/// Avatar monogramı, hasta adı ve konum bilgisini gösterir.
/// Dokunulduğunda [onTap] tetiklenir.
///
/// Bu widget doğrudan kullanılmaz; [CabinPatientPickerList] tarafından
/// yönetilir.
class CabinPatientPickerItem extends StatelessWidget {
  const CabinPatientPickerItem({super.key, required this.assignment, required this.onTap});

  final BedAssignment assignment;
  final VoidCallback onTap;

  /// Hasta adını döndürür. Hasta verisi yoksa `'Bilinmeyen Hasta'` gösterilir.
  String get _name {
    final p = assignment.hospitalization?.patient;
    if (p == null) return 'Bilinmeyen Hasta';
    final full = p.fullName.trim();
    return full.isNotEmpty ? full : '—';
  }

  /// Oda ve yatak adını `·` ile birleştirir.
  ///
  /// Sadece biri mevcutsa tek başına gösterilir.
  /// Her ikisi de null ise `null` döner ve konum satırı gizlenir.
  String? get _location {
    final room = assignment.bed?.room?.name;
    final bed = assignment.bed?.name;
    if (room != null && bed != null) return '$room · $bed';
    return room ?? bed;
  }

  /// [_name] değerinden avatar monogramı üretir.
  ///
  /// Tek kelimeli isimde yalnızca ilk harf, çok kelimeli isimde
  /// ilk ve son kelimenin baş harfleri büyük harfle döndürülür.
  /// Boş veya geçersiz isimde `'?'` döner.

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            MedAvatar(
              initials: assignment.hospitalization?.patient?.initials ?? '?',
              palette: AvatarPalette.blue,
              size: 32,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (_location != null) Text(_location!, style: MedTextStyles.monoMd(color: MedColors.text3)),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 16, color: MedColors.text4),
          ],
        ),
      ),
    );
  }
}
