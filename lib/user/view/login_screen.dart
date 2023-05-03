import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class LoginScreen extends StatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String email = '';
    String password = '';

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
                _renderMidView(email, password),
                KeyboardVisibilityBuilder(
                  builder: (p0, isKeyboardVisible) {
                    print('keyboard $isKeyboardVisible');
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

  Column _renderMidView(String email, String password) {
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: POINT_COLOR,
              ),
              child: const Text(
                '로그인',
              ),
            ),
          ),
        ),
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
