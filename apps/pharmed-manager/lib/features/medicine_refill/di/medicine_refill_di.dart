import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../domain/usecase/refill_medicine_usecase.dart';

class MedicineRefillProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<RefillMedicineUseCase>(
        create: (context) => RefillMedicineUseCase(context.read()),
      ),
    ];
  }
}
