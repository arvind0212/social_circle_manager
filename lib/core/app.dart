import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';

class SocialCircleApp extends StatelessWidget {
  const SocialCircleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Use the standard ShadApp.material approach
    return ShadApp.material(
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadBlueColorScheme.light(), // Use predefined color scheme
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadBlueColorScheme.dark(), // Use predefined color scheme
      ),
    );
  }
} 