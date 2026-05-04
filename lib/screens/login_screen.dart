// ============================================================
// FILE: lib/screens/login_screen.dart
// PURPOSE: Login form. Dispatches LoginRequested event to
//          AuthBloc. Listens for AuthError to show snackbar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers hold the text typed in each field
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordHidden = true; // toggle eye icon

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    // Dispatch event → AuthBloc will handle validation
    context.read<AuthBloc>().add(LoginRequested(
      email:    _emailController.text,
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        // listener fires for side effects (snackbar) — not UI rebuilds
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.highRisk,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        // builder rebuilds UI when state changes
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 40),

                  // ── App Logo ────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF0060FF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('InvestNow',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const Text('Smart Deal Management',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  const Text('Sign in to explore investment opportunities',
                      style: TextStyle(color: AppColors.textSecondary)),

                  const SizedBox(height: 40),

                  // ── Email Field ─────────────────────────
                  _FieldLabel('Email Address'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'investor@demo.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Password Field ──────────────────────
                  _FieldLabel('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _passwordHidden,
                    style: const TextStyle(color: AppColors.textPrimary),
                    onSubmitted: (_) => _submitLogin(),
                    decoration: InputDecoration(
                      hintText: 'Demo@1234',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                        icon: Icon(
                          _passwordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary, size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Login Button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Text('Sign In'),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Demo Credentials Hint ───────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔑  Demo Credentials',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 8),
                        Text('Email:     investor@demo.com',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.7)),
                        Text('Password:  Demo@1234',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary));
  }
}
