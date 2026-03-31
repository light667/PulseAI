import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Instant Triage',
      description: 'Get lightning-fast medical assessments powered by our advanced AI tailored for Africa.',
      imagePath: AppAssets.onboarding1,
      icon: Icons.monitor_heart_outlined,
    ),
    OnboardingSlide(
      title: 'Smart Routing',
      description: 'Find the nearest optimal hospital based on capacity, distance, and your emergency level.',
      imagePath: AppAssets.onboarding2,
      icon: Icons.local_hospital_outlined,
    ),
    OnboardingSlide(
      title: 'Virtual Assistant',
      description: '24/7 mental health support and personalized daily wellness coaching from Lyra.',
      imagePath: AppAssets.onboarding3,
      icon: Icons.psychology_outlined,
    ),
    OnboardingSlide(
      title: 'Drug Scanner',
      description: 'Verify medication authenticity and get instant usage instructions safely with AI.',
      imagePath: AppAssets.onboarding4,
      icon: Icons.medication_outlined,
    ),
  ];

  void _nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Lighter blue background
      body: Stack(
        children: [
          // Background Carousel
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: _slides.length,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return _buildBackgroundSlide(_slides[index]);
            },
          ),
          
          // Subtle Top Gradient for status bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Header / Skip Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo styling
                  Hero(
                    tag: 'logo',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                  
                  // Skip button
                  if (_currentIndex != _slides.length - 1)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            ),
          ),
          
          // Bottom Content Overlay (Glassmorphism)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.primaryDark.withOpacity(0.95),
                    AppTheme.primaryDark.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slide Content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _buildTextContent(_slides[_currentIndex]),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Indicators and Next Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedSmoothIndicator(
                            activeIndex: _currentIndex,
                            count: _slides.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white.withOpacity(0.3),
                              spacing: 8,
                              expansionFactor: 4,
                            ),
                          ),
                          GestureDetector(
                            onTap: _nextSlide,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppTheme.primaryBlue,
                                size: 24,
                              ),
                            ),
                          ).animate(target: _currentIndex == _slides.length - 1 ? 1 : 0).scale(
                            end: const Offset(1.1, 1.1),
                            curve: Curves.easeOutBack,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSlide(OnboardingSlide slide) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.only(bottom: 300), // Push image up
      child: Center(
        child: Image.asset(
          slide.imagePath,
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.85,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.image_not_supported, color: AppTheme.primaryBlue, size: 100),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextContent(OnboardingSlide slide) {
    return Column(
      key: ValueKey(slide.title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(
            slide.icon,
            color: Colors.white,
            size: 32,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 24),
        Text(
          slide.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 12),
        Text(
          slide.description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.85),
            height: 1.5,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}
