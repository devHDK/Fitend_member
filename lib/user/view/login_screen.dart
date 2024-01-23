import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/view/verification_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  String email = '';
  String password = '';
  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
    // _loadEmailAndPassword();
    // _getDeviceInfo();
    _idTextController.addListener(idTextListener);
    _passwordTextController.addListener(passwordTextListener);
  }

  void idTextListener() {
    if (_idTextController.text.length < 8 ||
        _passwordTextController.text.length < 8) {
      buttonEnable = false;
    } else {
      buttonEnable = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void passwordTextListener() {
    if (_idTextController.text.length < 8 ||
        _passwordTextController.text.length < 8) {
      buttonEnable = false;
    } else {
      buttonEnable = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _idTextController.removeListener(idTextListener);
    _passwordTextController.removeListener(passwordTextListener);

    _idTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);
    // final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Icon(Icons.arrow_back_sharp),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            // key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 24,
                ),
                AutoSizeText(
                  '핏엔드와 함께\n지속가능한 운동습관을 경험해보세요!',
                  style: h3Headline.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(
                  height: 36,
                ),
                _renderMidView(
                  email,
                  password,
                  ref,
                  state,
                  _idTextController,
                  _passwordTextController,
                ),
                KeyboardVisibilityBuilder(
                  builder: (p0, isKeyboardVisible) {
                    return SizedBox(
                      height: !isKeyboardVisible
                          ? 100.h - kToolbarHeight - 56 - 400
                          : 30,
                    );
                  },
                ),
                _renderBottomView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _renderMidView(
    String email,
    String password,
    WidgetRef ref,
    UserModelBase? state,
    TextEditingController idTextcontroller,
    TextEditingController passwordTextcontroller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutofillGroup(
          child: Column(
            children: [
              CustomTextFormField(
                controller: idTextcontroller,
                fullLabelText: '이메일을 입력해주세요',
                labelText: '이메일',
                autoFocus: false,
                textInputType: TextInputType.emailAddress,
                autoFillHint: const [
                  AutofillHints.username,
                  AutofillHints.email
                ],
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              CustomTextFormField(
                controller: passwordTextcontroller,
                fullLabelText: '비밀번호를 입력해주세요',
                labelText: '비밀번호',
                autoFocus: false,
                obscureText: true,
                textInputType: TextInputType.visiblePassword,
                autoFillHint: const [
                  AutofillHints.password,
                ],
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: idTextcontroller.text.isEmpty ||
                      passwordTextcontroller.text.isEmpty
                  ? Pallete.point.withOpacity(0.4)
                  : Pallete.point,
            ),
            child: ElevatedButton(
              onPressed: state is UserModelLoading
                  ? null
                  : idTextcontroller.text.isEmpty ||
                          passwordTextcontroller.text.isEmpty
                      ? () {}
                      : () async {
                          TextInput.finishAutofillContext(shouldSave: true);

                          if (_idTextController.text.isNotEmpty &&
                              _passwordTextController.text.isNotEmpty) {
                            // _saveEmailAndPassword();
                          }

                          if (_idTextController.text.isEmpty &&
                              _passwordTextController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DialogWidgets.oneButtonDialog(
                                message: '이메일 또는 비밀번호를 입력해주세요',
                                confirmText: '확인',
                                confirmOnTap: () => context.pop(),
                              ),
                            );
                            return;
                          }

                          RegExp emailRegExp = RegExp(
                              r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
                          bool isMatch =
                              emailRegExp.hasMatch(_idTextController.text);

                          if (!isMatch ||
                              _passwordTextController.text.length < 8) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DialogWidgets.oneButtonDialog(
                                message: '이메일 또는 비밀번호를 확인해주세요 😭',
                                confirmText: '확인',
                                confirmOnTap: () => context.pop(),
                              ),
                            );
                            return;
                          }

                          final token =
                              await FirebaseMessaging.instance.getToken();

                          final deviceId = await _getDeviceInfo();

                          final ret = await ref
                              .read(getMeProvider.notifier)
                              .login(
                                email: idTextcontroller.text,
                                password: passwordTextcontroller.text,
                                platform: Platform.isIOS ? 'ios' : 'android',
                                token: token!,
                                deviceId: deviceId,
                              );

                          if (ret is UserModelError) {
                            if (!mounted) return;
                            //async 함수 내에서 context사용전 위젯이 마운트되지 않으면
                            // errorDialog(ret).show(context);
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DialogWidgets.oneButtonDialog(
                                message: ret.error,
                                confirmText: '확인',
                                confirmOnTap: () {
                                  context.pop();
                                },
                              ),
                            );
                          }
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: state is UserModelLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '로그인',
                      style: h6Headline.copyWith(
                        color: idTextcontroller.text.isEmpty ||
                                passwordTextcontroller.text.isEmpty
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => VerificationScreen(
                  verificationType: VerificationType.reset,
                ),
              ));
            },
            child: Text(
              '로그인 정보를 잊으셨나요?',
              style: s3SubTitle.copyWith(
                color: Pallete.lightGray,
              ),
            ),
          ),
        )
      ],
    );
  }

  Column _renderBottomView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '로그인하시면 아래 내용에 동의하는 것으로 간주됩니다.',
          style: s3SubTitle.copyWith(
            color: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () =>
                  DataUtils.onWebViewTap(uri: URLConstants.notionPrivacy),
              child: Text(
                '개인정보 처리방침',
                style: s3SubTitle.copyWith(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            TextButton(
              onPressed: () =>
                  DataUtils.onWebViewTap(uri: URLConstants.notionServiceUser),
              child: Text(
                '서비스 이용약관',
                style: s3SubTitle.copyWith(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Future<void> _saveEmailAndPassword() async {
  //   final storage = ref.read(secureStorageProvider);
  //   await storage.write(key: 'email', value: _idTextController.text);
  //   await storage.write(key: 'password', value: _passwordTextController.text);
  // }

  // Future<void> _loadEmailAndPassword() async {
  //   final storage = ref.read(secureStorageProvider);
  //   String? savedEmail = await storage.read(key: 'email');
  //   String? savedPassword = await storage.read(key: 'password');

  //   if (savedEmail != null && savedPassword != null) {
  //     _idTextController.text = savedEmail;
  //     _passwordTextController.text = savedPassword;
  //   }
  // }

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
