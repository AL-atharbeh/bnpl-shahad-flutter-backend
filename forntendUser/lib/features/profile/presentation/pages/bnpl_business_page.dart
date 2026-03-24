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
      appBar: AppBar(
        title: Text(l10n.bnplForBusiness),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
                  colors: [Color(0xFF111827), Color(0xFF374151)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'BNPL للأعمال',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'انضم إلينا وقدم لعملائك تجربة دفع مرنة ومتطورة',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Benefits Section
            Text(
              'مزايا الانضمام',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            _buildBenefitCard(
              icon: Icons.trending_up,
              title: 'زيادة المبيعات',
              description: 'زيادة معدل التحويل بنسبة تصل إلى 40%',
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.payment,
              title: 'دفع مرن',
              description: 'امنح عملائك خيارات دفع متعددة',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.security,
              title: 'أمان عالي',
              description: 'حماية متقدمة للمعاملات والبيانات',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildBenefitCard(
              icon: Icons.analytics,
              title: 'تقارير مفصلة',
              description: 'احصل على رؤى شاملة عن أداء مبيعاتك',
              color: Colors.purple,
            ),
            const SizedBox(height: 32),

            // Registration Form
            Text(
              'سجل شركتك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _companyNameController,
                    label: 'اسم الشركة',
                    icon: Icons.business,
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
                    label: 'الشخص المسؤول',
                    icon: Icons.person,
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
                    label: 'البريد الإلكتروني',
                    icon: Icons.email,
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
                    label: 'رقم الهاتف',
                    icon: Icons.phone,
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
                    label: 'الموقع الإلكتروني (اختياري)',
                    icon: Icons.language,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'وصف النشاط التجاري',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل وصف النشاط التجاري';
                      }
                      if (value.length < 20) {
                        return 'الوصف قصير جداً';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إرسال الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                  _buildContactInfo('البريد الإلكتروني', 'business@bnpl.com'),
                  _buildContactInfo('الهاتف', '+962 79 123 4567'),
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
          borderSide: const BorderSide(color: Color(0xFF111827), width: 2),
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
