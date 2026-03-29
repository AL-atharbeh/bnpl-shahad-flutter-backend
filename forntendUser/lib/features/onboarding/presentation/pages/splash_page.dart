import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/security_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───
  late AnimationController _entranceController;  // Snappy Pop-in
  late AnimationController _parallaxController;  // BG Parallax Flow
  late AnimationController _floatController;     // Dual-axis Drifting
  late AnimationController _bgFadeController;    // Global Color Shift
  
  // ─── Entrance Animations ───
  late Animation<double> _scaleAmount;
  late Animation<double> _opacityAmount;
  late Animation<double> _slideOffset;

  // ─── Global Color Shift ───
  late Animation<Color?> _bgColor;

  // ─── Cinematic Color Palette ───
  static const Color emeraldBright = Color(0xFF10A37F);
  static const Color emeraldDark = Color(0xFF042F1F);
  static const Color emeraldDeep = Color(0xFF01120B);

  @override
  void initState() {
    super.initState();

    // 1. BG Color Fade: Vibrant -> Deep
    _bgFadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _bgColor = ColorTween(
      begin: emeraldDark,
      end: emeraldDeep,
    ).animate(CurvedAnimation(
      parent: _bgFadeController,
      curve: Curves.easeInOutSine,
    ));

    // 2. Entrance: Snappy Elastic Pop
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _scaleAmount = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutBack),
      ),
    );
    _opacityAmount = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _slideOffset = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    // 3. Parallax Background Flow
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // 4. Advanced 3D-like Floating (Dual Sine Waves)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _runSequencedAnimations();
  }

  void _runSequencedAnimations() async {
    // Stage 1: BG starts shifted slightly and Entrance begins
    _bgFadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _entranceController.forward();

    // Stage 2: Navigation
    await Future.delayed(const Duration(milliseconds: 3800));
    if (mounted) {
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      final authService = AuthService();
      final isLoggedIn = await authService.autoLogin();

      if (!mounted) return;

      if (isLoggedIn) {
        final token = await authService.getSavedToken();
        if (token != null) {
          authService.setAuthToken(token);
          try {
            final securityService = SecurityService();
            final settingsResponse =
                await securityService.getSecuritySettings();
            if (!mounted) return;
            if (settingsResponse['success']) {
              final backendData = settingsResponse['data'];
              final settingsData = backendData['data'] ?? backendData;
              final pinEnabled = settingsData['pinEnabled'] ?? false;
              if (pinEnabled) {
                AppRouter.navigateToPinLoginCinematic(context);
              } else {
                AppRouter.navigateToHomeCinematic(context);
              }
            } else {
              AppRouter.navigateToHomeCinematic(context);
            }
          } catch (e) {
            if (mounted) AppRouter.navigateToHomeCinematic(context);
          }
        } else {
          AppRouter.navigateToPhoneInputCinematic(context);
        }
      } else {
        AppRouter.navigateToPhoneInputCinematic(context);
      }
    } else {
      AppRouter.navigateToOnboardingCinematic(context);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _parallaxController.dispose();
    _floatController.dispose();
    _bgFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgFadeController, _parallaxController]),
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: _bgColor.value ?? emeraldDark,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Layer 1: Parallax Paritcles (Back Deep) ──
                _buildParallaxLayer(0.2, emeraldBright.withOpacity(0.05)),

                // ── Layer 2: Parallax Digital Lines (Mid) ──
                _buildDigitalFlowLayer(size, emeraldBright.withOpacity(0.08)),

                // ── Layer 3: Parallax Particles (Front Close) ──
                _buildParallaxLayer(0.6, Colors.white.withOpacity(0.1)),

                // ── Layer 4: Snappy Cinematic Mascot ──
                _buildCinematicMascot(size),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParallaxLayer(double speedFactor, Color color) {
    return CustomPaint(
      painter: _MotionPainter(
        progress: _parallaxController.value,
        speedFactor: speedFactor,
        color: color,
        type: _MotionType.particles,
      ),
    );
  }

  Widget _buildDigitalFlowLayer(Size size, Color color) {
    return CustomPaint(
      painter: _MotionPainter(
        progress: _parallaxController.value,
        speedFactor: 0.4,
        color: color,
        type: _MotionType.lines,
      ),
    );
  }

  Widget _buildCinematicMascot(Size size) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _floatController]),
        builder: (context, _) {
          // Dual Sine-wave Floating
          final t = _floatController.value * 2 * pi;
          final xOffset = sin(t) * 12.0;
          final yOffset = cos(t * 1.5) * 8.0;
          final rotation = sin(t * 0.5) * 0.03;

          return Transform.translate(
            offset: Offset(xOffset, _slideOffset.value + yOffset),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: _scaleAmount.value,
                child: Opacity(
                  opacity: _opacityAmount.value,
                  child: Image.asset(
                    'assets/images/splashscreen.png',
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _MotionType { particles, lines }

class _MotionPainter extends CustomPainter {
  final double progress;
  final double speedFactor;
  final Color color;
  final _MotionType type;

  _MotionPainter({
    required this.progress,
    required this.speedFactor,
    required this.color,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(type == _MotionType.particles ? 777 : 888);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final effectiveProgress = (progress * speedFactor) % 1.0;

    if (type == _MotionType.particles) {
      for (int i = 0; i < 40; i++) {
        final baseX = rng.nextDouble() * size.width;
        final baseY = rng.nextDouble() * size.height;
        
        // Drifting motion
        final x = (baseX + effectiveProgress * size.width * 0.5) % size.width;
        final y = (baseY - effectiveProgress * size.height * 0.3) % size.height;
        
        final pSize = 1.0 + rng.nextDouble() * 2.5;
        canvas.drawCircle(Offset(x, y), pSize, paint);
      }
    } else {
      // Digital Flow Lines
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 0.5;
      for (int i = 0; i < 12; i++) {
        final y = (rng.nextDouble() * size.height + effectiveProgress * size.height) % size.height;
        final length = 50.0 + rng.nextDouble() * 100;
        final x = rng.nextDouble() * size.width;
        
        canvas.drawLine(Offset(x, y), Offset(x + length, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MotionPainter oldDelegate) => true;
}
