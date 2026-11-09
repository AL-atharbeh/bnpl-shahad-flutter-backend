import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/ui.dart';
import '../finance/finance_page.dart';
import '../finance/settlements_page.dart';
import '../notifications/notifications_page.dart';
import 'api_credentials_page.dart';
import 'profile_page.dart';
import 'store_settings_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Future<void> _logout(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      message: context.trNow('logoutConfirm'),
      confirmLabel: context.trNow('logout'),
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await context.read<SessionService>().logout();
    }
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    final language = context.watch<LanguageService>();
    final vendor = session.vendor ?? const {};

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(bottom: GlassBottomNav.clearance(context)),
        children: [
          PageHeader(title: context.tr('account')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (vendor['email'] != null)
                          Text(
                            '${vendor['email']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('verifiedPartner'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.trending_up_rounded,
                title: context.tr('finance'),
                subtitle: context.tr('financeDescription'),
                onTap: () => _push(context, const FinancePage()),
              ),
              _MenuTile(
                icon: Icons.account_balance_outlined,
                title: context.tr('settlementHistory'),
                subtitle: context.tr('settlementHistoryDetail'),
                onTap: () => _push(context, const SettlementsPage()),
              ),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                title: context.tr('notifications'),
                subtitle: context.tr('notificationsDetail'),
                onTap: () => _push(context, const NotificationsPage()),
              ),
              _MenuTile(
                icon: Icons.storefront_outlined,
                title: context.tr('storeSettings'),
                subtitle: context.tr('manageProfile'),
                onTap: () => _push(context, const StoreSettingsPage()),
              ),
              _MenuTile(
                icon: Icons.key_rounded,
                title: context.tr('apiCredentials'),
                subtitle: context.tr('apiCredentialsDetail'),
                onTap: () => _push(context, const ApiCredentialsPage()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.person_outline_rounded,
                title: context.tr('myProfile'),
                subtitle: context.tr('myProfileDetail'),
                onTap: () => _push(context, const ProfilePage()),
              ),
              _MenuTile(
                icon: Icons.translate_rounded,
                title: context.tr('switchLanguage'),
                trailing: Text(
                  language.isArabic ? 'العربية' : 'English',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                onTap: language.toggle,
              ),
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                title: context.tr('privacyPolicy'),
                onTap: () => _open('https://shahedapp.com/privacy'),
              ),
              _MenuTile(
                icon: Icons.description_outlined,
                title: context.tr('termsOfUse'),
                onTap: () => _open('https://shahedapp.com/terms'),
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: context.tr('logout'),
                color: AppColors.error,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(indent: 68, endIndent: 16),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final destructive = color == AppColors.error;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: destructive ? AppColors.error : AppColors.heading,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textHint),
            ),
      trailing:
          trailing ??
          (destructive
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                )),
    );
  }
}
