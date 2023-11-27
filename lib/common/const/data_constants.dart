import 'dart:io';
import 'package:fitend_member/flavors.dart';

const List<String> weekday = [
  '월',
  '화',
  '수',
  '목',
  '금',
  '토',
  '일',
];

enum WorkoutPushType {
  workoutScheduleCreate,
  workoutScheduleDelete,
  workoutScheduleChange,
}

enum ThreadPushType {
  threadCreate,
  threadDelete,
  threadUpdate,
}

enum CommentPushType {
  commentCreate,
  commentDelete,
  commentUpdate,
}

enum EmojiPushType {
  emojiCreate,
  emojiDelete,
}

enum ThreadType {
  record,
  general,
}

class StringConstants {
  static String needNotificationUpdate = 'notificationUpdate';
  static String hasNewNotification = 'hasNewNotification';

  static String needScheduleUpdate = 'scheduleUpdate';
  static String needWorkoutUpdateList = 'needWorkoutUpdateList';

  static String threadBadgeCount = 'threadBadgeCount';

  static String needThreadUpdate = 'needThreadUpdate';
  static String needThreadUpdateList = 'needThreadUpdateList';
  static String needThreadDelete = 'needThreadDelete';

  static String needCommentCreate = 'commentCreate';
  static String needCommentDelete = 'needCommentDelete';

  static String needEmojiCreate = 'emojiCreate';
  static String needEmojiDelete = 'emojiDelete';

  static String workoutRecordSimple = 'WorkoutRecords';
  static String timerXOneRecord = 'timerXoneRecords';
  static String timerXMoreRecord = 'timerXMoreRecords';
  static String timerTotalTimeRecord = 'timerProcessTimeRecord';
  static String workoutResult = 'workoutResult';
  static String modifiedExercise = 'modifiedExercise';
  static String workoutFeedback = 'WorkoutFeedback';
  static String processingExerciseIndex = 'processExerciseIndex';

  static final accessToken =
      F.appFlavor == Flavor.production ? 'ACCESS_TOKEN' : 'ACCESS_TOKEN_DEV';
  static final refreshToken =
      F.appFlavor == Flavor.production ? 'REFRESH_TOKEN' : 'REFRESH_TOKEN_DEV';
  static const deviceId = 'StringConstants.deviceId';
}

class URLConstants {
  static const emulatorIp = 'http://10.0.2.2:4000/api/mobile';
  static const simulatorIp = 'http://127.0.0.1:4000/api/mobile';

  static final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
      ? emulatorIp
      : simulatorIp;

  // static const devIp = 'https://api-dev.fit-end.com/api/mobile'; //개발 서버
  // static const devIp = 'http://192.168.0.63:4000/api/mobile'; //home
  static const devIp = 'http://192.168.0.8:4000/api/mobile'; //company
  static const deployIp = 'https://api-prod.fit-end.com/api/mobile';

//s3URL
  static final s3Url = F.appFlavor != Flavor.production
      ? 'https://d20e02zksul93k.cloudfront.net/'
      : 'https://djt0uuz3ub045.cloudfront.net/';
  static const muscleImageUrl = 'public/targetMuscles/';

  static const maleProfileUrl =
      'https://api-dev-minimal-v4.vercel.app/assets/images/avatars/avatar_7.jpg';
  static const femaleProfileUrl =
      'https://api-dev-minimal-v4.vercel.app/assets/images/avatars/avatar_1.jpg';
}

final urlRegExp = RegExp(
    r"((https?:\/\/)?(www\.)?)?[-a-zA-Z@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*)");
