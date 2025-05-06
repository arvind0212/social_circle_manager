import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_model.dart';
import '../widgets/circle_card.dart';
import '../widgets/empty_circles_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/create_circle_dialog.dart';
import '../screens/circle_detail_screen.dart';
import '../../../../main.dart';

class CirclesScreen extends StatefulWidget {
  const CirclesScreen({Key? key}) : super(key: key);

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen> with SingleTickerProviderStateMixin {
  // For demo purposes, we'll use sample data
  // In a real app, this would come from a repository or API
  final List<Circle> _circles = Circle.sampleCircles;
  
  // For demo purposes, we can toggle between empty and populated states
  bool _showEmptyState = false;
  
  // Animation controller for page transitions - initialize directly instead of using late
  AnimationController? _animationController;
  
  @override
  void initState() {
    super.initState();
    // Initialize the controller after super.initState()
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Add a small delay before starting the animation
    // This prevents errors when hot reloading
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _animationController != null) {
        _animationController!.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    // Calculate horizontal padding like Events screen
    final width = MediaQuery.of(context).size.width;
    final hPadding = width < 600 ? 12.0 : 20.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      // Remove the standard AppBar and replace with a custom header
      appBar: null,
      body: Stack(
        children: [
          // White background with light blue hint
          Container(
            color: theme.colorScheme.background,
          ),
          
          // Decorative pattern element
          Positioned(
            top: -screenHeight * 0.1,
            right: -screenHeight * 0.1,
            child: Container(
              width: screenHeight * 0.4,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.03),
              ),
            ),
          ),
          
          // Custom header area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPadding, statusBarHeight + 16, hPadding, 16),
              child: Row(
                children: [
                  // App Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: ThemeProvider.primaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title with refined typography
                  Text(
                    'Circles',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.foreground,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.search_rounded, size: 22),
                      color: theme.colorScheme.foreground,
                      onPressed: () => HapticFeedback.lightImpact(),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
          
          // Main content positioned below header
          Positioned.fill(
            top: statusBarHeight + 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: _showEmptyState || _circles.isEmpty
                ? EmptyCirclesState(onCreateCircle: _handleCreateCircle)
                : _animationController == null
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(hPadding, 12.0, hPadding, 12.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _circles.length,
                        itemBuilder: (context, index) {
                          final circle = _circles[index];
                          return CircleCard(
                            circle: circle,
                            onTap: () => _handleCircleTap(circle),
                          ).animate(delay: (80 * index).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: !_showEmptyState && _circles.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.3)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: FloatingActionButton(
                heroTag: null,
                elevation: 0,
                backgroundColor: Colors.transparent,
                onPressed: _handleCreateCircle,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
          : null,
    );
  }

  void _handleCircleTap(Circle circle) {
    print('DEBUG: _handleCircleTap entered for ${circle.name}');
    // Haptic feedback for better tactile response
    HapticFeedback.lightImpact();

    // Navigate to circle details screen, passing the selected circle
    print('DEBUG: Attempting Navigator.push...');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CircleDetailScreen(circle: circle),
      ),
    );
    print('DEBUG: Navigator.push executed.');
  }

  void _handleCreateCircle() {
    // Haptic feedback for better tactile response
    HapticFeedback.mediumImpact();
    
    // Show the multi-step create circle dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Theme(
        data: Theme.of(context),
        child: const CreateCircleDialog(),
      ),
    );
  }
} 