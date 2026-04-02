import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'router.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: SuperFarmerApp()));
}

class SuperFarmerApp extends ConsumerStatefulWidget {
  const SuperFarmerApp({super.key});

  @override
  ConsumerState<SuperFarmerApp> createState() => _SuperFarmerAppState();
}

class _SuperFarmerAppState extends ConsumerState<SuperFarmerApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themePref = ref.watch(themeProvider);
    final themeMode = themePref.themeMode;

    if (_showSplash) {
      return MaterialApp(
        title: 'Super Farmer',
        theme: SuperFarmerTheme.lightTheme,
        darkTheme: SuperFarmerTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onComplete: _onSplashComplete),
      );
    }

    return MaterialApp.router(
      title: 'Super Farmer',
      theme: SuperFarmerTheme.lightTheme,
      darkTheme: SuperFarmerTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
