import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';

class BNPLBusinessPage extends StatefulWidget {
  const BNPLBusinessPage({super.key});

  @override
  State<BNPLBusinessPage> createState() => _BNPLBusinessPageState();
}

class _BNPLBusinessPageState extends State<BNPLBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.bnplForBusiness),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: isRTL ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, textDirection: TextDirection.ltr, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: isRTL ? [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, textDirection: TextDirection.ltr, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'شهد للأعمال',
                    style: TextStyle(
                      fontFamily: 'Changa',
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'انضم إلى شهد للأعمال وقدم لعملائك تجربة دفع مرنة، مبتكرة وسلسة للغاية',
                    style: TextStyle(
                      fontFamily: 'Mada',
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Benefits Section
            Text(
              'مزايا الانضمام لشهد للأعمال',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 16),

            _buildBenefitCard(
              icon: Icons.trending_up_rounded,
              title: 'زيادة المبيعات والنمو',
              description: 'حقق نمواً في مبيعاتك بنسبة تصل إلى 40% من خلال تمكين عملائك من الشراء الفوري والتقسيط المريح.',
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.payment_rounded,
              title: 'تقسيط مرن وبدون فوائد',
              description: 'امنح عملائك تجربة تقسيط مرنة ومريحة على دفعات ميسرة تماماً دون أي فوائد أو رسوم إضافية مخفية.',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.security_rounded,
              title: 'تحصيل آمن وتسوية فورية',
              description: 'احصل على كامل قيمة مبيعاتك فورياً، بينما نتولى نحن إدارة وتحصيل الأقساط المستقبلية بشكل آمن بالكامل.',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.analytics_rounded,
              title: 'تحليلات ذكية ولوحة تحكم',
              description: 'تابع نمو أعمالك لحظياً من خلال لوحة تحكم ذكية وشاملة توفر رؤى تفصيلية حول المبيعات وسلوك العملاء.',
              color: Colors.purple,
            ),
            const SizedBox(height: 32),

            // Registration Form
            Text(
              'سجل شركتك الآن',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _companyNameController,
                    label: 'اسم الشركة / العلامة التجارية',
                    icon: Icons.business_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل اسم الشركة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _contactPersonController,
                    label: 'اسم الشخص المسؤول عن التواصل',
                    icon: Icons.person_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل اسم الشخص المسؤول';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني للعمل',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'بريد إلكتروني غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف للتواصل',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _websiteController,
                    label: 'الموقع الإلكتروني أو صفحة السوشيال ميديا (اختياري)',
                    icon: Icons.language_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'وصف مختصر لنشاطكم التجاري',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل وصف النشاط التجاري';
                      }
                      if (value.length < 20) {
                        return 'الوصف قصير جداً (أدخل 20 حرفاً على الأقل)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button - Emerald Gradient
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'تقديم طلب الانضمام',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات التواصل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo('البريد الإلكتروني', 'support@shahedapp.com'),
                  _buildContactInfo('الهاتف', '+962 7 7671 9225'),
                  _buildContactInfo('ساعات العمل', 'الأحد - الخميس: 9:00 ص - 6:00 م'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلبك بنجاح! سنتواصل معك قريباً'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _companyNameController.clear();
      _contactPersonController.clear();
      _emailController.clear();
      _phoneController.clear();
      _websiteController.clear();
      _descriptionController.clear();
    }
  }
}
