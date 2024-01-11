import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

RegExp emailRegExp =
    RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

class UserRegisterScreen extends ConsumerStatefulWidget {
  static String get routeName => 'userRegister';
  const UserRegisterScreen({
    super.key,
    required this.phone,
  });

  final String phone;

  @override
  ConsumerState<UserRegisterScreen> createState() => _UserRegisterScreen();
}

class _UserRegisterScreen extends ConsumerState<UserRegisterScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();

  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(userRegisterProvider(widget.phone));

    print(model.toJson());

    switch (model.step) {
      case 1:
        if (model.nickname != null && model.nickname!.length >= 2) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 2:
        if (model.email != null && model.email!.isNotEmpty) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }

        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        break;
      case 8:
        break;
      case 9:
        break;
      case 10:
        break;
      case 11:
        break;
      case 12:
        break;
      case 13:
        break;

      default:
        break;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Pallete.background,
        appBar: AppBar(
          backgroundColor: Pallete.background,
          elevation: 0,
          title: SizedBox(
            width: 250,
            child: LinearProgressIndicator(
              backgroundColor: Pallete.lightGray,
              color: Pallete.point,
              value: model.progressStep! / 11,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              int tempStep = model.step!;
              int tempProgressStep = model.progressStep!;

              if (tempStep == 1) {
                context.pop();
              } else {
                if (tempStep != 6 || tempStep != 11) tempProgressStep--;
                tempStep--;

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(
                      step: tempStep,
                      progressStep: tempProgressStep,
                    );
              }
            },
            icon: const Padding(
              padding: EdgeInsets.only(left: 18),
              child: Icon(Icons.arrow_back_sharp),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              if (model.step == 1)
                _step1NicknameWidget()
              else if (model.step == 2)
                _step2EmailWidget()
            ],
          ),
        ),
        floatingActionButton: TextButton(
          onPressed: buttonEnable
              ? () async {
                  _pressNextButton(model);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              height: 44,
              width: 100.w,
              decoration: BoxDecoration(
                color: buttonEnable
                    ? Pallete.point
                    : Pallete.point.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '다음',
                  style: h6Headline.copyWith(
                    color: buttonEnable
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void _pressNextButton(PostUserRegisterModel model) async {
    try {
      int tempStep = model.step!;
      int tempProgressStep = model.progressStep!;

      if (tempStep == 2) {
        final ret = await _checkEmail(tempStep, model);
        if (!ret) return;
      }

      if (tempStep != 5 || tempStep != 10) {
        tempProgressStep++;
      }
      tempStep++;

      ref.read(userRegisterProvider(widget.phone).notifier).updateData(
            step: tempStep,
            progressStep: tempProgressStep,
          );
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<bool> _checkEmail(int tempStep, PostUserRegisterModel model) async {
    if (!emailRegExp.hasMatch(model.email!)) {
      showDialog(
        context: context,
        builder: (context) => DialogWidgets.oneButtonDialog(
          message: '이메일 형식이 올바르지 않아요 😯',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
      return false;
    } else if (emailRegExp.hasMatch(model.email!)) {
      if (mounted) {
        setState(() {
          buttonEnable = false;
        });

        try {
          await ref
              .read(userRegisterProvider(widget.phone).notifier)
              .checkEmail(model.email!);
        } catch (e) {
          if (e is DioException && e.response != null && tempStep == 2) {
            if (!context.mounted) {
              return false;
            }

            if (e.response!.statusCode == 409) {
              showDialog(
                context: context,
                builder: (context) => DialogWidgets.oneButtonDialog(
                  message: '이미 가입된 이메일이에요 😭',
                  confirmText: '확인',
                  confirmOnTap: () => context.pop(),
                ),
              );
            }
          }
          return false;
        }
      }
    }

    return true;
  }

  Column _step1NicknameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회원님의 성함을 입력해주세요.',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        CustomTextFormField(
          onChanged: (value) {
            if (mounted) {
              ref.read(userRegisterProvider(widget.phone).notifier).updateData(
                    nickname: value,
                  );
            }
          },
          controller: _nicknameController,
          fullLabelText: '성함을 입력해주세요',
          labelText: '성함',
        ),
      ],
    );
  }

  Column _step2EmailWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이메일을 입력해주세요.',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        CustomTextFormField(
          onChanged: (value) {
            if (mounted) {
              ref.read(userRegisterProvider(widget.phone).notifier).updateData(
                    email: value,
                  );
            }
          },
          controller: _emailController,
          fullLabelText: '이메일을 입력해주세요.',
          labelText: '이메일',
        ),
      ],
    );
  }
}
