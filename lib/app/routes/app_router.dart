import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/methods/screens/methods_screen.dart';
import '../../features/methods/screens/method_detail_screen.dart';
import '../../features/methods/screens/method_form_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/orders/screens/trade_detail_screen.dart';
import '../../features/psychology/psychology_screen.dart';
import '../../core/api/supabase_api.dart';
import '../../core/models/trade_method_model.dart';
import '../../core/models/trade_model.dart';

// Route names
class AppRoutes {
  static const String dashboard = '/';
  static const String methods = '/methods';
  static const String methodDetail = '/methods/:id';
  static const String methodCreate = '/methods/create';
  static const String methodEdit = '/methods/edit/:id';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String psychology = '/psychology';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
}

// Router provider
final goRouterProvider = Provider<GoRouter>((ref) {
  // We'll implement auth checking here
  final authService = ref.watch(authServiceProvider);

  // Navigation bar key
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final isLoggedIn = authService.isLoggedIn;
      final isLoggingIn =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If logged in and on login/register page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      // No redirect needed
      return null;
    },
    // Add an onGenerateRoute handler for named routes
    onException: (_, GoRouterState state, GoRouter router) {
      // On exception, redirect to login
      router.go(AppRoutes.login);
    },
    routes: [
      // Auth routes (outside the shell)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const AuthScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const AuthScreen(initialMode: true),
            ),
      ),

      // Main app routes with bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard branch
          StatefulShellBranch(
            navigatorKey: shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),

          // Orders branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: OrdersScreen()),
                routes: [
                  // Trade detail screen
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final tradeId = state.pathParameters['id']!;
                      final trade = state.extra as Trade?;
                      return MaterialPage(
                        key: state.pageKey,
                        child: TradeDetailScreen(
                          tradeId: tradeId,
                          trade: trade,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Psychology branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.psychology,
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: PsychologyScreen()),
              ),
            ],
          ),

          // Methods branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/methods',
                name: 'methods',
                builder: (context, state) => const MethodsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'methodCreate',
                    builder: (context, state) => const MethodFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'methodEdit',
                    builder: (context, state) {
                      final methodId = state.pathParameters['id']!;
                      final method = state.extra as TradeMethod?;
                      return MethodFormScreen(method: method);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'methodDetail',
                    builder: (context, state) {
                      final methodId = state.pathParameters['id']!;
                      final method = state.extra as TradeMethod?;
                      return method != null
                          ? MethodDetailScreen(method: method)
                          : const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Simple auth service class
class AuthService {
  // Kiểm tra thực sự đăng nhập qua Supabase thay vì luôn return true
  bool get isLoggedIn => SupabaseApi.instance.isAuthenticated;
}

// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({Key? key, required this.navigationShell})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Psychology',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Methods',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index);
  }
}
