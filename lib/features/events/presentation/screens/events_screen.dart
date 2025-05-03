import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: ThemeProvider.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeProvider.accentPeach,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle create new event
        },
        backgroundColor: ThemeProvider.accentPeach,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(upcoming: true),
          _buildEventsList(upcoming: false),
        ],
      ),
    );
  }

  Widget _buildEventsList({required bool upcoming}) {
    // For now, we'll display placeholder events
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (upcoming) ...[
          _buildEventCard(
            'Book Club Meeting',
            'Friday, June 10 • 6:00 PM',
            'Central Library, Room 4B',
            'Book Club',
            5,
          ),
          _buildEventCard(
            'Team Lunch',
            'Wednesday, June 15 • 12:30 PM',
            'Pasta Garden Restaurant',
            'Work Team',
            8,
          ),
        ] else ...[
          _buildEventCard(
            'Game Night',
            'Saturday, May 28 • 8:00 PM',
            'Mike\'s Place',
            'College Friends',
            6,
            isPast: true,
          ),
          _buildEventCard(
            'Weekend Hike',
            'Sunday, May 15 • 9:00 AM',
            'Forest Park Trail',
            'Family',
            4,
            isPast: true,
          ),
        ],
      ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildEventCard(String title, String datetime, String location, String circle, int attendees, {bool isPast = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isPast ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  ShadBadge(
                    child: Text(
                      circle,
                      style: TextStyle(
                        color: isPast ? Colors.grey : ThemeProvider.secondaryPurple,
                      ),
                    ),
                    backgroundColor: isPast ? Colors.grey.shade200 : ThemeProvider.secondaryPurple.withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isPast ? Colors.grey : ThemeProvider.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    datetime,
                    style: TextStyle(
                      color: isPast ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: isPast ? Colors.grey : ThemeProvider.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    location,
                    style: TextStyle(
                      color: isPast ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        attendees > 3 ? 3 : attendees,
                        (index) => Container(
                          margin: EdgeInsets.only(right: index == 2 && attendees > 3 ? 0 : 4),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: ThemeProvider.primaryBlue.withOpacity(0.1 * (index + 1)),
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (attendees > 3) ...[
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            child: Text(
                              '+${attendees - 3}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  ShadButton.ghost(
                    onPressed: () {
                      // Navigate to event details
                    },
                    child: Row(
                      children: [
                        Text(
                          isPast ? 'View details' : 'View & RSVP',
                          style: TextStyle(
                            color: isPast ? Colors.grey : ThemeProvider.primaryBlue,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isPast ? Colors.grey : ThemeProvider.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 