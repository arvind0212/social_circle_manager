import 'package:flutter/material.dart';
import 'package:social_circle_manager/core/theme/app_theme.dart'; // Assuming ThemeProvider might have default colors

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String circleName;
  final String circleId;
  final Color circleColor;
  final int attendees;
  final bool? isRsvpd;
  final String? eventCreatorId; // Added field

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.circleName,
    required this.circleId,
    required this.circleColor,
    required this.attendees,
    this.isRsvpd,
    this.eventCreatorId, // Added field
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final String? rsvpStatus = json['user_rsvp_status'] as String?;
    bool? rsvpd;
    if (rsvpStatus == 'going') {
      rsvpd = true;
    } else if (rsvpStatus == 'not_going') {
      rsvpd = false;
    } else {
      // 'maybe' or null will result in null
      rsvpd = null;
    }

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? 'Not specified',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      circleId: json['circle_id'] as String,
      circleName: json['circle_name'] as String? ?? 'Unknown Circle',
      circleColor: _colorFromHex(json['circle_hex_color'] as String?) ?? ThemeProvider.primaryBlue, // Default color
      attendees: (json['attendee_count'] as num?)?.toInt() ?? 0,
      isRsvpd: rsvpd,
      eventCreatorId: json['event_creator_id'] as String?,
    );
  }

  static Color? _colorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return null;
    }
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    if (hexCode.length == 8) {
      return Color(int.parse(hexCode, radix: 16));
    }
    return null;
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());

  // Calculate event duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Format event duration as a human-readable string (e.g., "2h 30m")
  String get formattedDuration {
    final minutes = durationMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }

  // Create a formatted date string for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final startDate = DateTime(startTime.year, startTime.month, startTime.day);

    if (startDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (startDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      // Format day of week for events within the next week
      final difference = startDate.difference(today).inDays;
      if (difference < 7 && difference > 0) {
        switch (startTime.weekday) {
          case 1:
            return 'Monday';
          case 2:
            return 'Tuesday';
          case 3:
            return 'Wednesday';
          case 4:
            return 'Thursday';
          case 5:
            return 'Friday';
          case 6:
            return 'Saturday';
          case 7:
            return 'Sunday';
          default:
            return '';
        }
      } else {
        // Format as Month Day for dates further in the future or past
        final List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[startTime.month - 1]} ${startTime.day}';
      }
    }
  }

  // Format time as "7:30 PM"
  String get formattedTime {
    final hour = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = startTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
} 