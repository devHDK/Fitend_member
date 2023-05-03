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
      height: 128,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
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
                  children: const [
                    Text(
                      '화',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '18',
                      style: TextStyle(
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
                children: const [
                  Text(
                    '근비대+근파워 데이🔥🦵💪',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    '스트렝스 훈련',
                    style: TextStyle(
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
      ),
    );
  }
}
