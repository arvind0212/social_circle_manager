import 'package:flutter/material.dart';
import 'dart:convert'; // Required for jsonDecode if needed, though usually handled before calling

import 'package:social_circle_manager/core/theme/app_theme.dart'; // For ThemeProvider colors

class EventRecommendation {
  final String id;
  final String title;
  final String description;
  final String location;
  final double estimatedDurationHours;
  final double preferenceScore; // Corresponds to score_total from API
  final Color AIGeneratedColor; // Keep or remove
  final int votes; // Net votes fetched separately
  List<String> upvoters; // State managed in UI, not from API directly
  List<String> downvoters; // State managed in UI, not from API directly

  // Fields added from API response
  final String eventId; // Corresponds to event_id from API
  final String origin; // Corresponds to event_table_origin from API
  final String? reasoning; // Corresponds to reasoning from API
  final Map<String, double>? subScores; // Corresponds to scores map from API

  // Added fields for start and end time
  final String startTime; 
  final String endTime;

  EventRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.estimatedDurationHours = 2.0,
    required this.preferenceScore,
    required this.AIGeneratedColor,
    required this.votes,
    List<String>? upvoters,
    List<String>? downvoters,
    required this.eventId,
    required this.origin,
    this.reasoning,
    this.subScores,
    required this.startTime,
    required this.endTime,
  }) : this.upvoters = upvoters ?? [],
       this.downvoters = downvoters ?? [];

  // Factory constructor to parse from API JSON map
  factory EventRecommendation.fromJson(Map<String, dynamic> json) {
    // Safely extract sub-scores map
    final Map<String, dynamic>? scoresMap = json['scores'] as Map<String, dynamic>?;
    Map<String, double>? parsedSubScores;
    if (scoresMap != null) {
      parsedSubScores = scoresMap.map((key, value) {
        // Ensure value is treated as num before converting to double
        final num? numValue = value as num?;
        return MapEntry(key, numValue?.toDouble() ?? 0.0);
      });
    }

    // Safely extract score_total
    final num? scoreTotalNum = json['score_total'] as num?;
    final double scoreTotal = scoreTotalNum?.toDouble() ?? 0.0;

    // Generate a placeholder ID if missing (should ideally not happen)
    final String recommendationId = json['recommendation_id'] as String? ?? 'missing_rec_id_${DateTime.now().millisecondsSinceEpoch}';
    final String eventId = json['event_id'] as String? ?? 'missing_event_id';

    // Extract event_data details if needed (example for title, desc, location if not top-level)
    // Adjust based on the actual structure of `event_data` in your API response
    final Map<String, dynamic>? eventData = json['event_data'] as Map<String, dynamic>?;
    final String title = eventData?['title'] as String? ?? json['title'] as String? ?? 'No Title';
    final String description = eventData?['description'] as String? ?? json['description'] as String? ?? 'No Description';
    final String location = eventData?['location'] as String? ?? eventData?['location_text'] as String? ?? json['location'] as String? ?? 'No Location';
    // Extract start_time and end_time from eventData
    final String startTime = eventData?['start_time'] as String? ?? '';
    final String endTime = eventData?['end_time'] as String? ?? '';

    return EventRecommendation(
      id: recommendationId, // recommendation_id from API
      title: title,
      description: description,
      location: location,
      preferenceScore: scoreTotal, // score_total from API
      votes: 0, // Initialize votes to 0, will be fetched separately
      eventId: eventId, // event_id from API
      origin: json['event_table_origin'] as String? ?? 'unknown', // origin from API
      reasoning: json['reasoning'] as String?,
      subScores: parsedSubScores, 
      startTime: startTime,
      endTime: endTime,
      AIGeneratedColor: _getColorFromScore(scoreTotal),
      estimatedDurationHours: 2.0, // Or parse from event_data if available
      upvoters: [], 
      downvoters: [], 
    );
  }

  // Helper function to derive color from score (example)
  static Color _getColorFromScore(double score) {
    if (score >= 0.9) return Colors.green.shade600; // >= 0.9
    if (score >= 0.75) return ThemeProvider.accentPeach; // >= 0.75
    if (score >= 0.6) return ThemeProvider.primaryBlue; // >= 0.6
    return Colors.grey.shade600; // Default for lower scores
  }

  // Factory constructor for mock data - UPDATE if needed or remove if unused
  factory EventRecommendation.mock(String id, String title, String description, String location, double score, int initialVotes) {
    // This mock needs updating to provide eventId, origin, etc., or be removed.
    print("Warning: EventRecommendation.mock is likely outdated.");
    return EventRecommendation(
      id: id,
      title: title,
      description: description,
      location: location,
      preferenceScore: score,
      votes: initialVotes,
      eventId: 'mock_event_id', // Placeholder
      origin: 'events', // Placeholder
      AIGeneratedColor: _getColorFromScore(score), // Use helper
      upvoters: [], 
      downvoters: [],
      startTime: '',
      endTime: '',
    );
  }

  // copyWith method - UPDATE to include new fields
  EventRecommendation copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    double? estimatedDurationHours,
    double? preferenceScore,
    Color? AIGeneratedColor,
    int? votes,
    List<String>? upvoters,
    List<String>? downvoters,
    String? eventId,
    String? origin,
    String? reasoning,
    Map<String, double>? subScores,
    String? startTime,
    String? endTime,
  }) {
    return EventRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      estimatedDurationHours: estimatedDurationHours ?? this.estimatedDurationHours,
      preferenceScore: preferenceScore ?? this.preferenceScore,
      AIGeneratedColor: AIGeneratedColor ?? this.AIGeneratedColor,
      votes: votes ?? this.votes,
      upvoters: upvoters ?? this.upvoters,
      downvoters: downvoters ?? this.downvoters,
      eventId: eventId ?? this.eventId,
      origin: origin ?? this.origin,
      reasoning: reasoning ?? this.reasoning,
      subScores: subScores ?? this.subScores,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
} 