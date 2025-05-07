import 'package:flutter/material.dart';
import 'circle_creation_model.dart';

// Interest model
class InterestModel {
  final String id;
  final String name;
  final String? category;
  // final DateTime? createdAt; // from public.interests table if added

  InterestModel({
    required this.id,
    required this.name,
    this.category,
    // this.createdAt,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      // createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
    };
    if (category != null) {
      data['category'] = category;
    }
    // if (createdAt != null) {
    //   data['created_at'] = createdAt!.toIso8601String();
    // }
    return data;
  }
}

// Event Attendee related models
enum EventAttendeeStatus {
  going,
  not_going,
  maybe,
  invited;

  String toJson() => name;
  static EventAttendeeStatus fromJson(String json) => values.byName(json);
}

class EventAttendee {
  final String userId; // from user_profiles.id
  final String? fullName; // from user_profiles.full_name
  final String? avatarUrl; // from user_profiles.avatar_url
  final EventAttendeeStatus status; // RSVP status for this event
  final DateTime rsvpedAt;
  // You might also want to include user_profile_updated_at if displaying that info here

  EventAttendee({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    required this.status,
    required this.rsvpedAt,
  });

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    // Assumes json is a record from event_attendees joined with user_profiles.
    // The user_profile data might be directly in json if the select was e.g., supabase.from('event_attendees').select('*, user_id(*)')
    // or nested if it was supabase.from('event_attendees').select('*, user_profiles:user_id(*)')
    Map<String, dynamic> userProfileData = json['user_profiles'] ?? json['user_id'] ?? json;
    
    return EventAttendee(
      userId: userProfileData['id'] as String? ?? json['user_id'] as String, // user_id is the FK on event_attendees
      fullName: userProfileData['full_name'] as String?,
      avatarUrl: userProfileData['avatar_url'] as String?,
      status: EventAttendeeStatus.fromJson(json['status'] as String? ?? 'invited'), // status is from event_attendees table itself
      rsvpedAt: DateTime.parse(json['rsvped_at'] as String? ?? DateTime.now().toIso8601String()), // rsvped_at from event_attendees
    );
  }
}

// Event model for circle events
class Event {
  final String id;
  final String circleId; // Foreign Key to Circle
  final String createdByUserId; // Foreign Key to UserProfile
  final String title;
  final String? description;
  final DateTime eventDatetime; // Maps to event_datetime
  final String? location;
  final List<EventAttendee>? attendees; // Changed from List<CircleMember>
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.circleId,
    required this.createdByUserId,
    required this.title,
    this.description,
    required this.eventDatetime,
    this.location,
    this.attendees,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      circleId: json['circle_id'] as String,
      createdByUserId: json['created_by_user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDatetime: DateTime.parse(json['event_datetime'] as String),
      location: json['location'] as String?,
      attendees: (json['event_attendees'] as List?)
          ?.map((attendeeJson) => EventAttendee.fromJson(attendeeJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Basic toJson - attendeesDetails might not be directly settable this way
    return {
      'id': id,
      'circle_id': circleId,
      'created_by_user_id': createdByUserId,
      'title': title,
      'description': description,
      'event_datetime': eventDatetime.toIso8601String(),
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // attendees are managed via event_attendees table typically
    };
  }
}

class Circle {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl; // maps to image_url
  final DateTime createdAt; // maps to created_at
  final DateTime updatedAt; // maps to updated_at
  final String adminId; // Foreign Key to UserProfile, maps to admin_id
  final String? meetingFrequency; // maps to meeting_frequency
  final List<String>? commonActivities; // maps to common_activities TEXT[]
  final String? lastActivity; // maps to last_activity (consider deriving this)

  // Joined data / App-side derived data
  final List<InterestModel>? interests; // From joined circle_interests -> interests
  final List<CircleMember>? members; // From joined circle_members -> user_profiles
  final List<Event>? upcomingEvents; // Fetched and filtered client-side or specific query
  final List<Event>? pastEvents; // Fetched and filtered client-side or specific query
  final int? memberCount; // Can be derived from members.length or fetched

  Circle({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.adminId,
    this.meetingFrequency,
    this.commonActivities,
    this.lastActivity,
    this.interests,
    this.members,
    this.upcomingEvents,
    this.pastEvents,
    this.memberCount,
  });

  factory Circle.fromJson(Map<String, dynamic> json) {
    var rawMembers = json['circle_members'] as List?;
    List<CircleMember>? parsedMembers;
    if (rawMembers != null) {
      parsedMembers = rawMembers
          .map((memberData) {
            var userProfileData = memberData['user_profiles']; 
            if (userProfileData is Map<String, dynamic>) {
              // Extract circle_member specific fields
              String? statusStr = memberData['status'] as String?;
              String? roleStr = memberData['role'] as String?;
              String? joinedAtStr = memberData['joined_at'] as String?;
              String? invitedAtStr = memberData['invited_at'] as String?;
              String? requestedAtStr = memberData['requested_at'] as String?;
              String? updatedAtStr = memberData['updated_at'] as String?; // from circle_members table

              return CircleMember.fromJson(
                userProfileData, // This is the Map<String, dynamic> for user profile
                cId: memberData['circle_id'] as String?, // Pass circle_id if available at this level
                memberStatus: statusStr != null ? MemberStatus.fromJson(statusStr) : MemberStatus.pending,
                memberRole: roleStr != null ? MemberRole.fromJson(roleStr) : MemberRole.member,
                mJoinedAt: joinedAtStr != null ? DateTime.parse(joinedAtStr) : null,
                mInvitedAt: invitedAtStr != null ? DateTime.parse(invitedAtStr) : null,
                mRequestedAt: requestedAtStr != null ? DateTime.parse(requestedAtStr) : null,
                mUpdatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : null,
              );
            } else if (memberData['user_id'] is Map<String, dynamic>) { // Alternative nesting: user_id is the profile
              Map<String, dynamic> userProfileMap = memberData['user_id'] as Map<String, dynamic>; 
              String? statusStr = memberData['status'] as String?;
              String? roleStr = memberData['role'] as String?;
              String? joinedAtStr = memberData['joined_at'] as String?;
              String? invitedAtStr = memberData['invited_at'] as String?;
              String? requestedAtStr = memberData['requested_at'] as String?;
              String? updatedAtStr = memberData['updated_at'] as String?;

              return CircleMember.fromJson(
                userProfileMap,
                cId: memberData['circle_id'] as String?,
                memberStatus: statusStr != null ? MemberStatus.fromJson(statusStr) : MemberStatus.pending,
                memberRole: roleStr != null ? MemberRole.fromJson(roleStr) : MemberRole.member,
                mJoinedAt: joinedAtStr != null ? DateTime.parse(joinedAtStr) : null,
                mInvitedAt: invitedAtStr != null ? DateTime.parse(invitedAtStr) : null,
                mRequestedAt: requestedAtStr != null ? DateTime.parse(requestedAtStr) : null,
                mUpdatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : null,
              );
            }
            return null; 
          })
          .whereType<CircleMember>()
          .toList();
    }
    
    var rawInterests = json['circle_interests'] as List?;
    List<InterestModel>? parsedInterests;
    if (rawInterests != null) {
      parsedInterests = rawInterests
        .map((interestData) {
            var interestDetails = interestData['interests']; // Assuming 'interests' is the joined table alias
            if (interestDetails is Map<String, dynamic>) {
                return InterestModel.fromJson(interestDetails);
            }
            return null;
        })
        .whereType<InterestModel>()
        .toList();
    }

    // Events are typically fetched separately based on circle_id
    // and then filtered into upcoming/past in the app or via specific queries.
    // For this example, let's assume they might be passed in if fetched together (less common for top-level circle list).
    List<Event>? parsedUpcomingEvents;
    List<Event>? parsedPastEvents;
    if ((json['events'] as List?) != null) {
        final now = DateTime.now();
        List<Event> allEvents = (json['events'] as List)
            .map((eventData) => Event.fromJson(eventData as Map<String, dynamic>))
            .toList();
        parsedUpcomingEvents = allEvents.where((e) => e.eventDatetime.isAfter(now)).toList();
        parsedPastEvents = allEvents.where((e) => e.eventDatetime.isBefore(now)).toList();
    }


    return Circle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      adminId: json['admin_id'] is Map<String,dynamic> ? json['admin_id']['id'] as String : json['admin_id'] as String, // Handle if admin_id is expanded
      meetingFrequency: json['meeting_frequency'] as String?,
      commonActivities: (json['common_activities'] as List?)?.map((e) => e as String).toList(),
      lastActivity: json['last_activity'] as String?,
      interests: parsedInterests,
      members: parsedMembers,
      memberCount: parsedMembers?.length ?? json['member_count'] as int?, // Derive or use if provided
      upcomingEvents: parsedUpcomingEvents ?? (json['upcoming_events'] as List?)?.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList(),
      pastEvents: parsedPastEvents ?? (json['past_events'] as List?)?.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // toJson is mainly for creating/updating a circle's direct fields.
    // Joined data like members, interests, events are managed via their own tables/endpoints.
    return {
      'id': id, // Usually not sent on create, but useful for updates
      'name': name,
      'description': description,
      'image_url': imageUrl,
      // 'created_at': createdAt.toIso8601String(), // সাধারণত ডাটাবেস সেট করে
      // 'updated_at': updatedAt.toIso8601String(), // সাধারণত ডাটাবেস সেট করে
      'admin_id': adminId,
      'meeting_frequency': meetingFrequency,
      'common_activities': commonActivities,
      'last_activity': lastActivity,
      // interests, members, events are not typically set directly in circle's json payload for create/update
    };
  }
} 