import 'package:fitend_member/common/const/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrainerListExtendScreen extends ConsumerStatefulWidget {
  const TrainerListExtendScreen({super.key});

  @override
  ConsumerState<TrainerListExtendScreen> createState() =>
      _TrainerListExtendScreenState();
}

class _TrainerListExtendScreenState
    extends ConsumerState<TrainerListExtendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
    );
  }
}
