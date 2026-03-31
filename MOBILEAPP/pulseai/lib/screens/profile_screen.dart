import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulseai/services/firebase/auth.dart';
import 'package:pulseai/providers/locale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/medical_id_card.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = false;
  
  String _bloodGroup = '-';
  String _weight = '-';
  String _height = '-';
  String _allergies = '';
  int _diagnosticCount = 0;
  int _scanCount = 0;
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _bloodGroup = prefs.getString('blood_group') ?? '-';
        _weight = prefs.getString('weight') ?? '-';
        _height = prefs.getString('height') ?? '-';
        _allergies = prefs.getString('allergies') ?? '';
        _diagnosticCount = prefs.getInt('diagnostic_count') ?? 0;
        _scanCount = prefs.getInt('scan_count') ?? 0;
        _sessionCount = prefs.getInt('session_count') ?? 0;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Auth().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.chooseLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageTile(flag: '🇬🇧', name: 'English', code: 'en', currentLocale: currentLocale, onTap: () => _changeLanguage('en')),
              _buildLanguageTile(flag: '🇫🇷', name: 'Français', code: 'fr', currentLocale: currentLocale, onTap: () => _changeLanguage('fr')),
              _buildLanguageTile(flag: '🇹🇬', name: 'Ewe (Ɛʋɛgbe)', code: 'ee', currentLocale: currentLocale, onTap: () => _changeLanguage('ee')),
              _buildLanguageTile(flag: '🇹🇬', name: 'Kabiyè', code: 'kbp', currentLocale: currentLocale, onTap: () => _changeLanguage('kbp')),
              _buildLanguageTile(flag: '🇹🇬', name: 'Tem (Kotokoli)', code: 'tem', currentLocale: currentLocale, onTap: () => _changeLanguage('tem')),
              _buildLanguageTile(flag: '🇧🇯', name: 'Fɔngbe (Fon)', code: 'fon', currentLocale: currentLocale, onTap: () => _changeLanguage('fon')),
              _buildLanguageTile(flag: '🇳🇬', name: 'Yorùbá', code: 'yo', currentLocale: currentLocale, onTap: () => _changeLanguage('yo')),
              _buildLanguageTile(flag: '🇨🇩', name: 'Lingála', code: 'ln', currentLocale: currentLocale, onTap: () => _changeLanguage('ln')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String flag,
    required String name,
    required String code,
    required String currentLocale,
    required VoidCallback onTap,
  }) {
    final isSelected = currentLocale == code;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue) : null,
      selected: isSelected,
      selectedTileColor: AppTheme.primaryBlue.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(Locale(languageCode));
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.languageChanged,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myProfile,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Premium Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF0077B6), Color(0xFF023E8A), Color(0xFF0096C7)],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Glassmorphic Profile Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName?.toUpperCase() ?? 'USER',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'email@example.com',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.pushNamed(context, '/edit_profile');
                                      if (result == true) _loadProfileData();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.editProfile,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
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
                  ).animate().fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 24),
                  
                  // Medical ID Card Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        // Since MedicalIDCard inside has its own white background, 
                        // we'll still use it but the padding gives it a nice frosted border.
                        // Wait, to keep premium UI, I will just display the MedicalIDCard and ensure it meshes.
                        child: MedicalIDCard(
                          bloodGroup: _bloodGroup,
                          weight: _weight,
                          height: _height,
                          allergies: _allergies,
                          onEdit: () async {
                            final result = await Navigator.pushNamed(context, '/edit_profile');
                            if (result == true) _loadProfileData();
                          },
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  // History Section Header
                  Text(
                    l10n.history,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/diagnosis_history');
                            _loadProfileData();
                          },
                          child: _buildStatCard(_diagnosticCount.toString(), 'Diagnoses', Icons.healing_rounded),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(_scanCount.toString(), 'Scans', Icons.qr_code_scanner_rounded)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/chat_history');
                            _loadProfileData();
                          },
                          child: _buildStatCard(_sessionCount.toString(), 'Sessions', Icons.forum_rounded),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                  const SizedBox(height: 32),

                  // Settings Section Header
                  Text(
                    l10n.settings,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildSettingItem(
                              Icons.translate_rounded, 
                              l10n.chooseLanguage, 
                              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                              onItemTap: _showLanguageDialog,
                            ),
                            Divider(height: 1, indent: 24, endIndent: 24, color: Colors.white.withOpacity(0.2)),
                            _buildSettingItem(
                              Icons.notifications_active_rounded,
                              l10n.notifications,
                              trailing: Switch(
                                value: _notifications,
                                onChanged: (val) => setState(() => _notifications = val),
                                activeColor: AppTheme.primaryLight,
                                activeTrackColor: Colors.white.withOpacity(0.4),
                                inactiveThumbColor: Colors.white70,
                                inactiveTrackColor: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Divider(height: 1, indent: 24, endIndent: 24, color: Colors.white.withOpacity(0.2)),
                            _buildSettingItem(
                              Icons.help_center_rounded, 
                              l10n.helpSupport, 
                              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () => _signOut(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.redAccent.withOpacity(0.5),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {Widget? trailing, VoidCallback? onItemTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
      ),
      trailing: trailing,
      onTap: onItemTap ?? () {},
    );
  }
}
