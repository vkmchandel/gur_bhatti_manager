import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/gur_bhatti_app.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/data/auth_provider.dart';
import 'features/farmer/data/farmer_provider.dart';
import 'features/farmer/data/repositories/demo_farmer_repository.dart';
import 'features/procurement/data/procurement_provider.dart';
import 'features/procurement/data/repositories/demo_procurement_repository.dart';
import 'features/session/data/session_provider.dart';
import 'features/session/data/repositories/demo_session_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => FarmerProvider(DemoFarmerRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProcurementProvider(DemoProcurementRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(DemoSessionRepository()),
        ),
      ],
      child: const GurBhattiApp(),
    ),
  );
}
