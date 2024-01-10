import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserRegisterScreen extends ConsumerStatefulWidget {
  static String get routeName => 'passwordConfirm';
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
  bool buttonEnable = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
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
          '',
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
                  setState(() {});
                }
              },
              controller: _nicknameController,
              fullLabelText: '성함을 입력해주세요',
              labelText: '성함',
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: _nicknameController.text.length > 1 || buttonEnable
            ? null
            : () async {
                try {} catch (e) {}
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color: _nicknameController.text.length < 8
                  ? Pallete.point.withOpacity(0.5)
                  : Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '다음',
                style: h6Headline.copyWith(
                  color: _nicknameController.text.length < 8
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
