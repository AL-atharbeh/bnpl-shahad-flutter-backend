import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/services/id_ocr_service.dart';
import 'civil_id_scanner_page.dart';
import '../widgets/auth_scaffold.dart';

class CivilIdCapturePage extends StatefulWidget {
  final String phoneNumber;

  const CivilIdCapturePage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<CivilIdCapturePage> createState() => _CivilIdCapturePageState();
}

class _CivilIdCapturePageState extends State<CivilIdCapturePage> {
  final ImagePicker _picker = ImagePicker();
  final IdOcrService _ocrService = IdOcrService();
  
  XFile? _frontImage;
  XFile? _backImage;
  bool _isLoading = false;
  String _loadingText = '';
  
  // 0: تصوير الجهة الأمامية، 1: تصوير الجهة الخلفية، 2: مراجعة الصورتين ومتابعة الـ OCR
  int _currentStep = 0;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    final isArabic = Provider.of<LanguageService>(context, listen: false).isArabic;
    final instruction = isArabic 
        ? 'ضع وجه الهوية الأمامي داخل الإطار للمسح' 
        : 'Place the front of your ID inside the frame';

    try {
      final String? imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => CivilIdScannerPage(instruction: instruction),
        ),
      );

      if (imagePath != null) {
        final image = XFile(imagePath);
        setState(() {
          if (_currentStep == 0) {
            _frontImage = image;
            _currentStep = 1; // الانتقال للخطوة التالية تلقائياً
          } else if (_currentStep == 1) {
            _backImage = image;
            _currentStep = 2; // الذهاب لصفحة المراجعة
          } else {
            _frontImage = image;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم التقاط الصورة بنجاح'
                  : 'Photo captured successfully'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _captureBackImage() async {
    final isArabic = Provider.of<LanguageService>(context, listen: false).isArabic;
    final instruction = isArabic 
        ? 'ضع ظهر الهوية الخلفي داخل الإطار للمسح' 
        : 'Place the back of your ID inside the frame';

    try {
      final String? imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => CivilIdScannerPage(instruction: instruction),
        ),
      );

      if (imagePath != null) {
        final image = XFile(imagePath);
        setState(() {
          _backImage = image;
          _currentStep = 2; // الذهاب لصفحة المراجعة
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم التقاط الصورة بنجاح'
                  : 'Photo captured successfully'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _handleContinue() async {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseUploadBothSides),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingText = Provider.of<LanguageService>(context, listen: false).isArabic
          ? 'جاري فحص وقراءة الهوية رقمياً بالـ OCR واستخراج البيانات الكاملة...'
          : 'Scanning & reading ID digitally with OCR. Extracting details...';
    });

    try {
      // تشغيل معالجة الـ OCR تلقائياً
      final ocrResult = await _ocrService.extractData(
        frontImagePath: _frontImage!.path,
        backImagePath: _backImage!.path,
      );

      debugPrint('OCR Extraction Result: $ocrResult');

      if (mounted) {
        setState(() => _isLoading = false);

        // الانتقال لصفحة إكمال الملف مع البيانات المستخرجة
        Navigator.pushNamed(
          context,
          AppRouter.completeProfile,
          arguments: {
            'phoneNumber': widget.phoneNumber,
            'frontIdPath': _frontImage!.path,
            'backIdPath': _backImage!.path,
            'extractedName': ocrResult.fullName,
            'extractedCivilId': ocrResult.nationalId,
            'extractedDob': ocrResult.dateOfBirth,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل مسح الهوية تلقائياً. يرجى إدخال البيانات يدوياً'),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // الانتقال اليدوي كخيار احتياطي
        Navigator.pushNamed(
          context,
          AppRouter.completeProfile,
          arguments: {
            'phoneNumber': widget.phoneNumber,
            'frontIdPath': _frontImage!.path,
            'backIdPath': _backImage!.path,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Real scanning animation indicator
                _buildRealScanningProgressIndicator(isRTL),
                const SizedBox(height: 32),
                Text(
                  _loadingText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isRTL ? 'يرجى الانتظار، لا تغلق هذه الصفحة' : 'Please wait, do not close this page',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final titles = [
      isRTL ? 'صوّر وجه الهوية' : 'Photograph the front',
      isRTL ? 'صوّر ظهر الهوية' : 'Photograph the back',
      isRTL ? 'راجع الصورتين' : 'Check both photos',
    ];
    final subtitles = [
      isRTL
          ? 'ضع البطاقة داخل الإطار في ضوء جيد، وتجنّب انعكاس الضوء على السطح.'
          : 'Place the card inside the frame in good light, and avoid glare.',
      isRTL
          ? 'اقلب البطاقة وصوّر الوجه الآخر بنفس الطريقة.'
          : 'Turn the card over and photograph the other side the same way.',
      isRTL
          ? 'تأكد أن البيانات واضحة ومقروءة قبل المتابعة.'
          : 'Make sure the details are sharp and readable before continuing.',
    ];

    return AuthScaffold(
      step: 3,
      title: titles[_currentStep],
      subtitle: subtitles[_currentStep],
      // Back moves between the three sub-steps before it leaves the screen, so
      // a mistaken photo does not cost the whole step.
      onBack: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        } else {
          Navigator.of(context).pop();
        }
      },
      action: AuthPrimaryButton(
        label: l10n.continueButton,
        isLoading: _isLoading,
        onPressed: _canContinue ? _handleContinue : null,
      ),
      children: [
        if (_currentStep == 0)
          _buildFrontStepView(isRTL)
        else if (_currentStep == 1)
          _buildBackStepView(isRTL)
        else
          _buildReviewStepView(isRTL, l10n),
      ],
    );
  }

  /// The action waits until the step it belongs to is actually done.
  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _frontImage != null;
      case 1:
        return _backImage != null;
      default:
        return _frontImage != null && _backImage != null;
    }
  }

  Widget _buildFrontStepView(bool isRTL) {
    return _buildScannerFrame(
      image: _frontImage,
      label: isRTL ? 'اضغط لتصوير الوجه الأمامي' : 'Tap to photograph the front',
      onTap: _captureImage,
    );
  }

  Widget _buildBackStepView(bool isRTL) {
    return _buildScannerFrame(
      image: _backImage,
      label: isRTL ? 'اضغط لتصوير الوجه الخلفي' : 'Tap to photograph the back',
      onTap: _captureBackImage,
    );
  }

  Widget _buildReviewStepView(bool isRTL, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isRTL ? 'مراجعة المسح الضوئي' : 'Review ID Scans',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isRTL 
              ? 'الرجاء التأكد من أن النصوص والأرقام واضحة ومقروءة تماماً في كلا الوجهين.' 
              : 'Please ensure that the text and numbers are completely clear and readable on both sides.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Front Image Card
        _buildCapturedCard(
          title: isRTL ? 'الوجه الأمامي الممسوح' : 'Scanned Front Side',
          image: _frontImage!,
          onRetake: () {
            setState(() {
              _currentStep = 0;
            });
            _captureImage();
          },
          l10n: l10n,
        ),
        
        const SizedBox(height: 20),
        
        // Back Image Card
        _buildCapturedCard(
          title: isRTL ? 'الوجه الخلفي الممسوح' : 'Scanned Back Side',
          image: _backImage!,
          onRetake: () {
            setState(() {
              _currentStep = 1;
            });
            _captureBackImage();
          },
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildScannerFrame({
    required XFile? image,
    required String label,
    required VoidCallback onTap,
  }) {
    return AspectRatio(
      // The ISO ID-1 ratio every national ID card is cut to, so the target is
      // the shape of the thing being photographed.
      aspectRatio: 1.585,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Image.file(File(image.path), fit: BoxFit.cover)
              else ...[
                // The laser belongs to a live frame; before capture it reads as
                // a cue that scanning is what this area is for.
                const Positioned.fill(child: _ScanLaserAnimation()),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        // A card, not a QR glyph: this photographs an ID, and a
                        // QR code is a different thing entirely.
                        Icons.badge_outlined,
                        size: 40,
                        color: AppColors.primary.withOpacity(0.55),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Brackets mark the edges to line the card up with; a full border
              // would read as a container rather than a target.
              ..._buildFrameCorners(),

              if (image != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFrameCorners() {
    const double size = 22;
    const double thickness = 5;
    final color = AppColors.primary;

    return [
      // Top Left
      Positioned(
        top: 10,
        left: 10,
        child: Container(
          width: size,
          height: thickness,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Positioned(
        top: 10,
        left: 10,
        child: Container(
          width: thickness,
          height: size,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      // Top Right
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          width: size,
          height: thickness,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          width: thickness,
          height: size,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: 10,
        left: 10,
        child: Container(
          width: size,
          height: thickness,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Positioned(
        bottom: 10,
        left: 10,
        child: Container(
          width: thickness,
          height: size,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: 10,
        right: 10,
        child: Container(
          width: size,
          height: thickness,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 10,
        child: Container(
          width: thickness,
          height: size,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    ];
  }

  Widget _buildCapturedCard({
    required String title,
    required XFile image,
    required VoidCallback onRetake,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              TextButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة مسح' : 'Rescan',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealScanningProgressIndicator(bool isRTL) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Icon(
            Icons.document_scanner_rounded,
            size: 44,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Dynamic moving scan laser animation
class _ScanLaserAnimation extends StatefulWidget {
  const _ScanLaserAnimation();

  @override
  State<_ScanLaserAnimation> createState() => _ScanLaserAnimationState();
}

class _ScanLaserAnimationState extends State<_ScanLaserAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: _animation.value * 180, // Move line up & down based on container height
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.08),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Clipper for card viewport (darkens outside the cutout area)
class CardScannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(16, 16, size.width - 16, size.height - 16),
      const Radius.circular(16),
    );

    return Path.combine(
      PathOperation.difference,
      path,
      Path()..addRRect(cutoutRect),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
