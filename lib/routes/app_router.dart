import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/models/dream_model.dart';
import '../data/models/transaction_model.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/cashflow/add_transaction_screen.dart';
import '../presentation/cashflow/cashflow_screen.dart';
import '../presentation/cashflow/edit_transaction_screen.dart';
import '../presentation/cashflow/transaction_detail_screen.dart';
import '../presentation/dreams/add_dream_screen.dart';
import '../presentation/dreams/dream_detail_screen.dart';
import '../presentation/dreams/dreams_screen.dart';
import '../presentation/dreams/edit_dream_screen.dart';
import '../presentation/history/history_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/profile/app_info_screen.dart';
import '../presentation/profile/faq_screen.dart';
import '../presentation/profile/help_screen.dart';
import '../presentation/profile/invite_member_screen.dart';
import '../presentation/profile/manage_members_screen.dart';
import '../presentation/profile/privacy_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/home/cashflow';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/cashflow',
                builder: (context, state) => const CashflowScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddTransactionScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final tx = state.extra as TransactionModel;
                      return EditTransactionScreen(tx: tx);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final tx = state.extra as TransactionModel;
                      return TransactionDetailScreen(tx: tx);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/history',
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddTransactionScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final tx = state.extra as TransactionModel;
                      return EditTransactionScreen(tx: tx);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final tx = state.extra as TransactionModel;
                      return TransactionDetailScreen(tx: tx);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dreams',
                builder: (context, state) => const DreamsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddDreamScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final dream = state.extra as DreamModel;
                      return EditDreamScreen(dream: dream);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final dream = state.extra as DreamModel;
                      return DreamDetailScreen(dream: dream);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'invite',
                    builder: (context, state) => const InviteMemberScreen(),
                  ),
                  GoRoute(
                    path: 'members',
                    builder: (context, state) => const ManageMembersScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                  GoRoute(
                    path: 'faq',
                    builder: (context, state) => const FaqScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const PrivacyScreen(),
                  ),
                  GoRoute(
                    path: 'app-info',
                    builder: (context, state) => const AppInfoScreen(),
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
