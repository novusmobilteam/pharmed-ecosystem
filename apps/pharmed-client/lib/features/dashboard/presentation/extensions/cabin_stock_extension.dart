import 'package:pharmed_core/pharmed_core.dart';
import '../../../../widgets/domain/domain.dart';

extension CabinStockSktStatus on CabinStock {
  SktStatus get sktStatus {
    final days = daysUntilExpiration;
    if (days < 0) return SktStatus.expired;
    if (days <= 7) return SktStatus.critical;
    return SktStatus.warning;
  }
}
