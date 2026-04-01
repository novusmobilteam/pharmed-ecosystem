import 'package:pharmed_client/shared/widgets/molecules/skt_row.dart';
import 'package:pharmed_core/pharmed_core.dart';

extension CabinStockSktStatus on CabinStock {
  SktStatus get sktStatus {
    final days = daysUntilExpiration;
    if (days < 0) return SktStatus.expired;
    if (days <= 7) return SktStatus.critical;
    return SktStatus.warning;
  }
}
