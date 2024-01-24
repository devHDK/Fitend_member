import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/user/model/user_register_state_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:fitend_member/user/repository/get_me_repository.dart';
import 'package:fitend_member/user/view/register_welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slack_notifier/slack_notifier.dart';
import 'package:uuid/uuid.dart';

class RegisterCompleteScreen extends ConsumerStatefulWidget {
  const RegisterCompleteScreen({
    super.key,
    required this.phone,
    required this.trainerName,
    required this.trainerProfileImage,
  });

  final String phone;
  final String trainerName;
  final String trainerProfileImage;

  @override
  ConsumerState<RegisterCompleteScreen> createState() =>
      _RegisterCompleteScreenState();
}

class _RegisterCompleteScreenState
    extends ConsumerState<RegisterCompleteScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registerModel = ref.watch(userRegisterProvider(widget.phone));

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              Text(
                '${widget.trainerName} 코치님과\n앞으로의 운동여정을 응원합니다 💪',
                style: h3Headline.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 36,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(SVGConstants.checkWhite),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '맞춤형 운동계획',
                        style: h4Headline.copyWith(color: Colors.white),
                      ),
                      Text(
                        '${registerModel.nickname!.substring(1)}님의 사전설문 데이터를 바탕으로\n실행가능한 운동루틴을 만들어드려요.',
                        style: s1SubTitle.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(SVGConstants.checkWhite),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1:1 관리 및 피드백',
                        style: h4Headline.copyWith(color: Colors.white),
                      ),
                      Text(
                        '자세 및 운동과 관련된 질문이 생기면\n코치님께 언제든지 물어볼 수 있어요.',
                        style: s1SubTitle.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(SVGConstants.checkWhite),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지속가능한 운동습관',
                        style: h4Headline.copyWith(color: Colors.white),
                      ),
                      Text(
                        '포기하지 않고 꾸준히 지속할 수 있도록\n동기부여와 멘탈케어를 해드릴게요.',
                        style: s1SubTitle.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: s3SubTitle.copyWith(
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: '∙ 14일 무료체험 시작시 '),
                    TextSpan(
                      text: '개인정보',
                      style: s3SubTitle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        color: Colors.white,
                      ),
                      recognizer: TapAndPanGestureRecognizer()
                        ..onTapDown = (detail) => DataUtils.onWebViewTap(
                            uri: URLConstants.notionPrivacy),
                    ),
                    TextSpan(
                      text: 'n',
                      style: s2SubTitle.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.transparent,
                        decorationColor: Colors.white,
                        fontSize: 6,
                        letterSpacing: 0,
                        decorationThickness: 2.0,
                      ),
                    ),
                    TextSpan(
                      text: '처리방침',
                      style: s3SubTitle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        color: Colors.white,
                      ),
                      recognizer: TapAndPanGestureRecognizer()
                        ..onTapDown = (detail) => DataUtils.onWebViewTap(
                            uri: URLConstants.notionPrivacy),
                    ),
                    const TextSpan(text: ' 과 서비스 '),
                    TextSpan(
                      text: '이용약관',
                      style: s3SubTitle.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                      recognizer: TapAndPanGestureRecognizer()
                        ..onTapDown = (detail) => DataUtils.onWebViewTap(
                              uri: URLConstants.notionServiceUser,
                            ),
                    ),
                    const TextSpan(text: '에\n    동의하는 것으로 간주됩니다.'),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _completeButton(registerModel, context),
            ],
          ),
        ),
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  TextButton _completeButton(
      UserRegisterStateModel registerModel, BuildContext context) {
    return TextButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });

        final model =
            UserRegisterStateModel().stateModelToPostModel(registerModel);
        try {
          final token = await FirebaseMessaging.instance.getToken();
          final deviceId = await _getDeviceInfo();

          final pref = await SharedPreferences.getInstance();
          pref.setBool(StringConstants.isNeedMeeting, true);

          await ref
              .read(getMeRepositoryProvider)
              .userRegister(model: model)
              .then((value) async {
            FirebaseAnalytics.instance.logEvent(name: 'sign_up');

            await ref.read(getMeProvider.notifier).login(
                  email: registerModel.email!,
                  password: registerModel.password!,
                  platform: Platform.isAndroid ? 'android' : 'ios',
                  token: token!,
                  deviceId: deviceId,
                );

            final slack = SlackNotifier(URLConstants.slackNewUserWebhook);
            await slack.send(
              '${F.appFlavor != Flavor.production ? '[TEST]' : ''}[${widget.trainerName}] [${registerModel.nickname}] 회원님이 신규 가입! [${registerModel.gender == 'male' ? '남' : '여'}] 생년월일 : ${DateFormat('yyyy-MM-dd').format(registerModel.birth!)} 🎉🎉🎉',
              channel: '#cs6_신규가입-알림',
            );

            //관련 저장 항목 삭제
            ref
                .read(userRegisterProvider(widget.phone).notifier)
                .resetLocalDB();

            if (!context.mounted) return;

            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => RegisterWelcomeScreen(
                userNickname: registerModel.nickname!,
                trainerName: widget.trainerName,
                trainerProfileImage: widget.trainerProfileImage,
                trainerId: registerModel.trainerId!,
              ),
            ));
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });

          final pref = await SharedPreferences.getInstance();
          pref.setBool(StringConstants.isNeedMeeting, false);

          DialogWidgets.showToast(content: '서버와 통신 중 문제가 발생하였습니다.');
        }
      },
      child: Container(
        height: 44,
        width: 100.w,
        decoration: BoxDecoration(
          color: Pallete.point,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : Text(
                  '14일 무료체험 시작',
                  style: h6Headline.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }

  Future<String> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo? iosInfo;
    String? androidUuid;

    if (Platform.isAndroid) {
      final savedUuid = await ref
          .read(secureStorageProvider)
          .read(key: StringConstants.deviceId);
      if (savedUuid == null) {
        var uuid = const Uuid();
        androidUuid = uuid.v1();
        await ref
            .read(secureStorageProvider)
            .write(key: StringConstants.deviceId, value: androidUuid);
      } else {
        androidUuid = savedUuid;
      }

      debugPrint('deviceId : $androidUuid');
    } else if (Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
      debugPrint('deviceId : ${iosInfo.identifierForVendor!}');
    }

    return Platform.isAndroid ? androidUuid! : iosInfo!.identifierForVendor!;
  }
}
