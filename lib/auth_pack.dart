import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class AuthPack extends StatefulWidget {
  const AuthPack({super.key});

  @override
  State<AuthPack> createState() => _AuthPackState();
}

class _AuthPackState extends State<AuthPack> {
  String _status = "Checking biometrics...";
  bool _isLoading = true;
  bool _biometricAvailable = false;
  BiometricType _biometricType = BiometricType.weak;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();
      final bool isSupported = await auth.isDeviceSupported();

      if (!isSupported) {
        setState(() {
          _status = "Biometrics not supported on this device";
          _isLoading = false;
        });
        return;
      }

      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        setState(() {
          _status = "No biometrics enrolled";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _biometricAvailable = true;
        _biometricType = availableBiometrics.first;
        _status = "Ready to authenticate";
        _isLoading = false;
      });

      // Immediately try to authenticate
      _authenticate();
    } catch (e) {
      setState(() {
        _status = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _status = "Authenticating...";
    });

    try {
      final bool success = await AuthService().authenticateUser();

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/homepage', arguments: {
          'isDark': false,
          'forecast': [
            "Mon: 30°C",
            "Tue: 32°C",
            "Wed: 29°C",
            "Thu: 31°C",
            "Fri: 33°C",
          ],
        });
      } else {
        setState(() {
          _isLoading = false;
          _status = "Authentication failed";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "Error: ${e.toString()}";
      });
    }
  }

  void _goToPINScreen() {
    Navigator.pushReplacementNamed(context, '/number');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _biometricType == BiometricType.face
                      ? Icons.face
                      : Icons.fingerprint,
                  size: 80,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(height: 30),
                Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else if (_biometricAvailable) ...[
                  ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "TRY AGAIN",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                TextButton(
                  onPressed: _goToPINScreen,
                  child: const Text(
                    "USE PIN INSTEAD",
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
