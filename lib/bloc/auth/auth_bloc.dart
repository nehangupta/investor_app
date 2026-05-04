// ============================================================
// FILE: lib/bloc/auth/auth_bloc.dart
// PURPOSE: Manages login, logout, and session state.
//
// HOW BLOC WORKS:
//   UI  →  dispatches Event  →  BLoC processes  →  emits State  →  UI rebuilds
//
// EVENTS (what user does):   AppStarted, LoginRequested, LogoutRequested
// STATES (what UI shows):    AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── EVENTS ────────────────────────────────────────────────
// Events extend Equatable so BLoC can compare them properly

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Fired when the app first opens — checks if already logged in
class AppStarted extends AuthEvent {}

// Fired when user taps the Login button
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Fired when user taps Logout
class LogoutRequested extends AuthEvent {}

// ─── STATES ────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state before anything happens
class AuthInitial extends AuthState {}

// Shown while checking session or verifying credentials
class AuthLoading extends AuthState {}

// User is logged in — holds the email for display
class AuthAuthenticated extends AuthState {
  final String email;
  AuthAuthenticated(this.email);
  @override
  List<Object?> get props => [email];
}

// User is NOT logged in → show LoginScreen
class AuthUnauthenticated extends AuthState {}

// Wrong email/password → show error message
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLOC ──────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Key used to store email in SharedPreferences
  static const String _sessionKey = 'user_session_email';

  // Mock credentials (no real backend needed)
  static const String _validEmail    = 'investor@demo.com';
  static const String _validPassword = 'Demo@1234';

  AuthBloc() : super(AuthInitial()) {
    // Register event handlers
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ── Handler 1: App opens → check if session exists ──────
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // show loading spinner
    await Future.delayed(const Duration(milliseconds: 600)); // small delay for splash feel

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_sessionKey); // null if not logged in

    if (savedEmail != null) {
      emit(AuthAuthenticated(savedEmail)); // auto-login
    } else {
      emit(AuthUnauthenticated()); // go to login screen
    }
  }

  // ── Handler 2: User submits login form ──────────────────
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // show button spinner
    await Future.delayed(const Duration(milliseconds: 800)); // simulate API call

    // Check credentials
    final emailMatches    = event.email.trim() == _validEmail;
    final passwordMatches = event.password == _validPassword;

    if (emailMatches && passwordMatches) {
      // Save session to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, event.email.trim());

      emit(AuthAuthenticated(event.email.trim()));
    } else {
      emit(AuthError('Invalid credentials.\nUse: investor@demo.com / Demo@1234'));
    }
  }

  // ── Handler 3: User taps logout ─────────────────────────
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey); // clear session
    emit(AuthUnauthenticated());
  }
}
