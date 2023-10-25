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

String needNotificationUpdate = 'notificationUpdate';
String hasNewNotification = 'hasNewNotification';

String needScheduleUpdate = 'scheduleUpdate';
String needWorkoutUpdateList = 'needWorkoutUpdateList';

String threadBadgeCount = 'threadBadgeCount';

String needThreadUpdate = 'needThreadUpdate';
String needThreadUpdateList = 'needThreadUpdateList';
String needThreadDelete = 'needThreadDelete';

String needCommentCreate = 'commentCreate';
// String needCommentUpdate = 'commentUpdate';
String needCommentDelete = 'needCommentDelete';

String needEmojiCreate = 'emojiCreate';
String needEmojiDelete = 'emojiDelete';

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

final buildEnv = F.appFlavor == Flavor.local
    ? Flavor.local.name
    : F.appFlavor == Flavor.development
        ? Flavor.development.name
        : Flavor.production.name;

final ACCESS_TOKEN_KEY =
    F.appFlavor == Flavor.production ? 'ACCESS_TOKEN' : 'ACCESS_TOKEN_DEV';
final REFRESH_TOKEN_KEY =
    F.appFlavor == Flavor.production ? 'REFRESH_TOKEN' : 'REFRESH_TOKEN_DEV';
const DEVICEID = 'DEVICEID';

const emulatorIp = 'http://10.0.2.2:4000/api/mobile';
const simulatorIp = 'http://127.0.0.1:4000/api/mobile';

final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
    ? emulatorIp
    : simulatorIp;

const devIp = 'https://api-dev.fit-end.com/api/mobile'; //개발 서버
// const devIp = 'http://192.168.0.63:4000/api/mobile'; //home
// const devIp = 'http://192.168.0.8:4000/api/mobile'; //company
const deployIp = 'https://api-prod.fit-end.com/api/mobile';

//s3URL
final s3Url = F.appFlavor != Flavor.production
    ? 'https://d20e02zksul93k.cloudfront.net/'
    : 'https://djt0uuz3ub045.cloudfront.net/';
const muscleImageUrl = 'public/targetMuscles/';

const maleProfileUrl =
    'https://api-dev-minimal-v4.vercel.app/assets/images/avatars/avatar_7.jpg';
const femaleProfileUrl =
    'https://api-dev-minimal-v4.vercel.app/assets/images/avatars/avatar_1.jpg';

String workoutRecordSimple = 'WorkoutRecords';
String timerXOneRecord = 'timerXoneRecords';
String timerXMoreRecord = 'timerXMoreRecords';
String timerTotalTimeRecord = 'timerProcessTimeRecord';
String workoutResult = 'workoutResult';
String modifiedExercise = 'modifiedExercise';
String workoutFeedback = 'WorkoutFeedback';
String processingExerciseIndex = 'processExerciseIndex';

// final RegExp urlRegExp =
//     RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-=%.]+');

// final urlRegExp = RegExp(
//     r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

final urlRegExp = RegExp(
    r"((https?:\/\/)?(www\.)?)?[-a-zA-Z@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*)");
