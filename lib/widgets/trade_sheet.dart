import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
import '../providers/game_provider.dart';
import 'player_area.dart';

class TradeSheet extends StatelessWidget {
  const TradeSheet({
    super.key,
    required this.gameState,
    required this.onTrade,
  });

  final GameState gameState;
  final void Function(ExchangeRate rate) onTrade;

  static const _farmAnimals = [
    Animal.rabbit,
    Animal.lamb,
    Animal.pig,
    Animal.cow,
    Animal.horse,
  ];

  static const _exchangeRateValues = [6, 2, 3, 2];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = gameState.currentPlayer!;
    final playerIndex = gameState.currentPlayerIndex;
    final color = PlayerArea.playerColors[playerIndex % PlayerArea.playerColors.length];

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '${player.name} — Trade',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Current animals overview
              _buildAnimalsOverview(player, theme),
              const Divider(height: 24),
              // Animal exchanges
              Text(
                'Exchange Animals',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._buildExchangeRows(player, color, theme),
              const SizedBox(height: 16),
              // Dog purchases
              Text(
                'Buy Dogs',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDogPurchase(player, Animal.smallDog, Animal.lamb, 1, Exchange.rates[4], color, theme),
              const SizedBox(height: 8),
              _buildDogPurchase(player, Animal.bigDog, Animal.cow, 1, Exchange.rates[5], color, theme),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalsOverview(PlayerHerd player, ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: Animal.values.map((a) {
        final count = player.countOf(a);
        return Chip(
          avatar: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(a.assetPath, fit: BoxFit.contain),
          ),
          label: Text('$count'),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  List<Widget> _buildExchangeRows(PlayerHerd player, Color color, ThemeData theme) {
    final rows = <Widget>[];
    for (int i = 0; i < _farmAnimals.length - 1; i++) {
      final rate = _exchangeRateValues[i];
      final lower = _farmAnimals[i];
      final higher = _farmAnimals[i + 1];
      final forwardRate = Exchange.rates[i];
      final reverseRate = ExchangeRate(
        from: higher,
        fromCount: 1,
        to: lower,
        toCount: rate,
      );

      final canTradeUp = player.countOf(lower) >= forwardRate.fromCount &&
          (gameState.bank[higher] ?? 0) >= 1;
      final canTradeDown = player.countOf(higher) >= 1 &&
          (gameState.bank[lower] ?? 0) >= rate;

      rows.add(
        Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: SvgPicture.asset(lower.assetPath, fit: BoxFit.contain),
                ),
                const SizedBox(width: 4),
                Text('${forwardRate.fromCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: canTradeUp ? () => onTrade(forwardRate) : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(48, 36),
                  ),
                  child: const Icon(Icons.arrow_forward, size: 18),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: canTradeDown ? () => onTrade(reverseRate) : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(48, 36),
                  ),
                  child: const Icon(Icons.arrow_back, size: 18),
                ),
                const Spacer(),
                Text('1', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 24, height: 24,
                  child: SvgPicture.asset(higher.assetPath, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildDogPurchase(
    PlayerHerd player,
    Animal dog,
    Animal costAnimal,
    int costCount,
    ExchangeRate rate,
    Color color,
    ThemeData theme,
  ) {
    final canBuy = player.countOf(costAnimal) >= costCount &&
        (gameState.bank[dog] ?? 0) >= 1;
    final owned = player.countOf(dog);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24, height: 24,
              child: SvgPicture.asset(dog.assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
            Text(
              '${dog.label} (owned: $owned)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: canBuy ? () => onTrade(rate) : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(80, 36),
              ),
              child: Text('Buy (1 ${costAnimal.label})'),
            ),
          ],
        ),
      ),
    );
  }
}
