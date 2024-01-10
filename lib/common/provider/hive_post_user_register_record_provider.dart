import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveUserRegisterRecordProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<PostUserRegisterModel>(StringConstants.registerUserInfo);

    Box box = Hive.box<PostUserRegisterModel>(StringConstants.registerUserInfo);

    return box;
  },
);
