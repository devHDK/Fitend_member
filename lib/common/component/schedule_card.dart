import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final DateTime date;
  final String title;
  final String? subTitle;
  final String? time;
  final String result;
  final String type;
  final bool selected;

  const ScheduleCard({
    super.key,
    required this.date,
    required this.title,
    this.subTitle,
    this.time,
    required this.result,
    required this.type,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: selected ? 174 : 123,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: selected
            ? const DecorationImage(
                image: AssetImage("asset/img/schedule_image_pt.png"),
                fit: BoxFit.fill,
                opacity: 0.3)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    // image: ,
                  ),
                  width: 39,
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          weekday[date.weekday - 1],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          date.day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        subTitle != null ? subTitle! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline,
                  size: 24,
                  color: Colors.white,
                ),
              ],
            ),
            if (selected)
              Column(
                children: [
                  const SizedBox(
                    height: 23,
                  ),
                  SizedBox(
                    width: 319,
                    height: 44,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: POINT_COLOR,
                        ),
                        onPressed: () {},
                        child: const Text(
                          '운동확인 하기🔍',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
