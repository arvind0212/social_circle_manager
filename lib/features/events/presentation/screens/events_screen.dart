import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event.dart';
import '../widgets/event_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Rebuild UI when the tab index changes (including swipe actions)
    setState(() {});
    // Provide haptic feedback on tap/animateTo changes
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _loadEvents() async {
    // Simulate loading for now - replace with actual data fetch
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data for testing the UI - using more realistic and diverse data
    setState(() {
      _upcomingEvents = [
        Event(
          id: '1',
          title: 'Coffee Chat & Catch-up',
          description: 'Casual morning coffee with the team to discuss upcoming projects and industry trends',
          location: 'Starbucks Downtown, 123 Main St',
          startTime: DateTime.now().add(const Duration(days: 0, hours: 3)),
          endTime: DateTime.now().add(const Duration(days: 0, hours: 5)),
          circleName: 'Work Friends',
          circleId: 'c1',
          circleColor: ThemeProvider.primaryBlue,
          attendees: 4,
          isRsvpd: true,
        ),
        Event(
          id: '2',
          title: 'Movie Night: Dune Part Two',
          description: 'Watching the new sci-fi blockbuster followed by dinner and discussion',
          location: 'AMC Theaters, West Plaza Mall',
          startTime: DateTime.now().add(const Duration(days: 2, hours: 19)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 22)),
          circleName: 'Movie Club',
          circleId: 'c2',
          circleColor: ThemeProvider.secondaryPurple,
          attendees: 6,
          isRsvpd: null,
        ),
        Event(
          id: '3',
          title: 'Sunrise Hike & Breakfast',
          description: 'Moderate trail with beautiful views followed by breakfast at the Eagle Mountain Lodge',
          location: 'Eagle Mountain Trail, North Entrance',
          startTime: DateTime.now().add(const Duration(days: 5, hours: 6)),
          endTime: DateTime.now().add(const Duration(days: 5, hours: 11)),
          circleName: 'Adventure Group',
          circleId: 'c3',
          circleColor: Colors.green.shade700,
          attendees: 5,
        ),
        Event(
          id: '4',
          title: 'Potluck Dinner Party',
          description: 'Bring your favorite dish! Theme is international cuisine. BYOB encouraged.',
          location: 'Sarah\'s Place, 456 Oak Avenue, Apt 7B',
          startTime: DateTime.now().add(const Duration(days: 7, hours: 18)),
          endTime: DateTime.now().add(const Duration(days: 7, hours: 22)),
          circleName: 'Close Friends',
          circleId: 'c4',
          circleColor: ThemeProvider.accentPeach,
          attendees: 8,
          isRsvpd: false,
        ),
        Event(
          id: '9',
          title: 'Art Gallery Opening',
          description: 'Contemporary art exhibition featuring local artists. Wine and refreshments provided.',
          location: 'Downtown Gallery, 789 Arts District',
          startTime: DateTime.now().add(const Duration(days: 10, hours: 19)),
          endTime: DateTime.now().add(const Duration(days: 10, hours: 21)),
          circleName: 'Culture Club',
          circleId: 'c9',
          circleColor: Colors.purple.shade700,
          attendees: 7,
        ),
        Event(
          id: '10',
          title: 'Weekend Beach Trip',
          description: 'Three-day getaway to the coast. Activities include swimming, hiking, and campfire.',
          location: 'Sunset Beach, Cabin 12',
          startTime: DateTime.now().add(const Duration(days: 14, hours: 10)),
          endTime: DateTime.now().add(const Duration(days: 16, hours: 17)),
          circleName: 'Adventure Group',
          circleId: 'c3',
          circleColor: Colors.green.shade700,
          attendees: 9,
        ),
      ];
      
      _pastEvents = [
        Event(
          id: '5',
          title: 'Book Club: "The Midnight Library"',
          description: 'Discussion of Matt Haig\'s novel exploring the choices that make a life worth living',
          location: 'City Central Library, Meeting Room 3',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 18)),
          endTime: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
          circleName: 'Book Lovers',
          circleId: 'c5',
          circleColor: Colors.teal.shade700,
          attendees: 7,
          isRsvpd: true,
        ),
        Event(
          id: '6',
          title: 'Board Game & Pizza Night',
          description: 'Casual evening of strategy games, card games, and plenty of snacks',
          location: 'Mike\'s Apartment, 789 Pine Street',
          startTime: DateTime.now().subtract(const Duration(days: 7, hours: 19)),
          endTime: DateTime.now().subtract(const Duration(days: 7, hours: 23)),
          circleName: 'Gaming Group',
          circleId: 'c6',
          circleColor: Colors.red.shade700,
          attendees: 5,
          isRsvpd: true,
        ),
        Event(
          id: '7',
          title: 'Emma\'s Surprise Birthday Party',
          description: 'Celebrating Emma\'s 30th! Food, drinks, and dancing. Remember to arrive 30 mins early!',
          location: 'Lakeside Restaurant, Private Room',
          startTime: DateTime.now().subtract(const Duration(days: 14, hours: 19)),
          endTime: DateTime.now().subtract(const Duration(days: 14, hours: 23)),
          circleName: 'Close Friends',
          circleId: 'c4',
          circleColor: ThemeProvider.accentPeach,
          attendees: 12,
          isRsvpd: true,
        ),
        Event(
          id: '8',
          title: 'Tech Meetup: AI & Machine Learning',
          description: 'Monthly tech talk featuring expert speakers and networking session',
          location: 'Innovation Hub, Conference Center',
          startTime: DateTime.now().subtract(const Duration(days: 21, hours: 18)),
          endTime: DateTime.now().subtract(const Duration(days: 21, hours: 21)),
          circleName: 'Tech Network',
          circleId: 'c8',
          circleColor: Colors.blue.shade800,
          attendees: 15,
          isRsvpd: true,
        ),
      ];
      
      _isLoading = false;
    });
  }

  void _handleCreateEvent() {
    HapticFeedback.mediumImpact();
    // TODO: Implement event creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create event functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final hPadding = width < 600 ? 12.0 : 20.0;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.background,
                  Color.lerp(theme.colorScheme.background, ThemeProvider.accentPeach, 0.03) ?? theme.colorScheme.background,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 0),
                    child: _buildAppBar(theme),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 0),
                    child: _buildTabBar(theme),
                  ),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(theme)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildEventsList(_upcomingEvents, theme, isUpcoming: true),
                              _buildEventsList(_pastEvents, theme, isUpcoming: false),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildCreateEventButton(),
    );
  }

  Widget _buildAppBar(ShadThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeProvider.accentPeach.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.event_rounded,
                color: ThemeProvider.accentPeach,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Events',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
        Row(
          children: [
            _buildIconButton(
              icon: Icons.search_rounded,
              onPressed: () => HapticFeedback.lightImpact(),
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.filter_list_rounded,
              onPressed: () => HapticFeedback.lightImpact(),
              theme: theme,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ShadThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        color: theme.colorScheme.foreground,
      ),
    );
  }

  Widget _buildTabBar(ShadThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _tabController.index == 0 ? ThemeProvider.accentPeach.withOpacity(0.15) : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: _tabController.index == 0 ? ThemeProvider.accentPeach : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _tabController.index == 0 ? FontWeight.w600 : FontWeight.w500,
                        color: _tabController.index == 0 ? ThemeProvider.accentPeach : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _tabController.index == 1 ? ThemeProvider.accentPeach.withOpacity(0.15) : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: _tabController.index == 1 ? ThemeProvider.accentPeach : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Past',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _tabController.index == 1 ? FontWeight.w600 : FontWeight.w500,
                        color: _tabController.index == 1 ? ThemeProvider.accentPeach : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildLoadingState(ShadThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;
        final childAspectRatio = crossAxisCount == 1 ? 1.0 : 0.75;
        final padding = width < 400 ? 12.0 : 20.0;
        final spacing = width < 400 ? 12.0 : 16.0;
        return GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1.5.seconds, color: theme.colorScheme.muted.withOpacity(0.1));
          },
        );
      },
    );
  }

  Widget _buildEventsList(List<Event> events, ShadThemeData theme, {required bool isUpcoming}) {
    if (events.isEmpty) {
      return _buildEmptyState(isUpcoming, theme);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;
        final childAspectRatio = crossAxisCount > 1 ? 0.75 : 1.5;
        final padding = width < 400 ? 12.0 : 20.0;
        final spacing = width < 400 ? 12.0 : 16.0;
        final bottomPadding = spacing * 5;
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(padding, padding, padding, bottomPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              isUpcoming: isUpcoming,
            ).animate(delay: (80 * index).ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isUpcoming, ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeProvider.accentPeach.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              isUpcoming ? Icons.event_available_rounded : Icons.history_rounded,
              color: ThemeProvider.accentPeach,
              size: 48,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            isUpcoming ? 'No Upcoming Events' : 'No Past Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.foreground,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final w = MediaQuery.of(context).size.width;
              final boxWidth = w < 360 ? w * 0.8 : 280.0;
              return SizedBox(
                width: boxWidth,
                child: Text(
                  isUpcoming
                      ? 'Create a new event to start planning with your circles'
                      : 'Events you\'ve attended will appear here',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.mutedForeground,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 32),
          if (isUpcoming)
            _buildCreateButton().animate().fadeIn(duration: 400.ms, delay: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildCreateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeProvider.accentPeach,
            Color.lerp(ThemeProvider.accentPeach, Colors.red, 0.3) ?? ThemeProvider.accentPeach,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.accentPeach.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShadButton(
        onPressed: _handleCreateEvent,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        leading: const Icon(Icons.add_rounded, size: 20),
        child: const Text(
          'Create Event',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreateEventButton() {
    return FloatingActionButton(
      heroTag: null,
      elevation: 2,
      backgroundColor: ThemeProvider.accentPeach,
      onPressed: _handleCreateEvent,
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
      ),
    )
    .animate(delay: 400.ms)
    .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut);
  }
} 