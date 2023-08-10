import 'package:client/screens/home_screen.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/widgets/bottom_navbar_widget.dart';
import 'package:client/widgets/safe_area_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state, child) {
            print(state.location);
            return NoTransitionPage(
              child: BottomNavbarWidget(location: state.location, child: child),
            );
          },
          routes: [
            GoRoute(
              name: "login",
              path: '/login',
              pageBuilder: (context, state) {
                return const MaterialPage(
                  child: SafeAreaWidget(
                    LoginScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              name: "home",
              path: '/',
              pageBuilder: (context, state) {
                return const MaterialPage(
                  child: SafeAreaWidget(
                    HomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
      initialLocation: "/",
      redirect: (context, state) {
        if (isAuth) {
          if (state.location == "/login") {
            return "/";
          }
          return null;
        } else {
          return '/login';
        }
      },
    );

    return router;
  }
}