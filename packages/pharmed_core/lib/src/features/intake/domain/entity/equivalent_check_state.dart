import 'package:pharmed_core/pharmed_core.dart';

sealed class EquivalentCheckState {
  const EquivalentCheckState();
}

final class EquivalentIdle extends EquivalentCheckState {
  const EquivalentIdle();
}

final class EquivalentLoading extends EquivalentCheckState {
  const EquivalentLoading();
}

final class EquivalentFound extends EquivalentCheckState {
  const EquivalentFound(this.options, {this.selected});

  final List<EquivalentMedicine> options;
  final EquivalentMedicine? selected;
}

final class EquivalentNotFound extends EquivalentCheckState {
  const EquivalentNotFound();
}

final class EquivalentFailed extends EquivalentCheckState {
  const EquivalentFailed(this.message);

  final String? message;
}
