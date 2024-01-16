import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class CustomOneButtonDialog extends StatefulWidget {
  CustomOneButtonDialog({
    super.key,
    this.title,
    required this.content,
    required this.confirmText,
    required this.confirmOnTap,
    this.dismissable = true,
  });

  String? title;
  final String content;
  final String confirmText;
  final GestureTapCallback confirmOnTap;
  bool? dismissable;

  @override
  State<CustomOneButtonDialog> createState() => _CustomOneButtonDialogState();
}

class _CustomOneButtonDialogState extends State<CustomOneButtonDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      blur: 0.2,
      dismissable: widget.dismissable,
      dialog: SimpleDialog(
        insetPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        backgroundColor: Colors.transparent,
        children: [
          Container(
            width: 335,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: s1SubTitle.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  Text(
                    widget.content,
                    style: s1SubTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              widget.confirmOnTap();
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: Container(
                      width: 279,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Pallete.point,
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.confirmText,
                                style: h6Headline.copyWith(
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
