import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'register';

  final String verificationType;

  const VerificationScreen({
    super.key,
    required this.verificationType,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _phoneTextController = TextEditingController();
  final _codeTextController = TextEditingController();

  String phoneNumber = '';
  String code = '';
  bool nextButtonEnable = false;
  bool sendButtonEnable = false;

  @override
  void initState() {
    super.initState();
    _phoneTextController.addListener(phoneTextListener);
    _codeTextController.addListener(codeTextListener);
  }

  void phoneTextListener() {
    String phone = _phoneTextController.text;

    if (phone.replaceAll('-', '').length < 11) {
      sendButtonEnable = false;
    } else {
      sendButtonEnable = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void codeTextListener() {
    if (_codeTextController.text.length < 6) {
      nextButtonEnable = false;
    } else {
      nextButtonEnable = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _phoneTextController.removeListener(phoneTextListener);
    _codeTextController.removeListener(codeTextListener);

    _phoneTextController.dispose();
    _codeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SizedBox(
          height: 44,
          width: 100.w,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: nextButtonEnable
                  ? Pallete.point
                  : Pallete.point.withOpacity(0.4),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child:
                  // state is UserModelLoading
                  //     ? const SizedBox(
                  //         width: 15,
                  //         height: 15,
                  //         child: CircularProgressIndicator(
                  //           color: Pallete.point,
                  //         ),
                  //       )
                  //     :
                  Text(
                '다음',
                style: h6Headline.copyWith(
                  color: _phoneTextController.text.isEmpty ||
                          _codeTextController.text.isEmpty
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  widget.verificationType == VerificationType.register
                      ? '시작하기 위해\n 휴대폰 번호를 입력해주세요.'
                      : '가입확인을 위해\n 휴대폰 번호를 입력해주세요.',
                  style: h3Headline.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(
                  height: 36,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AutofillGroup(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: CustomTextFormField(
                                    maxLength: 13,
                                    maxLine: 1,
                                    controller: _phoneTextController,
                                    fullLabelText: '휴대폰 번호를 입력해주세요',
                                    labelText: '휴대폰 번호',
                                    autoFocus: false,
                                    textInputType: TextInputType.number,
                                    autoFillHint: const [
                                      AutofillHints.telephoneNumber,
                                    ],
                                    formatter: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      PhoneNumberFormatter(),
                                    ],
                                    onChanged: (value) {
                                      phoneNumber = value;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Container(
                                width: 73,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: sendButtonEnable
                                      ? Pallete.point
                                      : Pallete.gray,
                                ),
                                child: Center(
                                  child: Text(
                                    '발송',
                                    style: s2SubTitle.copyWith(
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            height: 44,
                            child: CustomTextFormField(
                              maxLength: 6,
                              maxLine: 1,
                              controller: _codeTextController,
                              fullLabelText: '인증번호 6자리를 입력해주세요',
                              labelText: '인증번호',
                              autoFocus: false,
                              textInputType: TextInputType.number,
                              autoFillHint: const [
                                AutofillHints.oneTimeCode,
                              ],
                              onChanged: (value) {
                                code = value;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                KeyboardVisibilityBuilder(
                  builder: (p0, isKeyboardVisible) {
                    return SizedBox(
                      height: !isKeyboardVisible
                          ? 100.h - kToolbarHeight - 56 - 370
                          : 50,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
