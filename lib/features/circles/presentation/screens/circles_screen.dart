import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_model.dart';
import '../../data/circle_service.dart';
import '../widgets/circle_card.dart';
import '../widgets/empty_circles_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/create_circle_dialog.dart';
import '../screens/circle_detail_screen.dart';

class CirclesScreen extends StatefulWidget {
  const CirclesScreen({Key? key}) : super(key: key);

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen> with SingleTickerProviderStateMixin {
  final CircleService _circleService = CircleService();
  List<Circle> _circles = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  AnimationController? _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fetchCircles();
  }

  Future<void> _fetchCircles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final circles = await _circleService.getCircles();
      if (mounted) {
        setState(() {
          _circles = circles;
          _isLoading = false;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _animationController != null) {
            _animationController!.forward();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _handleCreateCircle() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateCircleDialog();
      },
    ).then((newCircleCreated) {
        if (newCircleCreated == true) {
            _fetchCircles();
        }
    });
  }

  void _handleCircleTap(Circle circle) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CircleDetailScreen(circle: circle)),
    ).then((_) => _fetchCircles());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final width = MediaQuery.of(context).size.width;
    final hPadding = width < 600 ? 12.0 : 20.0;
    
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading circles:', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: theme.textTheme.muted, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ShadButton.outline(
                child: const Text('Retry'),
                onPressed: _fetchCircles,
              ),
            ],
          ),
        ),
      );
    } else if (_circles.isEmpty) {
      content = EmptyCirclesState(onCreateCircle: _handleCreateCircle);
    } else {
      content = GridView.builder(
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
          ).animate(controller: _animationController, delay: (80 * index).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack);
        },
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: null,
      body: Stack(
        children: [
          Container(
            color: theme.colorScheme.background,
          ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPadding, statusBarHeight + 16, hPadding, 16),
              child: Row(
                children: [
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
          ).animate(controller: _animationController).fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
          Positioned.fill(
            top: statusBarHeight + 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: content,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isLoading || _circles.isEmpty
          ? null
          : Container(
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
            ),
    );
  }
} 