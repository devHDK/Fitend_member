import 'package:fitend_member/common/view/error_screen.dart';
import 'package:fitend_member/common/view/onboarding_screen.dart';
import 'package:fitend_member/common/view/splash_screen.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/schedule/view/schedule_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:fitend_member/workout/view/workout_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({required this.ref}) {
    ref.listen<UserModelBase?>(
      userMeProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/onboard',
          name: OnBoardingScreen.routeName,
          builder: (context, state) => const OnBoardingScreen(),
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
          routes: [
            GoRoute(
              path: 'login',
              name: LoginScreen.routeName,
              builder: (context, state) => const LoginScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/schedule',
          name: ScheduleScreen.routeName,
          builder: (context, state) => const ScheduleScreen(),
          routes: [
            GoRoute(
              path: 'workout/:workoutScheduleId',
              name: WorkoutListScreen.routeName,
              builder: (context, state) => WorkoutListScreen(
                id: int.parse(state.pathParameters['workoutScheduleId']!),
              ),
              routes: [
                GoRoute(
                  path: 'exercise',
                  name: ExerciseScreen.routeName,
                  builder: (context, state) => ExerciseScreen(
                    id: int.parse(state.pathParameters['workoutScheduleId']!),
                    exercise: state.extra as Exercise,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/error',
          name: ErrorScreen.routeName,
          builder: (context, state) => const ErrorScreen(),
        ),
      ];

  Future<String?> redirectLogic(
      BuildContext context, GoRouterState state) async {
    final UserModelBase? user = ref.read(userMeProvider);

    final loginIn = state.location == '/splash/login';

    if (user == null) {
      return loginIn ? null : '/splash';
    }

    //user != null

    //UserModel
    //로그인 중이거나 현재 위치가 onboardScreen이면 홈으로 이동
    if (user is UserModel) {
      return loginIn || state.location == '/onboard' ? '/schedule' : null;
    }

    // getMe Error...
    if (user is UserModelError) {
      return loginIn && user.statusCode != 504 ? '/splash/login' : '/error';
    }

    return null;
  }
}
