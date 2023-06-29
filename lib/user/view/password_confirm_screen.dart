import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/model/post_confirm_password.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/password_change_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PasswordConfirmScreen extends ConsumerStatefulWidget {
  static String get routeName => 'passwordConfirm';
  const PasswordConfirmScreen({super.key});

  @override
  ConsumerState<PasswordConfirmScreen> createState() =>
      _PasswordConfirmScreen();
}

class _PasswordConfirmScreen extends ConsumerState<PasswordConfirmScreen> {
  final _passwordController = TextEditingController();
  bool buttonOn = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        elevation: 0,
        title: Text(
          '비밀번호 변경',
          style: h4Headline,
        ),
        centerTitle: true,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(
              '안전한 변경을 위해\n현재 비밀번호를 입력해주세요',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 36,
            ),
            CustomTextFormField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _passwordController,
              fullLabelText: '현재 비밀번호',
              labelText: '현재 비밀번호',
              textInputType: TextInputType.visiblePassword,
              obscureText: true,
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: _passwordController.text.length < 8 || !buttonOn
            ? null
            : () async {
                try {
                  setState(() {
                    buttonOn = false;
                  });

                  await ref
                      .read(getMeProvider.notifier)
                      .confirmPassword(
                        password: PostConfirmPassword(
                            password: _passwordController.text),
                      )
                      .then((value) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => PasswordChangeScreen(
                          password: _passwordController.text,
                        ),
                      ),
                    );
                  });

                  setState(() {
                    buttonOn = true;
                  });
                } catch (e) {
                  setState(() {
                    buttonOn = true;
                  });

                  showDialog(
                    context: context,
                    builder: (context) => DialogWidgets.errorDialog(
                      message: '비밀번호가 맞지 않아요 😂',
                      confirmText: '확인',
                      confirmOnTap: () => context.pop(),
                    ),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: _passwordController.text.length < 8
                  ? POINT_COLOR.withOpacity(0.5)
                  : POINT_COLOR,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '다음',
                style: h6Headline.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
