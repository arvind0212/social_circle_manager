import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/circles/domain/models/circle_model.dart';
import 'features/circles/domain/models/circle_creation_model.dart';
import 'features/circles/presentation/screens/circle_detail_screen.dart';
import 'features/events/data/services/event_service.dart';

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
  
  // Supabase initialization
  try {
    await Supabase.initialize(
      url: 'https://qerogpoernbdhruodqpz.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlcm9ncG9lcm5iZGhydW9kcXB6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY2MzMwMTMsImV4cCI6MjA2MjIwOTAxM30.ISxYZjG9W8ruNeM_ut2zmDrv_wQwgJHKPxcGSwmKP70',
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        // Add providers here as needed
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide SupabaseClient instance
        Provider<SupabaseClient>(create: (_) => Supabase.instance.client),
        // Provide EventService, which depends on SupabaseClient
        ProxyProvider<SupabaseClient, EventService>(
          update: (context, supabaseClient, previousEventService) => 
              EventService(supabaseClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
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