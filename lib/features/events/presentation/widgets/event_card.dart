import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event.dart';
import '../screens/event_details_screen.dart';

// RSVP status options
enum RSVPStatus { none, going, maybe, notGoing }

class EventCard extends StatefulWidget {
  final Event event;
  final bool isUpcoming;
  
  const EventCard({
    Key? key,
    required this.event,
    required this.isUpcoming,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late RSVPStatus _status;

  @override
  void initState() {
    super.initState();
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
            children: RSVPStatus.values.map((option) => ListTile(
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
            )).toList(),
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

  @override
  Widget build(BuildContext context) {
    // dynamic inner padding for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 8.0 : 14.0;
    final verticalTopPadding = screenWidth < 360 ? 8.0 : 14.0;
    final verticalBottomPadding = screenWidth < 360 ? 6.0 : 10.0;
    final theme = ShadTheme.of(context);
    final isToday = _isToday(widget.event.startTime);
    
    final statusColor = widget.isUpcoming 
        ? ThemeProvider.accentPeach 
        : theme.colorScheme.mutedForeground;

    return InkWell(
      onTap: () => _handleEventTap(context),
      splashColor: widget.event.circleColor.withOpacity(0.1),
      highlightColor: widget.event.circleColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.foreground.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalTopPadding,
                horizontalPadding,
                verticalBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCircleChip(theme),
                  
                  const SizedBox(height: 10),

                  Text(
                    widget.event.title,
                    style: theme.textTheme.large.copyWith(
                      fontWeight: FontWeight.w600, 
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Text(
                    widget.event.description,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(theme, isToday, statusColor),
                  
                  const SizedBox(height: 6),
                  
                  _buildLocationRow(theme),

                ],
              ),
            ),
            
            const Spacer(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleChip(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.event.circleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.event.circleColor.withOpacity(0.2),
          width: 0.5,
        ),
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
          const SizedBox(width: 5),
          Text(
            widget.event.circleName,
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.event.circleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ShadThemeData theme, bool isToday, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          widget.isUpcoming ? Icons.calendar_today_outlined : Icons.event_available_outlined,
          size: 13,
          color: statusColor,
        ),
        const SizedBox(width: 5),
        Text(
          _formatEventDate(widget.event.startTime),
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w500,
            color: statusColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.access_time_outlined,
          size: 13,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 5),
        Text(
          _formatTimeOnly(widget.event.startTime),
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.mutedForeground,
            fontSize: 12,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Today',
              style: theme.textTheme.small.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildLocationRow(ShadThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 13,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            widget.event.location,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    // get theme for footer styling
    final theme = ShadTheme.of(context);
    // dynamic footer padding for responsive layout
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 360 ? 8.0 : 14.0;
    final vPad = width < 360 ? 6.0 : 10.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(0.6),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.border.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAttendeesInfo(theme),
          
          widget.isUpcoming ? _buildRsvpButton(theme) : _buildViewButton(theme),
        ],
      ),
    );
  }

  Widget _buildAttendeesInfo(ShadThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.group_outlined,
          size: 14,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.event.attendees}',
          style: theme.textTheme.small.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRsvpButton(ShadThemeData theme) {
    // Determine label, icon, and color based on status
    final label = _status == RSVPStatus.going
        ? 'Going'
        : _status == RSVPStatus.notGoing
            ? 'Not going'
            : _status == RSVPStatus.maybe
                ? 'Maybe'
                : 'RSVP';
    final icon = _status == RSVPStatus.going
        ? Icons.check_circle_outline
        : _status == RSVPStatus.notGoing
            ? Icons.cancel_outlined
            : _status == RSVPStatus.maybe
                ? Icons.help_outline
                : Icons.how_to_vote_outlined;
    final fgColor = _status == RSVPStatus.going
        ? widget.event.circleColor
        : _status == RSVPStatus.notGoing
            ? Colors.red.shade600
            : ThemeProvider.accentPeach;

    if (_status == RSVPStatus.none) {
      return ShadButton.outline(
        onPressed: _showRsvpOptions,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(icon, size: 13),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        foregroundColor: fgColor,
      );
    }

    // Filled button for selected status
    return ShadButton(
      onPressed: _showRsvpOptions,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      leading: Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Icon(icon, size: 13),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: fgColor,
      foregroundColor: Colors.white,
    );
  }
  
  Widget _buildViewButton(ShadThemeData theme) {
    return ShadButton.ghost(
      onPressed: () => HapticFeedback.lightImpact(),
      foregroundColor: theme.colorScheme.mutedForeground,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: const Text(
        'View',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Padding(
        padding: EdgeInsets.only(left: 2.0),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 9,
        ),
      ),
    );
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);
    
    if (eventDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (eventDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      final formatString = date.year == now.year ? 'MMM d' : 'MMM d, yyyy';
      final DateFormat formatter = DateFormat(formatString);
      return formatter.format(date);
    }
  }
  
  String _formatTimeOnly(DateTime dateTime) {
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(dateTime).toLowerCase();
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  void _handleEventTap(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(event: widget.event),
      ),
    );
  }
} 