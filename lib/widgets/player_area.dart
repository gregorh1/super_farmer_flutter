import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../models/exchange.dart';
import '../providers/game_provider.dart';

class PlayerArea extends StatelessWidget {
  const PlayerArea({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.isCurrentPlayer,
    required this.gameState,
    required this.onTrade,
  });

  final PlayerHerd player;
  final int playerIndex;
  final bool isCurrentPlayer;
  final GameState gameState;
  final void Function(ExchangeRate rate) onTrade;

  static const farmAnimals = [
    Animal.rabbit,
    Animal.lamb,
    Animal.pig,
    Animal.cow,
    Animal.horse,
  ];

  static const exchangeRateValues = [6, 2, 3, 2];

  static const playerColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];

  double get _winProgress {
    int collected = 0;
    for (final a in farmAnimals) {
      if (player.countOf(a) >= 1) collected++;
    }
    return collected / 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final color = playerColors[playerIndex % playerColors.length];
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isCurrentPlayer
        ? color.withValues(alpha: 0.08)
        : isDark
            ? const Color(0xFF1E1E1E)
            : theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentPlayer
              ? color
              : isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : color.withValues(alpha: 0.3),
          width: isCurrentPlayer ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: surfaceColor,
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(color, theme),
                const SizedBox(height: 2),
                _buildAnimalRow(color, theme),
                const SizedBox(height: 2),
                _buildDogRow(color, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final progressPercent = (_winProgress * 100).round();
    final progressColor = isDark && !isCurrentPlayer
        ? const Color(0xFFE0E0E0)
        : color;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isCurrentPlayer
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          player.name,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrentPlayer
                ? color
                : isDark
                    ? const Color(0xFFE0E0E0)
                    : null,
          ),
        ),
        const Spacer(),
        Text(
          '$progressPercent%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _winProgress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalRow(Color color, ThemeData theme) {
    final widgets = <Widget>[];
    for (int i = 0; i < farmAnimals.length; i++) {
      widgets.add(
        Expanded(child: _buildAnimalCell(farmAnimals[i], theme)),
      );
      if (i < farmAnimals.length - 1) {
        widgets.add(_buildExchangeControl(i, color, theme));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }

  Widget _buildAnimalCell(Animal animal, ThemeData theme) {
    final count = player.countOf(animal);
    final hasOne = count >= 1;
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: isDark
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          padding: const EdgeInsets.all(2),
          child: Opacity(
            opacity: hasOne ? 1.0 : 0.4,
            child: SvgPicture.asset(animal.assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: hasOne
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeControl(int index, Color color, ThemeData theme) {
    final rate = exchangeRateValues[index];
    final lowerAnimal = farmAnimals[index];
    final higherAnimal = farmAnimals[index + 1];

    final forwardRate = Exchange.rates[index];
    final reverseRate = ExchangeRate(
      from: higherAnimal,
      fromCount: 1,
      to: lowerAnimal,
      toCount: rate,
    );

    final canTradeUp = isCurrentPlayer &&
        player.countOf(lowerAnimal) >= forwardRate.fromCount &&
        (gameState.bank[higherAnimal] ?? 0) >= 1;

    final canTradeDown = isCurrentPlayer &&
        player.countOf(higherAnimal) >= 1 &&
        (gameState.bank[lowerAnimal] ?? 0) >= rate;

    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TradeButton(
            icon: Icons.arrow_upward,
            enabled: canTradeUp,
            color: color,
            onTap: () => onTrade(forwardRate),
          ),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? color.withValues(alpha: 0.25)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '$rate',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE0E0E0) : color,
              ),
            ),
          ),
          _TradeButton(
            icon: Icons.arrow_downward,
            enabled: canTradeDown,
            color: color,
            onTap: () => onTrade(reverseRate),
          ),
        ],
      ),
    );
  }

  Widget _buildDogRow(Color color, ThemeData theme) {
    final canBuySmallDog = isCurrentPlayer &&
        player.countOf(Animal.lamb) >= 1 &&
        (gameState.bank[Animal.smallDog] ?? 0) >= 1;

    final canBuyBigDog = isCurrentPlayer &&
        player.countOf(Animal.cow) >= 1 &&
        (gameState.bank[Animal.bigDog] ?? 0) >= 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDogCell(
          Animal.smallDog,
          'Buy (1 Lamb)',
          canBuySmallDog,
          Exchange.rates[4],
          color,
          theme,
        ),
        const SizedBox(width: 16),
        _buildDogCell(
          Animal.bigDog,
          'Buy (1 Cow)',
          canBuyBigDog,
          Exchange.rates[5],
          color,
          theme,
        ),
      ],
    );
  }

  Widget _buildDogCell(
    Animal dog,
    String tooltip,
    bool canBuy,
    ExchangeRate rate,
    Color color,
    ThemeData theme,
  ) {
    final count = player.countOf(dog);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: isDark
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Opacity(
            opacity: count > 0 ? 1.0 : 0.4,
            child: SvgPicture.asset(dog.assetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'x$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: canBuy ? () => onTrade(rate) : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(48, 32),
              tapTargetSize: MaterialTapTargetSize.padded,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              foregroundColor: color,
            ),
            child: Text(tooltip),
          ),
        ),
      ],
    );
  }
}

class _TradeButton extends StatelessWidget {
  const _TradeButton({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 14),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: color,
        disabledColor: color.withValues(alpha: 0.2),
        splashRadius: 12,
        tooltip: enabled ? null : 'Not enough animals',
      ),
    );
  }
}
