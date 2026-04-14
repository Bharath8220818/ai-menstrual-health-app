import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/constants/app_strings.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/routes/routes.dart';
import 'package:femi_friendly/widgets/custom_button.dart';
import 'package:femi_friendly/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: AppStrings.demoEmail);
    _passwordController = TextEditingController(text: AppStrings.demoPassword);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final route = auth.hasCompletedSetup
          ? AppRoutes.home
          : AppRoutes.profileSetup;
      Navigator.pushReplacementNamed(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Invalid email or password'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFAD1457),
                  Color(0xFFE91E63),
                  Color(0xFFFF4081),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Header section (on gradient)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Femi-Friendly',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Welcome Back 💖',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue your health journey',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign In',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'Enter your email',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (text.isEmpty) return 'Email required';
                                    if (!text.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  onSuffixTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (text.isEmpty) return 'Password required';
                                    if (text.length < 6) {
                                      return 'At least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) => CustomButton(
                                    label: 'Sign In',
                                    onPressed: _handleLogin,
                                    isLoading: auth.isLoading,
                                    icon: Icons.arrow_forward_rounded,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Demo credentials hint
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Demo: ${AppStrings.demoEmail}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
