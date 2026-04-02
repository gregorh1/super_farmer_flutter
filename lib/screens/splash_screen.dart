import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../widgets/farm_decorations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  late final AnimationController _animalBobController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _animalBobController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _animalBobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Fence decoration along bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 20,
            child: CustomPaint(
              painter: FencePainter(
                fenceColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Hay texture above fence
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            height: 14,
            child: CustomPaint(
              painter: HayTexturePainter(
                color: Colors.white.withValues(alpha: 0.1),
                seed: 7,
              ),
            ),
          ),
          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Barn + animal icon
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          // Barn background
                          CustomPaint(
                            size: const Size(120, 120),
                            painter: BarnPainter(),
                          ),
                          // Bobbing rabbit in front of the barn
                          Positioned(
                            bottom: 4,
                            left: 0,
                            right: 0,
                            child: AnimatedBuilder(
                              animation: _animalBobController,
                              builder: (context, child) {
                                final t = _animalBobController.value;
                                final bob =
                                    -3.0 * (0.5 - (t - 0.5).abs()) * 2;
                                return Transform.translate(
                                  offset: Offset(0, bob),
                                  child: child,
                                );
                              },
                              child: Center(
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: SvgPicture.asset(
                                    'assets/images/rabbit.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n?.appTitle ?? 'Super Farmer',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.collectYourAnimals ?? 'Collect your animals!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
