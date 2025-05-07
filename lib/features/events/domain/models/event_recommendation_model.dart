import 'package:flutter/material.dart';

class EventRecommendation {
  final String id;
  final String title;
  final String description;
  final String location;
  final double estimatedDurationHours;
  final double preferenceScore; // 0.0 to 1.0
  final Color AIGeneratedColor; // To store the purple color for AI indication
  int votes; // Net votes (upvotes - downvotes)
  List<String> upvoters; 
  List<String> downvoters;

  EventRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.estimatedDurationHours = 2.0,
    required this.preferenceScore,
    this.AIGeneratedColor = Colors.purple, // Default AI color
    this.votes = 0,
    this.upvoters = const [],
    this.downvoters = const [],
  });

  // Factory constructor for mock data
  factory EventRecommendation.mock(String id, String title, String description, String location, double score, int initialVotes) {
    // For mock, we can distribute initialVotes somewhat arbitrarily or just set net votes
    // And simulate some upvoters/downvoters if needed for UI testing, though starting fresh is fine.
    return EventRecommendation(
      id: id,
      title: title,
      description: description,
      location: location,
      preferenceScore: score,
      votes: initialVotes, // This will be the starting net votes for mock data
      upvoters: [], // Start with empty lists for mock, voting will populate them
      downvoters: [],
    );
  }
} 