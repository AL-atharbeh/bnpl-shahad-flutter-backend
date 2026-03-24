import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/app_router.dart';

class CompleteProfilePage extends StatefulWidget {
  final String phoneNumber;
  final String frontIdPath;
  final String backIdPath;

  const CompleteProfilePage({
    super.key,
    required this.phoneNumber,
    required this.frontIdPath,
    required this.backIdPath,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _civilIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _employerController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _civilIdController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _monthlyIncomeController.dispose();
    _employerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1950),
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار تاريخ الميلاد'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // تحويل تاريخ الميلاد إلى صيغة YYYY-MM-DD
      final dateOfBirth = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // إنشاء الحساب مع جميع البيانات
      final result = await authService.createAccountWithProfile(
        phoneNumber: widget.phoneNumber,
        fullName: _fullNameController.text.trim(),
        civilId: _civilIdController.text.trim(),
        frontIdPath: widget.frontIdPath,
        backIdPath: widget.backIdPath,
        dateOfBirth: dateOfBirth,
        address: _addressController.text.trim(),
        monthlyIncome: _monthlyIncomeController.text.trim(),
        employer: _employerController.text.trim(),
      );

      if (!result['success']) {
        if (mounted) {
          setState(() => _isLoading = false);
          
          // إذا كان الخطأ 409 (رقم الهاتف مستخدم)، عرض رسالة خاصة
          final statusCode = result['statusCode'];
          final errorMessage = result['error'] ?? 'فشل إنشاء الحساب';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: statusCode == 409 ? Colors.orange.shade400 : Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
              action: statusCode == 409
                  ? SnackBarAction(
                      label: 'تسجيل الدخول',
                      textColor: Colors.white,
                      onPressed: () {
                        // العودة لصفحة إدخال رقم الهاتف
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.phoneInput,
                          (route) => false,
                        );
                      },
                    )
                  : null,
            ),
          );
        }
        return;
      }

      // تم حفظ Token في authService.createAccountWithProfile
      if (mounted) {
        setState(() => _isLoading = false);

        // إرسال FCM token إلى الـ backend
        print('🔐 Account created successfully, updating FCM token...');
        try {
          final firebaseService = Provider.of<FirebaseService>(context, listen: false);
          await firebaseService.updateTokenOnServer(null);
          print('✅ FCM token update initiated');
        } catch (e) {
          print('⚠️ Failed to update FCM token: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountCreatedSuccessfully),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ. يرجى المحاولة مرة أخرى: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.completYourProfile,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _ProgressDot(isCompleted: true),
                _ProgressLine(isCompleted: true),
                _ProgressDot(isCompleted: true),
                _ProgressLine(isCompleted: true),
                _ProgressDot(isCompleted: false, isCurrent: true),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.almostThere,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isRTL
                          ? 'املأ المعلومات التالية'
                          : 'Complete the information',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _CustomTextField(
                      controller: _fullNameController,
                      label: l10n.fullName,
                      hint: isRTL ? 'الاسم الكامل' : 'Full Name',
                      icon: Icons.person_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء إدخال الاسم'
                              : 'Please enter name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: _civilIdController,
                      label: l10n.civilIdNumber,
                      hint: '1234567890',
                      icon: Icons.badge_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء إدخال رقم الهوية'
                              : 'Please enter ID number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: _dobController,
                      label: l10n.dateOfBirth,
                      hint: 'DD/MM/YYYY',
                      icon: Icons.cake_rounded,
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء اختيار التاريخ'
                              : 'Please select date';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: _addressController,
                      label: l10n.address,
                      hint: isRTL ? 'العنوان' : 'Address',
                      icon: Icons.location_on_rounded,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء إدخال العنوان'
                              : 'Please enter address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: _monthlyIncomeController,
                      label: l10n.monthlyIncome,
                      hint: '500',
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      suffixText: 'JOD',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء إدخال الدخل'
                              : 'Please enter income';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: _employerController,
                      label: l10n.employer,
                      hint: isRTL ? 'جهة العمل' : 'Employer',
                      icon: Icons.business_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isRTL
                              ? 'الرجاء إدخال جهة العمل'
                              : 'Please enter employer';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, size: 20),
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final String? suffixText;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;

  const _ProgressDot({
    required this.isCompleted,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted || isCurrent ? AppColors.primary : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.white,
            )
          : isCurrent
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final bool isCompleted;

  const _ProgressLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}
