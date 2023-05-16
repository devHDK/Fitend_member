import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final int count;

  const WorkoutCard({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> countList = [];
    List<Widget> firstList = [];
    List<Widget> secondList = [];

    List.generate(
      count,
      (index) => countList.add(
        Row(
          children: [
            Container(
              width: 30,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: BODY_TEXT_COLOR,
              ),
            ),
            const SizedBox(
              width: 8,
            )
          ],
        ),
      ),
    );

    if (count > 5) {
      firstList = countList.sublist(0, 5);
      secondList = countList.sublist(5, count);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 157,
      decoration: const BoxDecoration(
        color: BACKGROUND_COLOR,
      ),
      child: Row(
        children: [
          _renderImage(),
          const SizedBox(
            width: 23,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 52,
              ),
              const Text(
                '로우 머신',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '$count SET',
                style: const TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (count <= 5)
                    Row(
                      children: countList.toList(),
                    ),
                  if (count > 5)
                    Row(
                      children: firstList.toList(),
                    ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (count > 5)
                    Row(
                      children: secondList.toList(),
                    )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Stack _renderImage() {
    return Stack(
      children: [
        SizedBox(
          width: 72,
          height: 128,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('asset/img/low_machine.png'),
          ),
        ),
        Positioned(
          left: 42,
          top: 98,
          child: SizedBox(
            width: 35,
            height: 35,
            child: ClipRRect(
              child: Image.asset('asset/img/muscle.png'),
            ),
          ),
        )
      ],
    );
  }
}
