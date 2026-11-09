// [SWREQ-DATA-INTAKE-002] Ordered alımda stok planı (#123).

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// Yalnızca ordered check'i yakalar; diğer metodlar bu testte çağrılmaz.
class _FakeIntakeRepository implements IIntakeRepository {
  final sent = <Map<String, dynamic>>[];

  @override
  Future<Result<void>> checkOrderedIntake(Map<String, dynamic> data) async {
    sent.add(data);
    return const Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Göz 1 (önde) ve göz 2 (arkada); 1170 göz 1'de 1 adet, 1171 göz 2'de 3 adet.
MedicineAssignment _assignment() => MedicineAssignment(
  id: 352,
  cabinDrawerDetail: const [DrawerCell(id: 1, stepNo: 1), DrawerCell(id: 2, stepNo: 2)],
  stocks: [
    CabinStock(id: 1170, cabinDrawerDetailId: 1, quantity: 1),
    CabinStock(id: 1171, cabinDrawerDetailId: 2, quantity: 3),
  ],
);

CheckIntakeParams _params(double dose, {Map<int, double> planned = const {}, int resolvedId = 1170}) => CheckIntakeParams(
  type: IntakeType.ordered,
  userId: 1,
  prescriptionDetailId: 2689,
  assignment: _assignment(),
  resolvedStock: CabinStock(id: resolvedId, quantity: resolvedId == 1170 ? 1 : 3),
  dosePiece: dose,
  alreadyPlanned: planned,
);

String _plan(List<IntakeDetail> details) => details.map((d) => '${d.stockId}:${d.dosePiece}').join(',');

void main() {
  late _FakeIntakeRepository repo;
  late CheckIntakeUseCase useCase;

  setUp(() {
    repo = _FakeIntakeRepository();
    useCase = CheckIntakeUseCase(repo);
  });

  test('çözülen kayıt dozu karşılıyorsa yalnızca o kullanılır', () async {
    final r = await useCase.call(_params(2, resolvedId: 1171));
    expect(_plan(r.data!), '1171:2.0');
  });

  test('çözülen kayıt yetmezse kalan aynı atamadan FIFO ile tamamlanır', () async {
    final r = await useCase.call(_params(2));
    expect(_plan(r.data!), '1170:1.0,1171:1.0');
    expect((repo.sent.single['detail'] as List).length, 2);
  });

  test('önceki kalemlerin planı düşülür', () async {
    final r = await useCase.call(_params(2, planned: {1170: 1}));
    expect(_plan(r.data!), '1171:2.0');
  });

  test('atamanın toplamı da yetmezse servise gidilmez', () async {
    final r = await useCase.call(_params(5));
    expect(r.data, isNull);
    expect(repo.sent, isEmpty);
  });
}
