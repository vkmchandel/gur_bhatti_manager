import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/gur_bhatti_app.dart';
import 'core/providers/locale_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const GurBhattiApp(),
    ),
  );
}
