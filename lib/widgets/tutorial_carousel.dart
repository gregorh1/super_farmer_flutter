import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';

/// Interactive tutorial carousel explaining Super Farmer rules.
/// Displays as a full-screen dialog with swipeable pages and progress dots.
class TutorialCarousel extends StatefulWidget {
  const TutorialCarousel({super.key});

  /// Show the tutorial as a full-screen modal.
  static Future<void> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const TutorialCarousel(),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  State<TutorialCarousel> createState() => _TutorialCarouselState();
}

class _TutorialCarouselState extends State<TutorialCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pageCount = 7;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _pageCount - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.howToPlay),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _close,
          tooltip: l10n.close,
        ),
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _close,
              child: Text(
                l10n.skip,
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor ?? Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: const [
                _WelcomePage(),
                _DiceRollingPage(),
                _BreedingPage(),
                _TradingPage(),
                _GuardDogsPage(),
                _AttacksPage(),
                _WinConditionPage(),
              ],
            ),
          ),
          // Progress dots and button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomPadding),
            child: Column(
              children: [
                _ProgressDots(
                  count: _pageCount,
                  current: _currentPage,
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isLastPage
                      ? FilledButton(
                          onPressed: _close,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.gotIt,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: _nextPage,
                          icon: Text(
                            l10n.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          label: const Icon(Icons.arrow_forward, size: 20),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress dots
// ---------------------------------------------------------------------------

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  final int count;
  final int current;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : activeColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tutorial page scaffold
// ---------------------------------------------------------------------------

class _TutorialPageLayout extends StatelessWidget {
  const _TutorialPageLayout({
    required this.icon,
    required this.title,
    required this.description,
    required this.illustration,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          // Icon badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          illustration,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1: Welcome
// ---------------------------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.agriculture,
      title: l10n.tutorialWelcomeTitle,
      description: l10n.tutorialWelcomeDesc,
      illustration: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final animal in [
                Animal.rabbit,
                Animal.lamb,
                Animal.pig,
                Animal.cow,
                Animal.horse,
              ])
                _AnimalBadge(animal: animal),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalBadge extends StatelessWidget {
  const _AnimalBadge({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: SvgPicture.asset(animal.assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 4),
        Text(
          localizedAnimalName(context, animal),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2: Dice Rolling
// ---------------------------------------------------------------------------

class _DiceRollingPage extends StatefulWidget {
  const _DiceRollingPage();

  @override
  State<_DiceRollingPage> createState() => _DiceRollingPageState();
}

class _DiceRollingPageState extends State<_DiceRollingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  int _greenIndex = 0;
  int _redIndex = 0;
  bool _settled = false;

  static const _greenFaces = ['rabbit', 'lamb', 'pig', 'cow', 'wolf'];
  static const _redFaces = ['rabbit', 'lamb', 'pig', 'horse', 'fox'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _settled = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _roll() {
    final rng = math.Random();
    setState(() {
      _greenIndex = rng.nextInt(_greenFaces.length);
      _redIndex = rng.nextInt(_redFaces.length);
      _settled = false;
    });
    _controller.forward(from: 0);
  }

  String _assetPath(String name) {
    // Map to animal asset or predator asset
    final animal = Animal.values.where((a) => a.label.toLowerCase() == name);
    if (animal.isNotEmpty) return animal.first.assetPath;
    return 'assets/images/$name.svg';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.casino,
      title: l10n.tutorialDiceTitle,
      description: l10n.tutorialDiceDesc,
      illustration: Column(
        children: [
          AnimatedBuilder(
            animation: _rotation,
            builder: (context, child) {
              final angle = _settled ? 0.0 : _rotation.value;
              return Transform.rotate(angle: angle, child: child);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DemoDie(
                  color: const Color(0xFF2E7D32),
                  label: l10n.greenDie,
                  assetPath: _assetPath(_greenFaces[_greenIndex]),
                ),
                const SizedBox(width: 20),
                _DemoDie(
                  color: const Color(0xFFC62828),
                  label: l10n.redDie,
                  assetPath: _assetPath(_redFaces[_redIndex]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _roll,
            icon: const Icon(Icons.casino, size: 20),
            label: Text(l10n.tryRolling),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoDie extends StatelessWidget {
  const _DemoDie({
    required this.color,
    required this.label,
    required this.assetPath,
  });

  final Color color;
  final String label;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3: Breeding
// ---------------------------------------------------------------------------

class _BreedingPage extends StatefulWidget {
  const _BreedingPage();

  @override
  State<_BreedingPage> createState() => _BreedingPageState();
}

class _BreedingPageState extends State<_BreedingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _popScale;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _popScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _demonstrate() {
    setState(() => _showResult = true);
    _popController.forward(from: 0);
  }

  void _reset() {
    _popController.reverse().then((_) {
      if (mounted) setState(() => _showResult = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.pets,
      title: l10n.tutorialBreedingTitle,
      description: l10n.tutorialBreedingDesc,
      illustration: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Example: You have 3 rabbits, roll 2 rabbits
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _countLabel(theme, l10n.youHave, '3'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      Animal.rabbit.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 16),
                  _countLabel(theme, l10n.rolled, '2'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      Animal.rabbit.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_showResult)
                ScaleTransition(
                  scale: _popScale,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_downward,
                            color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.breedingResult,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _showResult
                  ? TextButton(
                      onPressed: _reset, child: Text(l10n.reset))
                  : FilledButton.tonal(
                      onPressed: _demonstrate,
                      child: Text(l10n.showResult),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countLabel(ThemeData theme, String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 4: Trading
// ---------------------------------------------------------------------------

class _TradingPage extends StatelessWidget {
  const _TradingPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final trades = [
      (l10n.trade6Rabbits, Animal.rabbit, l10n.trade1Lamb, Animal.lamb),
      (l10n.trade2Lambs, Animal.lamb, l10n.trade1Pig, Animal.pig),
      (l10n.trade3Pigs, Animal.pig, l10n.trade1Cow, Animal.cow),
      (l10n.trade2Cows, Animal.cow, l10n.trade1Horse, Animal.horse),
    ];
    return _TutorialPageLayout(
      icon: Icons.swap_horiz,
      title: l10n.tutorialTradingTitle,
      description: l10n.tutorialTradingDesc,
      illustration: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              for (int i = 0; i < trades.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _TradeRow(
                  fromLabel: trades[i].$1,
                  fromAnimal: trades[i].$2,
                  toLabel: trades[i].$3,
                  toAnimal: trades[i].$4,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({
    required this.fromLabel,
    required this.fromAnimal,
    required this.toLabel,
    required this.toAnimal,
  });

  final String fromLabel;
  final Animal fromAnimal;
  final String toLabel;
  final Animal toAnimal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(fromAnimal.assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(fromLabel, style: theme.textTheme.bodyMedium),
          ),
          Icon(
            Icons.arrow_forward,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: Text(
              toLabel,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(toAnimal.assetPath, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 5: Guard Dogs
// ---------------------------------------------------------------------------

class _GuardDogsPage extends StatelessWidget {
  const _GuardDogsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.shield,
      title: l10n.tutorialDogsTitle,
      description: l10n.tutorialDogsDesc,
      illustration: Column(
        children: [
          _DogInfoCard(
            dog: Animal.smallDog,
            protectsAgainst: l10n.blocksFox,
            protectsIcon: 'assets/images/fox.svg',
            cost: l10n.trade1Lamb,
            costAnimal: Animal.lamb,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _DogInfoCard(
            dog: Animal.bigDog,
            protectsAgainst: l10n.blocksWolf,
            protectsIcon: 'assets/images/wolf.svg',
            cost: l10n.trade1Cow,
            costAnimal: Animal.cow,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

class _DogInfoCard extends StatelessWidget {
  const _DogInfoCard({
    required this.dog,
    required this.protectsAgainst,
    required this.protectsIcon,
    required this.cost,
    required this.costAnimal,
    required this.color,
  });

  final Animal dog;
  final String protectsAgainst;
  final String protectsIcon;
  final String cost;
  final Animal costAnimal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: SvgPicture.asset(dog.assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedAnimalName(context, dog),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.shield, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        protectsAgainst,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(protectsIcon,
                            fit: BoxFit.contain),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.sell, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(l10n.costLabel(cost), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 6: Fox & Wolf Attacks
// ---------------------------------------------------------------------------

class _AttacksPage extends StatefulWidget {
  const _AttacksPage();

  @override
  State<_AttacksPage> createState() => _AttacksPageState();
}

class _AttacksPageState extends State<_AttacksPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeOffset = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      } else if (status == AnimationStatus.dismissed && _isShaking) {
        setState(() => _isShaking = false);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    setState(() => _isShaking = true);
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.warning_amber,
      title: l10n.tutorialAttacksTitle,
      description: l10n.tutorialAttacksDesc,
      illustration: Column(
        children: [
          _AttackCard(
            predatorAsset: 'assets/images/fox.svg',
            attackTitle: l10n.foxAttackTitle,
            effect: l10n.foxEffect,
            guardLabel: l10n.smallDogSavesRabbits,
            guardAsset: Animal.smallDog.assetPath,
            color: Colors.red.shade700,
            shakeAnimation: _shakeOffset,
            isShaking: _isShaking,
          ),
          const SizedBox(height: 12),
          _AttackCard(
            predatorAsset: 'assets/images/wolf.svg',
            attackTitle: l10n.wolfAttackTitle,
            effect: l10n.wolfEffect,
            guardLabel: l10n.bigDogSavesHerd,
            guardAsset: Animal.bigDog.assetPath,
            color: Colors.blueGrey.shade700,
            shakeAnimation: _shakeOffset,
            isShaking: _isShaking,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _isShaking ? null : _triggerShake,
            child: Text(l10n.simulateAttack),
          ),
        ],
      ),
    );
  }
}

class _AttackCard extends StatelessWidget {
  const _AttackCard({
    required this.predatorAsset,
    required this.attackTitle,
    required this.effect,
    required this.guardLabel,
    required this.guardAsset,
    required this.color,
    required this.shakeAnimation,
    required this.isShaking,
  });

  final String predatorAsset;
  final String attackTitle;
  final String effect;
  final String guardLabel;
  final String guardAsset;
  final Color color;
  final Animation<double> shakeAnimation;
  final bool isShaking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final offset =
            isShaking ? math.sin(shakeAnimation.value * math.pi * 4) * 6 : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Card(
        color: isShaking
            ? color.withValues(alpha: 0.08)
            : theme.cardTheme.color,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child:
                    SvgPicture.asset(predatorAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attackTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(effect, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: SvgPicture.asset(guardAsset,
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            guardLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 7: Win Condition
// ---------------------------------------------------------------------------

class _WinConditionPage extends StatefulWidget {
  const _WinConditionPage();

  @override
  State<_WinConditionPage> createState() => _WinConditionPageState();
}

class _WinConditionPageState extends State<_WinConditionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  static const _winAnimals = [
    Animal.rabbit,
    Animal.lamb,
    Animal.pig,
    Animal.cow,
    Animal.horse,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _TutorialPageLayout(
      icon: Icons.emoji_events,
      title: l10n.tutorialWinTitle,
      description: l10n.tutorialWinDesc,
      illustration: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.collectOneOfEach,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_winAnimals.length, (i) {
                      // Stagger the bounce
                      final delay = i * 0.15;
                      final t =
                          ((_bounceController.value + delay) % 1.0);
                      final offset = math.sin(t * math.pi) * -8;
                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: SvgPicture.asset(
                                _winAnimals[i].assetPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green.shade600,
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.firstToWin,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
