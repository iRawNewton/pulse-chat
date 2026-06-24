import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_event.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_state.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_text_field.dart';
import 'package:pulse_chat/features/authentication/widgets/google_auth_button.dart';
import 'package:pulse_chat/features/authentication/widgets/or_divider.dart';
import 'package:pulse_chat/features/authentication/widgets/pulse_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isGoogleLoading = false;
  bool _isEmailLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    setState(() => _isGoogleLoading = true);
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

  void _handleEmailLogin() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isEmailLoading = true);
    context.read<AuthBloc>().add(
      SignInWithEmailRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() {
            _isGoogleLoading = false;
            _isEmailLoading = false;
          });
          context.go(AppRoutes.home);
        } else if (state is AuthFailure) {
          setState(() {
            _isGoogleLoading = false;
            _isEmailLoading = false;
          });
          showToast(
            state.error,
            position: ToastPosition.bottom,
            backgroundColor: Colors.redAccent,
          );
        } else if (state is Unauthenticated) {
          setState(() {
            _isGoogleLoading = false;
            _isEmailLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 1.sh - 80.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),

                    // --- Wordmark ---
                    Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colors.primary, colors.secondary],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.bolt_rounded, color: Colors.white, size: 22.r),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Pulse Chat',
                          style: AppTextStyles.w700.copyWith(fontSize: 18.sp, color: colors.textPrimary),
                        ),
                      ],
                    ),

                    SizedBox(height: 44.h),

                    Text(
                      'Welcome back',
                      style: AppTextStyles.w700.copyWith(
                        fontSize: 30.sp,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to pick up your conversations.',
                      style: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textSecondary, height: 1.4),
                    ),

                    SizedBox(height: 36.h),

                    GoogleAuthButton(
                      label: 'Continue with Google',
                      isLoading: _isGoogleLoading,
                      onPressed: _handleGoogleSignIn,
                    ),

                    SizedBox(height: 28.h),
                    const OrDivider(),
                    SizedBox(height: 28.h),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'you@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter your email';
                              if (!value.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          SizedBox(height: 18.h),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleEmailLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Enter your password';
                              if (value.length < 6) return 'At least 6 characters';
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO(developer): navigate to forgot-password flow.
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 32.h)),
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.w600.copyWith(fontSize: 13.sp, color: colors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    PulseButton(label: 'Log in', isLoading: _isEmailLoading, onPressed: _handleEmailLogin),

                    SizedBox(height: 28.h),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await context.push(AppRoutes.signup);
                            },
                            child: Text(
                              'Sign up',
                              style: AppTextStyles.w700.copyWith(fontSize: 14.sp, color: colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
