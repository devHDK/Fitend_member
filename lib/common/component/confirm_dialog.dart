import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

DialogBackground confirmDialog({
  required String message,
  required String confirmText,
  required String cancelText,
  required GestureTapCallback confirmOnTap,
  required GestureTapCallback cancelOnTap,
}) {
  return DialogBackground(
    blur: 0.3,
    dialog: Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 319,
        height: 204,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: confirmOnTap,
                child: Container(
                  width: 279,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: POINT_COLOR,
                  ),
                  child: const Center(
                    child: Text(
                      '네, 저장할게요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              GestureDetector(
                onTap: confirmOnTap,
                child: Container(
                  width: 279,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: POINT_COLOR),
                  ),
                  child: const Center(
                    child: Text(
                      '아니요, 리셋할게요',
                      style: TextStyle(
                        fontSize: 14,
                        color: POINT_COLOR,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
