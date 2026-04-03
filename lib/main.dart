import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'router.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
    final langPref = ref.watch(languageProvider);
    final locale = langPref.locale;

    if (_showSplash) {
      return MaterialApp(
        title: 'Super Farmer',
        theme: SuperFarmerTheme.lightTheme,
        darkTheme: SuperFarmerTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
