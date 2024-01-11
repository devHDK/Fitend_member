import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/component/custom_date_picker.dart';
import 'package:fitend_member/user/component/date_picker_button.dart';
import 'package:fitend_member/user/component/place_button.dart';
import 'package:fitend_member/user/component/survey_button.dart';
import 'package:fitend_member/user/model/user_register_state_model.dart';
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

    debugPrint('${model.toJson()}');

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
                _step6_11VentilWidget(
                    '이제 지속가능한\n운동습관을 경험하세요', '이제 지속가능한 운동습관을 경험하세요')
              else if (model.step == 7)
                _step7ExperienceWidget(model)
              else if (model.step == 8)
                _step8PurposeWidget(model)
              else if (model.step == 9)
                _step9AchieveWidget(model)
              else if (model.step == 10)
                _step10ObstacleWidget(model)
              else if (model.step == 11)
                _step6_11VentilWidget(
                    '언제, 어디서든\n당신의 코치와 함께하세요', '언제, 어디서든 당신의 코치와 함께하세요')
              else if (model.step == 12)
                _step12PlaceWidget(model)
              else if (model.step == 13)
                _step13PreferDayWidget(model)
            ],
          ),
        ),
        floatingActionButtonAnimator: _NoAnimationFabAnimator(),
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

  void _checkButtonEnable(UserRegisterStateModel model) {
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
        buttonEnable = true;
        break;
      case 7:
        if (model.experience != null) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 8:
        if (model.purpose != null) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 9:
        if (model.achievement != null && model.achievement!.isNotEmpty) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 10:
        if (model.obstacle != null && model.obstacle!.isNotEmpty) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 11:
        break;
      case 12:
        if (model.place != null) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;
      case 13:
        if (model.place != null) {
          buttonEnable = true;
        } else {
          buttonEnable = false;
        }
        break;

      default:
        break;
    }
  }

  void _pressNextButton(UserRegisterStateModel model) async {
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

      if (model.step == 13) {
        //TODO: 트레이너 선택 screen으로 이동
      } else {
        ref.read(userRegisterProvider(widget.phone).notifier).updateData(
              step: tempStep,
              progressStep: tempProgressStep,
            );
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<bool> _checkEmail(int tempStep, UserRegisterStateModel model) async {
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
          textInputType: TextInputType.emailAddress,
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

  Column _step4GenderWidget(UserRegisterStateModel model) {
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

  Column _step5BodySpecWidget(UserRegisterStateModel model) {
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

  SizedBox _step6_11VentilWidget(String header, String content) {
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

  Column _step7ExperienceWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '헬스를 해본 경험이 있으신가요?',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ...SurveyConstants.experiences.mapIndexed((index, element) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SurveyButton(
              content: element,
              onTap: () {
                if (!mounted) return;

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(experience: index + 1);
              },
              isSelected: model.experience == index + 1,
            ),
          );
        })
      ],
    );
  }

  Column _step8PurposeWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 목표를 이루고 싶으신가요?',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ...SurveyConstants.purposes.mapIndexed((index, element) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SurveyButton(
              content: element,
              onTap: () {
                if (!mounted) return;

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(purpose: index + 1);
              },
              isSelected: model.purpose == index + 1,
            ),
          );
        })
      ],
    );
  }

  Column _step9AchieveWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '어떨 때 성취감을 느끼시나요?',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              '(최대 3개)',
              style: s2SubTitle.copyWith(
                color: Pallete.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        ...SurveyConstants.achievements.mapIndexed((index, element) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SurveyButton(
              content: element,
              onTap: () {
                List<int> tempList = model.achievement ?? [];

                if (tempList.contains(index + 1)) {
                  tempList.remove(index + 1);
                } else {
                  if (tempList.length == 3) {
                    tempList.removeAt(0);
                    tempList.add(index + 1);
                  } else {
                    tempList.add(index + 1);
                  }
                }

                if (!mounted) {
                  return;
                }

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(
                      achievement: tempList.toSet().toList(),
                    );
              },
              isSelected: model.achievement!.contains(index + 1),
            ),
          );
        })
      ],
    );
  }

  Column _step10ObstacleWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '목표 달성에 장애물이 있나요?',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              '(최대 3개)',
              style: s2SubTitle.copyWith(
                color: Pallete.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        ...SurveyConstants.obstacles.mapIndexed((index, element) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SurveyButton(
              content: element,
              onTap: () {
                List<int> tempList = model.obstacle ?? [];

                if (tempList.contains(index + 1)) {
                  tempList.remove(index + 1);
                } else {
                  if (tempList.length == 3) {
                    tempList.removeAt(0);
                    tempList.add(index + 1);
                  } else {
                    tempList.add(index + 1);
                  }
                }

                if (!mounted) {
                  return;
                }

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(
                      obstacle: tempList.toSet().toList(),
                    );
              },
              isSelected: model.obstacle!.contains(index + 1),
            ),
          );
        })
      ],
    );
  }

  Column _step12PlaceWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어디서 운동하실 계획이세요?',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlaceButton(
              content: '집 🏠\n(시공간의 제약 없이\n자유롭게 하길 원해요)',
              onTap: () {
                if (!mounted) return;

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(place: 'home');
              },
              isSelected: model.place == 'home',
            ),
            PlaceButton(
              content: '헬스장 🎟️\n(이미 등록했거나\n등록할 계획이에요)',
              onTap: () {
                if (!mounted) return;

                ref
                    .read(userRegisterProvider(widget.phone).notifier)
                    .updateData(place: 'gym');
              },
              isSelected: model.place == 'gym',
            )
          ],
        )
      ],
    );
  }

  Column _step13PreferDayWidget(UserRegisterStateModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주로 어떤 요일을 희망하세요?',
          style: h3Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...weekday.mapIndexed(
              (index, element) {
                return SurveyButton(
                  content: element,
                  textAlign: TextAlign.center,
                  width: index < 5 ? 15.w : 40.w,
                  onTap: () {
                    List<int> tempList = model.preferDays ?? [];

                    if (tempList.contains(index + 1)) {
                      tempList.remove(index + 1);
                    } else {
                      tempList.add(index + 1);
                    }

                    ref
                        .read(userRegisterProvider(widget.phone).notifier)
                        .updateData(
                          preferDays: tempList.toSet().toList(),
                        );
                  },
                  isSelected: model.preferDays!.contains(index + 1),
                );
              },
            )
          ],
        ),
      ],
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

class _NoAnimationFabAnimator extends FloatingActionButtonAnimator {
  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(0);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }
}
