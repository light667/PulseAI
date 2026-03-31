import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pulseai/services/firebase/auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_assets.dart';
import '../providers/locale_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Auth().loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue';
      if (e.code == 'user-not-found') message = 'Aucun utilisateur trouvé avec cet email';
      else if (e.code == 'wrong-password') message = 'Mot de passe incorrect';
      else if (e.code == 'invalid-credential') message = 'Email ou mot de passe incorrect';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await Auth().signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Google: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).pushNamed('/signup');
  }

  void _showPasswordResetDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Réinitialiser le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre email pour recevoir un lien de réinitialisation'),
            const SizedBox(height: 20),
            TextField(
              controller: resetController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.emailLabel,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Auth().sendPasswordResetEmail(resetController.text);
                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email envoyé avec succès')),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

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
      body: Stack(
        children: [
          // Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF0096C7)],
              ),
            ),
          ),
          
          // Decorative Blurred Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.3)),
            ).animate().fadeIn(duration: 1.seconds).scale(),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF48CAE4).withOpacity(0.2)),
            ).animate().fadeIn(duration: 1.2.seconds).scale(),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language Dropdown Glass
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Locale>(
                            value: localeProvider.locale,
                            icon: const Icon(Icons.language, color: Colors.white),
                            dropdownColor: AppTheme.primaryDark,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            onChanged: (Locale? newValue) {
                              if (newValue != null) localeProvider.setLocale(newValue);
                            },
                            items: const [
                              DropdownMenuItem(value: Locale('fr'), child: Text('🇫🇷 Français')),
                              DropdownMenuItem(value: Locale('en'), child: Text('🇺🇸 English')),
                              DropdownMenuItem(value: Locale('ee'), child: Text('🇹🇬 Ewe')),
                              DropdownMenuItem(value: Locale('kbp'), child: Text('🇹🇬 Kabye')),
                              DropdownMenuItem(value: Locale('tem'), child: Text('🇹🇬 Kotokoli')),
                              DropdownMenuItem(value: Locale('fon'), child: Text('🇧🇯 Fon')),
                              DropdownMenuItem(value: Locale('yo'), child: Text('🇧🇯 Yoruba')),
                              DropdownMenuItem(value: Locale('ln'), child: Text('🇨🇩 Lingala')),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 30),

                    // Logo Glass Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => const Icon(Icons.health_and_safety, size: 60, color: Colors.white),
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 32),

                    // Glassmorphic Login Card
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
                              children: [
                                Text(
                                  l10n.loginTitle,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn().slideY(begin: 0.2),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.loginSubtitle,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                                
                                const SizedBox(height: 32),
                                
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputDecor.copyWith(
                                    labelText: l10n.emailLabel,
                                    prefixIcon: const Icon(Icons.email_outlined),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'L\'email est requis' : null,
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                                
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
                                  validator: (v) => (v == null || v.isEmpty) ? 'Le mot de passe est requis' : null,
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showPasswordResetDialog,
                                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                                    child: Text(l10n.forgotPassword, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signInWithEmail,
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
                                        : Text(l10n.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

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
                                  onPressed: _isLoading ? null : _signInWithGoogle,
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
                                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${l10n.noAccount} ", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                    GestureDetector(
                                      onTap: _navigateToSignup,
                                      child: Text(
                                        l10n.register,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 600.ms),
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
          ),
        ],
      ),
    );
  }
}
