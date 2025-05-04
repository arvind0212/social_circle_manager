import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class EmptyCirclesState extends StatelessWidget {
  final VoidCallback onCreateCircle;

  const EmptyCirclesState({
    Key? key,
    required this.onCreateCircle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative background elements
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer circles for decoration
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.accent.withOpacity(0.04),
                          theme.colorScheme.accent.withOpacity(0.01),
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: 3.seconds,
                      curve: Curves.easeInOut,
                    ),
                  
                  // Middle circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.08),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 2.5.seconds,
                      curve: Curves.easeInOut,
                    ),
                  
                  // Inner circle with icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.accent.withOpacity(0.9),
                          theme.colorScheme.primary.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      size: 54,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Title with gradient text
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      ThemeProvider.secondaryPurple,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'No Circles Yet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 300.ms),
              
              const SizedBox(height: 20),
              
              // Description with more engaging copy
              Text(
                'Create your first social circle to start organizing events with friends, family, or colleagues.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: 600.ms, delay: 500.ms),
              
              const SizedBox(height: 40),
              
              // Benefits list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.border.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildBenefitItem(
                      context,
                      'Plan events together',
                      Icons.calendar_today_rounded,
                      1,
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      'Keep everyone in the loop',
                      Icons.chat_bubble_outline_rounded,
                      2,
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      'Remember special occasions',
                      Icons.cake_rounded,
                      3,
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 700.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms),
              
              const SizedBox(height: 40),
              
              // Enhanced create button
              SizedBox(
                width: screenWidth * 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ShadButton(
                    onPressed: onCreateCircle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.4)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Create Your First Circle',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 900.ms)
                .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build benefit items
  Widget _buildBenefitItem(BuildContext context, String text, IconData icon, int index) {
    final theme = ShadTheme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.accent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(delay: (200 * index).ms + 700.ms, duration: 400.ms)
      .slideX(begin: 0.2, end: 0);
  }
} 