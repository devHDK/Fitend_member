import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'flavors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.local;

  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  await Hive.initFlutter(appDocumentDirectory.path);

  Hive.registerAdapter<WorkoutRecordModel>(WorkoutRecordModelAdapter());
  Hive.registerAdapter<WorkoutRecordResult>(WorkoutRecordResultAdapter());
  Hive.registerAdapter<SetInfo>(SetInfoAdapter());
  Hive.registerAdapter<WorkoutFeedbackRecordModel>(
      WorkoutFeedbackRecordModelAdapter());

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
