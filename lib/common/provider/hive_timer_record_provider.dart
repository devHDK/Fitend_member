import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveTimerRecordProvider = FutureProvider<Box>((ref) async {
  // final appDocumentDirectory = await getApplicationDocumentsDirectory();
  // await Hive.initFlutter(appDocumentDirectory.path);
  // Hive.registerAdapter<SetInfo>(SetInfoAdapter());

  await Hive.openBox<SetInfo>(timerXOneRecordBox);

  Box box = Hive.box<SetInfo>(timerXOneRecordBox);

  return box;
});
