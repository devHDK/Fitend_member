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

String needScheduleUpdate = 'scheduleUpdate';
String needNotificationUpdate = 'notificationUpdate';
String needWorkoutUpdateList = 'needWorkoutUpdateList';

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
// const simulatorIp = 'http://192.168.0.31:4000/api/mobile';

final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
    ? emulatorIp
    : simulatorIp;

const devIp = 'https://api-dev.fit-end.com/api/mobile';
// const devIp = 'http://172.30.1.67:4000/api/mobile';
// const devIp = 'http://192.168.0.63:4000/api/mobile';
const deployIp = 'https://api-prod.fit-end.com/api/mobile';

//s3URL
final s3Url = F.appFlavor != Flavor.production
    ? 'https://d20e02zksul93k.cloudfront.net/'
    : 'https://djt0uuz3ub045.cloudfront.net/';
const muscleImageUrl = 'public/targetMuscles/';

String workoutRecordBox = 'WorkoutRecords';
String timerXOneRecordBox = 'timerXoneRecords';
String timerXMoreRecordBox = 'timerXMoreRecords';
String workoutResult = 'workoutResult';
String modifiedExercise = 'modifiedExercise';
String workoutFeedback = 'WorkoutFeedback';
String processingExerciseIndex = 'processExerciseIndex';
