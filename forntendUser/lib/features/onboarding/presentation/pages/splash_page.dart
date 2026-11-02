import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/security_service.dart';
import '../widgets/assembling_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ─── Animation Controllers ───
  late AnimationController _assembleController;
  late AnimationController _settleController;
  late AnimationController _exitController;

  // ─── Animations ───
  late Animation<double> _assemble;
  late Animation<double> _settle;
  late Animation<double> _wordmark;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    // The slices fly in and lock together.
    _assembleController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _assemble = CurvedAnimation(
      parent: _assembleController,
      curve: Curves.easeOutCubic,
    );

    // A short pulse once the pieces meet, so the assembly has a landing.
    _settleController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _settle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOut),
    );
    _wordmark = CurvedAnimation(
      parent: _settleController,
      curve: const Interval(0.25, 1, curve: Curves.easeOut),
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_exitController);
    _exitScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _runSplashSequence();
  }

  void _runSplashSequence() async {
    await _assembleController.forward();
    if (!mounted) return;

    await _settleController.forward();
    if (!mounted) return;

    // Lets the finished mark hold for a beat before it leaves.
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    await _exitController.forward();
    if (mounted) _navigateNext();
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
              final biometricEnabled = settingsData['biometricEnabled'] ?? false;
              
              if (pinEnabled || biometricEnabled) {
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
    _assembleController.dispose();
    _settleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_settleController, _exitController]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Container(
              decoration: const BoxDecoration(
                // A quiet gradient instead of one flat fill, so the mark has
                // something to sit on.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F6E9), Color(0xFFC8E6C9)],
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: _exitScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _settle.value,
                        child: AssemblingLogo(
                          progress: _assemble,
                          size: 170,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // The name arrives once the mark is whole, so the two do
                      // not compete for attention.
                      Opacity(
                        opacity: _wordmark.value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - _wordmark.value)),
                          child: const Text(
                            'شِهد',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B7A32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: _wordmark.value,
                        child: const Text(
                          'اشترِ الآن وادفع لاحقاً',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF3F7A4E),
                          ),
                        ),
                      ),
                    ],
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
