import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/security_service.dart';
import '../../../../services/banner_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

enum SplashStage { logo, loading }

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ─── Dynamic Splash Image ───
  String? _splashImageUrl;
  bool _isNetworkImage = false;
  SplashStage _currentStage = SplashStage.logo;

  // ─── Animation Controllers ───
  late AnimationController _logoController;
  late AnimationController _stageTransitionController;
  late AnimationController _progressController; // For the shimmering progress bar
  late AnimationController _exitController;

  // ─── Animations ───
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _loadingStageOpacity;
  late Animation<double> _progressAnimation;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _loadCachedSplash();

    // Set status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // 1. Stage 1: Logo Animations
    _logoController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    
    _logoOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_logoController);
    
    _logoScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // 2. Stage Transition
    _stageTransitionController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _loadingStageOpacity = CurvedAnimation(
      parent: _stageTransitionController,
      curve: Curves.easeIn,
    );

    // 3. Progress Bar (Stage 2)
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // 4. Global Exit
    _exitController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_exitController);
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _runSplashSequence();
  }

  void _runSplashSequence() async {
    // Stage 1: Show White Logo Screen
    await _logoController.forward();

    // Stage 2: Transition to Loading Image
    if (mounted) {
      setState(() => _currentStage = SplashStage.loading);
      _stageTransitionController.forward();
      _progressController.forward();
    }

    // Fetch new splash in background
    _fetchNewSplash(); 
    
    // Wait for progress to finish
    await Future.delayed(const Duration(milliseconds: 3200));

    // Stage 3: Exit & Navigate
    if (mounted) {
      await _exitController.forward();
      _navigateNext();
    }
  }

  Future<void> _loadCachedSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString('cached_splash_url');
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      if (mounted) {
        setState(() {
          _splashImageUrl = cachedUrl;
          _isNetworkImage = cachedUrl.startsWith('http');
        });
        if (_isNetworkImage) {
          precacheImage(NetworkImage(cachedUrl), context).catchError((_) => null);
        }
      }
    }
  }

  Future<void> _fetchNewSplash() async {
    try {
      final bannerService = BannerService();
      final response = await bannerService.getSplashBanner();
      if (response['success'] && response['data'] != null) {
        final backendBody = response['data'];
        final configData = backendBody['data'];
        if (configData != null) {
          final String? newUrl = configData['splashImageUrl'];
          if (newUrl != null && newUrl.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cached_splash_url', newUrl);
            if (mounted && newUrl != _splashImageUrl) {
              setState(() {
                _splashImageUrl = newUrl;
                _isNetworkImage = newUrl.startsWith('http');
              });
            }
          }
        }
      }
    } catch (e) {}
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
            final settingsResponse = await securityService.getSecuritySettings();
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
    _logoController.dispose();
    _stageTransitionController.dispose();
    _progressController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitOpacity,
            child: ScaleTransition(
              scale: _exitScale,
              child: child,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Stage 1: Brand Introduction ──
            if (_currentStage == SplashStage.logo)
              Container(
                color: Colors.white,
                child: Center(
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Image.asset(
                        'assets/images/logoshah.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Stage 2: Dynamic Admin Splash & Progress ──
            if (_currentStage == SplashStage.loading)
              FadeTransition(
                opacity: _loadingStageOpacity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dynamic Image with Fallback
                    _buildDynamicImage(),
                    
                    // Dark Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                        ),
                      ),
                    ),

                    // Shimmering Progress Bar ("Scroll Bar")
                    Positioned(
                      left: 45,
                      right: 45,
                      bottom: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildProgressPercentage(),
                          const SizedBox(height: 20),
                          _buildUnmatchedProgressBar(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicImage() {
    if (_splashImageUrl != null && _isNetworkImage) {
      return Image.network(
        _splashImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/splah.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/images/splah.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildProgressPercentage() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        final percent = (_progressAnimation.value * 100).toInt();
        return Text(
          '$percent%',
          style: const TextStyle(
            color: Color(0xFF10A37F),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildUnmatchedProgressBar() {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF042F1F), Color(0xFF10A37F), Colors.white],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10A37F).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildShimmerEffect(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(seconds: 2),
      builder: (context, shine, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Transform.translate(
            offset: Offset(shine * 200, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.3), Colors.white.withOpacity(0)],
                  stops: const [0.3, 0.5, 0.7],
                ),
              ),
            ),
          ),
        );
      },
      onEnd: () {}, 
    );
  }
}
