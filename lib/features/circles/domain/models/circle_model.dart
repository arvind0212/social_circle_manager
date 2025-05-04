class Circle {
  final String id;
  final String name;
  final int memberCount;
  final String description;
  final String? imageUrl;
  final String lastActivity;
  
  Circle({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.description,
    this.imageUrl,
    required this.lastActivity,
  });

  // Sample data for prototype
  static List<Circle> sampleCircles = [
    Circle(
      id: '1',
      name: 'College Friends',
      memberCount: 8,
      description: 'Friends from university days',
      imageUrl: null, // We'll use initials for this one
      lastActivity: 'Movie night planned 2 days ago',
    ),
    Circle(
      id: '2',
      name: 'Book Club',
      memberCount: 5,
      description: 'Monthly book discussion group',
      imageUrl: 'https://images.unsplash.com/photo-1535905557558-afc4877a26fc?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'New book selected yesterday',
    ),
    Circle(
      id: '3',
      name: 'Hiking Group',
      memberCount: 12,
      description: 'Weekend warriors exploring trails',
      imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'Mt. Rainier hike scheduled for next weekend',
    ),
    Circle(
      id: '4',
      name: 'Office Happy Hour',
      memberCount: 15,
      description: 'Work colleagues who enjoy happy hours',
      imageUrl: 'https://images.unsplash.com/photo-1516997121675-4c2d1684aa3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80',
      lastActivity: 'Planning next Thursday\'s venue',
    ),
    Circle(
      id: '5',
      name: 'Family',
      memberCount: 6,
      description: 'Immediate family members',
      imageUrl: null,
      lastActivity: 'Mom\'s birthday planning in progress',
    ),
  ];
} 