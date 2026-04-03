import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _premiumKey = 'is_premium';

/// Product ID for the one-time premium unlock IAP.
const premiumProductId = 'super_farmer_premium';

/// Product ID for remove-ads only IAP.
const removeAdsProductId = 'super_farmer_remove_ads';

class PremiumState {
  const PremiumState({
    this.isPremium = false,
    this.isLoaded = false,
  });

  final bool isPremium;
  final bool isLoaded;

  PremiumState copyWith({bool? isPremium, bool? isLoaded}) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(const PremiumState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;
    if (mounted) {
      state = PremiumState(isPremium: isPremium, isLoaded: true);
    }
  }

  /// Call after a successful IAP purchase to unlock premium.
  Future<void> unlockPremium() async {
    state = state.copyWith(isPremium: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
  }

  /// Restore a previous purchase (e.g. on reinstall).
  Future<void> restorePurchase() async {
    await unlockPremium();
  }

  /// For testing / debug only.
  Future<void> resetPremium() async {
    state = state.copyWith(isPremium: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, false);
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);

/// Convenience provider that returns just the bool.
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
