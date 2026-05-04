// ============================================================
// FILE: lib/main.dart
// PURPOSE: App entry point.
//          1. Sets up all 3 BLoCs via MultiBlocProvider
//          2. AppRouter listens to AuthBloc and navigates
//             to LoginScreen or DealListScreen accordingly
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/deal/deal_bloc.dart';
import 'bloc/interest/interest_bloc.dart';
import 'data/deal_repository.dart';
import 'screens/login_screen.dart';
import 'screens/deal_list_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required before runApp
  runApp(const InvestorApp());
}

class InvestorApp extends StatelessWidget {
  const InvestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Provide all 3 BLoCs to the entire app from the root
      providers: [
        // AuthBloc: starts with AppStarted to check existing session
        BlocProvider(
          create: (_) => AuthBloc()..add(AppStarted()),
        ),
        // DealBloc: needs DealRepository to fetch data
        BlocProvider(
          create: (_) => DealBloc(DealRepository()),
        ),
        // InterestBloc: loads saved interest IDs from SharedPreferences
        BlocProvider(
          create: (_) => InterestBloc()..add(LoadInterests()),
        ),
      ],
      child: MaterialApp(
        title: 'InvestNow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark, // apply our custom dark fintech theme
        home: const AppRouter(),
      ),
    );
  }
}

// ── AppRouter: decides which screen to show ──────────────────
// This is the "gate" — it watches AuthBloc and shows the
// correct screen based on authentication state.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        // App is starting / checking session → show splash loader
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 20),
                  Text('InvestNow',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Loading...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        // User is logged in → go to main deal screen
        if (state is AuthAuthenticated) {
          return const DealListScreen();
        }

        // Not logged in (or logged out) → show login
        return const LoginScreen();
      },
    );
  }
}
