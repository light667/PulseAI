import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulseai/services/firebase/auth.dart';
import 'package:pulseai/services/user_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_assets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Optional fields
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodGroupController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Auth().createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await UserService().saveUserData(
            uid: user.uid,
            username: _nameController.text.trim(),
            email: _emailController.text.trim(),
            weight: _weightController.text.trim().isNotEmpty ? _weightController.text.trim() : null,
            height: _heightController.text.trim().isNotEmpty ? _heightController.text.trim() : null,
            bloodGroup: _bloodGroupController.text.trim().isNotEmpty ? _bloodGroupController.text.trim() : null,
          );
        } catch (e) {
          debugPrint('Error saving user data: $e');
        }
      }

      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred: ${e.message}';
      if (e.code == 'weak-password') message = 'The password provided is too weak.';
      else if (e.code == 'email-already-in-use') message = 'The account already exists for that email.';
      else if (e.code == 'invalid-email') message = 'Invalid email address.';
      else if (e.code == 'operation-not-allowed') message = 'Email/password accounts are not enabled.';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await Auth().signInWithGoogle();
      if (userCredential != null) {
        await UserService().saveUserData(
          uid: userCredential.user!.uid,
          username: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
        );

        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Premium input decoration for glassmorphic feel
    final inputDecor = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Basic premium gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF0077B6), Color(0xFF023E8A), Color(0xFF0096C7)],
              ),
            ),
          ),
          
          // Blurred background shapes
          Positioned(
            top: 50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.35)),
            ).animate().fadeIn(duration: 1.seconds).scale(),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF48CAE4).withOpacity(0.25)),
            ).animate().fadeIn(duration: 1.2.seconds).scale(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Logo Glass
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => const Icon(Icons.health_and_safety, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 24),
                  
                  // Glassmorphic Signup Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.signupTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ).animate().fadeIn().slideY(begin: 0.2),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Join PulseAI for revolutionary healthcare',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                              
                              const SizedBox(height: 32),

                              // Fields Section
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecor.copyWith(
                                  labelText: 'Username',
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Username required' : null,
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                              
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecor.copyWith(
                                  labelText: l10n.emailLabel,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Valid email required' : null,
                              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecor.copyWith(
                                  labelText: l10n.passwordLabel,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                              
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecor.copyWith(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Confirmation required';
                                  if (v != _passwordController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                              
                              const SizedBox(height: 32),
                              
                              // Optional Fields separated by a stylish divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "Optional Medical Data",
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                ],
                              ).animate().fadeIn(delay: 600.ms),
                              
                              const SizedBox(height: 24),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: inputDecor.copyWith(
                                        labelText: l10n.weight,
                                        suffixText: 'kg',
                                        suffixStyle: const TextStyle(color: Colors.white54),
                                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _heightController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: inputDecor.copyWith(
                                        labelText: l10n.height,
                                        suffixText: 'cm',
                                        suffixStyle: const TextStyle(color: Colors.white54),
                                        prefixIcon: const Icon(Icons.height),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 650.ms),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _bloodGroupController,
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecor.copyWith(
                                  labelText: l10n.bloodGroup,
                                  prefixIcon: const Icon(Icons.bloodtype),
                                  hintText: 'e.g., O+, A-',
                                ),
                              ).animate().fadeIn(delay: 700.ms),

                              const SizedBox(height: 40),
                              
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUpWithEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primaryDark,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24, width: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark),
                                        )
                                      : Text(l10n.register.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                              const SizedBox(height: 32),
                              
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      l10n.orContinueWith,
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : _signUpWithGoogle,
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Image.asset(AppAssets.google, height: 20),
                                ),
                                label: Text(l10n.googleLogin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                ),
                              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
                              
                              const SizedBox(height: 32),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      l10n.loginTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 1000.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
