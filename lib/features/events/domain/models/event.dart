import 'package:flutter/material.dart';

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
  });

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