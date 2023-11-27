import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveTimerRecordProvider = FutureProvider<Box>((ref) async {
  // final appDocumentDirectory = await getApplicationDocumentsDirectory();
  // await Hive.initFlutter(appDocumentDirectory.path);
  // Hive.registerAdapter<SetInfo>(SetInfoAdapter());

  await Hive.openBox<SetInfo>(StringConstants.timerXOneRecord);

  Box box = Hive.box<SetInfo>(StringConstants.timerXOneRecord);

  return box;
});
