import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = context.watch<LanguageService>();
    final isRTL = lang.isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.language,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // الحالية
          _CurrentLanguageCard(
            title: isRTL ? 'اللغة الحالية' : 'Current language',
            value: lang.isArabic ? 'العربية' : 'English',
          ),
          const SizedBox(height: 20),

          const _SectionHeader(icon: Icons.translate, title: 'اختر اللغة'),
          const SizedBox(height: 10),

          // العربية
          _LanguageOptionTile(
            flag: '🇯🇴',
            title: 'العربية',
            subtitle: 'Arabic',
            selected: lang.isArabic,
            onTap: () => _setLang(lang, 'ar', l10n),
          ),
          const SizedBox(height: 10),

          // الإنجليزية
          _LanguageOptionTile(
            flag: '🇺🇸',
            title: 'English',
            subtitle: 'الإنجليزية',
            selected: lang.isEnglish,
            onTap: () => _setLang(lang, 'en', l10n),
          ),

          const SizedBox(height: 24),

          // مساعدة
          _HelpCard(
            title: isRTL ? 'مساعدة' : 'Help',
            text: isRTL
                ? 'يمكنك تغيير اللغة في أي وقت. سيتم تطبيق التغييرات فورًا على التطبيق.'
                : 'You can change the language anytime. Changes apply instantly across the app.',
          ),
        ],
      ),
    );
  }

  void _setLang(LanguageService lang, String code, AppLocalizations l10n) {
    if ((code == 'ar' && lang.isArabic) || (code == 'en' && lang.isEnglish)) return;

    lang.setLanguage(code);
    _toast(code == 'ar' ? 'تم تغيير اللغة إلى العربية' : 'Language changed to English');
  }



  void _toast(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : const Color(0xFF111827),
    ));
  }
}

// ======================= UI Helpers =======================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF111827)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _CurrentLanguageCard extends StatelessWidget {
  final String title;
  final String value;
  const _CurrentLanguageCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.language, color: Colors.white, size: 44),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF111827) : const Color(0xFFE6ECF3);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6))],
          ),
          child: ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 28)),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? const Color(0xFF111827) : Colors.black,
              ),
            ),
            subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            trailing: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF111827) : Colors.transparent,
                border: Border.all(color: const Color(0xFF9CA3AF)),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}



class _HelpCard extends StatelessWidget {
  final String title;
  final String text;
  const _HelpCard({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline, color: Color(0xFF1D4ED8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: Color(0xFF1D4ED8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
