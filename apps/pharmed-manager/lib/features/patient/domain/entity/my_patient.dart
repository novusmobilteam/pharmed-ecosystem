import '../../../../core/core.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';

class MyPatient implements TableData {
  final int? id;
  final int? userId;
  final User? user;
  final Hospitalization? hospitalization;

  MyPatient({this.id, this.userId, this.user, this.hospitalization});

  MyPatient copyWith({int? id, int? userId, User? user, Hospitalization? hospitalization}) {
    return MyPatient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      hospitalization: hospitalization ?? this.hospitalization,
    );
  }

  @override
  List get content => hospitalization?.content ?? [];

  @override
  List get rawContent => hospitalization?.rawContent ?? [];

  @override
  List<String?> get titles => hospitalization?.titles ?? [];
}
