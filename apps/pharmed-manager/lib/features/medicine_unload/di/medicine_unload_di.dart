import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../domain/usecase/unload_medicine_usecase.dart';

class MedicineUnloadProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider<UnloadMedicineUseCase>(
        create: (context) => UnloadMedicineUseCase(context.read()),
      ),
    ];
  }
}
