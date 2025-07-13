import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'welcome_screen.dart';
import 'number_screen.dart';
import 'dynamic_homepage.dart';
import 'auth_pack.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Weather App',
      theme: Provider.of<ThemeProvider>(context).lightTheme,
      darkTheme: Provider.of<ThemeProvider>(context).darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthPack(),
        '/number': (context) => const NumberScreen(),
        '/homepage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;

          final isDark = args?['isDark'] ?? false;
          final forecast = args?['forecast'] ??
              [
                "Mon: 30°C",
                "Tue: 32°C",
                "Wed: 29°C",
                "Thu: 31°C",
                "Fri: 33°C",
              ];

          return DynamicHomePage(
            isDark: isDark,
            forecast: forecast,
          );
        },
      },
    );
  }
}
