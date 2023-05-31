import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'flavors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.local;

  await Hive.initFlutter();

  Hive.registerAdapter<WorkoutRecordModel>(WorkoutRecordModelAdapter());

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
