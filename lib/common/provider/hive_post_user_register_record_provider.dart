import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/user/model/user_register_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveUserRegisterRecordProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<UserRegisterStateModel>(
        StringConstants.registerUserInfo);

    Box box =
        Hive.box<UserRegisterStateModel>(StringConstants.registerUserInfo);

    return box;
  },
);
