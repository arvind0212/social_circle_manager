import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/models/event.dart';
import '../../../../core/theme/app_theme.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  static const int fallbackBudget = 150;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

enum RSVPStatus { none, going, maybe, notGoing }

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late RSVPStatus _status;
  late bool _showGoingList = false;

  @override
  void initState() {
    super.initState();
    // initialize from event.isRsvpd: true->going, false->notGoing, null->none
    _status = widget.event.isRsvpd == true
      ? RSVPStatus.going
      : widget.event.isRsvpd == false
        ? RSVPStatus.notGoing
        : RSVPStatus.none;
  }

  void _showRsvpOptions() async {
    final selected = await showModalBottomSheet<RSVPStatus>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = ShadTheme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var option in RSVPStatus.values)
                ListTile(
                  leading: Icon(
                    option == RSVPStatus.going
                      ? Icons.check_circle_outline
                      : option == RSVPStatus.notGoing
                        ? Icons.cancel_outlined
                        : option == RSVPStatus.maybe
                          ? Icons.help_outline
                          : Icons.how_to_vote_outlined,
                    color: option == RSVPStatus.going
                      ? widget.event.circleColor
                      : option == RSVPStatus.notGoing
                        ? Colors.red.shade600
                        : option == RSVPStatus.maybe
                          ? ThemeProvider.accentPeach
                          : theme.colorScheme.foreground,
                  ),
                  title: Text(
                    option == RSVPStatus.going ? 'Going'
                      : option == RSVPStatus.notGoing ? 'Not going'
                      : option == RSVPStatus.maybe ? 'Maybe'
                      : 'RSVP',
                    style: theme.textTheme.small,
                  ),
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _status = selected;
      });
    }
  }

  Widget _buildRsvpControl(ShadThemeData theme) {
    final label = _status == RSVPStatus.going ? 'Going'
      : _status == RSVPStatus.notGoing ? 'Not going'
      : _status == RSVPStatus.maybe ? 'Maybe'
      : 'RSVP';
    final icon = _status == RSVPStatus.going ? Icons.check_circle_outline
      : _status == RSVPStatus.notGoing ? Icons.cancel_outlined
      : _status == RSVPStatus.maybe ? Icons.help_outline
      : Icons.how_to_vote_outlined;
    final color = _status == RSVPStatus.going
      ? widget.event.circleColor
      : _status == RSVPStatus.notGoing
        ? Colors.red.shade600
        : theme.colorScheme.foreground;
    return SizedBox(
      width: double.infinity,
      child: _status == RSVPStatus.none
        ? ShadButton.outline(
            leading: Icon(icon, color: ThemeProvider.accentPeach),
            child: const Text('RSVP'),
            onPressed: _showRsvpOptions,
          )
        : ShadButton(
            leading: Icon(icon, size: 18),
            child: Text(label),
            backgroundColor: color,
            foregroundColor: Colors.white,
            onPressed: _showRsvpOptions,
          ),
    );
  }

  Widget _buildAttendeesSection(ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendees (${widget.event.attendees})',
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.group_outlined, size: 18, color: theme.colorScheme.mutedForeground),
            const SizedBox(width: 8),
            Text(
              '${widget.event.attendees} going',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// A tappable dropdown row to toggle the attendees list
  Widget _buildAttendeesDropdown(ShadThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _showGoingList = !_showGoingList),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: theme.colorScheme.foreground, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Attendees (${widget.event.attendees})',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
            Icon(
              _showGoingList ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.foreground,
            ),
          ],
        ),
      ),
    );
  }

  /// A vertical list of attendee avatars and names
  Widget _buildGoingList(ShadThemeData theme) {
    // Sample names list; replace with real attendee data when available
    final sampleNames = ['Alice', 'Bob', 'Charlie', 'Dana', 'Eve', 'Frank'];
    final names = sampleNames.take(widget.event.attendees).toList();
    return Column(
      children: names.map((name) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.event.circleColor.withOpacity(0.2),
                foregroundColor: widget.event.circleColor,
                child: Text(
                  name.substring(0, 1),
                  style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Text(name, style: theme.textTheme.small),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.foreground),
        title: Text(
          'Event Details',
          style: TextStyle(color: theme.colorScheme.foreground),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.event.circleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.event.circleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.event.circleName,
                      style: theme.textTheme.small.copyWith(
                        color: widget.event.circleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.event.title,
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 12),

              // Description
              Text(
                widget.event.description,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Date & Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: widget.event.circleColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.event.formattedDate,
                    style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•',
                    style: theme.textTheme.small,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.access_time_filled,
                    size: 18,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.event.formattedTime} (${widget.event.formattedDuration})',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 16),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: widget.event.circleColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.event.location,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 16),

              // Budget
              Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    size: 18,
                    color: ThemeProvider.accentPeach,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¤${EventDetailsScreen.fallbackBudget} SEK per person',
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 24),

              // RSVP control
              _buildRsvpControl(theme).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 32),

              // Attendees section
              _buildAttendeesSection(theme).animate().fadeIn(duration: 400.ms, delay: 600.ms),
              const SizedBox(height: 16),
              // Attendees dropdown toggle
              _buildAttendeesDropdown(theme).animate().fadeIn(duration: 400.ms, delay: 700.ms),
              if (_showGoingList) ...[
                const SizedBox(height: 8),
                _buildGoingList(theme).animate().fadeIn(duration: 400.ms, delay: 800.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 