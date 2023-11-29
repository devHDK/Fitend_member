import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
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
                imageUrl:
                    '${URLConstants.s3Url}${URLConstants.muscleImageUrl}${widget.muscle.id}.png',
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
                  '${muscleMap[widget.muscle.muscleType]}',
                  style: s3SubTitle.copyWith(
                    color: Pallete.lightGray,
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
                color: Pallete.lightGray,
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
