import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/home_screen.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/view/thread_detail_screen.dart';
import 'package:fitend_member/ticket/view/active_ticket_screen.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'flavors.dart';

class App extends ConsumerStatefulWidget {
  const App({
    super.key,
    this.initialMessage,
  });

  final RemoteMessage? initialMessage;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    initSharedPref(); //sharedPreferences 세팅
    setupFirebaseMessagingHandlersWhenOpen();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setupFirebaseMessagingHandlers(widget.initialMessage);
    });
  }

  void setupFirebaseMessagingHandlers(RemoteMessage? message) {
    if (message == null) {
      return;
    }

    if (message.data['type'] == 'commentCreate' ||
        message.data['type'] == 'threadCreate') {
      ref.read(routerProvider).goNamed(
        ThreadDetailScreen.routeName,
        pathParameters: {
          'threadId': message.data['threadId'],
        },
      );
    } else if (message.data['type'].toString().contains('reservation')) {
      ref.read(routerProvider).goNamed(NotificationScreen.routeName);
    } else if (message.data['type'].toString().contains('noFeedback')) {
      ref.read(routerProvider).goNamed(NotificationScreen.routeName);
    } else if (message.data['type'].toString().contains('ticketExpire')) {
      ref.read(routerProvider).goNamed(ActiveTicketScreen.routeName);
    } else if (message.data['type'].toString().contains('meeting')) {
      ref.read(routerProvider).goNamed(HomeScreen.routeName);
    }
  }

  void setupFirebaseMessagingHandlersWhenOpen() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("message: ${message.data}");
      if (message.data['type'] == 'commentCreate' ||
          message.data['type'] == 'threadCreate') {
        ref.read(routerProvider).goNamed(
          ThreadDetailScreen.routeName,
          pathParameters: {
            'threadId': message.data['threadId'],
          },
        );
      } else if (message.data['type'].toString().contains('reservation')) {
        ref.read(routerProvider).goNamed(NotificationScreen.routeName);
      } else if (message.data['type'].toString().contains('noFeedback')) {
        ref.read(routerProvider).goNamed(NotificationScreen.routeName);
      } else if (message.data['type'].toString().contains('ticketExpire')) {
        ref.read(routerProvider).goNamed(ActiveTicketScreen.routeName);
      } else if (message.data['type'].toString().contains('meeting')) {
        ref.read(routerProvider).goNamed(HomeScreen.routeName);
      }
    });
  }

  void initSharedPref() async {
    //sharedPreferences 세팅
    final pref = await ref.read(sharedPrefsProvider);

    if (pref.getBool(StringConstants.isFirstRunWorkout) == null) {
      pref.setBool(StringConstants.isFirstRunWorkout, true);
    }

    if (pref.getBool(StringConstants.isFirstRunThread) == null) {
      pref.setBool(StringConstants.isFirstRunThread, true);
    }

    if (pref.getBool(StringConstants.isNeedMeeting) == null) {
      pref.setBool(StringConstants.isNeedMeeting, false);
    }

    Future.wait([
      pref.setBool(StringConstants.needScheduleUpdate, false),
      pref.setBool(StringConstants.needNotificationUpdate, false),
      pref.setStringList(StringConstants.needWorkoutUpdateList, []),
      pref.setBool(StringConstants.needThreadUpdate, false),
      pref.setStringList(StringConstants.needThreadUpdateList, []),
      pref.setStringList(StringConstants.needThreadDelete, []),
      pref.setStringList(StringConstants.needCommentCreate, []),
      pref.setStringList(StringConstants.needCommentDelete, []),
      pref.setStringList(StringConstants.needEmojiCreate, []),
      pref.setStringList(StringConstants.needEmojiDelete, []),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routerProvider);
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
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
      },
    );
  }
}
