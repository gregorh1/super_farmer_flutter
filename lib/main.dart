import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: SuperFarmerApp()));
}

class SuperFarmerApp extends StatelessWidget {
  const SuperFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Super Farmer',
      theme: SuperFarmerTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
