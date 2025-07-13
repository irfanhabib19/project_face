import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumberScreen extends StatefulWidget {
  const NumberScreen({super.key});

  @override
  State<NumberScreen> createState() => _NumberScreenState();
}

class _NumberScreenState extends State<NumberScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  String? _storedPin;
  int _attempts = 0;
  bool _isLoading = true;
  String _status = "";
  bool _showRetryButton = false;

  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPIN();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadPIN() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('user_pin');
      _isLoading = false;
    });
  }

  Future<void> _savePIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
    setState(() {
      _storedPin = pin;
    });
  }

  void _validatePIN() async {
    if (_pinController.text.length != 4) {
      setState(() {
        _status = "PIN must be 4 digits";
        _showRetryButton = false;
      });
      _controller.forward(from: 0);
      return;
    }

    if (_storedPin == null) {
      await _savePIN(_pinController.text);
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
      return;
    }

    if (_pinController.text == _storedPin) {
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
      _attempts++;
      _controller.forward(from: 0);
      setState(() {
        _status = "Incorrect PIN. Attempts: $_attempts/3";
        _showRetryButton = _attempts >= 3;
        if (_attempts >= 3) {
          _pinController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF141E30), Color(0xFF243B55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 80, color: Colors.cyanAccent),
                        const SizedBox(height: 30),
                        Text(
                          _storedPin == null
                              ? "Create a 4-digit PIN"
                              : "Enter your PIN",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: 10,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintText: '••••',
                              hintStyle: const TextStyle(
                                letterSpacing: 10,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_status.isNotEmpty)
                          Text(
                            _status,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showRetryButton ? null : _validatePIN,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _storedPin == null ? "SET PIN" : "UNLOCK",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (_showRetryButton) ...[
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _attempts = 0;
                                _status = "";
                                _showRetryButton = false;
                              });
                            },
                            child: const Text(
                              "TRY AGAIN",
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
