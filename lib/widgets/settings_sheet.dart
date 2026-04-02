import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Padding(
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
                'Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sound toggle
          _SettingsTile(
            icon: settings.soundEnabled
                ? Icons.volume_up
                : Icons.volume_off,
            title: 'Sound',
            subtitle: settings.soundEnabled ? 'On' : 'Off',
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
            title: 'Animation Speed',
            subtitle: settings.animationSpeed.label,
            trailing: SegmentedButton<AnimationSpeed>(
              segments: AnimationSpeed.values.map((speed) {
                return ButtonSegment(
                  value: speed,
                  label: Text(speed.label, style: const TextStyle(fontSize: 12)),
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
            title: 'Confirm End Turn',
            subtitle: settings.confirmEndTurn
                ? 'Ask before ending turn'
                : 'End turn immediately',
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
            title: 'How to Play',
            subtitle: 'Interactive tutorial',
            trailing: FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pop(); // close settings sheet
                TutorialCarousel.show(context);
              },
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Open', style: TextStyle(fontSize: 12)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
          trailing,
        ],
      ),
    );
  }
}
