import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/bloc/user/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/screens/profile_screen.dart';
import 'package:client/screens/material_request_screen.dart';
import 'package:client/screens/home_screen.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/material_item.dart';

import 'package:client/widget/bottom_navbar_widget.dart';
import 'package:client/widget/safe_area_widget.dart';

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
            final showNavBar = state.location == '/' ||
                state.location == '/profile' ||
                state.location == '/material';
            return NoTransitionPage(
              child: BottomNavbarWidget(
                location: state.location,
                showNavbar: showNavBar,
                child: child,
              ),
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
            GoRoute(
              name: "profile",
              path: '/profile',
              pageBuilder: (context, state) {
                return const MaterialPage(
                  child: SafeAreaWidget(
                    ProfileScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              name: "material request",
              path: '/material',
              pageBuilder: (context, state) {
                return const MaterialPage(
                  child: SafeAreaWidget(
                    materialRequestScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              name: 'request',
              path: '/request/:id',
              pageBuilder: (context, state) {
                return MaterialPage(
                  child: SafeAreaWidget(
                    MaterialItemScreen(state.params),
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
