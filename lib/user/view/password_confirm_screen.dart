import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/user/model/post_confirm_password.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/password_change_screen.dart';
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
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
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
            const Text(
              '안전한 변경을 위해\n현재 비밀번호를 입력해주세요',
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
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PasswordChangeScreen(
                          password: _passwordController.text,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0),
                              end: Offset.zero,
                            ).chain(
                              CurveTween(curve: Curves.linearToEaseOut),
                            ),
                          ),
                          child: child,
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
            child: const Center(
              child: Text(
                '다음',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
