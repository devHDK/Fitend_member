import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/schedule/view/schedule_screen.dart';
import 'package:fitend_member/thread/view/thread_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String get routeName => 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final children = [const ScheduleScreen(), const ThreadScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: BACKGROUND_COLOR,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_outlined),
            label: '',
          ),
        ],
      ),
      body: children[_currentIndex],
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
