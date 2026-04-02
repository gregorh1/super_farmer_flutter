import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'tutorial_carousel.dart';

/// Bottom sheet for in-game settings.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameSettingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    String languageLabel(LanguagePreference pref) {
      switch (pref) {
        case LanguagePreference.system:
          return l10n.languageSystem;
        case LanguagePreference.polish:
          return l10n.languagePolish;
        case LanguagePreference.english:
          return l10n.languageEnglish;
      }
    }

    String themeLabel(ThemePreference pref) {
      switch (pref) {
        case ThemePreference.system:
          return l10n.themeSystem;
        case ThemePreference.light:
          return l10n.themeLight;
        case ThemePreference.dark:
          return l10n.themeDark;
      }
    }

    String animSpeedLabel(AnimationSpeed speed) {
      switch (speed) {
        case AnimationSpeed.slow:
          return l10n.speedSlow;
        case AnimationSpeed.normal:
          return l10n.speedNormal;
        case AnimationSpeed.fast:
          return l10n.speedFast;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: [
              Icon(Icons.settings, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.settings,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Language selector
          _SettingsTile(
            icon: ref.watch(languageProvider).icon,
            title: l10n.language,
            subtitle: languageLabel(ref.watch(languageProvider)),
            trailing: SegmentedButton<LanguagePreference>(
              segments: LanguagePreference.values.map((pref) {
                return ButtonSegment(
                  value: pref,
                  label: Text(languageLabel(pref), style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              selected: {ref.watch(languageProvider)},
              onSelectionChanged: (selected) {
                ref.read(languageProvider.notifier).setLanguage(selected.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const Divider(height: 1),

          // Theme selector
          _SettingsTile(
            icon: ref.watch(themeProvider).icon,
            title: l10n.theme,
            subtitle: themeLabel(ref.watch(themeProvider)),
            trailing: SegmentedButton<ThemePreference>(
              segments: ThemePreference.values.map((pref) {
                return ButtonSegment(
                  value: pref,
                  label: Text(themeLabel(pref), style: const TextStyle(fontSize: 12)),
                  icon: Icon(pref.icon, size: 16),
                );
              }).toList(),
              selected: {ref.watch(themeProvider)},
              onSelectionChanged: (selected) {
                ref.read(themeProvider.notifier).setTheme(selected.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const Divider(height: 1),

          // Sound toggle
          _SettingsTile(
            icon: settings.soundEnabled
                ? Icons.volume_up
                : Icons.volume_off,
            title: l10n.sound,
            subtitle: settings.soundEnabled ? l10n.soundOn : l10n.soundOff,
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (_) =>
                  ref.read(gameSettingsProvider.notifier).toggleSound(),
            ),
          ),

          // Volume slider (only when sound is enabled)
          if (settings.soundEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 8, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.volume_down,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  Expanded(
                    child: Slider(
                      value: settings.volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(settings.volume * 100).round()}%',
                      onChanged: (val) =>
                          ref.read(gameSettingsProvider.notifier).setVolume(val),
                    ),
                  ),
                  Icon(Icons.volume_up,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ],
              ),
            ),
          const Divider(height: 1),

          // Animation speed
          _SettingsTile(
            icon: Icons.speed,
            title: l10n.animationSpeed,
            subtitle: animSpeedLabel(settings.animationSpeed),
            trailing: SegmentedButton<AnimationSpeed>(
              segments: AnimationSpeed.values.map((speed) {
                return ButtonSegment(
                  value: speed,
                  label: Text(animSpeedLabel(speed), style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              selected: {settings.animationSpeed},
              onSelectionChanged: (selected) {
                ref
                    .read(gameSettingsProvider.notifier)
                    .setAnimationSpeed(selected.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const Divider(height: 1),

          // Confirm end turn
          _SettingsTile(
            icon: Icons.check_circle_outline,
            title: l10n.confirmEndTurn,
            subtitle: settings.confirmEndTurn
                ? l10n.askBeforeEnding
                : l10n.endTurnImmediately,
            trailing: Switch(
              value: settings.confirmEndTurn,
              onChanged: (_) =>
                  ref.read(gameSettingsProvider.notifier).toggleConfirmEndTurn(),
            ),
          ),
          const Divider(height: 1),

          // How to Play
          _SettingsTile(
            icon: Icons.menu_book,
            title: l10n.howToPlay,
            subtitle: l10n.interactiveTutorialShort,
            trailing: FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pop(); // close settings sheet
                TutorialCarousel.show(context);
              },
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.open, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
