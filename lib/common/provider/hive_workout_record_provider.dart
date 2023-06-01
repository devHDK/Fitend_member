import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final hiveWorkoutRecordProvider = FutureProvider<Box>((ref) async {
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(appDocumentDirectory.path);

  Hive.registerAdapter<WorkoutRecordModel>(WorkoutRecordModelAdapter());
  Hive.registerAdapter<SetInfo>(SetInfoAdapter());

  await Hive.openBox<WorkoutRecordModel>(workoutRecordBox);

  Box box = Hive.box<WorkoutRecordModel>(workoutRecordBox);

  return box;
});
