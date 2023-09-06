import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutBanner extends StatelessWidget {
  final String title;
  final String subTitle;
  final String time;
  final List<Exercise> exercises;

  const WorkoutBanner({
    super.key,
    required this.title,
    required this.subTitle,
    required this.time,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    List<String> timeString = time.split(':');
    Set targetMuscles = {};
    String muscleString = '';

    for (var exercise in exercises) {
      targetMuscles.add(exercise.targetMuscles[0].muscleType);
    }

    for (var muscle in targetMuscles) {
      muscleString += ' ${muscleGroup[muscle]!} ∙';
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('asset/img/schedule_image_pt.png'),
          fit: BoxFit.fill,
          opacity: 0.4,
        ),
      ),
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: h4Headline.copyWith(
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              subTitle,
              style: s2SubTitle.copyWith(
                color: LIGHT_GRAY_COLOR,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  muscleString.substring(
                    1,
                    muscleString.length - 1,
                  ),
                  style: h5Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                SvgPicture.asset(
                  'asset/img/icon_timer.svg',
                  width: 20,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  timeString[0] == '00'
                      ? ' ${timeString[1]}분'
                      : ' ${timeString[0]}시간 ${timeString[1]}분',
                  style: s2SubTitle.copyWith(
                    color: LIGHT_GRAY_COLOR,
                    height: 1.2,
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
