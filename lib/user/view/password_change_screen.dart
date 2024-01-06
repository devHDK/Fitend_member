import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
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
                '새로운 비밀번호를 입력해주세요',
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
                  if (mounted) {
                    setState(() {});
                  }
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
                  if (mounted) {
                    setState(() {
                      buttonOn = false;
                    });
                  }

                  if (_nuPasswordController.text !=
                      _newPasswordController.text) {
                    if (mounted) {
                      setState(() {
                        buttonOn = true;
                      });
                    }

                    showDialog(
                      context: context,
                      builder: (context) => DialogWidgets.oneButtonDialog(
                        message: '입력하신 비밀번호가 일치하지 않아요 😭',
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: (100.w - 160) / 2),
                          content: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Pallete.darkGray,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              child: Center(
                                child: AutoSizeText(
                                  '비밀번호가 변경되었습니다',
                                  style: s3SubTitle.copyWith(
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );

                      // showDialog(
                      //   context: context,
                      //   builder: (context) => DialogWidgets.errorDialog(
                      //     message: '비밀번호가 변경되었습니다!',
                      //     confirmText: '확인',
                      //     confirmOnTap: () => context.pop(),
                      //   ),
                      // );
                    });
                    if (mounted) {
                      setState(() {
                        buttonOn = true;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        buttonOn = true;
                      });
                    }

                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder: (context) => DialogWidgets.oneButtonDialog(
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
              width: 100.w,
              decoration: BoxDecoration(
                color: (_nuPasswordController.text.length < 8 ||
                            _newPasswordController.text.length < 8) ||
                        !buttonOn
                    ? Pallete.point.withOpacity(0.5)
                    : Pallete.point,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '변경 완료',
                  style: h6Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
