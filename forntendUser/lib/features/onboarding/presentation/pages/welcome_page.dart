import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/welcome_hero.dart';
import '../widgets/primary_cta.dart';
import '../../../../services/language_service.dart';
import '../../../../routing/app_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Entrance animation - plays only once on initial load
  late AnimationController _entranceAnimationController;
  late Animation<double> _entranceFadeAnimation;
  late Animation<Offset> _entranceSlideAnimation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'onboardingTitle1',
      'description': 'onboardingDescription1',
      'image': 'assets/images/onboarding_1.png',
    },
    {
      'title': 'onboardingTitle2',
      'description': 'onboardingDescription2',
      'image': 'assets/images/onboarding_2.png',
    },
    {
      'title': 'onboardingTitle3',
      'description': 'onboardingDescription3',
      'image': 'assets/images/onboarding_3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Entrance animation controller - plays once
    _entranceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _entranceFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceAnimationController,
      curve: Curves.easeInOut,
    ));

    _entranceSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _entranceAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

     void _completeOnboarding() async {
     // Save that user has seen onboarding
     final prefs = await SharedPreferences.getInstance();
     await prefs.setBool('has_seen_onboarding', true);
     
     // Navigate to phone input page (new auth system)
     if (mounted) {
       Navigator.pushNamedAndRemoveUntil(
         context,
         AppRouter.phoneInput,
         (route) => false,
       );
     }
   }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // No animation reset — PageView handles smooth sliding between pages
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: SafeArea(
              child: FadeTransition(
                opacity: _entranceFadeAnimation,
                child: SlideTransition(
                  position: _entranceSlideAnimation,
                  child: Column(
                    children: [
                      // Top buttons row (Skip and Language)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Language toggle button
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _toggleLanguage();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getCurrentLanguageText(),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Skip button
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          l10n.skip,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
                // Page content — PageView handles smooth horizontal sliding
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = _onboardingData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            // Top padding
                            const SizedBox(height: 40),
                            
                            // Hero image
                            Expanded(
                              flex: 3,
                              child: WelcomeHero(
                                imagePath: data['image']!,
                                isActive: index == _currentPage,
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Title
                            Text(
                              _getLocalizedString(l10n, data['title']!),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Description
                            Text(
                              _getLocalizedString(l10n, data['description']!),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            
                // Bottom section with indicators and buttons
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Navigation buttons
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          key: ValueKey<int>(_currentPage > 0 ? 1 : 0),
                          children: [
                            // Previous button (only show if not first page)
                            if (_currentPage > 0) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousPage,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(l10n.previous),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            
                            // Next/Get Started button
                            Expanded(
                              child: PrimaryCTA(
                                text: _currentPage == _onboardingData.length - 1
                                    ? l10n.getStarted
                                    : l10n.next,
                                onPressed: _nextPage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
                ),
              ),
          ),
    );
      },
    );
  }

  String _getLocalizedString(AppLocalizations l10n, String key) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    if (languageService.isArabic) {
      // Return Arabic text
      switch (key) {
        case 'onboardingTitle1':
          return 'أهلا وسهلا… يلا نبلّش';
        case 'onboardingTitle2':
          return 'رتّب مصروفك على كيفك';
        case 'onboardingTitle3':
          return 'تعامل مضمون ١٠٠٪';
        case 'onboardingDescription1':
          return 'اشتري اللي بدّك ياه هسّا… والدفع بعدين، ع رواق.';
        case 'onboardingDescription2':
          return 'قسّط دفعاتك على أشهر، وخلي بالك فاضي.';
        case 'onboardingDescription3':
          return 'دفعك آمن ومحمي… وانت مطمّن بكل خطوة.';
        default:
          return key;
      }
    } else {
      // Return English text
      switch (key) {
        case 'onboardingTitle1':
          return 'Welcome... Let\'s Start';
        case 'onboardingTitle2':
          return 'Organize Your Expenses';
        case 'onboardingTitle3':
          return '100% Secure Transactions';
        case 'onboardingDescription1':
          return 'Buy what you want now... and pay later, with ease.';
        case 'onboardingDescription2':
          return 'Split your payments over months, and keep your mind at ease.';
        case 'onboardingDescription3':
          return 'Your payment is secure and protected... and you\'re reassured at every step.';
        default:
          return key;
      }
    }
  }

  String _getCurrentLanguageText() {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    return languageService.isArabic ? 'EN' : 'عربي';
  }

  void _toggleLanguage() async {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    await languageService.toggleLanguage();
    
    // Show a snackbar to indicate language change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageService.isArabic ? 'تم تغيير اللغة إلى العربية' : 'Language changed to English',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
