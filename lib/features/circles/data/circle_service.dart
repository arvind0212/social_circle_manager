import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/circle_model.dart'; // Adjust path as needed

class CircleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetches a list of circles the current user is a joined member of, with details and member count
  Future<List<Circle>> getCircles() async {
    print('[CircleService] Attempting to fetch circles for user via RPC get_circles_for_user_with_details...'); 
    try {
      final response = await _supabase.rpc('get_circles_for_user_with_details');

      if (response == null) {
        print('[CircleService] RPC response is null.');
        return []; // Return empty list if response is null
      }

      if (response is! List) {
        print('[CircleService] Error: Unexpected RPC response type. Expected List, got ${response.runtimeType}');
        print('[CircleService] Raw RPC response: $response');
        throw Exception('Failed to load circles: Unexpected data format from RPC.');
      }

      final List<dynamic> data = response;
      List<Circle> circles = [];
      for (var circleData in data) {
        if (circleData is Map<String, dynamic>) {
          final Map<String, dynamic> jsonData = circleData;
          print('[CircleService] Processing raw circle data from RPC: $jsonData'); 
          try {
            // Ensure all required fields by Circle.fromJson are present or handled
            // 'member_count' is now directly available from the RPC.
            // 'user_profiles:admin_id' equivalent needs to be handled if Circle.fromJson expects it for admin details.
            // The RPC currently returns admin_id as a direct UUID.
            // If Circle.fromJson expects admin_id to be a map {id: uuid, ...}, we might need to adjust.
            // For now, assuming Circle.fromJson can handle this or doesn't strictly need full admin profile for card view.
            // If it crashes, this is a point to check.
            // One quick adaptation if Circle.fromJson *needs* admin_id as a map for the card:
            // if (jsonData.containsKey('admin_id') && jsonData['admin_id'] is String) {
            //   jsonData['user_profiles'] = {'id': jsonData['admin_id']}; // Mocking the structure CircleCard might expect for admin via user_profiles
            // }
            // However, the RPC currently provides admin_id directly. Let's see if Circle.fromJson handles it.

            circles.add(Circle.fromJson(jsonData));
          } catch (e, s) {
            print('[CircleService] Error parsing circle data from RPC for item: $jsonData'); 
            print('[CircleService] Parsing error: $e');
            print('[CircleService] Stacktrace: $s');
            // Optionally skip this item or rethrow, for now, skipping
          }
        } else {
          print('[CircleService] Warning: Found non-map item in RPC response list: $circleData');
        }
      }

      print('[CircleService] Successfully parsed ${circles.length} circles from RPC.'); 
      return circles;
    } on PostgrestException catch (e) {
      print('[CircleService] Error fetching circles via RPC (PostgrestException): ${e.message}'); 
      print('[CircleService] Postgrest details: Code=${e.code}, Details=${e.details}, Hint=${e.hint}');
      throw Exception('Failed to load circles (RPC Error): ${e.message}');
    } catch (e, s) {
      print('[CircleService] Unexpected error fetching circles via RPC: $e'); 
      print('[CircleService] Stacktrace: $s');
      throw Exception('An unexpected error occurred (RPC): $e');
    }
  }

  // Fetches a single circle with full details
  Future<Circle> getCircleById(String id) async {
    print('[CircleService] Attempting to fetch circle details for ID: $id'); // DEBUG
    try {
      final response = await _supabase
        .from('circles')
        .select('''
          id,
          name,
          description,
          image_url,
          created_at,
          updated_at,
          admin_id,
          meeting_frequency,
          common_activities,
          last_activity,
          user_profiles:admin_id (id, full_name, avatar_url), 
          circle_members (*, user_profiles:user_id (id, email, full_name, avatar_url, updated_at)),
          circle_interests (*, interests (id, name, category)),
          events (*, event_attendees (*, user_profiles:user_id(id, full_name, avatar_url)))
        ''')
        .eq('id', id)
        .single(); // Use .single() to get one record or throw error

      // Convert the dynamic response to a String for printing, then parse as JSON
      // This helps in visualizing the exact structure received from Supabase.
      final String rawResponseString = response.toString();
      print('[CircleService] Raw detail response STRING: $rawResponseString'); // DEBUG

      // The response should already be a Map<String, dynamic> if .single() is used and a record is found.
      // If it's not, there might be an issue with how Supabase client handles .single() or if no record is returned.
      if (response is! Map<String, dynamic>) {
        print('[CircleService] ERROR: Unexpected response type. Expected Map<String, dynamic>, got ${response.runtimeType}');
        throw Exception('Unexpected data format from Supabase for circle details.');
      }
      
      final Map<String, dynamic> jsonData = response as Map<String, dynamic>;
      print('[CircleService] Parsed RAW JSON for circle details: $jsonData'); // EXTENDED DEBUG

      // Manually adjust for member_count (though we get full list now)
      if (jsonData['circle_members'] is List) {
        jsonData['member_count'] = (jsonData['circle_members'] as List).length;
         print('[CircleService] Calculated member_count: ${jsonData['member_count']}'); // DEBUG
      } else {
        jsonData['member_count'] = 0;
        print('[CircleService] No circle_members list found or not a list, member_count set to 0.'); // DEBUG
      }
      
      // Events need to be filtered into upcoming/past within the model or UI
      // Circle.fromJson currently handles this if 'events' key exists
      
      final circle = Circle.fromJson(jsonData);
      print('[CircleService] Successfully parsed detailed circle: ${circle.name} with ${circle.members?.length ?? 0} members after parsing.'); // DEBUG
      return circle;

    } on PostgrestException catch (e) {
      print('[CircleService] Error fetching circle details (PostgrestException): ${e.message}');
      print('[CircleService] Postgrest details: Code=${e.code}, Details=${e.details}, Hint=${e.hint}');
      if (e.code == 'PGRST116') { // Not found code
        throw Exception('Circle with ID $id not found.');
      } else {
        throw Exception('Failed to load circle details: ${e.message}');
      }
    } catch (e, stacktrace) {
      print('[CircleService] Unexpected error fetching circle details: $e');
      print('[CircleService] Stacktrace: $stacktrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Creates a new circle in Supabase
  Future<Circle> createCircle(Map<String, dynamic> circleData) async {
    print('[CircleService] Attempting to create circle with data: $circleData');
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('[CircleService] Error: User not authenticated.');
        throw Exception('User not authenticated. Cannot create circle.');
      }

      final dataToInsert = {
        ...circleData,
        'admin_id': currentUser.id,
        // 'created_at' and 'updated_at' should be handled by Supabase (e.g. default now())
      };

      // Ensure essential fields are present if your table requires them
      // For example, if 'name' is NOT NULL:
      if (dataToInsert['name'] == null || (dataToInsert['name'] as String).isEmpty) {
        print('[CircleService] Error: Circle name cannot be empty.');
        throw Exception('Circle name cannot be empty.');
      }
      
      // Remove null values to avoid issues with Supabase, unless your DB explicitly allows them
      // and you intend to send them.
      dataToInsert.removeWhere((key, value) => value == null);

      print('[CircleService] Data to insert: $dataToInsert');

      final List<dynamic> response = await _supabase
          .from('circles')
          .insert(dataToInsert)
          .select('id, name, description, image_url, created_at, updated_at, admin_id, meeting_frequency, common_activities, last_activity, user_profiles:admin_id (id, full_name, avatar_url)'); // Select the full circle data including admin profile

      if (response.isEmpty) {
        print('[CircleService] Error: Failed to create circle, no data returned.');
        throw Exception('Failed to create circle, no data returned.');
      }
      
      final newCircleData = response.first as Map<String, dynamic>;
      print('[CircleService] Successfully created circle. Raw response: $newCircleData');
      
      // Add a placeholder for member_count as it's not directly available from insert.
      // The getCircles or getCircleById methods should provide this accurately later.
      newCircleData['member_count'] = 1; // Admin is the first member

      // Placeholder for other nested structures if Circle.fromJson expects them and they are not in the SELECT
      newCircleData.putIfAbsent('circle_members', () => []);
      newCircleData.putIfAbsent('circle_interests', () => []);
      newCircleData.putIfAbsent('events', () => []);
      
      return Circle.fromJson(newCircleData);

    } on PostgrestException catch (e) {
      print('[CircleService] Error creating circle (PostgrestException): ${e.message}');
      print('[CircleService] Postgrest details: Code=${e.code}, Details=${e.details}, Hint=${e.hint}');
      throw Exception('Failed to create circle: ${e.message}');
    } catch (e, s) {
      print('[CircleService] Unexpected error creating circle: $e');
      print('[CircleService] Stacktrace: $s');
      throw Exception('An unexpected error occurred while creating the circle: $e');
    }
  }

  // TODO: Add methods for:
  // - updateCircle(Circle circleData)
  // - deleteCircle(String id)
  // - etc.
} 