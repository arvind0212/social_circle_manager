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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ShadCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                child: Row(
                  children: [
                    // Avatar section - improved with decorative border
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.border, 
                          width: 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: circle.imageUrl != null
                            ? Image.network(
                                circle.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.accent,
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    
                    // Content section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Circle name with improved typography
                            Text(
                              circle.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.foreground,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Member count with more elegant styling
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: theme.colorScheme.accent.withOpacity(0.3),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${circle.memberCount} members',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary.withOpacity(0.8),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Last activity with icon for context
                            Row(
                              children: [
                                Icon(
                                  _getActivityIcon(circle.lastActivity),
                                  size: 14,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    circle.lastActivity,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Enhanced chevron
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.accent.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
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