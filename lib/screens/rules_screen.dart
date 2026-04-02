import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../widgets/tutorial_carousel.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // Interactive tutorial card
          Card(
            child: InkWell(
              onTap: () => TutorialCarousel.show(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Interactive Tutorial',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE0DDD5)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step-by-step guide with animations',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFB5B0A8)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => TutorialCarousel.show(context),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Start Tutorial'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick reference: How to Play
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Reference',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFE0DDD5)
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Super Farmer is a classic Polish board game where players '
                    'compete to collect animals by rolling dice.\n\n'
                    'Goal: Be the first player to collect at least one of each '
                    'animal type: rabbit, lamb, pig, cow, and horse.\n\n'
                    'On each turn, roll two dice. The animals shown on the dice '
                    'are added to your herd (paired with animals you already have).\n\n'
                    'Beware! A fox will steal all your rabbits, and a wolf will '
                    'steal everything except horses. Use a small dog to guard '
                    'against the fox and a big dog to guard against the wolf.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Animal values
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animal Values',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFE0DDD5)
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...Animal.values.map(
                    (animal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: SvgPicture.asset(
                              animal.assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            animal.label,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${animal.totalInGame} in game',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
