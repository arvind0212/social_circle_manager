import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CalendarIntegrationScreen extends StatelessWidget {
  const CalendarIntegrationScreen({Key? key}) : super(key: key);

  void _connectCalendar(BuildContext context) {
    // TODO: implement calendar permission and integration using device_calendar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calendar integration coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Calendar Integration'),
        backgroundColor: ThemeProvider.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Connect your device calendar to check availability during event planning.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ShadButton(
                  onPressed: () => _connectCalendar(context),
                  child: const Text('Connect Calendar'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
} 