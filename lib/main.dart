import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: SuperFarmerApp()));
}

class SuperFarmerApp extends StatefulWidget {
  const SuperFarmerApp({super.key});

  @override
  State<SuperFarmerApp> createState() => _SuperFarmerAppState();
}

class _SuperFarmerAppState extends State<SuperFarmerApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        title: 'Super Farmer',
        theme: SuperFarmerTheme.lightTheme,
        darkTheme: SuperFarmerTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onComplete: _onSplashComplete),
      );
    }

    return MaterialApp.router(
      title: 'Super Farmer',
      theme: SuperFarmerTheme.lightTheme,
      darkTheme: SuperFarmerTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
