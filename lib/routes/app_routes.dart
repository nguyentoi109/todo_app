import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/screens/auth/register_screen.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/task/add_task_screen.dart';
import '../screens/task/task_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        final loc = state.matchedLocation;

        if (status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        final isAuthRoute = loc == '/login' || loc == '/register';

        if (status == AuthStatus.unauthenticated) {
          return isAuthRoute ? null : '/login';
        }

        // authenticated
        if (loc == '/splash' || isAuthRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(
            path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen()),
        // GoRoute(
        //     path: '/home',
        //     builder: (context, state) => const MainScaffold(initialIndex: 0)),
        // GoRoute(
        //     path: '/tasks',
        //     builder: (context, state) => const MainScaffold(initialIndex: 1)),
        // GoRoute(
        //     path: '/profile',
        //     builder: (context, state) => const MainScaffold(initialIndex: 2)),
        GoRoute(
          path: '/tasks/add',
          builder: (context, state) => const AddTaskScreen(),
        ),
        GoRoute(
          path: '/tasks/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return TaskDetailScreen(taskId: id);
          },
        ),
      ],
    );
  }
}
