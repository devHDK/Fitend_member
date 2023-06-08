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

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

final buildEnv = F.appFlavor == Flavor.local
    ? Flavor.local.name
    : F.appFlavor == Flavor.development
        ? Flavor.development.name
        : Flavor.production.name;

const emulatorIp = 'http://10.0.2.2:4000/api/mobile';
const simulatorIp = 'http://127.0.0.1:4000/api/mobile';
// const simulatorIp = 'http://192.168.0.31:4000/api/mobile';

final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
    ? emulatorIp
    : simulatorIp;

const devIp = 'https://api-dev.fit-end.com/api/mobile';
const deployIp = '';

//s3URL
final s3Url = F.appFlavor != Flavor.production
    ? 'https://d20e02zksul93k.cloudfront.net/'
    : '';
const muscleImageUrl = 'public/targetMuscles/';

String workoutRecordBox = 'WorkoutRecords';
String timerXOneRecordBox = 'timerXoneRecords';
String timerXMoreRecordBox = 'timerXMoreRecords';
String workoutEdit = 'WorkoutEdit';
String workoutFeedback = 'WorkoutFeedback';
