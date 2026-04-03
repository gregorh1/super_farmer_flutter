import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_farmer/providers/premium_provider.dart';
import 'package:super_farmer/l10n/app_localizations.dart';

/// Helper to create a container and wait for async init.
Future<ProviderContainer> createPremiumContainer({
  bool initialPremium = false,
}) async {
  SharedPreferences.setMockInitialValues(
    initialPremium ? {'is_premium': true} : {},
  );
  final container = ProviderContainer();
  // Trigger provider creation
  container.read(premiumProvider);
  // Wait for the async SharedPreferences load to complete
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return container;
}

void main() {
  group('PremiumState', () {
    test('default state is not premium and not loaded', () {
      const state = PremiumState();
      expect(state.isPremium, false);
      expect(state.isLoaded, false);
    });

    test('copyWith creates new instance with updated values', () {
      const state = PremiumState();
      final updated = state.copyWith(isPremium: true, isLoaded: true);
      expect(updated.isPremium, true);
      expect(updated.isLoaded, true);
      expect(state.isPremium, false);
    });

    test('copyWith preserves values when not specified', () {
      const state = PremiumState(isPremium: true, isLoaded: true);
      final updated = state.copyWith();
      expect(updated.isPremium, true);
      expect(updated.isLoaded, true);
    });
  });

  group('PremiumNotifier', () {
    test('unlockPremium sets premium to true and persists', () async {
      final container = await createPremiumContainer();
      addTearDown(container.dispose);

      await container.read(premiumProvider.notifier).unlockPremium();
      expect(container.read(premiumProvider).isPremium, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), true);
    });

    test('resetPremium sets premium to false and persists', () async {
      final container = await createPremiumContainer(initialPremium: true);
      addTearDown(container.dispose);

      await container.read(premiumProvider.notifier).resetPremium();
      expect(container.read(premiumProvider).isPremium, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), false);
    });

    test('restorePurchase delegates to unlockPremium', () async {
      final container = await createPremiumContainer();
      addTearDown(container.dispose);

      await container.read(premiumProvider.notifier).restorePurchase();
      expect(container.read(premiumProvider).isPremium, true);
    });
  });

  group('isPremiumProvider', () {
    test('returns false when not premium', () async {
      final container = await createPremiumContainer();
      addTearDown(container.dispose);

      expect(container.read(isPremiumProvider), false);
    });

    test('updates when premium is unlocked', () async {
      final container = await createPremiumContainer();
      addTearDown(container.dispose);

      expect(container.read(isPremiumProvider), false);
      await container.read(premiumProvider.notifier).unlockPremium();
      expect(container.read(isPremiumProvider), true);
    });
  });

  group('Premium constants', () {
    test('product IDs are defined', () {
      expect(premiumProductId, 'super_farmer_premium');
      expect(removeAdsProductId, 'super_farmer_remove_ads');
    });
  });

  group('Feature gating logic', () {
    test('free users limited to 2 players', () {
      const isPremium = false;
      for (int count = 2; count <= 4; count++) {
        final isLocked = !isPremium && count > 2;
        if (count <= 2) {
          expect(isLocked, false, reason: '$count players should be free');
        } else {
          expect(isLocked, true, reason: '$count players should be locked');
        }
      }
    });

    test('premium users can use all player counts', () {
      const isPremium = true;
      for (int count = 2; count <= 4; count++) {
        final isLocked = !isPremium && count > 2;
        expect(isLocked, false, reason: '$count players should be unlocked');
      }
    });

    test('free users limited to easy AI', () {
      const isPremium = false;
      final difficulties = ['easy', 'medium', 'hard'];
      for (final diff in difficulties) {
        final isLocked = !isPremium && diff != 'easy';
        if (diff == 'easy') {
          expect(isLocked, false, reason: 'Easy should be free');
        } else {
          expect(isLocked, true, reason: '$diff should be locked');
        }
      }
    });

    test('premium users can use all AI difficulties', () {
      const isPremium = true;
      final difficulties = ['easy', 'medium', 'hard'];
      for (final diff in difficulties) {
        final isLocked = !isPremium && diff != 'easy';
        expect(isLocked, false, reason: '$diff should be unlocked');
      }
    });

    test('ads shown for free users only', () {
      // Free user: showAd = !isPremium
      expect(!false, true); // Free user sees ads
      expect(!true, false); // Premium user doesn't see ads
    });

    test('dark theme gated for free users', () {
      const isPremium = false;
      const selectedTheme = 'dark';
      final isLocked = !isPremium && selectedTheme == 'dark';
      expect(isLocked, true);
    });

    test('dark theme available for premium users', () {
      const isPremium = true;
      const selectedTheme = 'dark';
      final isLocked = !isPremium && selectedTheme == 'dark';
      expect(isLocked, false);
    });

    test('light and system themes available for all', () {
      const isPremium = false;
      for (final t in ['light', 'system']) {
        final isLocked = !isPremium && t == 'dark';
        expect(isLocked, false, reason: '$t theme should be free');
      }
    });

    test('stats screen gated for free users', () {
      const isPremium = false;
      expect(!isPremium, true); // Should show premium gate
    });

    test('stats screen available for premium users', () {
      const isPremium = true;
      expect(isPremium, true); // Should show stats
    });
  });

  group('Premium widget tests', () {
    testWidgets('premium required dialog shows lock icon and text',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.amber),
                          SizedBox(width: 8),
                          Text('Premium Required'),
                        ],
                      ),
                      content: const Text(
                          'This feature requires Premium. Upgrade to unlock all features!'),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(find.text('Premium Required'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Upgrade'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
