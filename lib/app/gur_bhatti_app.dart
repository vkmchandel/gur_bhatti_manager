import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';

import '../core/providers/locale_provider.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class GurBhattiApp extends StatelessWidget {
  const GurBhattiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      title: 'GurBhattiManager',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
    );
  }
}
