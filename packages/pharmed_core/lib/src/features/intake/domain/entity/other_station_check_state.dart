import 'package:pharmed_core/pharmed_core.dart';

sealed class OtherStationCheckState {
  const OtherStationCheckState();
}

final class OtherStationIdle extends OtherStationCheckState {
  const OtherStationIdle();
}

final class OtherStationLoading extends OtherStationCheckState {
  const OtherStationLoading();
}

final class OtherStationFound extends OtherStationCheckState {
  const OtherStationFound(this.stations);
  final List<OtherStationMedicine> stations;
}

final class OtherStationNotFound extends OtherStationCheckState {
  const OtherStationNotFound();
}

final class OtherStationFailed extends OtherStationCheckState {
  const OtherStationFailed(this.message);
  final String? message;
}

final class OtherStationRedirecting extends OtherStationCheckState {
  const OtherStationRedirecting(this.target);
  final OtherStationMedicine target;
}

final class OtherStationRedirected extends OtherStationCheckState {
  const OtherStationRedirected(this.target);
  final OtherStationMedicine target;
}

final class OtherStationRedirectFailed extends OtherStationCheckState {
  const OtherStationRedirectFailed(this.target, this.message);
  final OtherStationMedicine target;
  final String? message;
}
