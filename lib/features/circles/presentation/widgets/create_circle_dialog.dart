import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_creation_model.dart';
import '../providers/circle_creation_provider.dart';
import 'circle_details_form.dart';
import 'circle_members_form.dart';
import 'circle_preferences_form.dart';
import '../../../../core/theme/app_theme.dart';

/// A multi-step dialog for creating a new circle
class CreateCircleDialog extends StatefulWidget {
  const CreateCircleDialog({Key? key}) : super(key: key);

  @override
  State<CreateCircleDialog> createState() => _CreateCircleDialogState();
}

class _CreateCircleDialogState extends State<CreateCircleDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CircleCreationProvider _provider;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _animationController.forward();
    
    // Initialize the provider
    _provider = CircleCreationProvider();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CircleCreationProvider>(
        builder: (context, provider, _) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _animationController,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOutQuint,
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: ShadCard(
                        width: MediaQuery.of(context).size.width > 600 
                            ? 600 
                            : MediaQuery.of(context).size.width - 40,
                        height: MediaQuery.of(context).size.height * 0.85,
                        padding: EdgeInsets.zero,
                        backgroundColor: ShadTheme.of(context).colorScheme.background,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(context, provider),
                            _buildStepIndicator(context, provider),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: provider.currentStep > _getKeyValue(child) 
                                              ? const Offset(-0.1, 0) 
                                              : const Offset(0.1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _getStepContent(provider.currentStep),
                                ),
                              ),
                            ),
                            _buildFooter(context, provider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  // Helper to get a unique key value from the child widget for animation direction
  int _getKeyValue(Widget child) {
    if (child.key is ValueKey) {
      final ValueKey valueKey = child.key as ValueKey;
      if (valueKey.value is int) {
        return valueKey.value as int;
      }
    }
    return 0;
  }
  
  Widget _buildHeader(BuildContext context, CircleCreationProvider provider) {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Circle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepDescription(provider.currentStep),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.mutedForeground,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepIndicator(BuildContext context, CircleCreationProvider provider) {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = provider.currentStep == index;
          final isPast = provider.currentStep > index;
          
          return Row(
            children: [
              if (index > 0)
                Container(
                  width: 24,
                  height: 1,
                  color: isPast || provider.currentStep == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border,
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isActive ? 12 : 8,
                height: isActive ? 12 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primary
                      : isPast
                          ? theme.colorScheme.primary
                          : theme.colorScheme.border,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 24,
                  height: 1,
                  color: isPast
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border,
                ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return CircleDetailsForm(key: const ValueKey(0));
      case 1:
        return CircleMembersForm(key: const ValueKey(1));
      case 2:
        return CirclePreferencesForm(key: const ValueKey(2));
      default:
        return const SizedBox(key: ValueKey(0));
    }
  }
  
  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Basic circle details';
      case 1:
        return 'Add members';
      case 2:
        return 'Set circle preferences';
      default:
        return '';
    }
  }
  
  Widget _buildFooter(BuildContext context, CircleCreationProvider provider) {
    final theme = ShadTheme.of(context);
    final bool canProceed = provider.canProceedToNextStep();
    final bool isLastStep = provider.currentStep == 2;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          provider.currentStep > 0
              ? ShadButton.outline(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.previousStep();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Back'),
                    ],
                  ),
                )
              : const SizedBox(width: 100),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ShadButton(
              onPressed: canProceed
                  ? () {
                      HapticFeedback.mediumImpact();
                      if (isLastStep) {
                        _handleCreateCircle(context);
                      } else {
                        provider.nextStep();
                      }
                    }
                  : null,
              gradient: canProceed ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  Color.lerp(theme.colorScheme.primary, ThemeProvider.secondaryPurple, 0.4)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: canProceed ? 1.0 : 0.5,
                    child: Text(
                      isLastStep ? 'Create Circle' : 'Next',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastStep ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleCreateCircle(BuildContext context) {
    // In a real app, this would call a service to create the circle
    final theme = ShadTheme.of(context);
    final circleData = _provider.data;
    
    // Close the dialog
    Navigator.of(context).pop();
    
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Circle "${circleData.name}" created successfully!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 