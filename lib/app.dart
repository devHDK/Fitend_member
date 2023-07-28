import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flavors.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    initSharedPref(); //sharedPreferences 세팅
    setupFirebaseMessagingHandlers();
    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     print('FCM Click!!! terminated');
    //     GoRouter.of(context).goNamed(NotificationScreen.routeName);
    //   }
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('FCM Click!!!');
    //   GoRouter.of(context).pushNamed(NotificationScreen.routeName);
    // });
  }

  void setupFirebaseMessagingHandlers() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("getInitialMessage: ${message.messageId}");
        ref.read(routerProvider).goNamed(NotificationScreen.routeName);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: ${message.messageId}");
      ref.read(routerProvider).goNamed(NotificationScreen.routeName);
    });
  }

  void initSharedPref() async {
    //sharedPreferences 세팅
    final pref = await ref.read(sharedPrefsProvider);

    Future.wait([
      pref.setBool(needScheduleUpdate, false),
      pref.setBool(needNotificationUpdate, false),
      pref.setStringList(needWorkoutUpdateList, []),
    ]);
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
      // routerDelegate: route.routerDelegate,
      // routeInformationParser: route.routeInformationParser,
    );
  }
}
