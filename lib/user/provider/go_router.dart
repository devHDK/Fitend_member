import 'package:fitend_member/user/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routeObserverProvider = Provider((ref) => RouteObserver<PageRoute>());

final routerProvider = Provider<GoRouter>(
  (ref) {
    final auth = ref.read(authProvider);
    final route = ref.read(routeObserverProvider);

    return GoRouter(
      observers: [route],
      routes: auth.routes,
      initialLocation: '/onboard',
      refreshListenable: auth,
      redirect: auth.redirectLogic,
    );
  },
);
