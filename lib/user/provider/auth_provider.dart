import 'package:fitend_member/common/view/error_screen.dart';
import 'package:fitend_member/common/view/onboarding_screen.dart';
import 'package:fitend_member/common/view/splash_screen.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/meeting/view/meeting_date_screen.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/schedule/view/nextweek_schedule_screen.dart';
import 'package:fitend_member/schedule/view/schedule_result_screen.dart';
import 'package:fitend_member/thread/view/thread_detail_screen.dart';
import 'package:fitend_member/ticket/view/active_ticket_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:fitend_member/home_screen.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:fitend_member/workout/view/workout_list_screen.dart';
import 'package:flutter/cupertino.dart';
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
      getMeProvider,
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
          pageBuilder: (context, state) => _fadeTransition(
            state,
            const SplashScreen(),
          ),
          routes: [
            GoRoute(
              path: 'login',
              name: LoginScreen.routeName,
              builder: (context, state) => const LoginScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/',
          name: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'workout/:workoutScheduleId',
              name: WorkoutListScreen.routeName,
              pageBuilder: (context, state) {
                return _rightToLeftTransiton(
                  state,
                  WorkoutListScreen(
                    id: int.parse(state.pathParameters['workoutScheduleId']!),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'exercise',
                  name: ExerciseScreen.routeName,
                  pageBuilder: (context, state) => _rightToLeftTransiton(
                    state,
                    ExerciseScreen(
                      id: int.parse(state.pathParameters['workoutScheduleId']!),
                      exercise: state.extra as Exercise,
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'mypage',
              name: MyPageScreen.routeName,
              builder: (context, state) => const MyPageScreen(),
              routes: [
                GoRoute(
                  path: 'ticket',
                  name: ActiveTicketScreen.routeName,
                  builder: (context, state) => const ActiveTicketScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'meetingDate/:trainerId',
              name: MeetingDateScreen.routeName,
              builder: (context, state) => MeetingDateScreen(
                trainerId: int.parse(state.pathParameters['trainerId']!),
              ),
            ),
            GoRoute(
              path: 'nextWeekSchedule',
              name: NextWeekScheduleScreen.routeName,
              pageBuilder: (context, state) => _botToTopTransiton(
                state,
                const NextWeekScheduleScreen(),
              ),
            ),
            GoRoute(
              path: 'notification',
              name: NotificationScreen.routeName,
              builder: (context, state) => const NotificationScreen(),
            ),
            GoRoute(
              path: 'threadDetail/:threadId',
              name: ThreadDetailScreen.routeName,
              builder: (context, state) => ThreadDetailScreen(
                threadId: int.parse(state.pathParameters['threadId']!),
              ),
            ),
            GoRoute(
              path: 'workoutFeedback/:workoutScheduleId',
              name: WorkoutFeedbackScreen.routeName,
              pageBuilder: (context, state) => _botToTopTransiton(
                state,
                WorkoutFeedbackScreen(
                  workoutScheduleId:
                      int.parse(state.pathParameters['workoutScheduleId']!),
                  exercises: state.extra as List<Exercise>,
                  startDate: state.uri.queryParameters['startDate'] as String,
                ),
              ),
            ),
            GoRoute(
              path: 'scheduleResult/:id',
              name: ScheduleResultScreen.routeName,
              pageBuilder: (context, state) {
                return _botToTopTransiton(
                  state,
                  ScheduleResultScreen(
                    workoutScheduleId: int.parse(state.pathParameters['id']!),
                    exercises: state.extra != null
                        ? state.extra as List<Exercise>
                        : null,
                    key: state.pageKey,
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/error',
          name: ErrorScreen.routeName,
          builder: (context, state) => const ErrorScreen(),
        ),
      ];

  CustomTransitionPage<void> _fadeTransition(
      GoRouterState state, Widget widget) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  CustomTransitionPage<void> _botToTopTransiton(
      GoRouterState state, Widget widget) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0, 2.0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.ease),
          ),
        ),
        child: child,
      ),
    );
  }

  CustomTransitionPage<void> _rightToLeftTransiton(
      GoRouterState state, Widget widget) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.ease),
          ),
        ),
        child: child,
      ),
    );
  }

  CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(
          Widget child) =>
      (BuildContext context, GoRouterState state) {
        return buildPageWithDefaultTransition<T>(
          context: context,
          state: state,
          child: child,
        );
      };

  Future<String?> redirectLogic(
      BuildContext context, GoRouterState state) async {
    final UserModelBase? user = ref.read(getMeProvider);

    final loginIn = state.uri.toString() == '/splash/login';

    if (user == null) {
      return loginIn ? null : '/splash';
    }

    //user != null

    //UserModel
    //로그인 중이거나 현재 위치가 onboardScreen이면 홈으로 이동
    if (user is UserModel) {
      return loginIn || state.uri.toString() == '/onboard' ? '/' : null;
    }

    if (user is UserModelError && user.statusCode == 444) {
      return null;
    }

    // getMe Error...
    if (user is UserModelError) {
      return loginIn && (user.statusCode != 504) ? '/splash/login' : '/error';
    }

    return null;
  }
}
