import 'package:flutter/material.dart';
import '../../domain/models/circle_creation_model.dart';

/// Provider for managing the circle creation process
class CircleCreationProvider extends ChangeNotifier {
  // Current circle creation data
  final CircleCreationData _data = CircleCreationData();
  
  // Current step in the creation process
  int _currentStep = 0;
  
  // Getters
  CircleCreationData get data => _data;
  int get currentStep => _currentStep;
  
  // Step management
  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }
  
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }
  
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  // Data update methods
  void updateBasicDetails({
    String? name,
    String? description,
    IconData? selectedIcon,
    dynamic customIconImage,
    bool? isUsingCustomImage,
  }) {
    if (name != null) _data.name = name;
    if (description != null) _data.description = description;
    if (selectedIcon != null) _data.selectedIcon = selectedIcon;
    if (customIconImage != null) _data.customIconImage = customIconImage;
    if (isUsingCustomImage != null) _data.isUsingCustomImage = isUsingCustomImage;
    
    notifyListeners();
  }
  
  void addMember(CircleMember member) {
    _data.members.add(member);
    notifyListeners();
  }
  
  void removeMember(String memberId) {
    _data.members.removeWhere((member) => member.id == memberId);
    notifyListeners();
  }
  
  void toggleInterest(String interestId) {
    if (_data.selectedInterests.contains(interestId)) {
      _data.selectedInterests.remove(interestId);
    } else {
      _data.selectedInterests.add(interestId);
    }
    notifyListeners();
  }
  
  void updateFrequencyPreference(FrequencyPreference preference) {
    _data.frequencyPreference = preference;
    notifyListeners();
  }
  
  void togglePreferredDay(WeekDay day) {
    if (_data.preferredDays.contains(day)) {
      _data.preferredDays.remove(day);
    } else {
      _data.preferredDays.add(day);
    }
    notifyListeners();
  }
  
  void togglePreferredTime(TimeOfDayPreference time) {
    if (_data.preferredTimes.contains(time)) {
      _data.preferredTimes.remove(time);
    } else {
      _data.preferredTimes.add(time);
    }
    notifyListeners();
  }
  
  // Reset all data
  void reset() {
    _data.reset();
    _currentStep = 0;
    notifyListeners();
  }
  
  // Validation methods
  bool canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Basic details
        return _data.isStep1Valid();
      case 1: // Members
        return true; // Members are optional initially
      case 2: // Preferences
        return _data.isStep3Valid();
      default:
        return false;
    }
  }
} 