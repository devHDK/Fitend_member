import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/target_muscle_model.dart';
import 'package:flutter/material.dart';

class MuscleCard extends StatefulWidget {
  final TargetMuscle muscle;
  const MuscleCard({
    super.key,
    required this.muscle,
  });

  @override
  State<MuscleCard> createState() => _MuscleCardState();
}

class _MuscleCardState extends State<MuscleCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: CustomNetworkImage(
                imageUrl: '$s3Url$muscleImageUrl${widget.muscle.id}.png',
                width: 52,
                height: 52,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${muscleGroup[widget.muscle.muscleType]}',
                  style: s3SubTitle.copyWith(
                    color: LIGHT_GRAY_COLOR,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  widget.muscle.name,
                  style: h5Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            Text(
              widget.muscle.type == 'main' ? 'Primary' : 'Secondary',
              style: s2SubTitle.copyWith(
                fontSize: 14,
                color: LIGHT_GRAY_COLOR,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 23,
        )
      ],
    );
  }
}
