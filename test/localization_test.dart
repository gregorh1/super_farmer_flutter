import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_farmer/l10n/app_localizations.dart';
import 'package:super_farmer/l10n/l10n_helpers.dart';
import 'package:super_farmer/main.dart';
import 'package:super_farmer/models/animal.dart';
import 'package:super_farmer/providers/settings_provider.dart';

/// Helper to build a minimal localized app for testing.
Widget _localizedApp({Locale locale = const Locale('en'), required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: child,
    ),
  );
}

void main() {
  group('AppLocalizations', () {
    testWidgets('English locale provides correct translations', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('en'),
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ));

      expect(l10n.appTitle, 'Super Farmer');
      expect(l10n.newGame, 'New Game');
      expect(l10n.animals, 'Animals');
      expect(l10n.settings, 'Settings');
      expect(l10n.rules, 'Rules');
      expect(l10n.statistics, 'Statistics');
      expect(l10n.achievements, 'Achievements');
      expect(l10n.rollDice, 'Roll Dice');
      expect(l10n.endTurn, 'End Turn');
    });

    testWidgets('Polish locale provides correct translations', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('pl'),
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ));

      expect(l10n.appTitle, 'Superfarmer');
      expect(l10n.newGame, 'Nowa Gra');
      expect(l10n.animals, 'Zwierzęta');
      expect(l10n.settings, 'Ustawienia');
      expect(l10n.rules, 'Zasady');
      expect(l10n.statistics, 'Statystyki');
      expect(l10n.achievements, 'Osiągnięcia');
      expect(l10n.rollDice, 'Rzuć Kośćmi');
      expect(l10n.endTurn, 'Zakończ Turę');
    });

    testWidgets('parameterized strings work correctly', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('en'),
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ));

      expect(l10n.playerN(1), 'Player 1');
      expect(l10n.playerN(3), 'Player 3');
      expect(l10n.playerTurn('Alice'), "Alice's Turn");
      expect(l10n.winnerMessage('Bob'), 'Bob has collected one of each animal and wins the game!');
      expect(l10n.nInGame(60), '60 in game');
      expect(l10n.nPlayers(4), '4 players');
      expect(l10n.nTurns(15), '15 turns');
      expect(l10n.nOfTotalUnlocked(3, 10), '3 of 10 unlocked');
    });

    testWidgets('Polish parameterized strings work', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('pl'),
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ));

      expect(l10n.playerN(1), 'Gracz 1');
      expect(l10n.playerTurn('Alicja'), 'Tura gracza Alicja');
      expect(l10n.nInGame(60), '60 w grze');
    });
  });

  group('Localized animal names', () {
    testWidgets('English animal names are correct', (tester) async {
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('en'),
        child: Builder(builder: (context) {
          expect(localizedAnimalName(context, Animal.rabbit), 'Rabbit');
          expect(localizedAnimalName(context, Animal.lamb), 'Lamb');
          expect(localizedAnimalName(context, Animal.pig), 'Pig');
          expect(localizedAnimalName(context, Animal.cow), 'Cow');
          expect(localizedAnimalName(context, Animal.horse), 'Horse');
          expect(localizedAnimalName(context, Animal.smallDog), 'Small Dog');
          expect(localizedAnimalName(context, Animal.bigDog), 'Big Dog');
          return const SizedBox();
        }),
      ));
    });

    testWidgets('Polish animal names are correct', (tester) async {
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('pl'),
        child: Builder(builder: (context) {
          expect(localizedAnimalName(context, Animal.rabbit), 'Królik');
          expect(localizedAnimalName(context, Animal.lamb), 'Owca');
          expect(localizedAnimalName(context, Animal.pig), 'Świnia');
          expect(localizedAnimalName(context, Animal.cow), 'Krowa');
          expect(localizedAnimalName(context, Animal.horse), 'Koń');
          expect(localizedAnimalName(context, Animal.smallDog), 'Mały Pies');
          expect(localizedAnimalName(context, Animal.bigDog), 'Duży Pies');
          return const SizedBox();
        }),
      ));
    });
  });

  group('Localized achievement names', () {
    testWidgets('English achievement names and descriptions', (tester) async {
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('en'),
        child: Builder(builder: (context) {
          expect(localizedAchievementName(context, 'firstFarm'), 'First Farm');
          expect(localizedAchievementDesc(context, 'firstFarm'), 'Win your first game');
          expect(localizedAchievementName(context, 'speedFarmer'), 'Speed Farmer');
          expect(localizedAchievementName(context, 'luckyRoller'), 'Lucky Roller');
          return const SizedBox();
        }),
      ));
    });

    testWidgets('Polish achievement names and descriptions', (tester) async {
      await tester.pumpWidget(_localizedApp(
        locale: const Locale('pl'),
        child: Builder(builder: (context) {
          expect(localizedAchievementName(context, 'firstFarm'), 'Pierwsza Farma');
          expect(localizedAchievementDesc(context, 'firstFarm'), 'Wygraj swoją pierwszą grę');
          expect(localizedAchievementName(context, 'speedFarmer'), 'Szybki Farmer');
          expect(localizedAchievementName(context, 'luckyRoller'), 'Szczęściarz');
          return const SizedBox();
        }),
      ));
    });
  });

  group('LanguagePreference', () {
    test('system returns null locale', () {
      expect(LanguagePreference.system.locale, isNull);
    });

    test('polish returns pl locale', () {
      expect(LanguagePreference.polish.locale, const Locale('pl'));
    });

    test('english returns en locale', () {
      expect(LanguagePreference.english.locale, const Locale('en'));
    });
  });

  group('LanguageNotifier', () {
    test('defaults to system', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(languageProvider), LanguagePreference.system);
    });

    test('setLanguage changes state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage(LanguagePreference.polish);
      expect(container.read(languageProvider), LanguagePreference.polish);
    });

    test('persists language preference', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage(LanguagePreference.english);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_preference'), 'english');
    });

    test('setLanguage persists and can be read back', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage(LanguagePreference.polish);
      expect(container.read(languageProvider), LanguagePreference.polish);

      // Verify it persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_preference'), 'polish');
    });
  });

  group('Language toggle in settings', () {
    testWidgets('settings sheet shows language selector', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Language section should be visible
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('System'), findsWidgets); // System appears in language and theme
      expect(find.text('Polski'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });
  });

  group('SuperFarmerApp localization', () {
    testWidgets('app includes localization delegates', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ProviderScope(child: SuperFarmerApp()));
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.localizationsDelegates, isNotNull);
      expect(app.supportedLocales, contains(const Locale('en')));
      expect(app.supportedLocales, contains(const Locale('pl')));

      // Drain splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('supports both en and pl locales', (tester) async {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('pl')));
    });
  });
}
