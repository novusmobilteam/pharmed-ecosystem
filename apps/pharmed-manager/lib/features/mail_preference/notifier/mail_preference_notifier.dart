import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_manager/core/mixins/api_request_mixin.dart';
import 'package:pharmed_manager/core/mixins/side_panel_mixin.dart';

class MailPreferenceNotifier extends ChangeNotifier with ApiRequestMixin, SidePanelMixin<MailPreference, Never> {
  MailPreferenceNotifier({
    required GetMailPreferencesUseCase getMailPreferences,
    required DeleteMailPreferenceUsecase deleteMailPreference,
  }) : _getMailPreferences = getMailPreferences,
       _deleteMailPreference = deleteMailPreference;

  final GetMailPreferencesUseCase _getMailPreferences;
  final DeleteMailPreferenceUsecase _deleteMailPreference;

  final OperationKey _fetchOp = OperationKey.fetch();
  final OperationKey _deleteOp = OperationKey.delete();

  List<MailPreference> _preferences = [];
  List<MailPreference> get preferences => _preferences;

  Future<void> getMailPreferences() async {
    await execute(
      _fetchOp,
      operation: () => _getMailPreferences.call(),
      onData: (data) {
        _preferences = data;
      },
    );
  }

  Future<void> deletePreference(
    MailPreference preference, {
    Function(String? msg)? onFailed,
    VoidCallback? onSuccess,
  }) async {
    await executeVoid(
      _deleteOp,
      operation: () => _deleteMailPreference.call(preference),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: onSuccess,
    );
  }
}
