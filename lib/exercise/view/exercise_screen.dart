import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  static String get routeName => 'exercise';
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
