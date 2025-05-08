import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // Intl is not directly used in the provided diff, but was in original

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event.dart'; // Updated path
import '../../data/services/event_service.dart'; // Import EventService
import '../widgets/event_card.dart';
import './create_event_match_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase client access if needed directly or for service init

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
  String? _errorMessage;
  late EventService _eventService; // Declare EventService

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    // It's better to initialize EventService in didChangeDependencies or pass it via constructor/provider
    // For this example, initializing here. Ensure Supabase.instance.client is ready.
    // If using Provider, you'd get it from context.
    _eventService = EventService(Supabase.instance.client);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allEvents = await _eventService.getEvents();
      final now = DateTime.now();
      
      if (!mounted) return;
      setState(() {
        _upcomingEvents = allEvents.where((event) => event.startTime.isAfter(now)).toList();
        _pastEvents = allEvents.where((event) => !event.startTime.isAfter(now)).toList();
        
        // Sort events: upcoming soonest first, past most recent first
        _upcomingEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
        _pastEvents.sort((a, b) => b.startTime.compareTo(a.startTime));
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        // You could use ShadToaster here for a less intrusive error message
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to load events'),
            description: Text(_errorMessage ?? 'An unknown error occurred.'),
          ),
        );
      });
    }
  }

  void _handleCreateEvent() {
    HapticFeedback.mediumImpact();
    // TODO: Fetch actual available circles if needed for the dropdown
    // For now, this just calls the dialog. Integration with event_matching_screen.dart will define the flow.
    showCreateEventMatchDialog(context, availableCircles: []);
    // No need to _loadEvents() here until event creation actually happens and returns a status
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    // final size = MediaQuery.of(context).size; // size is not used in the diff
    
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
                  const SizedBox(height: 12), // Use const
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 0),
                    child: _buildTabBar(theme),
                  ),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(theme)
                        : _errorMessage != null
                            ? _buildErrorState(theme)
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
                Icons.event_rounded, // Consider using HugeIcons here if available and desired
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
              icon: Icons.search_rounded, // Consider HugeIcons
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Implement search functionality
                 ShadToaster.of(context).show(
                  ShadToast(description: const Text('Search not implemented yet.')),
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.filter_list_rounded, // Consider HugeIcons
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Implement filter functionality
                ShadToaster.of(context).show(
                  ShadToast(description: const Text('Filter not implemented yet.')),
                );
              },
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
        color: theme.colorScheme.muted.withOpacity(0.1), // Consider a slightly different muted or card variant
        borderRadius: BorderRadius.circular(12),
      ),
      child: ShadButton.ghost( // Using ShadButton.ghost for better theme alignment and ripple
        icon: Icon(icon, size: 22, color: theme.colorScheme.foreground),
        onPressed: onPressed,
        // color: theme.colorScheme.foreground, // color is part of icon for ShadButton
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
                      Icons.calendar_today_rounded, // Consider HugeIcons.calendar_02 or similar
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
                    topRight: Radius.circular(16), // Maintain consistency
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded, // Consider HugeIcons.history_01 or similar
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
        final childAspectRatio = crossAxisCount == 1 ? (width < 400 ? 1.3 : 1.5) : 0.75; // Adjusted for single column
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
          itemCount: crossAxisCount == 1 ? 3 : 6, // Show fewer items in single column shimmer
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(16), // Increased radius for card look
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
        final double cardHeightFactor = crossAxisCount == 1 ? (width < 400 ? 0.75 : 0.65) : 1.33; 
        final childAspectRatio = width / (width / crossAxisCount * cardHeightFactor);


        final padding = width < 400 ? 12.0 : 20.0;
        final spacing = width < 400 ? 12.0 : 16.0;
        final bottomPadding = spacing * 6; 
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
              onRsvpUpdated: _loadEvents, // Pass the callback here
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
              isUpcoming ? Icons.event_available_rounded : Icons.history_rounded, // Consider HugeIcons
              color: ThemeProvider.accentPeach,
              size: 48,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            isUpcoming ? 'No upcoming events yet. Why not create one and invite your circles?' // More engaging text
                      : 'Your past events will appear here once you\'ve attended some.', // Escaped apostrophe
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
                width: boxWidth, // Use max width more effectively
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
            Color.lerp(ThemeProvider.accentPeach, Colors.red, 0.3) ?? ThemeProvider.accentPeach, // Consider slightly less red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.accentPeach.withOpacity(0.3), // Slightly stronger shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShadButton(
        onPressed: _handleCreateEvent,
        backgroundColor: Colors.transparent, // Gradient is on container
        foregroundColor: Colors.white, // Ensure contrast
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        leading: const Icon(Icons.add_rounded, size: 20, color: Colors.white), // Ensure icon color
        child: const Text(
          'Create Event',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Ensure text color
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

  Widget _buildErrorState(ShadThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.destructive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.error_outline_rounded, // Consider HugeIcons.alert_triangle or similar
                color: theme.colorScheme.destructive,
                size: 48,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'We couldn\'t load your events. Please check your connection and try again.', // Escaped apostrophe
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.mutedForeground,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 32),
            ShadButton(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh_rounded, size: 18), // Consider HugeIcons.refresh_cw_01
              child: const Text('Try Again'),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
} 