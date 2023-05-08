import 'dart:io';

import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/user_me_provider.dart';
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
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final state = ref.watch(userMeProvider);

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
            padding: EdgeInsets.only(left: 28),
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
                const Text(
                  '담당 트레이너님이 \n설정해주신 아이디로  바로 시작해보세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(
                  height: 36,
                ),
                _renderMidView(email, password, ref, state),
                KeyboardVisibilityBuilder(
                  builder: (p0, isKeyboardVisible) {
                    return SizedBox(
                      height: isKeyboardVisible ? 100 : 345,
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
      String email, String password, WidgetRef ref, UserModelBase? state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          fullLabelText: '이메일을 입력해주세요',
          labelText: '이메일',
          autoFocus: false,
          hasContent: email.isNotEmpty,
          onChanged: (value) {
            email = value;
          },
        ),
        const SizedBox(
          height: 12,
        ),
        CustomTextFormField(
          fullLabelText: '비밀번호를 입력해주세요',
          labelText: '비밀번호',
          autoFocus: false,
          obscureText: true,
          hasContent: password.isNotEmpty,
          onChanged: (value) {
            password = value;
          },
        ),
        const SizedBox(
          height: 12,
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
                      final ret = await ref.read(userMeProvider.notifier).login(
                            email: email,
                            password: password,
                            platform: Platform.isIOS ? 'ios' : 'android',
                            token: 'string',
                          );

                      if (ret is UserModelError) {
                        print('state.error : ${ret.error}');
                        print('state.statusCode : ${ret.statusCode}');

                        if (!mounted) return;
                        //async 함수 내에서 context사용전 위젯이 마운트되지 않으면
                        errorDialog(ret).show(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: POINT_COLOR,
              ),
              child: state is UserModelLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
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
              onPressed: () {},
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
              onPressed: () {},
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
}
