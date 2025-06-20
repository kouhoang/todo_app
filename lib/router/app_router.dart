import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/global/auth/auth_cubit.dart';
import 'package:todo_app/ui/views/splash/splash_view.dart';
import '../ui/views/home/home_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;

      if (authState is AuthAuthenticated && state.fullPath == '/') {
        return '/home';
      }

      if (authState is! AuthAuthenticated && state.fullPath != '/') {
        return '/';
      }

      return null;
    },
  );
}
