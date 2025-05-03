import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  
  const AuthHeader({
    Key? key,
    required this.title,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App logo with continuous breathing animation like in onboarding
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                ThemeProvider.primaryBlue,
                ThemeProvider.secondaryPurple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeProvider.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.people_alt_outlined,
              size: 36,
              color: Colors.white,
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.08, 1.08),
            end: const Offset(1, 1),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),
        
        const SizedBox(height: 16),
        
        // Title with simple fade in animation
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          ),
      ],
    );
  }
} 