import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/language_service.dart';
import '../../../../services/contact_service.dart';
import '../../../../services/auth_service.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final ContactService _contactService = ContactService();
  
  bool _isLoading = true;
  bool _isSending = false;
  
  String? _contactEmail;
  String? _contactPhone;
  String? _whatsappNumber;

  // حقول بسيطة
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _messageCtl = TextEditingController();
  final _phoneCtl = TextEditingController();

  List<String> _categories = [];
  String _selectedCategory = '';
   
  @override
  void initState() {
    super.initState();
    _loadContactSettings();
  }

  Future<void> _loadContactSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // محاولة جلب بيانات المستخدم أولاً (إذا كان مسجل دخول)
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final profileResponse = await authService.getProfile();
        
        if (profileResponse['success']) {
          final backendResponse = profileResponse['data'];
          final innerData = backendResponse?['data'] ?? backendResponse;
          final user = innerData?['user'] ?? innerData;
          
          // ملء الحقول من بيانات المستخدم
          if (mounted) {
            setState(() {
              _nameCtl.text = user?['name'] ?? '';
              _emailCtl.text = user?['email'] ?? '';
              _phoneCtl.text = user?['phone'] ?? '';
            });
          }
        }
      } catch (e) {
        // المستخدم غير مسجل دخول - لا بأس
        print('⚠️ User not logged in: $e');
      }
      
      // جلب إعدادات التواصل من Backend
      final response = await _contactService.getContactSettings();
      
      if (response['success']) {
        final data = response['data'];
        setState(() {
          _contactEmail = data['contactEmail'];
          _contactPhone = data['contactPhone'];
          _whatsappNumber = data['whatsappNumber'];
          _isLoading = false;
        });
      } else {
        // استخدام القيم الافتراضية إذا فشل جلب الإعدادات
        setState(() {
          _contactEmail = 'athatbehahmed99@gmail.com';
          _contactPhone = '+962792380449';
          _whatsappNumber = '962792380449';
          _isLoading = false;
        });
      }
    } catch (e) {
      // استخدام القيم الافتراضية في حالة الخطأ
      setState(() {
        _contactEmail = 'athatbehahmed99@gmail.com';
        _contactPhone = '+962792380449';
        _whatsappNumber = '962792380449';
        _isLoading = false;
      });
    }
  }
   
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      _updateCategories();
    }
  }
   
  void _updateCategories() {
    final l10n = AppLocalizations.of(context)!;
    _categories = [
      l10n.generalInquiry,
      l10n.technicalIssue,
      l10n.paymentBilling,
      l10n.suggestion,
      l10n.complaint,
    ];
    if (_selectedCategory.isEmpty || !_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _messageCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
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
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          l10n.contactUs,
          style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
          // بطاقة معلومات مختصرة + أزرار سريعة
          _ContactHeader(
            contactPhone: _contactPhone ?? '+962792380449',
            contactEmail: _contactEmail ?? 'athatbehahmed99@gmail.com',
            whatsappNumber: _whatsappNumber ?? '962792380449',
            onCall: _callHotline,
            onEmail: _sendEmail,
            onWhatsApp: _openWhatsApp,
          ),
          const SizedBox(height: 16),

          // فئات الرسائل (ChoiceChips)
          _SectionCard(
            title: l10n.messageType,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _selectedCategory == c;
                return ChoiceChip(
                  label: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  selected: selected,
                  selectedColor: const Color(0xFF111827),
                  backgroundColor: const Color(0xFFF2F4F7),
                  onSelected: (_) => setState(() => _selectedCategory = c),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // النموذج
          _SectionCard(
            title: l10n.contactInfo,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _Field(
                    controller: _nameCtl,
                    label: l10n.fullName,
                    hint: l10n.nameExample,
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterYourName : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _emailCtl,
                    label: l10n.email,
                    hint: l10n.emailHint,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return l10n.enterYourEmail;
                      final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(s);
                      return ok ? null : l10n.invalidEmail;
                    },
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _phoneCtl,
                    label: l10n.phoneOptional,
                    hint: l10n.phoneHint,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _messageCtl,
                    label: l10n.message,
                    hint: l10n.messageHint,
                    icon: Icons.chat_bubble_outline_rounded,
                    maxLines: 5,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return l10n.enterYourMessage;
                      if (s.length < 10) return l10n.messageTooShort;
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // زر الإرسال
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _submit,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSending ? 'جاري الإرسال...' : l10n.send,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======== Actions ========

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);

    try {
      final response = await _contactService.sendContactMessage(
        fullName: _nameCtl.text.trim(),
        email: _emailCtl.text.trim(),
        phone: _phoneCtl.text.trim(),
        message: _messageCtl.text.trim(),
        category: _selectedCategory,
      );

      if (response['success']) {
        final l10n = AppLocalizations.of(context)!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? l10n.messageSentSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // مسح الحقول بعد الإرسال الناجح
          _nameCtl.clear();
          _emailCtl.clear();
          _phoneCtl.clear();
          _messageCtl.clear();
          setState(() {
            _selectedCategory = _categories.first;
            _isSending = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'فشل إرسال الرسالة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _whatsappNumber ?? '962792380449';
    final msg = Uri.encodeComponent('مرحبًا، أحتاج مساعدة.');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _fallbackToast(l10n.whatsappError);
    }
  }

  Future<void> _callHotline() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _contactPhone ?? '+962792380449';
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _fallbackToast(l10n.callError);
    }
  }

  Future<void> _sendEmail() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _contactEmail ?? 'athatbehahmed99@gmail.com';
    final uri = Uri.parse('mailto:$email?subject=Support&body=');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _fallbackToast(l10n.emailError);
    }
  }

  void _fallbackToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ================== UI PARTS ==================

class _ContactHeader extends StatelessWidget {
  final String contactPhone;
  final String contactEmail;
  final String whatsappNumber;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  const _ContactHeader({
    required this.contactPhone,
    required this.contactEmail,
    required this.whatsappNumber,
    required this.onCall,
    required this.onEmail,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
                     Row(
             children: [
               const Icon(Icons.support_agent_rounded, color: Color(0xFF111827)),
               const SizedBox(width: 10),
               Expanded(
                 child: Text(
                   l10n.customerSupport,
                   style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                 ),
               ),
             ],
           ),
          const SizedBox(height: 14),
                     Row(
             children: [
               Expanded(child: _QuickAction(icon: Icons.phone, label: l10n.call, onTap: onCall)),
               const SizedBox(width: 8),
               Expanded(child: _QuickAction(icon: Icons.email_outlined, label: l10n.email, onTap: onEmail)),
               const SizedBox(width: 8),
               Expanded(
                 child: _QuickAction(
                   icon: Icons.chat, // لا يوجد WhatsApp ضمن Material، نستخدم شات بلون واتساب
                   label: l10n.whatsapp,
                   onTap: onWhatsApp,
                   tint: const Color(0xFF25D366),
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color tint;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tint, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: tint,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF111827)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
