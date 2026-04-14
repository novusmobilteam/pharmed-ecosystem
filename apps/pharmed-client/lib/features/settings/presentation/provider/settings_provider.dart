// lib/features/settings/presentation/provider/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/settings_notifier.dart';
import '../../domain/model/settings_state.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
