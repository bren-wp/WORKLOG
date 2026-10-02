import 'package:local_auth/local_auth.dart';

class SecurityAuthResult {
  const SecurityAuthResult({required this.success, this.message});

  final bool success;
  final String? message;
}

class LocalSecurityService {
  LocalSecurityService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<bool> isAvailable() async {
    try {
      return await _authentication.isDeviceSupported();
    } on LocalAuthException {
      return false;
    }
  }

  Future<SecurityAuthResult> authenticate({
    String reason = 'Otključaj WORKLOG za pristup poslovnim podacima.',
  }) async {
    try {
      final available = await _authentication.isDeviceSupported();
      if (!available) {
        return const SecurityAuthResult(
          success: false,
          message:
              'Na uređaju nije dostupna biometrija, PIN, uzorak ili sigurnosna šifra.',
        );
      }

      final authenticated = await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );
      return SecurityAuthResult(
        success: authenticated,
        message: authenticated ? null : 'Autentikacija nije potvrđena.',
      );
    } on LocalAuthException catch (error) {
      return SecurityAuthResult(
        success: false,
        message: _messageFor(error.code),
      );
    }
  }

  Future<void> cancel() async {
    try {
      await _authentication.stopAuthentication();
    } on LocalAuthException {
      // Nema aktivne autentikacije ili ju je platforma već zatvorila.
    }
  }

  String _messageFor(LocalAuthExceptionCode code) {
    return switch (code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'Uređaj nema podržanu lokalnu autentikaciju.',
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        'Na uređaju nije postavljena biometrija.',
      LocalAuthExceptionCode.noCredentialsSet =>
        'Na uređaju nije postavljen PIN, uzorak ili sigurnosna šifra.',
      LocalAuthExceptionCode.temporaryLockout =>
        'Autentikacija je privremeno zaključana. Pokušaj ponovno kasnije.',
      LocalAuthExceptionCode.biometricLockout =>
        'Biometrija je zaključana. Otključaj uređaj sigurnosnom šifrom.',
      LocalAuthExceptionCode.userCanceled => 'Autentikacija je otkazana.',
      LocalAuthExceptionCode.systemCanceled =>
        'Sustav je prekinuo autentikaciju.',
      _ => 'Lokalna autentikacija nije uspjela.',
    };
  }
}
