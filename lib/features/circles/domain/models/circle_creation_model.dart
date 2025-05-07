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

  // Convert CircleCreationData to a Map for Supabase insertion
  Map<String, dynamic> toMap() {
    String? imageUrl;
    if (isUsingCustomImage) {
      if (customIconImage is String) { // Assuming network URL is passed as String
        imageUrl = customIconImage as String?;
      } else {
        // If customIconImage is a File, it needs to be uploaded first.
        // For now, we'll represent this as null. The upload logic should exist
        // before calling createCircle, or createCircle should handle it.
        imageUrl = null; 
        print('[CircleCreationData.toMap] Warning: customIconImage is a local file and needs to be uploaded. Setting image_url to null for now.');
      }
    } else if (selectedIcon != null) {
      // You might have a way to map IconData to a default URL or a string representation
      // For now, setting to null or a placeholder if no direct URL mapping exists.
      // This could be a name of an icon from a predefined set stored in Supabase perhaps.
      imageUrl = null; // Placeholder: Decide how to represent selectedIcon as a URL or identifier
      print('[CircleCreationData.toMap] Warning: selectedIcon handling for image_url is not fully implemented. Setting to null.');
    }

    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      // Assuming your Supabase table stores these as text.
      // Adjust if your schema uses enum types directly in Postgres (though text is common).
      'meeting_frequency': frequencyPreference.name, // e.g., "monthly"
      // For common_activities (selectedInterests), convert Set<String> to a suitable format.
      // If your column is TEXT, a comma-separated string is one option.
      // If it's TEXT[], then a List<String> is needed.
      // For simplicity, let's assume comma-separated text for now. Adjust if it's an array.
      'common_activities': selectedInterests.toList(), 
      // For preferredDays and preferredTimes, Supabase TEXT[] arrays are common.
      // Convert enums to their string names.
      'preferred_days': preferredDays.map((day) => day.name).toList(), 
      'preferred_times': preferredTimes.map((time) => time.name).toList(),
      // admin_id will be added by CircleService
      // members will be handled separately after circle creation
    };
  }

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

/// Status of a circle member - maps to TEXT in Supabase
enum MemberStatus {
  pending,
  invited,
  requested,
  joined,
  rejected,
  left,
  banned;

  String toJson() => name;
  static MemberStatus fromJson(String json) => values.byName(json);
}

/// Role of a circle member - maps to TEXT in Supabase
enum MemberRole {
  member,
  admin,
  moderator;

  String toJson() => name;
  static MemberRole fromJson(String json) => values.byName(json);
}

/// Represents a member in a circle, combining user_profile and circle_member data
class CircleMember {
  // From user_profiles table (or auth.users)
  final String id; // This is the user_id (UUID)
  final String? email; // From user_profiles.email or auth.users.email
  final String? fullName; // From user_profiles.full_name
  final String? avatarUrl; // From user_profiles.avatar_url
  final DateTime? userProfileUpdatedAt; // From user_profiles.updated_at

  // From circle_members table
  final String? circleId; // The circle this membership pertains to (often implicit)
  final MemberStatus status;
  final MemberRole role;
  final DateTime? joinedAt;
  final DateTime? invitedAt;
  final DateTime? requestedAt;
  final DateTime? membershipUpdatedAt; // From circle_members.updated_at

  CircleMember({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.userProfileUpdatedAt,
    this.circleId, // Optional if member is part of a Circle object already
    required this.status,
    required this.role,
    this.joinedAt,
    this.invitedAt,
    this.requestedAt,
    this.membershipUpdatedAt,
  });

  // Adapting fromJson to handle potentially nested data or flat data
  // Option 1: Expects a map that is primarily user_profile data,
  // with circle_member specific fields passed as separate arguments (used from Circle.fromJson)
  factory CircleMember.fromJson(
    Map<String, dynamic> userProfileJson,
    {String? cId,
     MemberStatus? memberStatus,
     MemberRole? memberRole,
     DateTime? mJoinedAt,
     DateTime? mInvitedAt,
     DateTime? mRequestedAt,
     DateTime? mUpdatedAt}
  ) {
    return CircleMember(
      id: userProfileJson['id'] as String,
      email: userProfileJson['email'] as String?,
      fullName: userProfileJson['full_name'] as String? ?? userProfileJson['name'] as String?, // fallback for old 'name'
      avatarUrl: userProfileJson['avatar_url'] as String? ?? userProfileJson['photoUrl'] as String?, // fallback for old 'photoUrl'
      userProfileUpdatedAt: userProfileJson['updated_at'] != null ? DateTime.parse(userProfileJson['updated_at'] as String) : null,
      
      circleId: cId,
      status: memberStatus ?? (userProfileJson['status'] != null ? MemberStatus.fromJson(userProfileJson['status'] as String) : MemberStatus.pending), // Fallback if status is in userProfileJson (less likely)
      role: memberRole ?? (userProfileJson['role'] != null ? MemberRole.fromJson(userProfileJson['role'] as String) : MemberRole.member), // Fallback for role
      joinedAt: mJoinedAt ?? (userProfileJson['joined_at'] != null ? DateTime.parse(userProfileJson['joined_at'] as String) : null),
      invitedAt: mInvitedAt ?? (userProfileJson['invited_at'] != null ? DateTime.parse(userProfileJson['invited_at'] as String) : null),
      requestedAt: mRequestedAt ?? (userProfileJson['requested_at'] != null ? DateTime.parse(userProfileJson['requested_at'] as String) : null),
      membershipUpdatedAt: mUpdatedAt ?? (userProfileJson['membership_updated_at'] != null ? DateTime.parse(userProfileJson['membership_updated_at'] as String) : null),
    );
  }

  // Option 2: Expects a flat map containing all fields (e.g., from a custom Supabase RPC or view)
  factory CircleMember.fromJsonFlat(Map<String, dynamic> json) {
     return CircleMember(
      id: json['user_id'] as String? ?? json['id'] as String, // id from user_profiles is primary user id
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      userProfileUpdatedAt: json['user_profile_updated_at'] != null ? DateTime.parse(json['user_profile_updated_at'] as String) : null,
      
      circleId: json['circle_id'] as String?,
      status: MemberStatus.fromJson(json['status'] as String? ?? 'pending'),
      role: MemberRole.fromJson(json['role'] as String? ?? 'member'),
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at'] as String) : null,
      invitedAt: json['invited_at'] != null ? DateTime.parse(json['invited_at'] as String) : null,
      requestedAt: json['requested_at'] != null ? DateTime.parse(json['requested_at'] as String) : null,
      membershipUpdatedAt: json['membership_updated_at'] != null ? DateTime.parse(json['membership_updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // This toJson is primarily for user_profile fields if you were to update a user profile.
    // Membership aspects (status, role) are updated on the circle_members table, usually not with user profile data.
    final data = <String, dynamic>{
      'id': id, // user_id
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      // 'updated_at': userProfileUpdatedAt?.toIso8601String(), // for user_profiles table
    };
    // For circle_members table, you'd send something like:
    // { 'user_id': id, 'circle_id': circleId, 'status': status.name, 'role': role.name }
    return data;
  }
  
  // The old constructor/fields: 
  // final String identifier; // Email or phone
  // final String? name; // Optional if available from contacts
  // final String? photoUrl; // Optional contact photo
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