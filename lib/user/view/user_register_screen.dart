import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/component/custom_date_picker.dart';
import 'package:fitend_member/user/component/date_picker_button.dart';
import 'package:fitend_member/user/component/survey_button.dart';
import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _heightController = TextEditingController();
  final _wightController = TextEditingController();

  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _heightController.dispose();
    _wightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(userRegisterProvider(widget.phone));

    print(model.toJson());

    _checkButtonEnable(model);

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
                if (tempStep != 6 && tempStep != 11) tempProgressStep--;
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
              else if (model.step == 3)
                _step3PasswordWidget()
              else if (model.step == 4)
                _step4GenderWidget(model)
              else if (model.step == 5)
                _step5BodySpecWidget(model)
              else if (model.step == 6)
                _step6_11_VentilWidget(
                    '이제 지속가능한\n운동습관을 경험하세요', '이제 지속가능한운동습관을 경험하세요')
            ],
          ),
        ),
        floatingActionButton: model.step == 6 || model.step == 11
            ? Padding(
                padding: const EdgeInsets.only(right: 28),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Pallete.point,
                  onPressed: () {
                    _pressNextButton(model);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    ),
                  ),
                ),
              )
            : TextButton(
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
        floatingActionButtonLocation: model.step == 6 || model.step == 11
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void _checkButtonEnable(PostUserRegisterModel model) {
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
        if (model.password != null &&
            model.password!.length >= 8 &&
            _passwordConfirmController.text.length >= 8) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 4:
        if (model.gender != null) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }

        break;
      case 5:
        if (model.weight != null &&
            model.height != null &&
            model.birth != null &&
            _heightController.text.isNotEmpty &&
            _wightController.text.isNotEmpty) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
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
  }

  void _pressNextButton(PostUserRegisterModel model) async {
    try {
      int tempStep = model.step!;
      int tempProgressStep = model.progressStep!;

      if (tempStep == 2) {
        final ret = await _checkEmail(tempStep, model);
        if (!ret) return;
      }

      if (tempStep == 3) {
        if (model.password != _passwordConfirmController.text) {
          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (context) => DialogWidgets.oneButtonDialog(
              message: '입력하신 비밀번호가 일치하지 않아요 😭',
              confirmText: '확인',
              confirmOnTap: () => context.pop(),
            ),
          );
          return;
        }
      }

      if (tempStep != 5 && tempStep != 10) {
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

  Column _step3PasswordWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호를 입력해주세요.',
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
                    password: value,
                  );
            }
          },
          controller: _passwordController,
          fullLabelText: '비밀번호를 입력(최소8자)',
          labelText: '',
          obscureText: true,
          textInputType: TextInputType.visiblePassword,
        ),
        const SizedBox(
          height: 12,
        ),
        CustomTextFormField(
          onChanged: (value) {
            setState(() {});
          },
          controller: _passwordConfirmController,
          fullLabelText: '한번 더 입력해주세요',
          labelText: '',
          obscureText: true,
          textInputType: TextInputType.visiblePassword,
        ),
      ],
    );
  }

  Column _step4GenderWidget(PostUserRegisterModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별를 선택해주세요.',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        SurveyButton(
          content: '남성',
          onTap: () {
            ref
                .read(userRegisterProvider(widget.phone).notifier)
                .updateData(gender: 'male');
          },
          isSelected: model.gender == 'male',
        ),
        const SizedBox(
          height: 12,
        ),
        SurveyButton(
          content: '여성',
          onTap: () {
            ref
                .read(userRegisterProvider(widget.phone).notifier)
                .updateData(gender: 'female');
          },
          isSelected: model.gender == 'female',
        ),
      ],
    );
  }

  Column _step5BodySpecWidget(PostUserRegisterModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신체 정보를 알려주세요',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '키',
                style: s2SubTitle.copyWith(color: Pallete.lightGray),
              ),
            ),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  CustomTextFormField(
                    onChanged: (value) {
                      if (!mounted) return;

                      ref
                          .read(userRegisterProvider(widget.phone).notifier)
                          .updateData(height: double.tryParse(value));
                    },
                    controller: _heightController,
                    fullLabelText: '',
                    labelText: '',
                    textInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    maxLength: 5,
                    maxLine: 1,
                    textAlign: TextAlign.center,
                  ),
                  Positioned(
                    right: 20,
                    top: 11,
                    child: Text(
                      'cm',
                      style: s2SubTitle.copyWith(
                        color: Pallete.gray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '몸무게',
                style: s2SubTitle.copyWith(color: Pallete.lightGray),
              ),
            ),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  CustomTextFormField(
                    onChanged: (value) {
                      if (!mounted) return;

                      ref
                          .read(userRegisterProvider(widget.phone).notifier)
                          .updateData(weight: double.tryParse(value));
                    },
                    controller: _wightController,
                    fullLabelText: '',
                    labelText: '',
                    textInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    maxLength: 5,
                    maxLine: 1,
                  ),
                  Positioned(
                    right: 20,
                    top: 11,
                    child: Text(
                      'kg',
                      style: s2SubTitle.copyWith(
                        color: Pallete.gray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '몸무게',
                style: s2SubTitle.copyWith(color: Pallete.lightGray),
              ),
            ),
            Expanded(
              flex: 3,
              child: DatePickerbutton(
                content: model.birth != null
                    ? DateFormat('yyyy.MM.dd').format(model.birth!)
                    : '',
                onTap: () async {
                  await showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return _buildContainer(
                          CustomDatePicker(
                            date: model.birth ?? DateTime(1991, 1, 1),
                          ),
                        );
                      }).then((value) {
                    if (value != null && value is DateTime) {
                      ref
                          .read(userRegisterProvider(widget.phone).notifier)
                          .updateData(birth: value);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  SizedBox _step6_11_VentilWidget(String header, String content) {
    return SizedBox(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 350,
          ),
          Text(
            header,
            style: h1Headline.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            content,
            style: s1SubTitle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildContainer(Widget picker) {
  return Container(
    height: 260,
    padding: const EdgeInsets.only(top: 6.0),
    color: CupertinoColors.white,
    child: DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 22.0,
      ),
      child: GestureDetector(
        onTap: () {},
        child: SafeArea(
          top: false,
          child: picker,
        ),
      ),
    ),
  );
}
