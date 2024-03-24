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
  // 절대 변경 X
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
  static String scheduleRecord = 'scheduleRecord';
  static String workoutResult = 'workoutResult';
  static String modifiedExercise = 'modifiedExercise';
  static String workoutFeedback = 'WorkoutFeedback';
  static String processingExerciseIndex = 'processExerciseIndex';
  static String registerUserInfo = 'registerUserInfo';

  static String isFirstRunWorkout = 'isFirstRunWorkout';
  static String isFirstRunThread = 'isFirstRunThread';
  static String isNeedMeeting = 'isNeedMeeting';

  static final accessToken =
      F.appFlavor == Flavor.production ? 'ACCESS_TOKEN' : 'ACCESS_TOKEN_DEV';
  static final refreshToken =
      F.appFlavor == Flavor.production ? 'REFRESH_TOKEN' : 'REFRESH_TOKEN_DEV';
  static const deviceId = 'deviceId';
}

class URLConstants {
  static const emulatorIp = 'http://10.0.2.2:4000/api/mobile';
  static const simulatorIp = 'http://127.0.0.1:4000/api/mobile';

  static final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
      ? emulatorIp
      : simulatorIp;

  // static const devIp = 'https://api-dev.fit-end.com/api/mobile'; //개발 서버
  static const devIp = 'http://192.168.0.63:4000/api/mobile'; //home
  // static const devIp = 'http://192.168.0.8:4000/api/mobile'; //company
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

  //notion
  static const notionPrivacy =
      "https://weareraid.notion.site/06b383e3c7aa4515a4637c2c11f3d908?pvs=4";
  static const notionServiceUser =
      "https://weareraid.notion.site/87468f88c99b427b81ae3e44aeb1f37b?pvs=4";
  static const notionPurcharse =
      "https://www.notion.so/weareraid/FITEND-28beb6a66c8b4a82ad5b42ecc5774c25?pvs=4";

  static const slackNewUserWebhook =
      "https://hooks.slack.com/services/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";
  static const slackMeetingWebhook =
      "https://hooks.slack.com/services/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";
  static const slackMembershipWebhook =
      "https://hooks.slack.com/services/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";

  static const kakaoChannel = "http://pf.kakao.com/_ExanBG/chat";
}

class SurveyConstants {
  static List<String> experiences = [
    '이번이 처음이에요 🙋‍♂️',
    '과거에 했는데 다시 시작하고 싶어요 👋',
    '지금은 간헐적으로 하고 있어요 😏',
    '꾸준히 규칙적으로 하고 있어요 🏋️‍♂️'
  ];

  static List<String> purposes = [
    '체중을 조절하고 싶어요 📊 ',
    '탄력있는 몸을 갖고 싶어요 👙',
    '근력을 강화하고 싶어요 💪',
    '몸을 더 크게 만들고 싶어요 🤩',
    '기초체력을 늘리고 싶어요 🏃‍♀️',
    '통증을 개선하고 싶어요 🩹',
    '운동을 더 잘하고 싶어요 🙏',
    '잘 모르겠어요 👀'
  ];

  static List<String> achievements = [
    '기분이 좋아지면 😊',
    '강해졌다고 느껴지면 🔥',
    '자신감이 충만해지면 😎',
    '스스로의 한계를 극복하면 👍',
    '규칙적인 운동습관이 생기면 📆',
    '건강한 식습관을 갖게되면 🥗',
    '운동을 즐길 수 있게되면 👻',
    '잘 모르겠어요 👀'
  ];

  static List<String> obstacles = [
    '왜 해야하는지 동기가 부족해요 😓',
    '나 자신을 통제하기가 어려워요 ⏱️',
    '힘들기만 하고 별로 재미가 없어요 🤷‍♀️️',
    '기대했던것 보다 효과가 잘 안보여요 🪞',
    '운동방법을 이해하는게 너무 어려워요 🤯',
    '정체기가 와서 새로운 루틴이 필요해요 💡',
    '딱히 없는것 같아요 🙅‍♂️',
    '잘 모르겠어요 👀'
  ];
}

final urlRegExp = RegExp(
    r"((https?:\/\/)?(www\.)?)?[-a-zA-Z@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*)");
