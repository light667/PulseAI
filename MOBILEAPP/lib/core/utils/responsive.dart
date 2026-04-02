import 'package:flutter/material.dart';

/// Helper pour gérer la responsivité
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Retourne une valeur selon la taille d'écran
  static T valueWhen<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Padding de base responsive
  static double padding(BuildContext context) {
    return valueWhen(
      context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
  }

  /// Spacing avec multiplicateur
  static double spacing(BuildContext context, double multiplier) {
    final base = valueWhen(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    return base * multiplier;
  }

  /// Padding responsive
  static EdgeInsets paddingAll(BuildContext context) {
    return EdgeInsets.all(valueWhen(
      context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    ));
  }

  static EdgeInsets paddingHorizontal(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: valueWhen(
        context,
        mobile: 16,
        tablet: 32,
        desktop: 48,
      ),
    );
  }

  /// Grid responsive
  static int gridCrossAxisCount(BuildContext context) {
    return valueWhen(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }

  static double gridChildAspectRatio(BuildContext context) {
    return valueWhen(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.3,
    );
  }

  /// Max width pour contenu centré
  static double maxContentWidth(BuildContext context) {
    return valueWhen(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  /// Font sizes responsive
  static double fontSize(BuildContext context, double baseFontSize) {
    return baseFontSize * valueWhen(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }
}

/// Widget pour layout responsive
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= Responsive.mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Grid responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.gridCrossAxisCount(context),
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: Responsive.gridChildAspectRatio(context),
      children: children,
    );
  }
}

/// Container avec max width centré
class CenteredContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CenteredContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        padding: padding ?? Responsive.paddingAll(context),
        child: child,
      ),
    );
  }
}
