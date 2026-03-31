import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'home_screen.dart';
import 'diagnosis_screen.dart';
import 'hospital_map_screen.dart';
import 'scan_screen.dart';
import 'chat_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigate: _navigateToTab),
      const DiagnosisScreen(),
      const HospitalMapScreen(),
      const ScanScreen(),
      const ChatScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: AppTheme.glassDecoration.copyWith(
          color: AppTheme.primaryBlue.withOpacity(0.9), // Consistent background color
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              backgroundColor: Colors.transparent, // Transparent for glass effect
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              indicatorColor: Colors.white.withOpacity(0.2),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.medical_services_outlined),
                  selectedIcon: const Icon(Icons.medical_services),
                  label: AppLocalizations.of(context)!.navDiag,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.local_hospital_outlined),
                  selectedIcon: const Icon(Icons.local_hospital),
                  label: AppLocalizations.of(context)!.navHospital,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.qr_code_scanner),
                  selectedIcon: const Icon(Icons.qr_code_scanner),
                  label: AppLocalizations.of(context)!.navScan,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.psychology_outlined),
                  selectedIcon: const Icon(Icons.psychology),
                  label: AppLocalizations.of(context)!.navLyra,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 1, curve: Curves.easeOutCubic),
    );
  }
}
