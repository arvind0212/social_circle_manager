import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared_components/navigation/bottom_nav_bar.dart';
import '../../../circles/presentation/screens/circles_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

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
      const ExploreScreen(),
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
    // Get the status bar height to avoid positioning issues with animations
    // final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ).animate().fadeIn(duration: 300.ms),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
} 