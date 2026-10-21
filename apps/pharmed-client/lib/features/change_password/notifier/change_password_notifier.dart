// [SWREQ-CLI-AUTH-PWD-001] [IEC 62304 §5.5]
// Ayarlar › Şifre Değiştir — oturumdaki kullanıcının şifresini değiştirir.
// Akış manager'daki ChangePasswordNotifier ile aynıdır (ChangePasswordUseCase,
// mevcut + yeni şifre); yeni şifre tekrarı yalnızca form doğrulamasında
// kullanılır, backend'e gönderilmez.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart' show MedLogger;

import '../../../core/providers/providers.dart';

final changePasswordNotifierProvider = NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);

enum ChangePasswordStatus { idle, submitting, success, failure }

class ChangePasswordState {
  const ChangePasswordState({this.status = ChangePasswordStatus.idle, this.errorMessage});

  final ChangePasswordStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;
}

class ChangePasswordNotifier extends AutoDisposeNotifier<ChangePasswordState> {
  ChangePasswordUseCase get _useCase => ref.read(changePasswordUseCaseProvider);

  bool _disposed = false;

  @override
  ChangePasswordState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const ChangePasswordState();
  }

  /// Kullanıcı formu yeniden düzenlemeye başlayınca önceki sonuç bildirimi
  /// (başarı/hata) temizlenir.
  void clearResult() {
    if (state.status == ChangePasswordStatus.idle || state.isSubmitting) return;
    state = const ChangePasswordState();
  }

  /// Başarılıysa true döner — view alanları temizler.
  Future<bool> submit({required String currentPassword, required String newPassword}) async {
    if (state.isSubmitting) return false;
    state = const ChangePasswordState(status: ChangePasswordStatus.submitting);

    final result = await _useCase.call(
      ChangePasswordParams(currentPassword: currentPassword, newPassword: newPassword),
    );
    // Ayarlar istek sürerken kapatıldıysa state'e yazılmaz.
    if (_disposed) return false;

    return result.when(
      ok: (_) {
        MedLogger.info(unit: 'SW-UNIT-AUTH', swreq: 'SWREQ-CLI-AUTH-PWD-001', message: 'Şifre değiştirildi');
        state = const ChangePasswordState(status: ChangePasswordStatus.success);
        return true;
      },
      error: (e) {
        // Şifre değerleri asla loglanmaz.
        MedLogger.error(
          unit: 'SW-UNIT-AUTH',
          swreq: 'SWREQ-CLI-AUTH-PWD-001',
          message: 'Şifre değiştirilemedi',
          context: {'errorType': e.runtimeType.toString()},
        );
        state = ChangePasswordState(status: ChangePasswordStatus.failure, errorMessage: e.userMessage);
        return false;
      },
    );
  }
}
