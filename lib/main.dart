import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/circles/domain/models/circle_model.dart';
import 'features/circles/domain/models/circle_creation_model.dart';
import 'features/circles/presentation/screens/circle_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization - disabled for now
  // try {
  //   await Firebase.initializeApp(
  //     // options: FirebaseOptions(...),
  //   );
  //   print('Firebase initialized successfully');
  // } catch (e) {
  //   print('Firebase initialization skipped: $e');
  // }

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Supabase initialization - disabled for now
  try {
    await Supabase.initialize(
      url: '${dotenv.env['SUPABASE_URL']}',
      anonKey: '${dotenv.env['SUPABASE_ANON_KEY']}',
    );
    if (kDebugMode) {
      print('Supabase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Supabase initialization skipped: $e');
    }
  }

  Circle? fetchedCircle = await getCircleFromSupabase(1);
  if (fetchedCircle != null) {
    Circle.sampleCircles.insert(0, fetchedCircle);
  } else {
    print("Failed to fetch circle data from Supabase");
  }

  runApp(
    MultiProvider(
      providers: [
        // Add providers here as needed
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<Circle?> getCircleFromSupabase(int circleId) async {
  // Fetch circle data from Supabase
  final circleLookup = await Supabase.instance.client
      .from('circles')
      .select()
      .eq('id', circleId)
      .single();

  final membersLookup = await Supabase.instance.client
      .from('circle_members')
      .select()
      .eq('circle_id', circleId);

  final List<CircleMember> circleMembers = [];

  for (var memberLookup in membersLookup) {
    final userId = memberLookup['user_id'] as int;
    final member = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    var identifier =
        (member['email'] as String?) ?? (member['phone'] as String?);

    if (identifier == null) {
      identifier = "UNKNOWN";
      continue;
    }

    const membershipStatus = MemberStatus.joined; // Default to joined for now

    final CircleMember circleMember = CircleMember(
        id: (member['id'] as int).toString(),
        name: member['display_name'] as String,
        photoUrl: member['avatar_url'] as String?,
        identifier: identifier,
        status: membershipStatus);

    circleMembers.add(circleMember);
  }

  final events = await Supabase.instance.client
      .from('events')
      .select()
      .eq('circle_id', circleId);

  final List<Event> pastEvents = [];
  final List<Event> upcomingEvents = [];

  for (var event in events) {
    final eventId = event['event_id'] as int;
    final attendees =
        circleMembers.length; // Assuming all members are attendees for now

    final circleEvent = Event(
      id: eventId.toString(),
      title: event['title'] as String,
      description: event['description'] as String,
      dateTime: DateTime.parse(event['start_time'] as String),
      location: event['location'] as String,
      attendees: attendees,
    );

    if (circleEvent.dateTime.isBefore(DateTime.now())) {
      pastEvents.add(circleEvent);
    } else {
      upcomingEvents.add(circleEvent);
    }
  }

  Event? lastEvent;
  for (var event in pastEvents) {
    if (lastEvent == null || event.dateTime.isAfter(lastEvent.dateTime)) {
      lastEvent = event;
    }
  }

  String lastActivityMessage;
  if (lastEvent != null) {
    final dateformat = DateFormat("EEEE, MMM d, yyyy");
    lastActivityMessage =
        "${lastEvent.title} on ${dateformat.format(lastEvent.dateTime.toLocal())}";
  } else {
    lastActivityMessage = "No activities yet";
  }

  // Find admin
  final admin = membersLookup.firstWhere(
      (member) => (member['role'] == "admin" || member['role'] == "creator"),
      orElse: () => {
            'user_id': null,
            'role': 'none',
          });

  final List<String> interests = []; // TODO: Fetch interests from Supabase
  final List<String> commonActivities =
      []; // TODO: Fetch common activities from Supabase

  // Compute meeting frequency
  // Weekly, Bi-weekly, Monthly, etc.
  const meetingFrequency = "Weekly"; // Default to weekly for now

  final Circle circle = Circle(
    id: (circleLookup['id'] as int).toString(),
    name: circleLookup['name'] as String,
    memberCount: membersLookup.length,
    description: circleLookup['description'] as String,
    imageUrl: circleLookup['icon_url'] as String?,
    lastActivity: lastActivityMessage,
    createdDate: DateTime.parse(circleLookup['created_at'] as String),
    adminId: admin['user_id'].toString(),
    interests: interests,
    commonActivities: commonActivities,
    upcomingEvents: upcomingEvents,
    pastEvents: pastEvents,
    members: circleMembers,
    meetingFrequency: meetingFrequency,
  );
  return circle;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode from the provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Use the standard ShadApp.material approach with sonner for toast notifications
    return ShadApp.material(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadColorScheme(
          primary: ThemeProvider.primaryBlue,
          primaryForeground: Colors.white,
          secondary: ThemeProvider.secondaryPurple,
          secondaryForeground: Colors.white,
          destructive: Colors.red.shade700,
          destructiveForeground: Colors.white,
          background: Colors.grey.shade50,
          foreground: Colors.black87,
          card: Colors.white,
          cardForeground: Colors.black87,
          popover: Colors.white,
          popoverForeground: Colors.black87,
          muted: Colors.grey.shade100,
          mutedForeground: Colors.grey.shade700,
          accent: ThemeProvider.primaryBlue.withOpacity(0.2),
          accentForeground: ThemeProvider.primaryBlue,
          border: Colors.grey.shade200,
          input: Colors.grey.shade200,
          ring: ThemeProvider.primaryBlue.withOpacity(0.5),
          selection: ThemeProvider.primaryBlue.withOpacity(0.2),
        ),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadColorScheme(
          primary: ThemeProvider.primaryBlue,
          primaryForeground: Colors.white,
          secondary: ThemeProvider.secondaryPurple,
          secondaryForeground: Colors.white,
          destructive: Colors.red.shade400,
          destructiveForeground: Colors.white,
          background: const Color(0xFF121212),
          foreground: Colors.white,
          card: const Color(0xFF1E1E1E),
          cardForeground: Colors.white,
          popover: const Color(0xFF1E1E1E),
          popoverForeground: Colors.white,
          muted: const Color(0xFF2A2A2A),
          mutedForeground: Colors.grey.shade400,
          accent: ThemeProvider.primaryBlue.withOpacity(0.3),
          accentForeground: Colors.white,
          border: const Color(0xFF333333),
          input: const Color(0xFF333333),
          ring: ThemeProvider.primaryBlue.withOpacity(0.5),
          selection: ThemeProvider.primaryBlue.withOpacity(0.3),
        ),
      ),
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return ShadToaster(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

// Add this function somewhere accessible in your app, like in your main page
void showTestCircleDetail(BuildContext context) {
  // Create a sample circle with mock data
  final testCircle = Circle(
    id: 'test-id',
    name: 'College Friends',
    memberCount: 8,
    description:
        'Friends from university days who meet regularly for various activities and adventures. We share memories, create new ones, and support each other through life\'s journey.',
    imageUrl: null, // Will use initials
    lastActivity: 'Movie night planned 2 days ago',
    createdDate: DateTime.now().subtract(const Duration(days: 120)),
    adminId: 'user1',
    interests: ['Movies', 'Board Games', 'Travel', 'Food', 'Music'],
    commonActivities: [
      'Movie nights',
      'Weekend trips',
      'Game nights',
      'Dinners'
    ],
    upcomingEvents: [
      Event(
        id: 'e1',
        title: 'Summer Reunion',
        description:
            'Annual gathering at the lake house with barbecue, swimming, and catching up',
        dateTime: DateTime.now().add(const Duration(days: 15)),
        location: 'Lake Washington',
        attendees: 6,
      ),
      Event(
        id: 'e2',
        title: 'Movie Night: Inception',
        description:
            'Watching Inception at John\'s place with pizza and drinks',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        location: 'John\'s Apartment',
        attendees: 8,
      ),
      Event(
        id: 'e3',
        title: 'Dinner at Italian Place',
        description: 'Trying out the new Italian restaurant downtown',
        dateTime: DateTime.now().add(const Duration(hours: 5)), // Today
        location: 'Bella Italia Restaurant',
        attendees: 7,
      ),
    ],
    pastEvents: [
      Event(
        id: 'e4',
        title: 'Board Game Night',
        description: 'Played Catan and Ticket to Ride with snacks and drinks',
        dateTime: DateTime.now().subtract(const Duration(days: 12)),
        location: 'Sarah\'s House',
        attendees: 7,
      ),
      Event(
        id: 'e5',
        title: 'Happy Hour',
        description: 'After-finals celebration with cocktails and appetizers',
        dateTime: DateTime.now().subtract(const Duration(days: 45)),
        location: 'The Pub Downtown',
        attendees: 8,
      ),
      Event(
        id: 'e6',
        title: 'Birthday Party for Mike',
        description: 'Celebrated Mike\'s birthday with cake and karaoke',
        dateTime: DateTime.now().subtract(const Duration(days: 60)),
        location: 'Karaoke Bar',
        attendees: 8,
      ),
    ],
    members: [
      CircleMember(
        id: 'user1',
        identifier: 'john@example.com',
        name: 'John Smith',
        photoUrl:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        status: MemberStatus.joined,
      ),
      CircleMember(
        id: 'user2',
        identifier: 'sarah@example.com',
        name: 'Sarah Johnson',
        photoUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
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
        photoUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        status: MemberStatus.joined,
      ),
      CircleMember(
        id: 'user5',
        identifier: 'james@example.com',
        name: 'James Wilson',
        status: MemberStatus.joined,
      ),
      CircleMember(
        id: 'user6',
        identifier: 'alex@example.com',
        name: 'Alex Rodriguez',
        status: MemberStatus.joined,
      ),
      CircleMember(
        id: 'user7',
        identifier: 'sophia@example.com',
        name: 'Sophia Lee',
        photoUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        status: MemberStatus.joined,
      ),
      CircleMember(
        id: 'user8',
        identifier: 'david@example.com',
        name: 'David Kim',
        status: MemberStatus.joined,
      ),
    ],
    meetingFrequency: '2-3 times monthly',
  );

  final testCircle2 = Circle(
    id: 'test-id-2',
    name: 'Book Club',
    memberCount: 5,
    description:
        'A group of book lovers who meet monthly to discuss our latest reads and share recommendations.',
    imageUrl: null, // Will use initials
    lastActivity: 'Next meeting scheduled for next week',
    createdDate: DateTime.now().subtract(const Duration(days: 60)),
    adminId: 'user1',
    interests: ['Books', 'Literature', 'Writing'],
    commonActivities: [
      'Monthly book discussions',
      'Author Q&A sessions',
      'Book swaps'
    ],
    upcomingEvents: [],
    pastEvents: [],
    members: [],
    meetingFrequency: 'Monthly',
  );

  // Navigate to CircleDetailScreen with the test circle
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CircleDetailScreen(circle: testCircle),
    ),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CircleDetailScreen(circle: testCircle2),
    ),
  );
}
