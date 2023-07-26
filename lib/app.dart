import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavors.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    initSharedPref(); //sharedPreferences 세팅
  }

  void initSharedPref() async {
    //sharedPreferences 세팅
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(needScheduleUpdate, false);
    pref.setStringList(needWorkoutUpdateList, []);
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routerProvider);

    return MaterialApp.router(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: child!,
        );
      },
      title: F.title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      routerConfig: route,
    );
  }
}
