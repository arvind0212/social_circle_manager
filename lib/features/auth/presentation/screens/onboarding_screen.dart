import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Social Circle Manager',
      description: 'Simplify organizing social events by intelligently connecting friends, understanding preferences, and streamlining planning.',
      icon: Icons.people_alt_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF7B1FA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      title: 'Create Your Circles',
      description: 'Organize friends into social circles based on interests, relationships, or any way you prefer.',
      icon: Icons.bubble_chart_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFF7B1FA2), Color(0xFFE07A5F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      title: 'Plan Events Effortlessly',
      description: 'Our AI helps suggest events that work for everyone based on preferences, schedules, and past gatherings.',
      icon: Icons.event_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFFE07A5F), Color(0xFF4A90E2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      title: 'Stay Connected',
      description: 'Chat with your circles, split bills, and keep all event details in one place.',
      icon: Icons.chat_bubble_outline,
      gradient: const LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFFE07A5F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _pages[_currentPage].gradient.colors[0].withOpacity(0.1),
                  _pages[_currentPage].gradient.colors[1].withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildDecorativeElement(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                _buildPageIndicator(),
                _buildBottomButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElement() {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _pages[_currentPage].gradient,
                boxShadow: [
                  BoxShadow(
                    color: _pages[_currentPage].gradient.colors[0].withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
          ),
          Positioned(
            right: -10,
            top: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _pages[_currentPage].gradient.colors[1],
                    _pages[_currentPage].gradient.colors[0],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _pages[_currentPage].gradient.colors[1].withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: 0,
                end: 15,
                duration: 2.5.seconds,
                curve: Curves.easeInOut,
              )
              .then()
              .moveY(
                begin: 15,
                end: 0,
                duration: 2.5.seconds,
                curve: Curves.easeInOut,
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 80,
            color: page.gradient.colors[0],
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? _pages[_currentPage].gradient.colors[0]
                : Colors.grey.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Add method to skip straight to home
  void _navigateDirectlyToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShadButton.ghost(
                onPressed: () {
                  // Skip to login screen
                  _navigateToLogin();
                },
                child: const Text('Skip'),
              ),
              ShadButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Navigate to login screen after last page
                    _navigateToLogin();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currentPage < _pages.length - 1 ? 'Next' : 'Get Started'),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

// Extension to scale gradient colors
extension GradientExtension on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(factor)).toList(),
      begin: begin,
      end: end,
    );
  }
} 
