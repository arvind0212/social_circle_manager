import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_model.dart';
import '../../domain/models/circle_creation_model.dart';
import '../../../../core/theme/app_theme.dart';

class CircleDetailScreen extends StatefulWidget {
  final Circle circle;

  const CircleDetailScreen({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  State<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends State<CircleDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Circle _circle;

  @override
  void initState() {
    super.initState();
    _circle = widget.circle;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Delay the animation slightly to prevent build issues
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360; // Check for very small screens
    
    // Get initials if there's no image URL
    final initials = _circle.name.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('')
        .substring(0, _circle.name.split(' ').length > 1 ? 2 : 1);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: isSmallScreen ? 4 : 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.foreground,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.chat_outlined,
                color: theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Open circle chat
              },
            ),
          ),
          if (!isSmallScreen) Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Share circle
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Show more options
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Decorative background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.accent.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -screenHeight * 0.15,
            right: -screenHeight * 0.15,
            child: Container(
              width: screenHeight * 0.4,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.03),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with circle info
                  _buildHeader(theme, initials),
                  
                  // Dashboard overview
                  _buildDashboardOverview(theme),
                  
                  // Upcoming events section
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _circle.upcomingEvents.isNotEmpty 
                          ? ShadButton.ghost(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            onPressed: () {
                              // Navigate to events list
                              HapticFeedback.lightImpact();
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          )
                         : const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildUpcomingEvents(theme),
                  
                  // Members section
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _circle.members.isNotEmpty 
                          ? ShadButton.ghost(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            onPressed: () {
                              // Navigate to members list
                              HapticFeedback.lightImpact();
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          )
                         : const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMembersGrid(theme),
                  
                  // Activity timeline section
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Activity Timeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildActivityTimeline(theme),
                  
                  const SizedBox(height: 80), // Space at the bottom for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.3)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: FloatingActionButton(
          heroTag: null,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Create new event
          },
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ).animate().scale(
        begin: const Offset(0, 0),
        end: const Offset(1, 1),
        duration: 600.ms,
        curve: Curves.elasticOut,
      ),
    );
  }
  
  Widget _buildHeader(ShadThemeData theme, String initials) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with animation
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.border,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Background pulse animation
                      Positioned.fill(
                        child: Container(
                          color: theme.colorScheme.accent.withOpacity(0.2),
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).fade(
                          begin: 0.5,
                          end: 1.0,
                          duration: const Duration(seconds: 2),
                        ),
                      ),
                      // Avatar image or initials
                      Positioned.fill(
                        child: _circle.imageUrl != null
                            ? Image.network(
                                _circle.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 28,
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _circle.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.foreground,
                        letterSpacing: -0.5,
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.2, end: 0, duration: 400.ms),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ShadBadge(
                          backgroundColor: theme.colorScheme.accent.withOpacity(0.3),
                          foregroundColor: theme.colorScheme.primary.withOpacity(0.8),
                          child: Text('${_circle.memberCount} members'),
                        ).animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCreatedDate(_circle.createdDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ).animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            _circle.description,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.mutedForeground,
              height: 1.5,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildDashboardOverview(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ShadCard(
        backgroundColor: theme.colorScheme.card.withOpacity(0.8),
        border: Border.all(
          color: theme.colorScheme.border.withOpacity(0.3),
          width: 1,
        ),
        shadows: [
          BoxShadow(
            color: theme.colorScheme.foreground.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 6),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: const Text(
                  'Circle Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
              
              const SizedBox(height: 24),
              
              // Stats grid
              Row(
                children: [
                  _buildStat(
                    theme, 
                    'Total Events', 
                    '${_circle.upcomingEvents.length + _circle.pastEvents.length}',
                    Icons.event_note_rounded,
                    600
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    theme, 
                    'Upcoming', 
                    '${_circle.upcomingEvents.length}',
                    Icons.event_available_rounded,
                    700
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildStat(
                    theme, 
                    'Frequency', 
                    _circle.meetingFrequency,
                    Icons.calendar_today_rounded,
                    800
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    theme, 
                    'Top Activity', 
                    _getTopActivity(),
                    _getActivityIcon(_getTopActivity()),
                    900
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Progress section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Circle Activity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const ShadProgress(value: 0.7),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Very active - 70% more active than average',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ).animate()
                .fadeIn(duration: 400.ms, delay: 1000.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),
              
              const SizedBox(height: 20),
              
              // Interest tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _circle.interests.map((interest) {
                      return ShadBadge(
                        backgroundColor: _getInterestColor(interest, theme).withOpacity(0.15),
                        foregroundColor: _getInterestColor(interest, theme),
                        child: Text(interest),
                      );
                    }).toList(),
                  ),
                ],
              ).animate()
                .fadeIn(duration: 400.ms, delay: 1100.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms),
    );
  }
  
  Widget _buildStat(ShadThemeData theme, String label, String value, IconData icon, int delayMs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 14,
                  color: theme.colorScheme.destructive,
                ),
                const SizedBox(width: 4),
                Text(
                  '8%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.destructive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: delayMs.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms),
    );
  }
  
  String _formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return 'Created ${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Created $months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Created $years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  String _getTopActivity() {
    if (_circle.commonActivities.isNotEmpty) {
      return _circle.commonActivities.first;
    }
    return 'No activities yet';
  }
  
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
    } else if (activity.toLowerCase().contains('game')) {
      return Icons.sports_esports_outlined;
    } else if (activity.toLowerCase().contains('trip')) {
      return Icons.card_travel_outlined;
    } else {
      return Icons.group_outlined;
    }
  }
  
  Color _getInterestColor(String interest, ShadThemeData theme) {
    // Create specific matching for known interest words
    final String lowerInterest = interest.toLowerCase();
    
    // Reading/Book related interests should have primary color
    if (lowerInterest == 'reading' || 
        lowerInterest == 'literature' || 
        lowerInterest == 'writing' || 
        lowerInterest == 'books') {
      return theme.colorScheme.primary;
    }
    
    // Nature/Outdoor related interests
    if (lowerInterest == 'hiking' || 
        lowerInterest == 'nature' || 
        lowerInterest == 'outdoor' || 
        lowerInterest == 'camping' || 
        lowerInterest == 'photography') {
      return Colors.green.shade600;
    }
    
    // For interests that don't match exact keywords, fall back to categories
    // Create categories of related interests
    final natureOutdoor = [
      'trail', 'mountain', 'adventure', 'wildlife'
    ];
    
    final foodDining = [
      'food', 'dining', 'restaurant', 'cooking', 'baking', 'cuisine'
    ];
    
    final entertainment = [
      'movie', 'theater', 'art', 'show', 'concert', 'music'
    ];
    
    final games = [
      'game', 'board', 'social', 'card', 'video game', 'puzzle'
    ];
    
    final travel = [
      'travel', 'trip', 'vacation', 'tourism', 'journey', 'explore'
    ];
    
    // Check which category the interest belongs to
    if (natureOutdoor.any((term) => lowerInterest.contains(term))) {
      return Colors.green.shade600; // Green for nature/outdoor activities
    } else if (foodDining.any((term) => lowerInterest.contains(term))) {
      return Colors.orange; // Orange for food-related interests
    } else if (entertainment.any((term) => lowerInterest.contains(term))) {
      return theme.colorScheme.primary; // Primary color for entertainment
    } else if (games.any((term) => lowerInterest.contains(term))) {
      return ThemeProvider.secondaryPurple; // Purple for games
    } else if (travel.any((term) => lowerInterest.contains(term))) {
      return Colors.blue; // Blue for travel
    } else {
      return theme.colorScheme.accent; // Default accent color
    }
  }

  // Method to build upcoming events section
  Widget _buildUpcomingEvents(ShadThemeData theme) {
    if (_circle.upcomingEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.accent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.event_busy_outlined,
                  size: 28,
                  color: theme.colorScheme.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No upcoming events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule your first event to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ShadButton(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.3)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Create new event
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Create Event',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: 1200.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a more responsive approach based on available width
        final cardWidth = constraints.maxWidth > 600 ? 320.0 : 280.0;
        
        return SizedBox(
          height: 270,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _circle.upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = _circle.upcomingEvents[index];
              return _buildEventCard(event, theme, index, cardWidth);
            },
          ),
        );
      }
    );
  }
  
  // Helper method to build event card
  Widget _buildEventCard(Event event, ShadThemeData theme, int index, [double width = 280]) {
    final formattedDate = _formatEventDate(event.dateTime);
    final isToday = _isToday(event.dateTime);
    
    return Container(
      width: width,
      margin: EdgeInsets.only(
        left: index == 0 ? 8 : 0,
        right: 16,
        top: 8,
        bottom: 48,
      ),
      child: ShadCard(
        backgroundColor: theme.colorScheme.card.withOpacity(0.9),
        padding: EdgeInsets.zero,
        border: Border.all(
          color: theme.colorScheme.border.withOpacity(0.3),
          width: 1,
        ),
        shadows: [
          BoxShadow(
            color: theme.colorScheme.foreground.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to event details
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isToday
                        ? [
                            theme.colorScheme.primary.withOpacity(0.9),
                            Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.5)!.withOpacity(0.9),
                          ]
                        : [
                            theme.colorScheme.accent.withOpacity(0.1),
                            theme.colorScheme.accent.withOpacity(0.06),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.white.withOpacity(0.2)
                            : theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isToday
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? Colors.white
                              : theme.colorScheme.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      ShadBadge(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        child: const Text('Today'),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Event details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.mutedForeground,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outlined,
                          size: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.attendees} attendees',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: (1200 + index * 100).ms)
        .slideX(begin: 0.1, end: 0, duration: 600.ms),
    );
  }
  
  // Helper method to format event date
  String _formatEventDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (eventDate.isAtSameMomentAs(today)) {
      return 'Today, ${_formatTimeOnly(dateTime)}';
    } else if (eventDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow, ${_formatTimeOnly(dateTime)}';
    } else {
      return '${_formatDateOnly(dateTime)}, ${_formatTimeOnly(dateTime)}';
    }
  }
  
  // Helper to format time only
  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    final hourDisplay = hour > 12 ? hour - 12 : hour;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    
    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $amPm';
  }
  
  // Helper to format date only
  String _formatDateOnly(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    
    return '$month $day';
  }
  
  // Helper to check if a date is today
  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && 
           dateTime.month == now.month && 
           dateTime.day == now.day;
  }

  // Method to build members grid
  Widget _buildMembersGrid(ShadThemeData theme) {
    if (_circle.members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.accent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 28,
                  color: theme.colorScheme.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No members yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invite friends to join this circle',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ShadButton.outline(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Add members
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Members',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: 1300.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
    }
    
    // Show the first 8 members in the grid (or less if fewer members)
    final displayedMembers = _circle.members.take(8).toList();
    final hasMore = _circle.members.length > 8;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of members per row based on available width
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
        final isLargeScreen = screenWidth >= 600;
        
        // Determine number of members per row
        final itemsPerRow = isSmallScreen ? 3 : (isMediumScreen ? 4 : 5);
        
        // Calculate the item width based on available space and items per row
        final avatarSize = isSmallScreen ? 60.0 : (isMediumScreen ? 72.0 : 80.0);
        final spacing = isSmallScreen ? 12.0 : 16.0;
        
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              ...displayedMembers.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return _buildMemberAvatar(member, theme, index, avatarSize);
              }),
              
              // "More" avatar if we have more than 8 members
              if (hasMore)
                _buildMoreAvatar(theme, _circle.members.length - 8, avatarSize),
              
              // "Add" button
              _buildAddMemberButton(theme, avatarSize),
            ],
          ),
        );
      }
    );
  }
  
  // Helper method to build member avatar
  Widget _buildMemberAvatar(CircleMember member, ShadThemeData theme, int index, double size) {
    // Get member initials
    final name = member.name ?? member.identifier.split('@').first;
    final initials = name.split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('')
        .substring(0, name.split(' ').length > 1 ? 2 : 1);
    
    final hasPhoto = member.photoUrl != null && member.photoUrl!.isNotEmpty;
    
    return SizedBox(
      width: size,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // Show member profile or actions
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.foreground.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hasPhoto 
                ? ShadAvatar(member.photoUrl!)
                : Container(
                    width: size - 16,
                    height: size - 16,
                    decoration: BoxDecoration(
                      color: _getAvatarBackgroundColor(name, theme),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: (size - 16) * 0.35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          SizedBox(height: size * 0.1),
          Text(
            name.length > 10 ? '${name.substring(0, 8)}...' : name,
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (member.id == _circle.adminId)
            Container(
              padding: EdgeInsets.symmetric(horizontal: size * 0.08, vertical: size * 0.03),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: size * 0.14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: (1300 + index * 50).ms)
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOutQuint,
      );
  }
  
  // Generate a consistent color based on the name
  Color _getAvatarBackgroundColor(String name, ShadThemeData theme) {
    // Use a simple hash of the name to generate a consistent color
    final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    
    // Create a list of pleasant avatar background colors
    final List<Color> avatarColors = [
      Colors.blue.shade700,
      Colors.indigo.shade700,
      Colors.purple.shade700,
      Colors.deepPurple.shade700,
      Colors.teal.shade700,
      Colors.green.shade700,
      Colors.amber.shade800,
      Colors.deepOrange.shade700,
      theme.colorScheme.primary,
      ThemeProvider.secondaryPurple,
    ];
    
    // Use the hash to pick a color from the list
    return avatarColors[hash % avatarColors.length];
  }
  
  // Helper method to build "more" avatar
  Widget _buildMoreAvatar(ShadThemeData theme, int moreCount, double size) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.foreground.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: _getAvatarBackgroundColor("More Members", theme).withOpacity(0.9),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Show all members
                },
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size - 16,
                  height: size - 16,
                  child: Center(
                    child: Text(
                      '+$moreCount',
                      style: TextStyle(
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size * 0.1),
          Text(
            'More',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size * 0.03),
          SizedBox(height: size * 0.19),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 1700.ms)
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOutQuint,
      );
  }
  
  // Helper method to build "add member" button
  Widget _buildAddMemberButton(ShadThemeData theme, double size) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.foreground.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // Add new member
                },
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size - 16,
                  height: size - 16,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: size * 0.42,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size * 0.1),
          Text(
            'Add',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size * 0.22),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 1800.ms)
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOutQuint,
      );
  }

  // Method to build activity timeline
  Widget _buildActivityTimeline(ShadThemeData theme) {
    // Combine past events with most recent first
    final timelineEvents = [..._circle.pastEvents]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    if (timelineEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.accent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.history_outlined,
                  size: 28,
                  color: theme.colorScheme.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No activity yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Past events will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms, delay: 1900.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        children: timelineEvents.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == timelineEvents.length - 1;
          
          return _buildTimelineItem(event, theme, index, isLast);
        }).toList(),
      ),
    );
  }
  
  // Helper method to build timeline item
  Widget _buildTimelineItem(Event event, ShadThemeData theme, int index, bool isLast) {
    final formattedDate = _formatTimelineDate(event.dateTime);
    final timeAgo = _getTimeAgo(event.dateTime);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.accent.withOpacity(0.5),
                  border: Border.all(
                    color: index == 0
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.accent.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 85, // Adjust based on content height
                  color: theme.colorScheme.accent.withOpacity(0.2),
                  margin: const EdgeInsets.only(left: 5),
                ),
            ],
          ),
        ),
        
        // Event content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.border.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.foreground.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getEventTypeColor(event.title, theme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getEventTypeIcon(event.title),
                              size: 16,
                              color: _getEventTypeColor(event.title, theme),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.mutedForeground,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.attendees} attended',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 400.ms, delay: (1900 + index * 200).ms)
      .slideX(begin: -0.1, end: 0, duration: 500.ms);
  }
  
  // Helper method to format timeline date
  String _formatTimelineDate(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    
    return '$month $day, $year';
  }
  
  // Helper method to get time ago text
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Helper method to get event type icon
  IconData _getEventTypeIcon(String eventTitle) {
    if (eventTitle.toLowerCase().contains('movie')) {
      return Icons.movie_outlined;
    } else if (eventTitle.toLowerCase().contains('book')) {
      return Icons.book_outlined;
    } else if (eventTitle.toLowerCase().contains('hike') || 
              eventTitle.toLowerCase().contains('trail') ||
              eventTitle.toLowerCase().contains('park')) {
      return Icons.terrain_outlined;
    } else if (eventTitle.toLowerCase().contains('dinner') || 
              eventTitle.toLowerCase().contains('lunch') ||
              eventTitle.toLowerCase().contains('breakfast') ||
              eventTitle.toLowerCase().contains('restaurant')) {
      return Icons.restaurant_outlined;
    } else if (eventTitle.toLowerCase().contains('happy hour') || 
              eventTitle.toLowerCase().contains('bar') ||
              eventTitle.toLowerCase().contains('pub') ||
              eventTitle.toLowerCase().contains('brewery')) {
      return Icons.local_bar_outlined;
    } else if (eventTitle.toLowerCase().contains('birthday') || 
              eventTitle.toLowerCase().contains('celebration') ||
              eventTitle.toLowerCase().contains('party')) {
      return Icons.cake_outlined;
    } else if (eventTitle.toLowerCase().contains('game')) {
      return Icons.sports_esports_outlined;
    } else if (eventTitle.toLowerCase().contains('bbq')) {
      return Icons.outdoor_grill_outlined;
    } else {
      return Icons.event_note_outlined;
    }
  }
  
  // Helper method to get event type color based on title
  Color _getEventTypeColor(String eventTitle, ShadThemeData theme) {
    if (eventTitle.toLowerCase().contains('movie') || 
        eventTitle.toLowerCase().contains('book') || 
        eventTitle.toLowerCase().contains('discussion')) {
      return theme.colorScheme.primary;
    } else if (eventTitle.toLowerCase().contains('hike') || 
              eventTitle.toLowerCase().contains('park') ||
              eventTitle.toLowerCase().contains('outdoor')) {
      return Colors.green;
    } else if (eventTitle.toLowerCase().contains('dinner') || 
              eventTitle.toLowerCase().contains('lunch') ||
              eventTitle.toLowerCase().contains('restaurant') ||
              eventTitle.toLowerCase().contains('bbq')) {
      return Colors.orange;
    } else if (eventTitle.toLowerCase().contains('bar') || 
              eventTitle.toLowerCase().contains('happy hour') ||
              eventTitle.toLowerCase().contains('brewery') ||
              eventTitle.toLowerCase().contains('pub')) {
      return Colors.deepPurple;
    } else if (eventTitle.toLowerCase().contains('birthday') || 
              eventTitle.toLowerCase().contains('party') ||
              eventTitle.toLowerCase().contains('celebration')) {
      return Colors.pinkAccent;
    } else if (eventTitle.toLowerCase().contains('game')) {
      return ThemeProvider.secondaryPurple;
    } else {
      return theme.colorScheme.accent;
    }
  }
} 