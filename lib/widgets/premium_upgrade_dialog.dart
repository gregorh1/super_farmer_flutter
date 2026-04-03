import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/premium_provider.dart';
import '../services/purchase_service.dart';

/// Shows the premium upgrade dialog. Returns true if user purchased.
Future<bool> showPremiumUpgradeDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _PremiumUpgradeDialog(),
  );
  return result ?? false;
}

/// Shows a small prompt when a premium feature is tapped by a free user.
Future<bool> showPremiumRequiredDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(l10n.premiumRequired),
        ],
      ),
      content: Text(l10n.premiumRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop(true);
          },
          child: Text(l10n.upgrade),
        ),
      ],
    ),
  );

  if (result == true && context.mounted) {
    return showPremiumUpgradeDialog(context);
  }
  return false;
}

class _PremiumUpgradeDialog extends ConsumerStatefulWidget {
  const _PremiumUpgradeDialog();

  @override
  ConsumerState<_PremiumUpgradeDialog> createState() =>
      _PremiumUpgradeDialogState();
}

class _PremiumUpgradeDialogState
    extends ConsumerState<_PremiumUpgradeDialog> {
  bool _purchasing = false;
  final _purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    _purchaseService.initialize();
    _purchaseService.onPurchaseSuccess = _onPurchaseSuccess;
    _purchaseService.onPurchaseError = _onPurchaseError;
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  void _onPurchaseSuccess() {
    ref.read(premiumProvider.notifier).unlockPremium();
    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.premiumPurchaseSuccess),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  void _onPurchaseError(String error) {
    if (mounted) {
      setState(() => _purchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.premiumPurchaseError),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(l10n.premium),
          ],
        ),
        content: Text(l10n.premiumAlreadyUnlocked),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.close),
          ),
        ],
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.premiumUnlock)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.premiumDescription,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _featureRow(Icons.group, l10n.premiumFeature3to4Players),
          _featureRow(Icons.smart_toy, l10n.premiumFeatureAllAi),
          _featureRow(Icons.palette, l10n.premiumFeatureAllThemes),
          _featureRow(Icons.bar_chart, l10n.premiumFeatureStatistics),
          _featureRow(Icons.block, l10n.premiumFeatureAdFree),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.premiumPrice,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _purchasing
              ? null
              : () async {
                  setState(() => _purchasing = true);
                  await _purchaseService.restorePurchases();
                  if (mounted) setState(() => _purchasing = false);
                },
          child: Text(l10n.premiumRestore),
        ),
        FilledButton(
          onPressed: _purchasing
              ? null
              : () async {
                  setState(() => _purchasing = true);
                  await _purchaseService.buyPremium();
                  // Purchase result comes via stream callback
                },
          child: _purchasing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.premiumBuy),
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
