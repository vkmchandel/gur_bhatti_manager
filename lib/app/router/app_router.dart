import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/farmer/presentation/farmer_ledger_screen.dart';
import '../../features/farmer/presentation/farmer_screen.dart';
import '../../features/farmer/presentation/register_farmer_screen.dart';
import '../../features/procurement/presentation/add_procurement_screen.dart';
import '../../features/procurement/presentation/procurement_log_screen.dart';
import '../../features/session/presentation/session_management_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../widgets/app_shell_scaffold.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farmers',
                name: 'farmers',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: FarmerScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'register',
                    name: 'farmers-register',
                    builder: (context, state) => const RegisterFarmerScreen(),
                  ),
                  GoRoute(
                    path: ':farmerId',
                    name: 'farmers-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['farmerId']!;
                      return FarmerLedgerScreen(farmerId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'farmers-edit',
                        builder: (context, state) {
                          final id = state.pathParameters['farmerId']!;
                          return RegisterFarmerScreen(farmerId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/procurement',
                name: 'procurement',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: ProcurementLogScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'procurement-add',
                    builder: (context, state) => const AddProcurementScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: SettingsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'sessions',
                    name: 'settings-sessions',
                    builder: (context, state) => const SessionManagementScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
