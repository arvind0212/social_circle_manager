import 'package:flutter/material.dart';
import 'circle_creation_model.dart';

// Event model for circle events
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final int attendees;
  
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.attendees,
  });
}

class Circle {
  final String id;
  final String name;
  final int memberCount;
  final String description;
  final String? imageUrl;
  final String lastActivity;
  // Added properties for circle detail screen
  final DateTime createdDate;
  final String adminId;
  final List<String> interests;
  final List<String> commonActivities;
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;
  final List<CircleMember> members;
  final String meetingFrequency;
  
  Circle({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.description,
    this.imageUrl,
    required this.lastActivity,
    required this.createdDate,
    required this.adminId,
    required this.interests,
    required this.commonActivities,
    required this.upcomingEvents,
    required this.pastEvents,
    required this.members,
    required this.meetingFrequency,
  });

  // Sample data for prototype
  static List<Circle> sampleCircles = [
    Circle(
      id: '1',
      name: 'College Friends',
      memberCount: 8,
      description: 'Friends from university days',
      imageUrl: null, // We'll use initials for this one
      lastActivity: 'Movie night planned 2 days ago',
      createdDate: DateTime.now().subtract(const Duration(days: 120)),
      adminId: 'user1',
      interests: ['Movies', 'Board Games', 'Travel'],
      commonActivities: ['Movie nights', 'Weekend trips', 'Game nights'],
      upcomingEvents: [
        Event(
          id: 'e1',
          title: 'Summer Reunion',
          description: 'Annual gathering at the lake house',
          dateTime: DateTime.now().add(const Duration(days: 15)),
          location: 'Lake Washington',
          attendees: 6,
        ),
        Event(
          id: 'e2',
          title: 'Movie Night: Inception',
          description: 'Watching Inception at John\'s place',
          dateTime: DateTime.now().add(const Duration(days: 3)),
          location: 'John\'s Apartment',
          attendees: 8,
        ),
      ],
      pastEvents: [
        Event(
          id: 'e3',
          title: 'Board Game Night',
          description: 'Played Catan and Ticket to Ride',
          dateTime: DateTime.now().subtract(const Duration(days: 12)),
          location: 'Sarah\'s House',
          attendees: 7,
        ),
        Event(
          id: 'e4',
          title: 'Happy Hour',
          description: 'After-finals celebration',
          dateTime: DateTime.now().subtract(const Duration(days: 45)),
          location: 'The Pub Downtown',
          attendees: 8,
        ),
      ],
      members: [
        CircleMember(
          id: 'user1',
          identifier: 'john@example.com',
          name: 'John Smith',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user2',
          identifier: 'sarah@example.com',
          name: 'Sarah Johnson',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user3',
          identifier: 'mike@example.com',
          name: 'Mike Anderson',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user4',
          identifier: 'emily@example.com',
          name: 'Emily Davis',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user5',
          identifier: 'james@example.com',
          name: 'James Wilson',
          status: MemberStatus.joined,
        ),
      ],
      meetingFrequency: '2-3 times monthly',
    ),
    Circle(
      id: '2',
      name: 'Book Club',
      memberCount: 5,
      description: 'Monthly book discussion group',
      imageUrl: 'https://images.unsplash.com/photo-1535905557558-afc4877a26fc?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'New book selected yesterday',
      createdDate: DateTime.now().subtract(const Duration(days: 240)),
      adminId: 'user5',
      interests: ['Reading', 'Literature', 'Writing'],
      commonActivities: ['Book discussions', 'Author events', 'Writing workshops'],
      upcomingEvents: [
        Event(
          id: 'e5',
          title: 'July Book Discussion',
          description: 'Discussing "The Midnight Library" by Matt Haig',
          dateTime: DateTime.now().add(const Duration(days: 10)),
          location: 'City Library',
          attendees: 5,
        ),
      ],
      pastEvents: [
        Event(
          id: 'e6',
          title: 'June Book Discussion',
          description: 'Discussed "Educated" by Tara Westover',
          dateTime: DateTime.now().subtract(const Duration(days: 21)),
          location: 'Zoom Call',
          attendees: 4,
        ),
      ],
      members: [
        CircleMember(
          id: 'user5',
          identifier: 'james@example.com',
          name: 'James Wilson',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user6',
          identifier: 'olivia@example.com',
          name: 'Olivia Martinez',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user7',
          identifier: 'david@example.com',
          name: 'David Thompson',
          status: MemberStatus.joined,
        ),
      ],
      meetingFrequency: 'Monthly',
    ),
    Circle(
      id: '3',
      name: 'Hiking Group',
      memberCount: 12,
      description: 'Weekend warriors exploring trails',
      imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'Mt. Rainier hike scheduled for next weekend',
      createdDate: DateTime.now().subtract(const Duration(days: 85)),
      adminId: 'user10',
      interests: ['Hiking', 'Nature', 'Photography', 'Camping'],
      commonActivities: ['Weekend hikes', 'Photography trips', 'Camping'],
      upcomingEvents: [
        Event(
          id: 'e7',
          title: 'Mt. Rainier Day Hike',
          description: 'Exploring the Skyline Trail',
          dateTime: DateTime.now().add(const Duration(days: 5)),
          location: 'Mt. Rainier National Park',
          attendees: 10,
        ),
      ],
      pastEvents: [
        Event(
          id: 'e8',
          title: 'Olympic National Park',
          description: 'Overnight hiking and camping trip',
          dateTime: DateTime.now().subtract(const Duration(days: 14)),
          location: 'Olympic National Park',
          attendees: 8,
        ),
      ],
      members: [
        CircleMember(
          id: 'user8',
          identifier: 'lisa@example.com',
          name: 'Lisa Brown',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user9',
          identifier: 'robert@example.com',
          name: 'Robert Garcia',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user10',
          identifier: 'jennifer@example.com',
          name: 'Jennifer Lopez',
          status: MemberStatus.joined,
        ),
      ],
      meetingFrequency: 'Bi-weekly',
    ),
    Circle(
      id: '4',
      name: 'Office Happy Hour',
      memberCount: 15,
      description: 'Work colleagues who enjoy happy hours',
      imageUrl: 'https://images.unsplash.com/photo-1516997121675-4c2d1684aa3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'Planning next Thursday\'s venue',
      createdDate: DateTime.now().subtract(const Duration(days: 54)),
      adminId: 'user11',
      interests: ['Happy Hours', 'Networking', 'Dining'],
      commonActivities: ['After-work drinks', 'Team lunches', 'Networking'],
      upcomingEvents: [
        Event(
          id: 'e9',
          title: 'Thursday Happy Hour',
          description: 'Weekly happy hour at The Rooftop',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          location: 'The Rooftop Bar',
          attendees: 12,
        ),
      ],
      pastEvents: [
        Event(
          id: 'e10',
          title: 'Last Week\'s Happy Hour',
          description: 'Fun evening at Downtown Brewery',
          dateTime: DateTime.now().subtract(const Duration(days: 7)),
          location: 'Downtown Brewery',
          attendees: 10,
        ),
      ],
      members: [
        CircleMember(
          id: 'user11',
          identifier: 'michael@example.com',
          name: 'Michael Scott',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user12',
          identifier: 'pam@example.com',
          name: 'Pam Beesly',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user13',
          identifier: 'jim@example.com',
          name: 'Jim Halpert',
          status: MemberStatus.joined,
        ),
      ],
      meetingFrequency: 'Weekly',
    ),
    Circle(
      id: '5',
      name: 'Family',
      memberCount: 6,
      description: 'Immediate family members',
      imageUrl: null,
      lastActivity: 'Mom\'s birthday planning in progress',
      createdDate: DateTime.now().subtract(const Duration(days: 365)),
      adminId: 'user14',
      interests: ['Family Gatherings', 'Celebrations', 'Holidays'],
      commonActivities: ['Birthday celebrations', 'Holiday gatherings', 'Family dinners'],
      upcomingEvents: [
        Event(
          id: 'e11',
          title: 'Mom\'s Birthday Dinner',
          description: 'Surprise dinner at Mom\'s favorite restaurant',
          dateTime: DateTime.now().add(const Duration(days: 15)),
          location: 'Italian Bistro',
          attendees: 6,
        ),
        Event(
          id: 'e12',
          title: 'Weekend BBQ',
          description: 'Casual BBQ at the park',
          dateTime: DateTime.now().add(const Duration(days: 8)),
          location: 'City Park',
          attendees: 6,
        ),
      ],
      pastEvents: [
        Event(
          id: 'e13',
          title: 'Dad\'s Birthday',
          description: 'Celebrated at home with a special dinner',
          dateTime: DateTime.now().subtract(const Duration(days: 30)),
          location: 'Home',
          attendees: 6,
        ),
      ],
      members: [
        CircleMember(
          id: 'user14',
          identifier: 'mom@example.com',
          name: 'Mom',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user15',
          identifier: 'dad@example.com',
          name: 'Dad',
          status: MemberStatus.joined,
        ),
        CircleMember(
          id: 'user16',
          identifier: 'sister@example.com',
          name: 'Sister',
          status: MemberStatus.joined,
        ),
      ],
      meetingFrequency: 'Weekly',
    ),
  ];
} 