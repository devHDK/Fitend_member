import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/view/password_change_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

RegExp emailRegExp =
    RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

class EmailInputScreen extends ConsumerStatefulWidget {
  const EmailInputScreen({
    super.key,
    required this.email,
    required this.verificationType,
    required this.phoneToken,
    required this.phone,
  });

  final String email;
  final String verificationType;
  final String phoneToken;
  final String phone;

  @override
  ConsumerState<EmailInputScreen> createState() => _EmailInputScreen();
}

class _EmailInputScreen extends ConsumerState<EmailInputScreen> {
  final _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
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
              '안전한 변경을 위해\n계정의 이메일을 입력해주세요 ',
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
                  setState(() {});
                }
              },
              controller: _emailController,
              fullLabelText: '이메일을 입력해주세요',
              labelText: '이메일',
              textInputType: TextInputType.emailAddress,
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: !emailRegExp.hasMatch(_emailController.text)
            ? null
            : () async {
                if (_emailController.text != widget.email) {
                  showDialog(
                    context: context,
                    builder: (context) => DialogWidgets.oneButtonDialog(
                      message: '이메일이 일치하지 않아요 😭',
                      confirmText: '확인',
                      confirmOnTap: () => context.pop(),
                    ),
                  );
                } else {
                  _emailController.text = '';

                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => PasswordChangeScreen(
                      email: widget.email,
                      phone: widget.phone,
                      phoneToken: widget.phoneToken,
                    ),
                  ));
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color: !emailRegExp.hasMatch(_emailController.text)
                  ? Pallete.point.withOpacity(0.5)
                  : Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '다음',
                style: h6Headline.copyWith(
                  color: !emailRegExp.hasMatch(_emailController.text)
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white,
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
