import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/gur_bhatti_app.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/data/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const GurBhattiApp(),
    ),
  );
}
