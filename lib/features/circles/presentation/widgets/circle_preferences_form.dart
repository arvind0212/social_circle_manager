import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_creation_model.dart';
import '../providers/circle_creation_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// Form for setting circle preferences (Step 3)
class CirclePreferencesForm extends StatefulWidget {
  const CirclePreferencesForm({Key? key}) : super(key: key);

  @override
  State<CirclePreferencesForm> createState() => _CirclePreferencesFormState();
}

class _CirclePreferencesFormState extends State<CirclePreferencesForm> {
  // Maps for preferred days and times
  final Map<WeekDay, String> _weekdayNames = {
    WeekDay.monday: 'Monday',
    WeekDay.tuesday: 'Tuesday',
    WeekDay.wednesday: 'Wednesday',
    WeekDay.thursday: 'Thursday',
    WeekDay.friday: 'Friday',
    WeekDay.saturday: 'Saturday',
    WeekDay.sunday: 'Sunday',
  };
  
  final Map<TimeOfDayPreference, String> _timeNames = {
    TimeOfDayPreference.morning: 'Morning',
    TimeOfDayPreference.afternoon: 'Afternoon',
    TimeOfDayPreference.evening: 'Evening',
    TimeOfDayPreference.night: 'Night',
  };
  
  final Map<FrequencyPreference, String> _frequencyNames = {
    FrequencyPreference.weekly: 'Weekly',
    FrequencyPreference.biweekly: 'Bi-weekly',
    FrequencyPreference.monthly: 'Monthly',
    FrequencyPreference.quarterly: 'Quarterly',
    FrequencyPreference.custom: 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI recommendation explanation
          _buildRecommendationExplanation(),
          
          const SizedBox(height: 24),
          
          // Interest categories
          _buildInterestCategoriesSection(),
          
          const SizedBox(height: 24),
          
          // Frequency preferences
          _buildFrequencyPreferences(),
          
          const SizedBox(height: 24),
          
          // Time preferences
          _buildTimePreferences(),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationExplanation() {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeProvider.secondaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeProvider.secondaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeProvider.secondaryPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 20,
              color: ThemeProvider.secondaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select interests to help us generate personalized event recommendations for your circle.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }
  
  Widget _buildInterestCategoriesSection() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context);
    final categories = InterestCategory.getAllCategories();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Circle Interests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
            Text(
              'Selected: ${provider.data.selectedInterests.length}',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select interests that match your circle\'s activities',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = provider.data.selectedInterests.contains(category.id);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                provider.toggleInterest(category.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.card,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 28,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.foreground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: (50 * index).ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: (50 * index).ms, curve: Curves.easeOutCubic);
          },
        ),
      ],
    );
  }
  
  Widget _buildFrequencyPreferences() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Meetup Frequency',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How often does this circle typically meet?',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.border,
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(
              _frequencyNames.length,
              (index) {
                final frequency = _frequencyNames.keys.elementAt(index);
                final name = _frequencyNames[frequency]!;
                final isSelected = provider.data.frequencyPreference == frequency;
                
                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  leading: Radio<FrequencyPreference>(
                    value: frequency,
                    groupValue: provider.data.frequencyPreference,
                    onChanged: (FrequencyPreference? value) {
                      if (value != null) {
                        provider.updateFrequencyPreference(value);
                      }
                    },
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return theme.colorScheme.primary;
                      }
                      return theme.colorScheme.mutedForeground;
                    }),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.updateFrequencyPreference(frequency);
                  },
                );
              },
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }
  
  Widget _buildTimePreferences() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Days & Times',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'When does your circle prefer to meet?',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        
        // Preferred days
        Text(
          'Preferred Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekdayNames.entries.map((entry) {
            final day = entry.key;
            final name = entry.value;
            final isSelected = provider.data.preferredDays.contains(day);
            
            return FilterChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                provider.togglePreferredDay(day);
              },
              backgroundColor: theme.colorScheme.card,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Preferred times of day
        Text(
          'Preferred Times',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeNames.entries.map((entry) {
            final time = entry.key;
            final name = entry.value;
            final isSelected = provider.data.preferredTimes.contains(time);
            
            return FilterChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                provider.togglePreferredTime(time);
              },
              backgroundColor: theme.colorScheme.card,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }
} 