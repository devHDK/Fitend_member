import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'passwordConfirm';

  final String password;

  const PasswordChangeScreen({
    super.key,
    required this.password,
  });

  @override
  ConsumerState<PasswordChangeScreen> createState() => _PasswordChangeScreen();
}

class _PasswordChangeScreen extends ConsumerState<PasswordChangeScreen> {
  final _nuPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool buttonOn = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nuPasswordController.dispose();
    _newPasswordController.dispose();
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
              '새로운 비밀번호를 입력해주세요',
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
              controller: _nuPasswordController,
              fullLabelText: '새로운 비밀번호',
              labelText: '새로운 비밀번호 ',
              hintText: '새로운 비밀번호(최소 8자)',
              autoFocus: false,
              textInputType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            const SizedBox(
              height: 12,
            ),
            CustomTextFormField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _newPasswordController,
              fullLabelText: '한번 더 입력해주세요',
              labelText: '한번 더 입력해주세요',
              textInputType: TextInputType.visiblePassword,
              obscureText: true,
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: (_nuPasswordController.text.length < 8 ||
                    _newPasswordController.text.length < 8) ||
                !buttonOn
            ? null
            : () async {
                setState(() {
                  buttonOn = false;
                });

                if (_nuPasswordController.text != _newPasswordController.text) {
                  setState(() {
                    buttonOn = true;
                  });

                  showDialog(
                    context: context,
                    builder: (context) => DialogWidgets.errorDialog(
                      message: '입력하신 비밀번호가 일치하지 않아요 😂',
                      confirmText: '확인',
                      confirmOnTap: () => context.pop(),
                    ),
                  );
                  return;
                }

                try {
                  await ref
                      .read(getMeProvider.notifier)
                      .changePassword(
                        password: widget.password,
                        newPassword: _newPasswordController.text,
                      )
                      .then((value) {
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);

                    showDialog(
                      context: context,
                      builder: (context) => DialogWidgets.errorDialog(
                        message: '비밀번호가 변경되었습니다!',
                        confirmText: '확인',
                        confirmOnTap: () => context.pop(),
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
                      message: '오류가 발생하였습니다.😂',
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
              color: (_nuPasswordController.text.length < 8 ||
                          _newPasswordController.text.length < 8) ||
                      !buttonOn
                  ? POINT_COLOR.withOpacity(0.5)
                  : POINT_COLOR,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '변경 완료',
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
