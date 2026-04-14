import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/utils/feedback.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/widgets/custom_button.dart';
import 'package:femi_friendly/widgets/custom_text_field.dart';
import 'package:femi_friendly/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthProvider>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    showAppSnackBar(
      context,
      'Account created. Please login.',
      icon: Icons.check_circle_outline,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE2EE), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start your wellness journey with confidence.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              hint: 'Enter your name',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty || !text.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Create a password',
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              onSuffixTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.length < 6) {
                                  return 'Password should be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CustomButton(
                              label: 'Register',
                              onPressed: _register,
                              icon: Icons.favorite_outline,
                            ),
                          ],
                        ),
                      ),
                    ),
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
