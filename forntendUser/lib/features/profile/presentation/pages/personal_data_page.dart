import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/auth_service.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;

  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _nationalIdController  = TextEditingController();
  final _emailController       = TextEditingController();
  final _phoneController       = TextEditingController();
  final _addressController     = TextEditingController();

  XFile? _selectedAvatar;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.getProfile();

      if (response['success']) {
        final backendResponse = response['data'];
        final innerData = backendResponse?['data'] ?? backendResponse;
        final user = innerData?['user'] ?? innerData;

        // تقسيم الاسم إلى اسم أول واسم أخير
        final fullName = user?['name'] ?? '';
        final nameParts = fullName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _nationalIdController.text = user?['civilIdNumber'] ?? '';
          _emailController.text = user?['email'] ?? '';
          _phoneController.text = user?['phone'] ?? '';
          _addressController.text = user?['address'] ?? '';
          _currentAvatarUrl = user?['avatarUrl'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'فشل تحميل البيانات'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = context.watch<LanguageService>().isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: const Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          l10n.personalData,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderCard(
              isRTL: isRTL,
              onChangePhoto: _pickAvatar,
              avatarFile: _selectedAvatar,
              avatarUrl: _currentAvatarUrl,
            ),
            const SizedBox(height: 16),

            // ===== البيانات الأساسية =====
            _SectionCard(
              title: l10n.personalData,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: l10n.firstName,
                        hint: l10n.firstName,
                        icon: Icons.person_outline,
                        controller: _firstNameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterName : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: l10n.lastName,
                        hint: l10n.lastName,
                        icon: Icons.person_outline,
                        controller: _lastNameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterName : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                                 _LabeledField(
                   label: l10n.nationalId,
                   hint: '##########',
                   icon: Icons.badge_outlined,
                   controller: _nationalIdController,
                   keyboardType: TextInputType.number,
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                   enabled: false, // جعل الحقل غير قابل للتعديل
                   validator: (v) {
                     final s = (v ?? '').trim();
                     if (s.isEmpty) return l10n.enterNationalId;
                     if (s.length < 8) return l10n.nationalIdTooShort;
                     return null;
                   },
                 ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== معلومات التواصل (بدلاً من "تواصل معنا") =====
            const _SectionTitleSpacer(),
                         _SectionCard(
               title: l10n.contactInfo,
               children: [
                                 _LabeledField(
                   label: l10n.email,
                   hint: l10n.emailHint,
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                                     validator: (v) {
                     final s = (v ?? '').trim();
                     if (s.isEmpty) return l10n.enterEmail;
                     final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(s);
                     return ok ? null : l10n.invalidEmail;
                   },
                ),
                const SizedBox(height: 12),
                                 _LabeledField(
                   label: l10n.phoneNumber,
                   hint: l10n.phoneHint,
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                                     validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterPhone : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== العنوان =====
            const _SectionTitleSpacer(),
                         _SectionCard(
               title: l10n.address,
               children: [
                                  _LabeledField(
                   label: l10n.address,
                   hint: l10n.addressHint,
                  icon: Icons.location_on_outlined,
                  controller: _addressController,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _savePersonalData,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              _isSaving ? 'جاري الحفظ...' : l10n.save,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        setState(() {
          _selectedAvatar = image;
          _currentAvatarUrl = null; // إخفاء الصورة القديمة عند اختيار صورة جديدة
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم اختيار الصورة بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF111827)),
                title: Text('التقاط صورة'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF111827)),
                title: Text('اختيار من المعرض'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _imageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = imageFile.path.split('.').last.toLowerCase();
      final mime = mimeType == 'jpg' || mimeType == 'jpeg' 
          ? 'image/jpeg' 
          : 'image/png';
      return 'data:$mime;base64,$base64String';
    } catch (e) {
      print('❌ Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _savePersonalData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // دمج الاسم الأول والأخير
        final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
        
        // تحويل الصورة إلى Base64 إذا كانت موجودة
        String? avatarBase64;
        if (_selectedAvatar != null) {
          avatarBase64 = await _imageToBase64(_selectedAvatar!);
          if (avatarBase64 == null) {
            setState(() => _isSaving = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('فشل تحويل الصورة. يرجى المحاولة مرة أخرى'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
        
        final response = await authService.updateProfile(
          name: fullName,
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          phone: _phoneController.text.trim(),
          avatar: avatarBase64,
        );

        if (response['success']) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _selectedAvatar = null; // مسح الصورة المختارة بعد الحفظ
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.dataSavedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            // إعادة تحميل البيانات للحصول على avatarUrl الجديد
            await _loadUserData();
            // العودة للصفحة السابقة بعد ثانية
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          }
        } else {
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['error'] ?? 'فشل حفظ البيانات'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ---------------- Widgets ----------------

class _HeaderCard extends StatelessWidget {
  final bool isRTL;
  final VoidCallback onChangePhoto;
  final XFile? avatarFile;
  final String? avatarUrl;
  const _HeaderCard({
    required this.isRTL,
    required this.onChangePhoto,
    this.avatarFile,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF3F8),
                  boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))],
                ),
                child: avatarFile != null
                    ? ClipOval(
                        child: Image.file(
                          File(avatarFile!.path),
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      )
                    : avatarUrl != null && avatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : const Icon(Icons.person, size: 40, color: Color(0xFF9CA3AF)),
              ),
              Positioned(
                bottom: -2,
                right: isRTL ? null : -2,
                left: isRTL ? -2 : null,
                child: InkWell(
                  onTap: onChangePhoto,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
                     Expanded(
             child: Text(
               l10n.updateYourData,
               style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
             ),
           ),
          TextButton.icon(
            onPressed: onChangePhoto,
            icon: const Icon(Icons.edit_outlined, size: 18),
                         label: Text(l10n.edit),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              backgroundColor: const Color(0xFFF2F4F7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitleSpacer extends StatelessWidget {
  const _SectionTitleSpacer({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? const Color(0xFF111827) : const Color(0xFF6B7280),
      ),
              decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
          ),
          hintText: hint,
          prefixIcon: Icon(
            icon, 
            color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
          ),
          filled: true,
          fillColor: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF111827), width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
        ),
    );
  }
}
