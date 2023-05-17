import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class MuscleCard extends StatefulWidget {
  const MuscleCard({super.key});

  @override
  State<MuscleCard> createState() => _MuscleCardState();
}

class _MuscleCardState extends State<MuscleCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'asset/img/muscle.png',
                  width: 52,
                  height: 52,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '근육위치',
                    style: TextStyle(
                      fontSize: 12,
                      color: LIGHT_GRAY_COLOR,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    '근육이름',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              const Text(
                'Primary',
                style: TextStyle(
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
      ),
    );
  }
}
