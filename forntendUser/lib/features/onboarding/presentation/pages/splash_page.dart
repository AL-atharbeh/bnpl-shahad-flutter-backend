import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _logoSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoAnimationController.forward();
    
    // Start pulse animation after logo appears
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseAnimationController.repeat(reverse: true);
    
    // Start fade animation for text
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeAnimationController.forward();
    
    // Check onboarding status and navigate accordingly after 3 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      // Restore system UI before navigation
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      // Check if user has seen onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (hasSeenOnboarding) {
        // User has seen onboarding, check if logged in
        final authService = AuthService();
        final isLoggedIn = await authService.autoLogin();
        
        print('🚀 SplashPage - hasSeenOnboarding: $hasSeenOnboarding, isLoggedIn: $isLoggedIn');
        
        if (isLoggedIn) {
          // User is logged in, check if PIN is enabled
          final token = await authService.getSavedToken();
          if (token != null) {
            authService.setAuthToken(token);
            
            // Check if PIN is enabled
            try {
              final securityService = SecurityService();
              final settingsResponse = await securityService.getSecuritySettings();
              
              if (settingsResponse['success']) {
                final backendData = settingsResponse['data'];
                final settingsData = backendData['data'] ?? backendData;
                final pinEnabled = settingsData['pinEnabled'] ?? false;
                
                print('🔐 PIN Enabled: $pinEnabled');
                
                if (pinEnabled) {
                  // PIN is enabled, go to PIN login
                  AppRouter.navigateToPinLogin(context);
                } else {
                  // PIN not enabled, go to home directly
                  AppRouter.navigateToHome(context);
                }
              } else {
                // Failed to get settings, go to home
                AppRouter.navigateToHome(context);
              }
            } catch (e) {
              print('❌ Error checking PIN status: $e');
              // On error, go to home
              AppRouter.navigateToHome(context);
            }
          } else {
            // No token, go to phone input
            AppRouter.navigateToPhoneInput(context);
          }
        } else {
          // User is not logged in, go to phone input
          AppRouter.navigateToPhoneInput(context);
        }
      } else {
        // User hasn't seen onboarding, show it first
        AppRouter.navigateToOnboarding(context);
      }
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoAnimationController,
                      _pulseAnimationController,
                    ]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _logoSlideAnimation.value),
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value * _pulseAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'BNPL',
                                  style: GoogleFonts.changa(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // App name and tagline
              Expanded(
                flex: 1,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.appName,
                        style: GoogleFonts.changa(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buy Now, Pay Later',
                        style: GoogleFonts.mada(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loading indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
