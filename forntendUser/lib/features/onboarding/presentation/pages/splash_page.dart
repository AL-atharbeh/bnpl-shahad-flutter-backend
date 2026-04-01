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
  late AnimationController _progressController; // For the loading bar
  late AnimationController _exitController;     // Fade out before exit

  // ─── Progress Animation ───
  late Animation<double> _progressAnimation;

  // ─── Colors ───
  static const Color emeraldBright = Color(0xFF10A37F);
  static const Color emeraldDeep = Color(0xFF01120B);

  @override
  void initState() {
    super.initState();

    // 1. Progress Bar Animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // 2. Exit Fade
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _runSequencedAnimations();
  }

  void _runSequencedAnimations() async {
    // Start loading bar
    _progressController.forward();

    // Wait for the bar to finish (matching controller duration)
    await Future.delayed(const Duration(milliseconds: 3200));
    
    // Start exit animation
    if (mounted) {
      await _exitController.forward();
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
    _progressController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ──
          Image.asset(
            'assets/images/splah.png',
            fit: BoxFit.cover,
          ),

          // ── Dark gradient overlay at bottom for text readability ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ),

          // ── Premium Loading System ──
          Positioned(
            left: 45,
            right: 45,
            bottom: 90,
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_exitController),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Dynamic Status Text
                  _buildPremiumStatusText(),
                  const SizedBox(height: 30),
                  
                  // 2. The "Unmatched" Progress Bar
                  _buildUnmatchedProgressBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusText() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        final percent = (_progressAnimation.value * 100).toInt();
        return Column(
          children: [
            Text(
              'جاري تهيئة نظام شهد',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 4)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Color(0xFF10A37F),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace', // Gives a digital premium feel
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnmatchedProgressBar() {
    return Container(
      height: 14,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glassmorphic Track Layer
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Progress Fill with Shimmer
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF042F1F),
                        Color(0xFF10A37F),
                        Color(0xFF2ECC71),
                        Colors.white,
                      ],
                      stops: [0.0, 0.4, 0.9, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10A37F).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Animated Shine/Shimmer
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: -1.0, end: 2.0),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, shine, _) {
                            return Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(shine * 200, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.4),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                      stops: const [0.3, 0.5, 0.7],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onEnd: () {}, // Handled by standard rebuild
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Focal Point Glow (The "Head" of the progress)
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              if (_progressAnimation.value <= 0) return const SizedBox.shrink();
              return Positioned(
                left: (MediaQuery.of(context).size.width - 90) * _progressAnimation.value - 12,
                top: -10,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withOpacity(0.8),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                    gradient: const RadialGradient(
                      colors: [Colors.white, Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

