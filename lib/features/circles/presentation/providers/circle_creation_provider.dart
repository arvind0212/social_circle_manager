import 'package:flutter/material.dart';
import '../../domain/models/circle_creation_model.dart';

/// Provider for managing the circle creation process
class CircleCreationProvider extends ChangeNotifier {
  // Current circle creation data
  final CircleCreationData _data = CircleCreationData();
  
  // Current step in the creation process
  int _currentStep = 0;
  
  // Loading state for async operations
  bool _isLoading = false;
  
  // Getters
  CircleCreationData get data => _data;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  
  // Setter for loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
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
    _isLoading = false; // Reset loading state as well
    notifyListeners();
  }
  
  // Validation method (renamed and adapted from canProceedToNextStep)
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic details
        return _data.isStep1Valid(); // Assuming this method exists in CircleCreationData
      case 1: // Members - Assuming members are optional or validated within their own form part
        return true; 
      case 2: // Preferences
        return _data.isStep3Valid(); // Assuming this method exists in CircleCreationData
      default:
        return false;
    }
  }

  // Method to get data for circle creation
  Map<String, dynamic> getCircleCreationData() {
    // Assuming CircleCreationData has a toMap() method that prepares data for Supabase
    // This map should include keys like 'name', 'description', 'image_url', etc.
    // as expected by your 'circles' table and CircleService.createCircle.
    return _data.toMap(); 
  }

  // Deprecated: canProceedToNextStep, replaced by validateCurrentStep
  // bool canProceedToNextStep() {
  //   switch (_currentStep) {
  //     case 0: // Basic details
  //       return _data.isStep1Valid();
  //     case 1: // Members
  //       return true; // Members are optional initially
  //     case 2: // Preferences
  //       return _data.isStep3Valid();
  //     default:
  //       return false;
  //   }
  // }
} 