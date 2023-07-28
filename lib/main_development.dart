import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/exercise/model/target_muscle_model.dart';
import 'package:fitend_member/firebase_options.dart';
import 'package:fitend_member/firebase_setup.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'flavors.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  processPushMessage(message);

  // await setupFlutterNotifications(); // 셋팅 메소드
  // showFlutterNotification(message);
}

void processPushMessage(RemoteMessage message) async {
  final type = message.data['type'].toString();
  SharedPreferences pref = await SharedPreferences.getInstance();

  print('type: $type');
  print('message: ${message.toMap()}');

  if (type.contains('reservation')) {
    await SharedPrefUtils.updateIsNeedUpdateSchedule(pref, true);
    await SharedPrefUtils.updateIsNeedUpdateNotification(pref, true);
  } else {
    switch (DataUtils.getWorkoutPushType(type)) {
      case WorkoutPushType.workoutScheduleCreate:
        await SharedPrefUtils.updateIsNeedUpdateSchedule(pref, true);
        break;
      case WorkoutPushType.workoutScheduleDelete:
        await SharedPrefUtils.updateIsNeedUpdateSchedule(pref, true);
        break;
      case WorkoutPushType.workoutScheduleChange:
        String workoutScheduleId = message.data['workoutScheduleId'].toString();
        await SharedPrefUtils.updateIsNeedUpdateSchedule(pref, true);
        await SharedPrefUtils.addOneNeedUpdateWorkoutList(
            pref, workoutScheduleId);
        break;

      default:
        break;
    }
  }
}

void showFlutterNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  AppleNotification? ios = message.notification?.apple;

  if (notification != null && (android != null || ios != null) && !kIsWeb) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body!,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.development;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //firebase 세팅
  await Firebase.initializeApp(
    // name: 'dev',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();
  // foreground 수신처리
  FirebaseMessaging.onMessage.listen(
    (message) {
      processPushMessage(message);

      if (Platform.isAndroid) showFlutterNotification(message);
    },
  );
  // FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // background 수신처리
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  //hive 세팅
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  Hive.registerAdapter<WorkoutRecordModel>(WorkoutRecordModelAdapter());
  Hive.registerAdapter<WorkoutRecordResult>(WorkoutRecordResultAdapter());
  Hive.registerAdapter<SetInfo>(SetInfoAdapter());
  Hive.registerAdapter<WorkoutFeedbackRecordModel>(
      WorkoutFeedbackRecordModelAdapter());
  Hive.registerAdapter<Exercise>(ExerciseAdapter());
  Hive.registerAdapter<TargetMuscle>(TargetMuscleAdapter());
  Hive.registerAdapter<ExerciseVideo>(ExerciseVideoAdapter());

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
