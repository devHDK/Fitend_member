import 'package:fitend_member/common/view/splash_screen.dart';
import 'package:fitend_member/schedule/view/schedule_screen.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: Router.routes,
    initialLocation: '/splash',
    // refreshListenable: provider,
    // redirect: provider.redirectLogic,
  );
});

class Router extends ChangeNotifier {
  static List<GoRoute> get routes => [
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/schedule',
          name: ScheduleScreen.routeName,
          builder: (context, state) => const ScheduleScreen(),
        ),
      ];
}
