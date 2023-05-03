import 'package:fitend_member/user/provider/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flavors.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routerProvider);

    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      routerConfig: route,
    );
  }
}
