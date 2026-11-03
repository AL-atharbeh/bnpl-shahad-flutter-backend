import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/merchant_api.dart';
import 'core/l10n/language_service.dart';
import 'core/session/session_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/shell/merchant_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await initializeDateFormatting();

  final language = LanguageService();
  final session = SessionService(MerchantApi(ApiClient()));
  await Future.wait([language.load(), session.restore()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: language),
        ChangeNotifierProvider.value(value: session),
      ],
      child: const MerchantApp(),
    ),
  );
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageService>();
    final signedIn = context.select<SessionService, bool>((s) => s.isSignedIn);

    return MaterialApp(
      title: language.tr('appName'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: language.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Keyed on the account so signing out drops every tab's state.
      home: signedIn
          ? MerchantShell(key: ValueKey(context.read<SessionService>().storeId))
          : const LoginPage(),
    );
  }
}
