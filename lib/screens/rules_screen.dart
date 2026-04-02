import 'package:flutter/material.dart';
import '../models/animal.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Play',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...Animal.values.map(
                    (animal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: animal.color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: animal.color, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                animal.label[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: animal.color,
                                ),
                              ),
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
