import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart'; // Assuming a provider might be used later for circles

import '../../../../core/theme/app_theme.dart';
import '../../../circles/domain/models/circle_model.dart'; // Assuming Circle model path
import './event_matching_screen.dart'; // Added import

// Mock data for budget options
const List<Map<String, String>> budgetOptions = [
  {'value': 'free', 'label': 'Free'},
  {'value': 'under_20', 'label': '\$ (Under \$20)'},
  {'value': '20_50', 'label': '\$\$ (\$20 - \$50)'},
  {'value': 'over_50', 'label': '\$\$\$ (Over \$50)'},
  {'value': 'flexible', 'label': 'Flexible'},
];

class CreateEventMatchScreen extends StatefulWidget {
  final Circle? preselectedCircle;
  final List<Circle>? availableCircles; // Used if preselectedCircle is null

  const CreateEventMatchScreen({
    Key? key,
    this.preselectedCircle,
    this.availableCircles,
  }) : super(key: key);

  @override
  State<CreateEventMatchScreen> createState() => _CreateEventMatchScreenState();
}

class _CreateEventMatchScreenState extends State<CreateEventMatchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Circle? _selectedCircle;
  String _selectedBudget = budgetOptions.first['value']!;
  final _eventPreferencesController = TextEditingController();
  final _availabilityPreferencesController = TextEditingController();

  final _formKey = GlobalKey<ShadFormState>();

  // Mock list of circles for dropdown if none are provided
  late List<Circle> _circlesForDropdown;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();

    if (widget.preselectedCircle != null) {
      _selectedCircle = widget.preselectedCircle;
    } else if (widget.availableCircles != null && widget.availableCircles!.isNotEmpty) {
      _circlesForDropdown = widget.availableCircles!;
      _selectedCircle = _circlesForDropdown.first;
    } else {
      // Create mock circles if none provided (for standalone testing/initial implementation)
      _circlesForDropdown = [
        Circle(
          id: '1',
          name: 'Tech Innovators San Francisco',
          description: 'A group for tech enthusiasts and professionals in SF.',
          imageUrl: 'https://via.placeholder.com/150/FFA500/FFFFFF?text=TechSF', // Orange
          adminId: 'adminUser1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          memberCount: 150,
          lastActivity: 'New event posted: AI Workshop',
          meetingFrequency: 'Monthly',
        ),
        Circle(
          id: '2',
          name: 'Bay Area Hikers & Adventurers',
          description: 'Exploring the beautiful trails around the Bay Area.',
          imageUrl: 'https://via.placeholder.com/150/228B22/FFFFFF?text=Hikers', // Forest Green
          adminId: 'adminUser2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          memberCount: 230,
          lastActivity: 'Weekend hike to Mt. Tamalpais planned',
          meetingFrequency: 'Bi-weekly',
        ),
        Circle(
          id: '3',
          name: 'Foodies of Oakland Network (FON)',
          description: 'Discovering the best food spots in Oakland.',
          imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=FON', // Red
          adminId: 'adminUser3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          memberCount: 180,
          lastActivity: 'Review of new Ramen shop published',
          meetingFrequency: 'Weekly',
        ),
      ];
      if (_circlesForDropdown.isNotEmpty){
        _selectedCircle = _circlesForDropdown.first;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventPreferencesController.dispose();
    _availabilityPreferencesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    if (_formKey.currentState!.saveAndValidate()) {
      // In a real app, this data would be passed to an LLM or service
      final eventMatchData = {
        'circleId': _selectedCircle?.id,
        'circleName': _selectedCircle?.name,
        'eventPreferences': _eventPreferencesController.text,
        'budget': _selectedBudget,
        'availability': _availabilityPreferencesController.text,
      };
      print('Event Match Data: \$eventMatchData');
      
      // Pop current dialog first
      Navigator.of(context).pop();

      // Navigate to EventMatchingScreen
      if (_selectedCircle != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventMatchingScreen(
              circle: _selectedCircle!,
              eventPreferences: eventMatchData,
            ),
          ),
        );
      } else {
        // Handle case where no circle is selected (should not happen if validation is correct)
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: const Text('Error: No circle selected to find matches for.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }

      // Original SnackBar for suggestions generating is now less relevant here, 
      // as the user is navigated to a new screen.
      // Consider moving a similar loading state to EventMatchingScreen itself.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: ThemeProvider.accentPeach,
      //     margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //     content: const Row(
      //       children: [
      //         Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
      //         SizedBox(width: 12),
      //         Expanded(
      //           child: Text(
      //             'Event suggestions are being generated!',
      //             style: TextStyle(color: Colors.white),
      //           ),
      //         ),
      //       ],
      //     ),
      //     duration: const Duration(seconds: 3),
      //   ),
      // );
    } else {
      print('Form validation failed');
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 550.0 : screenWidth - 40;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animationController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ShadCard(
                  width: dialogWidth,
                  padding: EdgeInsets.zero,
                  backgroundColor: theme.colorScheme.background,
                  child: ShadForm(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(theme),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCircleSelection(theme),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  theme: theme,
                                  controller: _eventPreferencesController,
                                  label: 'Event Preferences',
                                  hint: 'e.g., Casual dinner, weekend hike, board games',
                                  icon: Icons.lightbulb_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please describe your event idea.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildBudgetSelector(theme),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  theme: theme,
                                  controller: _availabilityPreferencesController,
                                  label: 'Availability Preferences',
                                  hint: 'e.g., Next weekend, weekday evenings after 7 PM',
                                  icon: Icons.calendar_today_outlined,
                                   validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please suggest some availability.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                _buildInfoPanel(theme),
                              ],
                            ),
                          ),
                        ),
                        _buildFooter(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: theme.colorScheme.border.withOpacity(0.5)))
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: ThemeProvider.accentPeach, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggest an Event',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Help us find the perfect match for your group!',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ShadButton.ghost(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.mutedForeground,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleSelection(ShadThemeData theme) {
    if (widget.preselectedCircle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For Circle:',
            style: TextStyle(fontSize: 14, color: theme.colorScheme.mutedForeground, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.05),
              borderRadius: theme.radius,
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.preselectedCircle!.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.foreground),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_circlesForDropdown.isEmpty) {
       return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Circle:',
            style: TextStyle(fontSize: 14, color: theme.colorScheme.mutedForeground, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'No circles available. Please create or join a circle first.',
            style: TextStyle(color: theme.colorScheme.destructive, fontSize: 14),
          ),
        ],
      );
    }
    
    return ShadSelectFormField<Circle>(
      id: 'circle-select',
      label: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text('For which Circle?', style: TextStyle(fontSize: 14, color: theme.colorScheme.mutedForeground, fontWeight: FontWeight.w500)),
      ),
      
      initialValue: _selectedCircle,
      onChanged: (Circle? circle) {
        setState(() {
          _selectedCircle = circle;
        });
      },
      options: _circlesForDropdown
          .map((circle) => ShadOption(
                value: circle,
                child: Text(circle.name),
              ))
          .toList(),
      selectedOptionBuilder: (context, value) => Text(value.name),
      placeholder: const Text('Select a circle'),
      validator: (value) {
        if (value == null) {
          return 'Please select a circle.';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required ShadThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.mutedForeground, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ShadInputFormField(
          id: label.toLowerCase().replaceAll(' ', '-'),
          controller: controller,
          placeholder: Text(hint),
          maxLines: 2,
          minLines: 1,
          prefix: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: ThemeProvider.accentPeach.withOpacity(0.7), size: 18),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBudgetSelector(ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget per Person (Optional)',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.mutedForeground, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ShadSelectFormField<String>(
          id: 'budget-select',
          initialValue: _selectedBudget,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedBudget = value;
              });
            }
          },
          options: budgetOptions
              .map((option) => ShadOption(
                    value: option['value']!,
                    child: Text(option['label']!),
                  ))
              .toList(),
          selectedOptionBuilder: (context, value) {
            final selectedLabel = budgetOptions.firstWhere((opt) => opt['value'] == value)['label']!;
            return Text(selectedLabel);
          },
        ),
      ],
    );
  }
  
  Widget _buildInfoPanel(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeProvider.accentPeach.withOpacity(0.05),
        borderRadius: theme.radius,
        border: Border.all(color: ThemeProvider.accentPeach.withOpacity(0.2))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: ThemeProvider.accentPeach, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your preferences help our AI suggest tailored event ideas. The more details you provide, the better the recommendations!',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground.withOpacity(0.9), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
         border: Border(top: BorderSide(color: theme.colorScheme.border.withOpacity(0.5)))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ShadButton.outline(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ShadButton(
            onPressed: _handleSubmit,
            backgroundColor: ThemeProvider.accentPeach,
            foregroundColor: Colors.white,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Suggest Events'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showCreateEventMatchDialog(BuildContext context, {Circle? circle, List<Circle>? availableCircles}) {
  HapticFeedback.mediumImpact();
  showShadDialog(
    context: context,
    builder: (context) => CreateEventMatchScreen(
      preselectedCircle: circle,
      availableCircles: availableCircles,
    ),
    // barrierDismissible: false, // Optional: prevent dismissing by tapping outside
  );
} 