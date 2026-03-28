/// `SelectionDialog` kullanılarak seçim yapılabilen sınıflar için kullanılacak.
abstract class Selectable {
  final int? id;
  final String title;
  final String? subtitle;

  Selectable({this.id, required this.title, this.subtitle});
}
