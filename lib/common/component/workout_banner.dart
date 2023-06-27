import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class WorkoutBanner extends StatelessWidget {
  final String title;
  final String subTitle;
  final int exerciseCount;
  final String time;

  const WorkoutBanner({
    super.key,
    required this.title,
    required this.subTitle,
    required this.exerciseCount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    List<String> timeString = time.split(':');

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('asset/img/schedule_image_pt.png'),
          fit: BoxFit.fill,
          opacity: 0.4,
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              subTitle,
              style: const TextStyle(
                color: LIGHT_GRAY_COLOR,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 1,
              color: LIGHT_GRAY_COLOR,
            ),
            const SizedBox(
              height: 19,
            ),
            Row(
              children: [
                Text(
                  '총 $exerciseCount개의 운동',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                Image.asset(
                  'asset/img/timer.png',
                  width: 14,
                ),
                Text(
                  timeString[0] == '00'
                      ? ' ${timeString[1]}분'
                      : ' ${timeString[0]}시간 ${timeString[1]}분',
                  style: const TextStyle(
                    color: LIGHT_GRAY_COLOR,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
