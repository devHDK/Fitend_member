import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/firebase_options.dart';
import 'package:fitend_member/firebase_setup.dart';
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
  @override
  void initState() {
    super.initState();

    // foreground 수신처리
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    // background 수신처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
      // name: F.appFlavor == Flavor.local
      //     ? 'local'
      //     : F.appFlavor == Flavor.development
      //         ? 'dev'
      //         : 'prod',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await setupFlutterNotifications(); // 셋팅 메소드
    showFlutterNotification(message);
  }
}
