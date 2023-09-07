import 'package:flutter/cupertino.dart';

class CustomTimerPicker extends StatelessWidget {
  const CustomTimerPicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.ms,
      minuteInterval: 1,
      secondInterval: 1,
      onTimerDurationChanged: (Duration changeTimer) {},
    );
  }
}
