import 'package:flutter/material.dart';

/// Represents data for circle creation process
class CircleCreationData {
  // Basic details (Step 1)
  String name = '';
  String description = '';
  IconData? selectedIcon;
  dynamic customIconImage; // Can be File or network image
  bool isUsingCustomImage = false;
  
  // Members (Step 2)
  List<CircleMember> members = [];
  
  // Preferences (Step 3)
  Set<String> selectedInterests = {};
  FrequencyPreference frequencyPreference = FrequencyPreference.monthly;
  List<WeekDay> preferredDays = [];
  List<TimeOfDayPreference> preferredTimes = [];
  
  // Validation methods
  bool isStep1Valid() => name.length >= 3 && name.length <= 30;
  bool isStep3Valid() => selectedInterests.isNotEmpty;

  // Reset the data
  void reset() {
    name = '';
    description = '';
    selectedIcon = null;
    customIconImage = null;
    isUsingCustomImage = false;
    members = [];
    selectedInterests = {};
    frequencyPreference = FrequencyPreference.monthly;
    preferredDays = [];
    preferredTimes = [];
  }
}

/// Represents a member in a circle
class CircleMember {
  final String id;
  final String identifier; // Email or phone
  final String? name; // Optional if available from contacts
  final String? photoUrl; // Optional contact photo
  final MemberStatus status;
  
  CircleMember({
    required this.id,
    required this.identifier,
    this.name,
    this.photoUrl,
    this.status = MemberStatus.pending,
  });
}

/// Status of a circle member
enum MemberStatus {
  pending,
  joined
}

/// Frequency of circle meetups
enum FrequencyPreference {
  weekly,
  biweekly,
  monthly,
  quarterly,
  custom
}

/// Days of the week for preferred meetups
enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

/// Times of day for preferred meetups
enum TimeOfDayPreference {
  morning,
  afternoon,
  evening,
  night
}

/// Available interest categories for circles
class InterestCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  
  const InterestCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
  
  static List<InterestCategory> getAllCategories() {
    return [
      const InterestCategory(
        id: 'entertainment',
        name: 'Entertainment',
        icon: Icons.movie_outlined,
        description: 'Movies, shows, concerts, theater',
      ),
      const InterestCategory(
        id: 'dining',
        name: 'Dining & Food',
        icon: Icons.restaurant_outlined,
        description: 'Restaurants, cafes, cooking',
      ),
      const InterestCategory(
        id: 'outdoors',
        name: 'Outdoor Activities',
        icon: Icons.terrain_outlined,
        description: 'Hiking, parks, sports',
      ),
      const InterestCategory(
        id: 'social',
        name: 'Social',
        icon: Icons.groups_outlined,
        description: 'Game nights, parties, gatherings',
      ),
      const InterestCategory(
        id: 'cultural',
        name: 'Cultural',
        icon: Icons.museum_outlined,
        description: 'Museums, galleries, workshops',
      ),
      const InterestCategory(
        id: 'wellness',
        name: 'Wellness',
        icon: Icons.self_improvement_outlined,
        description: 'Fitness, yoga, meditation',
      ),
      const InterestCategory(
        id: 'learning',
        name: 'Learning',
        icon: Icons.school_outlined,
        description: 'Classes, workshops, book clubs',
      ),
    ];
  }
}