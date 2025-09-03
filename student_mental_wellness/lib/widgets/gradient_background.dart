import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool isAnimated;
  
  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultColors = isDark 
        ? [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ]
        : [
            const Color(0xFFF8FAFC),
            const Color(0xFFF1F5F9),
            const Color(0xFFE2E8F0),
          ];

    final gradientColors = colors ?? defaultColors;

    Widget background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: begin,
          end: end,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );

    if (isAnimated) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: background,
      );
    }

    return background;
  }
}


