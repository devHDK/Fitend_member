// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/exercise/model/target_muscle_model.dart';
import 'package:fitend_member/firebase_options.dart';
import 'package:fitend_member/firebase_setup.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/user/model/user_register_state_model.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
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
}

void processPushMessage(RemoteMessage message) async {
  final type = message.data['type'].toString();
  SharedPreferences pref = await SharedPreferences.getInstance();

  debugPrint('type: $type');
  debugPrint('message: ${message.toMap()}');

  if (type.contains('reservation')) {
    await SharedPrefUtils.updateIsNeedUpdate(
        StringConstants.needScheduleUpdate, pref, true);
    await SharedPrefUtils.updateIsNeedUpdate(
        StringConstants.needNotificationUpdate, pref, true);
  } else if (type.contains('workoutSchedule')) {
    switch (DataUtils.getWorkoutPushType(type)) {
      case WorkoutPushType.workoutScheduleCreate:
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needScheduleUpdate, pref, true);
        break;
      case WorkoutPushType.workoutScheduleDelete:
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needScheduleUpdate, pref, true);
        break;
      case WorkoutPushType.workoutScheduleChange:
        String workoutScheduleId = message.data['workoutScheduleId'].toString();
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needScheduleUpdate, pref, true);
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needWorkoutUpdateList, pref, workoutScheduleId);
        break;

      default:
        break;
    }
  } else if (type.contains('thread')) {
    switch (DataUtils.getThreadPushType(type)) {
      case ThreadPushType.threadCreate:
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needNotificationUpdate, pref, true);
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needThreadUpdate, pref, true);

        break;
      case ThreadPushType.threadDelete:
        String threadId = message.data['threadId'].toString();
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needThreadDelete, pref, threadId);
        break;
      case ThreadPushType.threadUpdate:
        String threadId = message.data['threadId'].toString();
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needThreadUpdate, pref, true);
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needThreadUpdateList, pref, threadId);
        break;

      default:
        break;
    }
  } else if (type.contains('comment')) {
    switch (DataUtils.getCommentPushType(type)) {
      case CommentPushType.commentCreate:
        await SharedPrefUtils.updateIsNeedUpdate(
            StringConstants.needNotificationUpdate, pref, true);

        String threadId = message.data['threadId'].toString();
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needCommentCreate, pref, threadId);

        break;
      case CommentPushType.commentDelete:
        String threadId = message.data['threadId'].toString();
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needCommentDelete, pref, threadId);
        break;
      case CommentPushType.commentUpdate:
        String threadId = message.data['threadId'].toString();
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needThreadUpdateList, pref, threadId);

        break;

      default:
        break;
    }
  } else if (type.contains('emoji')) {
    switch (DataUtils.getEmojiPushType(type)) {
      case EmojiPushType.emojiCreate:
        final pushData = EmojiModelFromPushData.fromJson(message.data);

        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needEmojiCreate,
            pref,
            json.encode(pushData.toJson()));

        var deleteList = SharedPrefUtils.getNeedUpdateList(
            StringConstants.needEmojiDelete, pref);

        final tempList = deleteList;

        for (var emoji in tempList) {
          Map<String, dynamic> emojiMap = jsonDecode(emoji);
          final deleteEmoji = EmojiModelFromPushData.fromJson(emojiMap);

          if (deleteEmoji.id == pushData.id &&
              deleteEmoji.trainerId == pushData.trainerId) {
            deleteList.remove(json.encode(emojiMap));
          }
        }

        SharedPrefUtils.updateNeedUpdateList(
            StringConstants.needEmojiDelete, pref, deleteList);

        break;
      case EmojiPushType.emojiDelete:
        final pushData = EmojiModelFromPushData.fromJson(message.data);
        await SharedPrefUtils.addOneNeedUpdateList(
            StringConstants.needEmojiDelete,
            pref,
            json.encode(pushData.toJson()));

        var createList = SharedPrefUtils.getNeedUpdateList(
            StringConstants.needEmojiCreate, pref);

        final tempList = createList;

        for (var emoji in tempList) {
          Map<String, dynamic> emojiMap = jsonDecode(emoji);
          final deleteEmoji = EmojiModelFromPushData.fromJson(emojiMap);

          if (deleteEmoji.id == pushData.id &&
              deleteEmoji.trainerId == pushData.trainerId) {
            createList.remove(json.encode(emojiMap));
          }
        }

        SharedPrefUtils.updateNeedUpdateList(
            StringConstants.needEmojiCreate, pref, createList);
        break;

      default:
        break;
    }
  } else if (type.contains('meeting')) {
    //알림, 스케줄 업데이트
    await SharedPrefUtils.updateIsNeedUpdate(
        StringConstants.needNotificationUpdate, pref, true);
    await SharedPrefUtils.updateIsNeedUpdate(
        StringConstants.needScheduleUpdate, pref, true);
  } else if (type.contains('noFeedback')) {
    await SharedPrefUtils.updateIsNeedUpdate(
        StringConstants.needNotificationUpdate, pref, true);
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.production;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //firebase 세팅
  await Firebase.initializeApp(
    // name: 'prod',
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

  //firebase analystic 설정
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  //FirebaseCrashlytics 설정
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  //hive 세팅
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  Hive.registerAdapter<WorkoutRecordSimple>(WorkoutRecordSimpleAdapter());
  Hive.registerAdapter<WorkoutRecord>(WorkoutRecordAdapter());
  Hive.registerAdapter<SetInfo>(SetInfoAdapter());
  Hive.registerAdapter<WorkoutFeedbackRecordModel>(
      WorkoutFeedbackRecordModelAdapter());
  Hive.registerAdapter<Exercise>(ExerciseAdapter());
  Hive.registerAdapter<TargetMuscle>(TargetMuscleAdapter());
  Hive.registerAdapter<ExerciseVideo>(ExerciseVideoAdapter());
  Hive.registerAdapter<ScheduleRecordsModel>(ScheduleRecordsModelAdapter());
  Hive.registerAdapter<UserRegisterStateModel>(UserRegisterStateModelAdapter());

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
