import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_model.dart';
import '../widgets/circle_card.dart';
import '../widgets/empty_circles_state.dart';
import '../../../../core/theme/app_theme.dart';

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
    
    return Scaffold(
      // Subtle gradient background
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            // App Logo/Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Title with refined typography
            Text(
              'Your Circles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Search button with improved styling
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                // Implement search functionality
              },
            ),
          ),
          // Filter button with improved styling
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                // Implement filter functionality
              },
            ),
          ),
          // Demo toggle button with improved styling
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _showEmptyState 
                  ? theme.colorScheme.destructive.withOpacity(0.1)
                  : theme.colorScheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _showEmptyState ? Icons.visibility_off : Icons.visibility,
                color: _showEmptyState 
                    ? theme.colorScheme.destructive 
                    : theme.colorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showEmptyState = !_showEmptyState;
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.accent.withOpacity(0.05),
                ],
              ),
            ),
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
          
          // Main content
          SafeArea(
            child: _showEmptyState || _circles.isEmpty
                ? EmptyCirclesState(
                    onCreateCircle: _handleCreateCircle,
                  )
                : _animationController == null
                    ? const Center(child: CircularProgressIndicator())
                    : AnimatedBuilder(
                        animation: _animationController!,
                        builder: (context, child) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 12, bottom: 96),
                            itemCount: _circles.length,
                            itemBuilder: (context, index) {
                              // Staggered animation effect
                              final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _animationController!,
                                  curve: Interval(
                                    (index * 0.1).clamp(0.0, 0.9),
                                    ((index + 1) * 0.1).clamp(0.1, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );
                              
                              final circle = _circles[index];
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: animation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - animation.value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: CircleCard(
                                  circle: circle,
                                  onTap: () => _handleCircleTap(circle),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
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
    // Haptic feedback for better tactile response
    HapticFeedback.lightImpact();
    
    // Navigate to circle details screen
    print('Tapped on circle: ${circle.name}');
    
    // Show a toast for demo purposes
    final theme = ShadTheme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(
              'Opening ${circle.name}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleCreateCircle() {
    // Haptic feedback for better tactile response
    HapticFeedback.mediumImpact();
    
    final theme = ShadTheme.of(context);
    
    // Show dialog or navigate to create circle screen
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(
          'Create New Circle',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        description: Text(
          'Start a new social circle to connect and plan events with your friends, family, or colleagues.',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ShadButton(
            child: const Text('Create'),
            onPressed: () {
              Navigator.of(context).pop();
              // Handle create action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: theme.colorScheme.primary,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'New circle would be created here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 