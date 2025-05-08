import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_circle_manager/features/events/domain/models/event.dart';

class EventService {
  final SupabaseClient _supabaseClient;

  EventService(this._supabaseClient);

  Future<List<Event>> getEvents() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseClient.rpc(
        'get_events_for_user',
        params: {'p_user_id': userId},
      );

      if (response is List) {
        return response.map((item) => Event.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Handle cases where response might not be a list, or is an error structure
        // For now, assume an empty list or rethrow if it's an error object from Supabase
        print('Supabase get_events_for_user RPC unexpected response type: $response');
        // You might want to inspect the response type and content here
        // if (response is Map && response.containsKey('error')) {
        //   throw Exception('Supabase RPC error: ${response['error']}');
        // }
        return [];
      }
    } on PostgrestException catch (e) {
      // Specific Supabase error
      print('Supabase error fetching events: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      print('Code: ${e.code}');
      throw Exception('Failed to load events from Supabase: ${e.message}');
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to load events: $e');
    }
  }

  Future<void> updateRsvpStatus(String eventId, String rsvpStatusEnumValue) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated for RSVP update');
    }

    // Ensure rsvpStatusEnumValue is one of the valid enum values for the database
    // The database enum is rsvp_status_enum ('going', 'not_going', 'maybe')
    if (!['going', 'not_going', 'maybe'].contains(rsvpStatusEnumValue)) {
      throw ArgumentError('Invalid RSVP status: $rsvpStatusEnumValue');
    }

    try {
      await _supabaseClient.from('event_attendees').upsert({
        'event_id': eventId,
        'user_id': userId,
        'rsvp_status': rsvpStatusEnumValue, // This is the primary enum value
        'status': rsvpStatusEnumValue, // Re-enabled: Ensure status text column gets a value
        'updated_at': DateTime.now().toIso8601String(),
      });
      // Note: The `status` column in `event_attendees` might be legacy 
      // if `rsvp_status` (enum) is the primary one now. 
      // If `status` is purely an internal state or different, adjust accordingly.
      // Based on schema, `rsvp_status` is the enum and `status` is text. This upsert will try to set both.
      // If only rsvp_status should be set, remove the 'status' line.

    } on PostgrestException catch (e) {
      print('Supabase error updating RSVP: ${e.message}');
      throw Exception('Failed to update RSVP: ${e.message}');
    } catch (e) {
      print('Error updating RSVP: $e');
      throw Exception('Failed to update RSVP: $e');
    }
  }

  // Placeholder for createEvent - to be implemented later
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    // final response = await _supabaseClient.from('events').insert(eventData).execute();
    // if (response.error != null) {
    //   throw response.error!;
    // }
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    print('Mock createEvent called with: $eventData');
  }

  // You can add other methods here like:
  // Future<Event> getEventById(String eventId) async { ... }
  // Future<void> updateEvent(Event event) async { ... }
  // Future<void> deleteEvent(String eventId) async { ... }
  // Future<void> rsvpToEvent(String eventId, String rsvpStatus) async { ... }
} 