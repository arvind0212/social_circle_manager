import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math'; // Import dart:math for min()
import 'package:intl/intl.dart'; // Add this for DateFormat
import 'package:timeago/timeago.dart' as timeago; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'dart:convert'; // Import for jsonDecode
import '../../domain/models/circle_model.dart';
import '../../data/circle_service.dart'; // Import the service
import '../../../../core/theme/app_theme.dart';
import '../../../../../features/events/presentation/widgets/event_card.dart' as event_widgets; // Alias event card import
import '../../../../../features/events/domain/models/event.dart' as events; // Alias event model import
import '../../../events/presentation/screens/create_event_match_screen.dart';
import '../../../events/presentation/screens/event_matching_screen.dart';

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
  final ScrollController _scrollController = ScrollController();
  final CircleService _circleService = CircleService();
  final supabase = Supabase.instance.client; // Add Supabase client instance

  // State variables for detailed data
  Circle? _detailedCircle;
  bool _isLoading = true;
  String? _errorMessage;

  // State variables for active session polling
  bool _isLoadingActiveSession = true;
  String? _activeSessionId;
  Map<String, dynamic>? _activeSessionResults; // To store {session_id: ..., recommendations: [...]} 

  @override
  void initState() {
    super.initState();
    // Use the basic circle data immediately for title/initial display
    _detailedCircle = widget.circle; 
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Fetch detailed data
    _fetchCircleDetails();
  }
  
  Future<void> _fetchCircleDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLoadingActiveSession = true; // Reset active session loading too
      _activeSessionId = null;
      _activeSessionResults = null;
    });
    try {
      final detailedData = await _circleService.getCircleById(widget.circle.id);
      if (mounted) {
        setState(() {
          _detailedCircle = detailedData;
          _isLoading = false; // Stop main loading
        });
        
        // Start fetch for active session *after* main details are loaded
        _fetchActiveSession(); 
        
        // Start animation after data is loaded
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _animationController.forward();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          // Keep basic data if detail fetch fails, but show error
          _detailedCircle = widget.circle;
        });
      }
    }
  }
  
  Future<void> _fetchActiveSession() async {
    setState(() {
      _isLoadingActiveSession = true;
      _activeSessionId = null;
      _activeSessionResults = null;
    });

    print("Checking for active voting session for circle ${widget.circle.id}...");

    try {
      // 1. Find the latest session with status 'voting_open' for this circle
      final List<dynamic> openSessions = await supabase
          .from('event_matching_sessions')
          .select('id')
          .eq('circle_id', widget.circle.id)
          .eq('status', 'voting_open')
          .order('created_at', ascending: false)
          .limit(1);

      if (openSessions.isNotEmpty && mounted) {
        final String sessionId = openSessions[0]['id'] as String;
        print("Found active voting session: $sessionId");
        setState(() {
          _activeSessionId = sessionId;
        });

        // 2. Fetch recommendations for this session using the RPC
        print("Fetching recommendations for session: $sessionId using RPC...");
        final dynamic rpcResult = await supabase.rpc(
          'get_recommendations_for_session',
          params: {'session_uuid': sessionId},
        );
        print("RPC Result raw: $rpcResult, type: ${rpcResult.runtimeType}");
        
        // The RPC returns JSONB, which the Dart client might parse differently.
        // Often it comes back as a List<dynamic> if it's a JSON array.
        if (rpcResult != null && rpcResult is List && mounted) {
           print("Successfully fetched ${rpcResult.length} recommendations via RPC.");
          // Construct the matchingResults map expected by EventMatchingScreen
          setState(() {
             _activeSessionResults = {
              'session_id': sessionId, 
              'recommendations': rpcResult 
            };
            _isLoadingActiveSession = false;
          });
        } else if (rpcResult != null && mounted) {
          // Handle cases where it might not be a list but still has data
          print("Warning: RPC result was not a List but was: ${rpcResult.runtimeType}");
          // Attempt to handle if it's a string representing JSON array
           if (rpcResult is String) {
              try {
                final decodedList = jsonDecode(rpcResult) as List?;
                if (decodedList != null) {
                   setState(() {
                     _activeSessionResults = {
                      'session_id': sessionId, 
                      'recommendations': decodedList 
                    };
                    _isLoadingActiveSession = false;
                  });
                } else {
                  throw FormatException("Decoded JSON string was not a list.");
                }
              } catch (e) {
                 print("Error decoding RPC result string: $e");
                 setState(() { _isLoadingActiveSession = false; }); // Stop loading on error
              }
           } else {
              setState(() { _isLoadingActiveSession = false; }); // Stop loading if format unexpected
           }
        } else if (mounted) {
          print("No recommendations found for session $sessionId or RPC returned null.");
          setState(() { _isLoadingActiveSession = false; });
        }
      } else if (mounted) {
        print("No active voting session found for circle ${widget.circle.id}.");
        setState(() { _isLoadingActiveSession = false; });
      }
    } catch (e, stacktrace) {
      print('Error fetching active session or recommendations: $e');
      print('Stacktrace: $stacktrace');
      if (mounted) {
        setState(() {
          _isLoadingActiveSession = false;
          // Optionally show an error message specific to fetching the poll
        });
      }
    }
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
    
    // Use _detailedCircle if available, otherwise fallback to widget.circle for initial build
    final Circle displayCircle = _detailedCircle ?? widget.circle;
    
    // Safer initials calculation
    final String joinedInitials = displayCircle.name.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join('');
    final int namePartCount = displayCircle.name.trim().split(' ').where((s) => s.isNotEmpty).length;
    final int maxLen = namePartCount > 1 ? 2 : 1;
    final int end = min(maxLen, joinedInitials.length);
    final String initials = joinedInitials.isNotEmpty ? joinedInitials.substring(0, end) : '?';
    
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
            child: _isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator
              : _errorMessage != null
                  ? _buildErrorState(theme) // Show error state
                  : _buildContentLoaded(theme, displayCircle, initials), // Show loaded content
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
            showCreateEventMatchDialog(context, circle: displayCircle);
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
  
  Widget _buildErrorState(ShadThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.destructive, size: 48),
            const SizedBox(height: 16),
            Text('Error Loading Circle Details', style: theme.textTheme.h4.copyWith(color: theme.colorScheme.destructive)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'An unknown error occurred.', style: theme.textTheme.muted, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ShadButton.outline(
              child: const Text('Retry'),
              onPressed: _fetchCircleDetails, // Retry button
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentLoaded(ShadThemeData theme, Circle displayCircle, String initials) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, displayCircle, initials),
          _buildDashboardOverview(theme, displayCircle),
          _buildActivePollCard(theme, displayCircle),
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
          _buildUpcomingEvents(theme, displayCircle),
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
          _buildMembersGrid(theme, displayCircle),
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
          _buildActivityTimeline(theme, displayCircle),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(ShadThemeData theme, Circle circle, String initials) {
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
                        child: circle.imageUrl != null
                            ? Image.network(
                                circle.imageUrl!,
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
                      circle.name,
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
                          child: Text('${circle.memberCount ?? 0} members'),
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
                          _formatCreatedDate(circle.createdAt),
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
            circle.description ?? 'No description available.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.mutedForeground,
              height: 1.5,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
          // Circle Preferences Pills
          if (circle.commonActivities != null && circle.commonActivities!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double pillWidth = (constraints.maxWidth - 8) / 2;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final activity in circle.commonActivities!.where((a) => a.trim().isNotEmpty))
                        SizedBox(
                          width: pillWidth,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _getInterestColor(activity, theme).withOpacity(0.13),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getActivityIcon(activity),
                                  size: 16,
                                  color: _getInterestColor(activity, theme),
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    activity,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _getInterestColor(activity, theme).withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardOverview(ShadThemeData theme, Circle circle) {
    // Minimal, consistent 1x3 grid for summary tiles
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildSummaryTile(
                theme,
                icon: Icons.event_note_rounded,
                value: '${(circle.upcomingEvents?.length ?? 0) + (circle.pastEvents?.length ?? 0)}',
                label: 'Total Events',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryTile(
                theme,
                icon: Icons.event_available_rounded,
                value: '${circle.upcomingEvents?.length ?? 0}',
                label: 'Upcoming',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryTile(
                theme,
                icon: Icons.calendar_month_rounded,
                value: _getMonthlyEventCount(circle),
                label: 'Monthly',
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms),
    );
  }

  Widget _buildSummaryTile(
    ShadThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.border.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthlyEventCount(Circle circle) {
    // Example logic: average events per month over the last 3 months
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    // Handle nullable upcomingEvents and pastEvents by providing empty lists if null
    final allEvents = [...(circle.upcomingEvents ?? []), ...(circle.pastEvents ?? [])];
    final eventsInLast3Months = allEvents.where((e) => e.startTime?.isAfter(threeMonthsAgo) ?? false).toList(); // Use startTime
    final months = <int>{};
    for (var e in eventsInLast3Months) {
      months.add(e.startTime?.month ?? 0 + (e.startTime?.year ?? 0) * 12 ?? 0); // Use startTime
    }
    final monthCount = months.length == 0 ? 1 : months.length;
    final avg = (eventsInLast3Months.length / monthCount).round();
    return avg.toString();
  }
  
  String _formatCreatedDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
  
  String _getTopActivity() {
    if ((_detailedCircle?.commonActivities?.isNotEmpty ?? false)) {
      return _detailedCircle!.commonActivities!.first;
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
  Widget _buildUpcomingEvents(ShadThemeData theme, Circle circle) {
    if ((circle.upcomingEvents?.isEmpty ?? true)) {
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
        final cardWidth = constraints.maxWidth > 600 ? 320.0 :
                         constraints.maxWidth > 360 ? 280.0 : constraints.maxWidth - 48.0;
        return SizedBox(
          height: 320,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: circle.upcomingEvents?.length ?? 0,
            itemBuilder: (context, index) {
              final event = circle.upcomingEvents![index];
              // Map event data using the actual event object
              // Provide default DateTime if startTime is null
              final startTimeOrDefault = event.startTime ?? DateTime.now();
              final endTimeOrDefault = event.endTime ?? startTimeOrDefault.add(const Duration(hours: 2));

              final eventCardModel = events.Event(
                id: event.id,
                title: event.title,
                description: event.description ?? 'No description.',
                location: event.location ?? 'Not specified.',
                startTime: startTimeOrDefault, // Pass non-nullable DateTime
                endTime: endTimeOrDefault,      // Pass non-nullable DateTime
                circleName: circle.name,
                circleId: circle.id,
                circleColor: theme.colorScheme.primary, 
                attendees: event.attendees?.length ?? 0, 
                isRsvpd: null, // Or determine based on current user later
              );
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  left: index == 0 ? 8 : 0,
                  right: 16,
                  top: 8,
                  bottom: 48,
                ),
                child: event_widgets.EventCard(
                  event: eventCardModel,
                  isUpcoming: true,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: (1200 + index * 100).ms)
                  .slideX(begin: 0.1, end: 0, duration: 600.ms),
              );
            },
          ),
        );
      },
    );
  }
  
  // Method to build members grid
  Widget _buildMembersGrid(ShadThemeData theme, Circle circle) {
    if ((circle.members?.isEmpty ?? true)) {
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
    final displayedMembers = circle.members?.take(8).toList() ?? [];
    final hasMore = (circle.members?.length ?? 0) > 8;
    
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

        // ***** ADD THIS DEBUG PRINT *****
        print('[CircleDetailScreen _buildMembersGrid] itemSize: $itemSize, columnsCount: $columnsCount, screenWidth: $screenWidth, spacing: $spacing');
        // *******************************
        
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
                        _buildMoreAvatar(theme, (circle.members?.length ?? 0) - 8, itemSize),
                      
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
  Widget _buildMemberAvatar(CircleMember member, ShadThemeData theme, int index, double itemSize) {
    print('[CircleDetailScreen _buildMemberAvatar] Member ID: ${member.id}, Name: ${member.fullName}, Avatar: ${member.avatarUrl}, Email: ${member.email}');

    final name = member.fullName ?? member.email?.split('@').first ?? 'User';
    final hasPhoto = member.avatarUrl != null && member.avatarUrl!.isNotEmpty;
    
    return SizedBox( // Added SizedBox to control width and allow Column for text
      width: itemSize, // Match the width logic of _buildMoreAvatar and _buildAddMemberButton
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for Wrap layout
        children: [
          Tooltip(
            message: name,
            child: CircleAvatar(
              radius: itemSize * 0.4, // Adjusted radius to fit within itemSize with text below (0.8 diameter of itemSize)
              backgroundColor: hasPhoto ? Colors.transparent : theme.colorScheme.muted,
              backgroundImage: hasPhoto ? NetworkImage(member.avatarUrl!) : null,
              child: !hasPhoto
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                          fontWeight: FontWeight.bold,
                          fontSize: itemSize * 0.3), // Adjusted font size
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8), // Space between avatar and name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2, // Allow for longer names to wrap
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: itemSize * 0.18, // Consistent with "More" and "Add" text
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
          ),
          // Consider if a fixed height SizedBox is needed at the bottom for alignment
          // like in _buildMoreAvatar and _buildAddMemberButton (SizedBox(height: 28))
          // For now, let Wrap handle vertical spacing with runSpacing.
        ],
      ),
    );
  }
  
  // Helper method to build "more" avatar
  Widget _buildMoreAvatar(ShadThemeData theme, int moreCount, double itemSize) {
    return SizedBox(
      width: itemSize,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(itemSize),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // Show all members
              },
              child: Container(
                width: itemSize * 0.8,
                height: itemSize * 0.8,
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
                      fontSize: itemSize * 0.28,
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
              fontSize: itemSize * 0.18,
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
  Widget _buildAddMemberButton(ShadThemeData theme, double itemSize) {
    return SizedBox(
      width: itemSize,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(itemSize),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Add new member
              },
              child: Container(
                width: itemSize * 0.8,
                height: itemSize * 0.8,
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
                    size: itemSize * 0.36,
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
              fontSize: itemSize * 0.18,
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
  Widget _buildActivityTimeline(ShadThemeData theme, Circle circle) {
    // Combine past events with most recent first
    final timelineEvents = [...(circle.pastEvents ?? [])]
      ..sort((a, b) => b.startTime?.compareTo(a.startTime) ?? DateTime.now().compareTo(DateTime.now()));
    
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
    final formattedDate = _formatTimelineDate(event.startTime);
    final timeAgo = _getTimeAgo(event.startTime);
    
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
                        event.description ?? 'No description.',
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
                                '${event.attendees?.length ?? 0} attended',
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
                                  event.location ?? 'Not specified.',
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
  String _formatTimelineDate(DateTime? dateTime) {
    if (dateTime == null) return 'Date TBD';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (eventDate == today) {
      return 'Today at ${DateFormat.jm().format(dateTime)}';
    } else if (eventDate == tomorrow) {
      return 'Tomorrow at ${DateFormat.jm().format(dateTime)}';
    } else if (eventDate == yesterday) {
      return 'Yesterday at ${DateFormat.jm().format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d, hh:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy, hh:mm a').format(dateTime);
    }
  }
  
  // Helper method to get time ago text
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    return timeago.format(dateTime);
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

  Widget _buildActivePollCard(ShadThemeData theme, Circle circle) {
    if (_isLoadingActiveSession) {
      // Show a subtle loading indicator for the poll card
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: ShadCard(
           backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
           border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
           padding: const EdgeInsets.all(20),
           child: Row(
             children: [
               SizedBox(
                 width: 16, 
                 height: 16, 
                 child: CircularProgressIndicator(
                   strokeWidth: 2, 
                   valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary), // Use theme color
                 ),
               ),
               const SizedBox(width: 12),
               Text("Checking for active polls...", style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground))
             ],
           )
        ).animate().fadeIn(duration: 300.ms)
      );
    }

    // Only show the card if an active session and its results were found
    if (_activeSessionId == null || _activeSessionResults == null) {
      // Optionally return an empty container or a different placeholder
      return const SizedBox.shrink(); // Don't show the card if no active poll
    }

    // Active poll found, display the card with the button
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), 
      child: ShadCard(
        backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.poll_outlined, color: theme.colorScheme.secondary, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Event Poll Active',
                  style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'New event ideas are up for a vote! Tap here to see recommendations and cast your vote.',
              style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 16),
            ShadButton(
              width: double.infinity,
              onPressed: () async {
                HapticFeedback.lightImpact();

                // Use await to wait for EventMatchingScreen to pop
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => EventMatchingScreen(
                      circle: circle,
                      eventPreferences: const {},
                      matchingResults: _activeSessionResults,
                    ),
                  ),
                );

                // Check if the result is true (indicating successful event creation)
                if (result == true && mounted) {
                  print("Returned from EventMatchingScreen with success, refreshing circle details...");
                  _fetchCircleDetails();
                }
              },
              backgroundColor: theme.colorScheme.secondary, // AI Purple
              foregroundColor: Colors.white,
              icon: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.how_to_vote_outlined, size: 16),
              ),
              child: const Text('View & Vote on Event Ideas'),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 700.ms) // Adjusted delay
        .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  // Add this helper function back
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
} 