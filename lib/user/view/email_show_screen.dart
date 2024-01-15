import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/view/email_input_screen.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EmailShowScreen extends StatefulWidget {
  // static String get routeName => 'verification';

  final String verificationType;
  final String email;
  final String? phoneToken;
  final String phone;

  const EmailShowScreen({
    super.key,
    required this.verificationType,
    required this.email,
    this.phoneToken,
    required this.phone,
  });

  @override
  State<EmailShowScreen> createState() => _EmailShowScreenState();
}

class _EmailShowScreenState extends State<EmailShowScreen> {
  @override
  Widget build(BuildContext context) {
    final emailId = widget.email.split('@');

    String obscureId = emailId[0].substring(0, emailId[0].length - 2);
    obscureId += '**';

    print(widget.phoneToken);
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SizedBox(
          height: 44,
          width: 100.w,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Pallete.point),
            child: TextButton(
              onPressed: () {
                context.pop();

                GoRouter.of(context).pushNamed(LoginScreen.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  height: 44,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Pallete.point,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '로그인 바로가기',
                      style: h6Headline.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
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
                '입력하신 번호로\n이전에 가입된 계정을 찾았어요!',
                style: h3Headline.copyWith(
                  color: Colors.white,
                ),
                maxLines: 2,
              ),
              const SizedBox(
                height: 36,
              ),
              Container(
                width: 100.w,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallete.darkGray, width: 1),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                  child: Text(
                    '$obscureId@${emailId[1]}',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.phoneToken != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => EmailInputScreen(
                            verificationType: widget.verificationType,
                            email: widget.email,
                            phone: widget.phone,
                            phoneToken: widget.phoneToken!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '비밀번호 변경이 필요하신가요?',
                      style: s3SubTitle.copyWith(
                        color: Pallete.lightGray,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
