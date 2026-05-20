import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ICensusRepository {
  /// Master kabin ilaç sayım servisi
  Future<Result<void>> masterCensus(List<dynamic> data);

  /// Mobil kabin ilaç sayım servisi
  Future<Result<void>> mobileCensus(List<dynamic> data);
}
