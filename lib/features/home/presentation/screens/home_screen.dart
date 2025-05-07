import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_components/navigation/bottom_nav_bar.dart';
import '../../../circles/presentation/screens/circles_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../main.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Initialize screens lazily to avoid circular dependencies during initialization
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const CirclesScreen(),
      const EventsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removing AppBar completely
      body: SafeArea(
        // Remove extra padding at the top
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ).animate().fadeIn(duration: 300.ms),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
