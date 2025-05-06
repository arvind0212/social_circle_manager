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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
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
          margin: EdgeInsets.only(left: isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.foreground,
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            tooltip: 'Back',
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.chat_outlined,
                color: theme.colorScheme.foreground,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Open circle chat
              },
              tooltip: 'Chat',
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
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Share circle
              },
              tooltip: 'Share',
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.foreground,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Show more options
              },
              tooltip: 'More options',
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
              controller: _scrollController,
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
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
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
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Members',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMembersGrid(theme),
                  
                  // Activity timeline section
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Activity Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
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
              theme.colorScheme.secondary,
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
          tooltip: 'Create new event',
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.2, end: 0, duration: 400.ms),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ShadBadge(
                          backgroundColor: theme.colorScheme.accent.withOpacity(0.3),
                          foregroundColor: theme.colorScheme.primary.withOpacity(0.8),
                          child: Text('${_circle.memberCount} members'),
                        ).animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // More compact grid with subtle background color
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // First row
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatCard(
                        theme, 
                        'Total Events', 
                        '${_circle.upcomingEvents.length + _circle.pastEvents.length}',
                        Icons.event_note_rounded,
                        600
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactStatCard(
                        theme, 
                        'Upcoming', 
                        '${_circle.upcomingEvents.length}',
                        Icons.event_available_rounded,
                        700
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Second row
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactFrequencyCard(
                        theme, 
                        'Frequency', 
                        _circle.meetingFrequency,
                        Icons.calendar_month_rounded,
                        800
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactActivityCard(
                        theme,
                        'Very active',
                        '70% more active than average',
                        0.7,
                        900
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms),
    );
  }
  
  Widget _buildCompactStatCard(ShadThemeData theme, String label, String value, IconData icon, int delayMs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in squared light blue background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactFrequencyCard(ShadThemeData theme, String label, String frequencyText, IconData icon, int delayMs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in squared light blue background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "2-3 times\nmonthly", // Display frequency as shown in image
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactActivityCard(ShadThemeData theme, String title, String subtitle, double value, int delayMs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in squared light blue background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            height: 6,
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  ThemeProvider.secondaryPurple,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
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
    
    // Social activities
    if (lowerInterest == 'happy hours' || 
        lowerInterest == 'networking' || 
        lowerInterest == 'social' || 
        lowerInterest == 'parties') {
      return Colors.blue.shade700;
    }
    
    // Food related
    if (lowerInterest == 'dining' || 
        lowerInterest == 'restaurants' || 
        lowerInterest == 'food' || 
        lowerInterest == 'cooking') {
      return Colors.orange.shade700;
    }
    
    // Nature/Outdoor related interests
    if (lowerInterest == 'hiking' || 
        lowerInterest == 'nature' || 
        lowerInterest == 'outdoor' || 
        lowerInterest == 'camping' || 
        lowerInterest == 'photography') {
      return Colors.green.shade700;
    }

    // Arts and culture
    if (lowerInterest == 'art' || 
        lowerInterest == 'music' || 
        lowerInterest == 'theatre' || 
        lowerInterest == 'concerts' || 
        lowerInterest == 'museums') {
      return Colors.purple.shade700;
    }
    
    // Sports and fitness
    if (lowerInterest == 'sports' || 
        lowerInterest == 'fitness' || 
        lowerInterest == 'yoga' || 
        lowerInterest == 'running' || 
        lowerInterest == 'biking') {
      return Colors.red.shade700;
    }
    
    // Reading/Book related interests should have primary color
    if (lowerInterest == 'reading' || 
        lowerInterest == 'literature' || 
        lowerInterest == 'writing' || 
        lowerInterest == 'books') {
      return theme.colorScheme.primary;
    }
    
    // For interests that don't match exact keywords, fall back to categories
    // Create categories of related interests
    final socialNetworking = [
      'meetup', 'social event', 'gathering', 'community', 'club', 'mixer'
    ];
    
    final foodDining = [
      'culinary', 'restaurant', 'chef', 'foodie', 'cuisine', 'tasting'
    ];
    
    final natureOutdoor = [
      'trail', 'mountain', 'adventure', 'wildlife', 'park', 'garden'
    ];
    
    final entertainment = [
      'movie', 'theater', 'art', 'show', 'concert', 'music'
    ];
    
    final games = [
      'game', 'board', 'card', 'video game', 'puzzle', 'chess'
    ];
    
    final travel = [
      'travel', 'trip', 'vacation', 'tourism', 'journey', 'explore'
    ];
    
    // Check which category the interest belongs to
    if (socialNetworking.any((term) => lowerInterest.contains(term))) {
      return Colors.blue.shade700; // Blue for social/networking activities
    } else if (foodDining.any((term) => lowerInterest.contains(term))) {
      return Colors.orange.shade700; // Orange for food-related interests
    } else if (natureOutdoor.any((term) => lowerInterest.contains(term))) {
      return Colors.green.shade700; // Green for nature/outdoor activities
    } else if (entertainment.any((term) => lowerInterest.contains(term))) {
      return Colors.purple.shade700; // Purple for entertainment
    } else if (games.any((term) => lowerInterest.contains(term))) {
      return Colors.pink.shade700; // Pink for games
    } else if (travel.any((term) => lowerInterest.contains(term))) {
      return Colors.teal.shade700; // Teal for travel
    } else {
      return theme.colorScheme.secondary; // Default secondary color
    }
  }

  // Method to build upcoming events
  Widget _buildUpcomingEvents(ShadThemeData theme) {
    if (_circle.upcomingEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ShadCard(
          backgroundColor: theme.colorScheme.card.withOpacity(0.8),
          border: Border.all(
            color: theme.colorScheme.border.withOpacity(0.3),
            width: 1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                      theme.colorScheme.secondary,
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
          .slideY(begin: 0.2, end: 0, duration: 600.ms),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a more responsive approach based on available width
        final cardWidth = constraints.maxWidth > 600 ? 320.0 : 
                         constraints.maxWidth > 360 ? 280.0 : constraints.maxWidth - 48.0;
        
        return SizedBox(
          // Increase height to show more content in each event card
          height: 320,
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to event details
            },
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
                              theme.colorScheme.secondary.withOpacity(0.9),
                            ]
                          : [
                              theme.colorScheme.accent.withOpacity(0.1),
                              theme.colorScheme.accent.withOpacity(0.06),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.foreground,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.mutedForeground,
                              height: 1.4,
                            ),
                            // Showing more lines of description
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            const SizedBox(width: 6),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outlined,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            const SizedBox(width: 6),
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
                ),
              ],
            ),
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
        child: ShadCard(
          backgroundColor: theme.colorScheme.card.withOpacity(0.8),
          border: Border.all(
            color: theme.colorScheme.border.withOpacity(0.3),
            width: 1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
          .slideY(begin: 0.2, end: 0, duration: 600.ms),
      );
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
        
        // Determine item size and columns count
        int columnsCount;
        double itemSize;
        
        if (isSmallScreen) {
          columnsCount = 3;
          itemSize = (screenWidth - 48 - ((columnsCount - 1) * 12)) / columnsCount;
        } else if (isMediumScreen) {
          columnsCount = 4;
          itemSize = (screenWidth - 48 - ((columnsCount - 1) * 16)) / columnsCount;
        } else {
          columnsCount = 5;
          itemSize = (screenWidth - 48 - ((columnsCount - 1) * 16)) / columnsCount;
        }
        
        final spacing = isSmallScreen ? 12.0 : 16.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: ShadCard(
            backgroundColor: theme.colorScheme.card.withOpacity(0.8),
            border: Border.all(
              color: theme.colorScheme.border.withOpacity(0.3),
              width: 1,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Circle Members',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing * 1.5,
                    children: [
                      ...displayedMembers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final member = entry.value;
                        return _buildMemberAvatar(member, theme, index, itemSize);
                      }),
                      
                      // "More" avatar if we have more than 8 members
                      if (hasMore)
                        _buildMoreAvatar(theme, _circle.members.length - 8, itemSize),
                      
                      // "Add" button
                      _buildAddMemberButton(theme, itemSize),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 1200.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms),
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
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(size),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // Show member profile or actions
              },
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(size),
                      child: Image.network(
                        member.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: _getAvatarBackgroundColor(name, theme),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: size * 0.28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: _getAvatarBackgroundColor(name, theme),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
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
          const SizedBox(height: 8),
          Container(
            width: size * 1.2,
            alignment: Alignment.center,
            child: Text(
              name,
              style: TextStyle(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.foreground,
                height: 1.2,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          if (member.id == _circle.adminId)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.08, 
                vertical: size * 0.03
              ),
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
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(size),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // Show all members
              },
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  color: _getAvatarBackgroundColor("More Members", theme).withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.foreground.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
          const SizedBox(height: 8),
          Text(
            'More',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          // Fixed height for consistency with other avatars
          SizedBox(height: 28),
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
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(size),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Add new member
              },
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.foreground.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: size * 0.36,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          // Fixed height for consistency with other avatars
          SizedBox(height: 28),
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
        child: ShadCard(
          backgroundColor: theme.colorScheme.card.withOpacity(0.8),
          border: Border.all(
            color: theme.colorScheme.border.withOpacity(0.3),
            width: 1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
          .slideY(begin: 0.2, end: 0, duration: 600.ms),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ShadCard(
        backgroundColor: theme.colorScheme.card.withOpacity(0.8),
        border: Border.all(
          color: theme.colorScheme.border.withOpacity(0.3),
          width: 1,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...timelineEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == timelineEvents.length - 1;
                
                return _buildTimelineItem(event, theme, index, isLast);
              }).toList(),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 600.ms, delay: 1800.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms),
    );
  }
  
  // Helper method to build timeline item
  Widget _buildTimelineItem(Event event, ShadThemeData theme, int index, bool isLast) {
    final formattedDate = _formatTimelineDate(event.dateTime);
    final timeAgo = _getTimeAgo(event.dateTime);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Timeline dot
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
                const SizedBox(width: 12),
                
                // Event date and time ago
                Expanded(
                  child: Row(
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
                ),
              ],
            ),
          ),
          
          // Timeline line
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 2,
                    height: 24,
                    color: theme.colorScheme.accent.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          
          // Event card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // View event details
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.foreground,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
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
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                size: 14,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${event.attendees} attended',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: (1900 + index * 200).ms)
            .slideX(begin: 0.05, end: 0, duration: 500.ms),
        ],
      ),
    );
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