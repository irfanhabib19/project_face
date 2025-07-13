import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticateUser() async {
    try {
      // First check if biometrics are available
      bool canCheck = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!isSupported) {
        print("Biometrics not supported on this device");
        return false;
      }

      if (!canCheck) {
        print("Cannot check biometrics");
        return false;
      }

      // Then authenticate
      return await _auth.authenticate(
        localizedReason: 'Scan your face or fingerprint to authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true, // Force biometric only
          stickyAuth: true, // Keep auth dialog open
          useErrorDialogs: true, // Show system error dialogs
        ),
      );
    } catch (e) {
      print("Biometric Auth Error: $e");
      return false;
    }
  }
}
