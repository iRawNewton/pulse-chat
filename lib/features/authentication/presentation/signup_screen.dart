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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isGoogleLoading = false;
  bool _isEmailLoading = false;
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleGoogleSignUp() {
    setState(() => _isGoogleLoading = true);
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

  void _handleEmailSignUp() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_agreedToTerms);

    if (!formValid || !_agreedToTerms) return;

    setState(() => _isEmailLoading = true);
    context.read<AuthBloc>().add(
          SignUpWithEmailRequested(
            name: _nameController.text.trim(),
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
            textStyle: const TextStyle(color: Colors.white),
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
                  SizedBox(height: 16.h),

                  // --- Back + wordmark row ---
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.login);
                          }
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(Icons.arrow_back_rounded, size: 20.r, color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  Text(
                    'Create your account',
                    style: AppTextStyles.w700.copyWith(
                      fontSize: 28.sp,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join Pulse Chat and start the conversation.',
                    style: AppTextStyles.w400.copyWith(fontSize: 15.sp, color: colors.textSecondary, height: 1.4),
                  ),

                  SizedBox(height: 32.h),

                  GoogleAuthButton(
                    label: 'Sign up with Google',
                    isLoading: _isGoogleLoading,
                    onPressed: _handleGoogleSignUp,
                  ),

                  SizedBox(height: 26.h),
                  const OrDivider(label: 'or sign up with email'),
                  SizedBox(height: 26.h),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthTextField(
                          controller: _nameController,
                          label: 'Full name',
                          hint: 'Alex Carter',
                          icon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter your name';
                            return null;
                          },
                        ),
                        SizedBox(height: 18.h),
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
                          hint: 'At least 6 characters',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter a password';
                            if (value.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 18.h),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleEmailSignUp(),
                          validator: (value) {
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),

                        SizedBox(height: 18.h),

                        // --- Terms checkbox ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                    if (_agreedToTerms) _showTermsError = false;
                                  });
                                },
                                activeColor: colors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                side: BorderSide(color: colors.border, width: 1.4),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text.rich(
                                  TextSpan(
                                    style: AppTextStyles.w400.copyWith(
                                      fontSize: 13.sp,
                                      color: colors.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTextStyles.w600.copyWith(fontSize: 13.sp, color: colors.primary),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTextStyles.w600.copyWith(fontSize: 13.sp, color: colors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_showTermsError)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h, left: 32.w),
                            child: Text(
                              'Please accept the terms to continue',
                              style: AppTextStyles.w500.copyWith(fontSize: 12.sp, color: colors.error),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  PulseButton(label: 'Create account', isLoading: _isEmailLoading, onPressed: _handleEmailSignUp),

                  SizedBox(height: 28.h),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.login);
                            }
                          },
                          child: Text(
                            'Log in',
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
