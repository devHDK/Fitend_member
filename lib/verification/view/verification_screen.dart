import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/view/email_show_screen.dart';
import 'package:fitend_member/user/view/user_register_screen.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_model.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_response.dart';
import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/model/verification_state_model.dart';
import 'package:fitend_member/verification/provider/verification_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'verification';

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

  late Timer timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _phoneTextController.addListener(phoneTextListener);
    _codeTextController.addListener(codeTextListener);
  }

  void phoneTextListener() {
    String phone = _phoneTextController.text;
    String phoneString = phone.replaceAll('-', '');

    if (phoneString.isNotEmpty) {
      ref
          .read(verificationProvider.notifier)
          .updateData(phoneNumber: phoneString);
    }

    if (phoneString.length < 11) {
      sendButtonEnable = false;
    } else {
      sendButtonEnable = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void codeTextListener() {
    String codeString = _codeTextController.text;

    if (codeString.isNotEmpty) {
      int code = int.parse(_codeTextController.text);
      ref.read(verificationProvider.notifier).updateData(code: code);
    }

    if (_codeTextController.text.length < 6) {
      nextButtonEnable = false;
    } else {
      nextButtonEnable = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onMessageSendPressed() {
    count = 180;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void onTick(Timer timer) {
    if (count > 0) {
      if (mounted) {
        setState(() {
          count--;
        });
      }
    } else {
      timer.cancel();
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
    final verificationModel = ref.watch(verificationProvider);

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
              ),
            ),
          )
        ],
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
              color: nextButtonEnable &&
                      verificationModel.isMessageSended &&
                      !verificationModel.isCodeSended
                  ? Pallete.point
                  : Pallete.point.withOpacity(0.4),
            ),
            child: _nextButton(verificationModel, context),
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
                              _messageSendButton(verificationModel, context)
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (verificationModel.isMessageSended)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell _messageSendButton(
      VerificationStateModel verificationModel, BuildContext context) {
    return InkWell(
      onTap: sendButtonEnable && !verificationModel.isMessageSended
          ? () async {
              try {
                await ref
                    .read(verificationProvider.notifier)
                    .postVerificationMessage(
                      reqModel: PostVerificationModel(
                        type: widget.verificationType,
                        phone: verificationModel.phoneNumber!,
                      ),
                    );

                onMessageSendPressed();
              } on DioException catch (e) {
                String message = '';

                if (e.response!.statusCode == 405) {
                  message = '잠시후 다시 시도해 주세요!';
                } else if (e.response!.statusCode == 404) {
                  message = '입력하신 번호로 가입된 계정이 없어요 😯';
                } else {
                  message = '서버와 통신중 오류가 발생하였습니다!';
                }

                if (!context.mounted) return;

                showDialog(
                  context: context,
                  builder: (context) => DialogWidgets.oneButtonDialog(
                    message: message,
                    confirmText: '확인',
                    confirmOnTap: () => context.pop(),
                  ),
                );

                _phoneTextController.text = '';
              }
            }
          : null,
      child: Container(
        width: 73,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sendButtonEnable && !verificationModel.isMessageSended
              ? Pallete.point
              : verificationModel.isMessageSended
                  ? Colors.white
                  : Pallete.gray,
        ),
        child: Center(
          child: Text(
            !verificationModel.isMessageSended
                ? '발송'
                : count == 0
                    ? '재발송'
                    : DataUtils.getTimeStringMinutes(
                        count,
                      ),
            style: s2SubTitle.copyWith(
              color: !verificationModel.isMessageSended
                  ? Colors.white
                  : Pallete.point,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton _nextButton(
      VerificationStateModel verificationModel, BuildContext context) {
    return ElevatedButton(
      onPressed: nextButtonEnable &&
              verificationModel.isMessageSended &&
              !verificationModel.isCodeSended
          ? () async {
              try {
                await ref
                    .read(verificationProvider.notifier)
                    .postVerificationConfirm(
                      reqModel: PostVerificationConfirmModel(
                        codeToken: verificationModel.codeToken!,
                        code: verificationModel.code!,
                      ),
                    )
                    .then((response) {
                  ref.read(verificationProvider.notifier).init();

                  _routeNextPage(
                    model: response,
                    phone: verificationModel.phoneNumber!,
                  );
                });
              } catch (e) {
                String message = '';
                if (e is DioException) {
                  if (e.response!.statusCode == 401) {
                    message = '인증번호가 만료되었어요!\n확인 후 재발송을 눌러주세요 🙏';
                  } else if (e.response!.statusCode == 403) {
                    message = '인증번호가 일치하지 않아요 😣';
                  }

                  if (!context.mounted) return;

                  ref
                      .read(verificationProvider.notifier)
                      .updateData(isCodeSended: false);

                  showDialog(
                    context: context,
                    builder: (context) => DialogWidgets.oneButtonDialog(
                      message: message,
                      confirmText: '확인',
                      confirmOnTap: () => context.pop(),
                    ),
                  );

                  _codeTextController.text = '';
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: verificationModel.isCodeSended
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Text(
              '다음',
              style: h6Headline.copyWith(
                color: nextButtonEnable && !verificationModel.isCodeSended
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
            ),
    );
  }

  void _routeNextPage(
      {PostVerificationConfirmResponse? model, required String phone}) {
    bool isAlreadyRegister = false;
    if (model != null && model.email != null) {
      isAlreadyRegister = true;
    }

    context.pop();

    if (widget.verificationType == VerificationType.register &&
        !isAlreadyRegister) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => UserRegisterScreen(
            phone: phone,
          ),
        ),
      );
    } else if ((widget.verificationType == VerificationType.register &&
            widget.verificationType == VerificationType.id) ||
        isAlreadyRegister) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => EmailShowScreen(
            verificationType: widget.verificationType,
            email: model!.email!,
            phone: phone,
            phoneToken: model.phoneToken,
          ),
        ),
      );
    }
    // else if (widget.verificationType == VerificationType.reset) {

    // }
  }
}
