import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_model.dart';
import '../../../../core/theme/app_theme.dart';

class CircleCard extends StatelessWidget {
  final Circle circle;
  final VoidCallback onTap;

  const CircleCard({
    Key? key,
    required this.circle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    // Get initials if there's no image URL
    final initials = circle.name.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('')
        .substring(0, circle.name.split(' ').length > 1 ? 2 : 1);

    return AnimatedContainer(
      margin: EdgeInsets.zero,
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: theme.colorScheme.accent.withOpacity(0.05),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ShadCard(
            backgroundColor: Colors.white,
            padding: EdgeInsets.zero,
            // Removed border for a cleaner look and subtle lift
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
            shadows: [
              BoxShadow(
                color: theme.colorScheme.foreground.withOpacity(0.1),
                blurRadius: 24,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: image/avatar (40%)
                Expanded(
                  flex: 5,
                  child: circle.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            circle.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: CircleAvatar(
                            backgroundColor: ThemeProvider.primaryBlue.withOpacity(0.15),
                            radius: 32,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                ),
                // Bottom section: metadata (60%)
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.group, size: 14, color: ThemeProvider.primaryBlue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${circle.memberCount} members',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          circle.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutQuint),
    );
  }
  
  // Helper method to select appropriate icon based on activity text
  IconData _getActivityIcon(String activity) {
    if (activity.toLowerCase().contains('movie')) {
      return Icons.movie_outlined;
    } else if (activity.toLowerCase().contains('book')) {
      return Icons.book_outlined;
    } else if (activity.toLowerCase().contains('hike') || activity.toLowerCase().contains('trail')) {
      return Icons.terrain_outlined;
    } else if (activity.toLowerCase().contains('venue') || activity.toLowerCase().contains('happy hour')) {
      return Icons.local_bar_outlined;
    } else if (activity.toLowerCase().contains('birthday')) {
      return Icons.cake_outlined;
    } else if (activity.toLowerCase().contains('plan')) {
      return Icons.event_note_outlined;
    } else {
      return Icons.access_time;
    }
  }
} 