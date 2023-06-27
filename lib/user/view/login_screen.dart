import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndialog/ndialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadEmailAndPassword();
    _getDeviceInfo();
  }

  @override
  void dispose() {
    _idTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 24,
                ),
                const AutoSizeText(
                  '담당 트레이너님이 \n설정해주신 아이디로  바로 시작해보세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.5,
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
                          ? MediaQuery.sizeOf(context).height -
                              kToolbarHeight -
                              MediaQuery.viewPaddingOf(context).top -
                              370
                          : 50,
                    );
                  },
                ),
                _renderBottomView()
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
      TextEditingController passwordTextcontroller) {
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
                autoFillHint: const [AutofillHints.email],
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
                autoFillHint: const [AutofillHints.password],
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ElevatedButton(
              onPressed: state is UserModelLoading
                  ? null
                  : () async {
                      // context.goNamed(ScheduleScreen.routeName);

                      if (_idTextController.text.isNotEmpty &&
                          _passwordTextController.text.isNotEmpty) {
                        _saveEmailAndPassword();
                      }

                      final ret = await ref.read(getMeProvider.notifier).login(
                            email: idTextcontroller.text,
                            password: passwordTextcontroller.text,
                            platform: Platform.isIOS ? 'ios' : 'android',
                            token: 'string',
                          );

                      if (ret is UserModelError) {
                        // print('state.error : ${ret.error}');
                        // print('state.statusCode : ${ret.statusCode}');

                        if (!mounted) return;
                        //async 함수 내에서 context사용전 위젯이 마운트되지 않으면
                        errorDialog(ret).show(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: POINT_COLOR,
              ),
              child: state is UserModelLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: POINT_COLOR,
                      ),
                    )
                  : const Text(
                      '로그인',
                    ),
            ),
          ),
        ),
      ],
    );
  }

  NAlertDialog errorDialog(UserModelError ret) {
    return NAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Center(
            child: Text(
          '${ret.error}😂',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        )),
      ),
      dialogStyle: DialogStyle(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Container(
            width: 279,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: POINT_COLOR,
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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
        const Text(
          '로그인하시면 아래 내용에 동의하는 것으로 간주됩니다.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => DataUtils.onWebViewTap(
                  uri:
                      "https://weareraid.notion.site/06b383e3c7aa4515a4637c2c11f3d908?pvs=4"),
              child: const Text(
                '개인정보처리방침',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            TextButton(
              onPressed: () => DataUtils.onWebViewTap(
                  uri:
                      "https://weareraid.notion.site/87468f88c99b427b81ae3e44aeb1f37b?pvs=4"),
              child: const Text(
                '이용약관',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> _saveEmailAndPassword() async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'email', value: _idTextController.text);
    await storage.write(key: 'password', value: _passwordTextController.text);
  }

  Future<void> _loadEmailAndPassword() async {
    final storage = ref.read(secureStorageProvider);
    String? savedEmail = await storage.read(key: 'email');
    String? savedPassword = await storage.read(key: 'password');

    if (savedEmail != null && savedPassword != null) {
      _idTextController.text = savedEmail;
      _passwordTextController.text = savedPassword;
    }
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint(androidInfo.version.incremental);
      debugPrint(androidInfo.version.sdkInt.toString());
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint(iosInfo.utsname.machine);
      debugPrint(iosInfo.systemVersion);
    }
  }
}
