import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/login_page.dart';
import '../core/prefs.dart';
import '../data/user_repository.dart';
import '../game/engine/difficulty.dart';
import '../game/pages/game_page.dart';
import '../game/pages/level_select_page.dart';
import '../history/history_page.dart';
import '../ranking/ranking_page.dart';
import '../settings/settings_page.dart';
import '../shell/app_shell.dart';

abstract final class Routes {
  static const login = '/login';
  static const play = '/play';
  static const ranking = '/ranking';
  static const history = '/history';
  static const settings = '/settings';

  static String game(Difficulty level) => '/play/game/${level.name}';

  /// Pages that can be reopened when the app restarts.
  static bool isRestorable(String? location) {
    if (location == null) return false;
    final path = Uri.tryParse(location)?.path ?? '';
    if ([play, ranking, history, settings].contains(path)) return true;
    final match = RegExp(r'^/play/game/(\w+)$').firstMatch(path);
    return match != null &&
        Difficulty.values.any((d) => d.name == match.group(1));
  }
}

/// Fade + slide transition used by every page.
Page<void> _page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

/// Notifies go_router whenever the signed-in user changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  final auth = ref.read(firebaseAuthProvider);
  final refresh = _AuthRefresh(auth.authStateChanges());

  String savedOrHome() {
    final saved = prefs.getString(PrefKeys.lastLocation);
    return Routes.isRestorable(saved) ? saved! : Routes.play;
  }

  final router = GoRouter(
    initialLocation: savedOrHome(),
    refreshListenable: refresh,
    // Unknown links go back to the home page.
    onException: (context, state, router) => router.go(Routes.play),
    redirect: (context, state) {
      final signedIn = auth.currentUser != null;
      final path = state.uri.path;
      if (!signedIn) return path == Routes.login ? null : Routes.login;
      // Signed in: leave the login page / root and go back to where the
      // player was the last time the app was open.
      if (path == Routes.login || path == '/' || path.isEmpty) {
        return savedOrHome();
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.play),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => _page(state, const LoginPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.play,
                pageBuilder: (context, state) =>
                    _page(state, const LevelSelectPage()),
                routes: [
                  GoRoute(
                    path: 'game/:level',
                    pageBuilder: (context, state) => _page(
                      state,
                      GamePage(
                        key: ValueKey(state.pathParameters['level']),
                        level: Difficulty.fromName(
                          state.pathParameters['level'],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.ranking,
                pageBuilder: (context, state) =>
                    _page(state, const RankingPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                pageBuilder: (context, state) =>
                    _page(state, const HistoryPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                pageBuilder: (context, state) =>
                    _page(state, const SettingsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Remember the current page so the app reopens on it (SharedPreferences).
  void remember() {
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    if (Routes.isRestorable(location)) {
      prefs.setString(PrefKeys.lastLocation, location);
    }
  }

  router.routerDelegate.addListener(remember);
  ref.onDispose(() {
    router.routerDelegate.removeListener(remember);
    router.dispose();
    refresh.dispose();
  });
  return router;
});
