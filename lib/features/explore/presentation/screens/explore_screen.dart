import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Dining',
    'Activities',
    'Nature',
    'Arts',
    'Games',
    'Fitness'
  ];
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: ThemeProvider.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShadInput(
                controller: _searchController,
                placeholder: const Text('Search activities, venues...'),
                leading: const Icon(Icons.search),
                trailing: ShadButton(
                  onPressed: () {
                    // Filter dialog
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildFilterSheet(),
                    );
                  },
                  child: const Icon(Icons.tune),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeProvider.secondaryPurple.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? ThemeProvider.secondaryPurple
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? ThemeProvider.secondaryPurple
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const _SectionTitle(
                    title: 'AI Recommendations',
                    subtitle: 'Based on your preferences',
                    icon: Icons.auto_awesome,
                    isAI: true,
                  ),
                  const SizedBox(height: 12),
                  _buildAIRecommendations(),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Popular This Week',
                    subtitle: 'Trending activities nearby',
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(height: 12),
                  _buildPopularActivities(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Budget Range',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ShadSelect<String>.multiple(
            placeholder: const Text('Select budget'),
            closeOnSelect: false,
            allowDeselection: true,
            options: const [
              ShadOption(
                value: 'low',
                child: Text('\$'),
              ),
              ShadOption(
                value: 'medium',
                child: Text('\$\$'),
              ),
              ShadOption(
                value: 'high',
                child: Text('\$\$\$'),
              ),
            ],
            selectedOptionsBuilder: (context, values) => Text(values.isEmpty
                ? 'Select budget'
                : values
                    .map((v) => v == 'low'
                        ? '\$'
                        : v == 'medium'
                            ? '\$\$'
                            : '\$\$\$')
                    .join(', ')),
          ),
          const SizedBox(height: 16),
          const Text(
            'Distance',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ShadSelect<String>(
            placeholder: const Text('Select distance'),
            options: const [
              ShadOption(
                value: 'walking',
                child: Text('Walking distance (1 mile)'),
              ),
              ShadOption(
                value: 'biking',
                child: Text('Biking distance (3 miles)'),
              ),
              ShadOption(
                value: 'driving',
                child: Text('Short drive (5 miles)'),
              ),
              ShadOption(
                value: 'anywhere',
                child: Text('Anywhere in the city'),
              ),
            ],
            selectedOptionBuilder: (context, value) => Text(value == 'walking'
                ? 'Walking distance (1 mile)'
                : value == 'biking'
                    ? 'Biking distance (3 miles)'
                    : value == 'driving'
                        ? 'Short drive (5 miles)'
                        : 'Anywhere in the city'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendations() {
    List<Map<String, dynamic>> recommendations = [
      {
        'title': 'Pasta Making Class',
        'location': 'Culinary Studio',
        'image': 'cooking',
        'price': '\$\$',
        'tags': ['Group-friendly', 'Indoor'],
      },
      {
        'title': 'Sunset Kayaking',
        'location': 'River Park',
        'image': 'kayaking',
        'price': '\$',
        'tags': ['Outdoor', 'Nature'],
      },
      {
        'title': 'Wine Tasting Tour',
        'location': 'Valley Vineyards',
        'image': 'wine',
        'price': '\$\$\$',
        'tags': ['Adult', 'Weekend'],
      },
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: ShadCard(
              backgroundColor: ThemeProvider.secondaryPurple.withOpacity(0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: ThemeProvider.secondaryPurple.withOpacity(0.2),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForImage(item['image'] as String),
                        size: 42,
                        color: ThemeProvider.secondaryPurple.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['location'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ShadBadge(
                              backgroundColor: Colors.transparent,
                              child: Text(
                                item['price'] as String,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ShadBadge(
                              backgroundColor: ThemeProvider.secondaryPurple
                                  .withOpacity(0.2),
                              child: Text(
                                item['tags'][0] as String,
                                style: TextStyle(
                                  color: ThemeProvider.secondaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: (50 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildPopularActivities() {
    List<Map<String, dynamic>> activities = [
      {
        'title': 'Bowling Night',
        'location': 'Cosmic Lanes',
        'rating': 4.7,
        'price': '\$\$',
      },
      {
        'title': 'Forest Hiking Trail',
        'location': 'National Park',
        'rating': 4.9,
        'price': '\$',
      },
      {
        'title': 'Modern Art Exhibition',
        'location': 'Downtown Gallery',
        'rating': 4.5,
        'price': '\$\$',
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForTitle(activity['title'] as String),
                        color: ThemeProvider.primaryBlue,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['location'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity['rating']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              activity['price'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ShadButton.ghost(
                    onPressed: () {
                      // View details
                    },
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForImage(String image) {
    switch (image) {
      case 'cooking':
        return Icons.restaurant;
      case 'kayaking':
        return Icons.rowing;
      case 'wine':
        return Icons.wine_bar;
      default:
        return Icons.star;
    }
  }

  IconData _getIconForTitle(String title) {
    if (title.contains('Bowl')) {
      return Icons.sports_cricket;
    } else if (title.contains('Hik')) {
      return Icons.terrain;
    } else if (title.contains('Art')) {
      return Icons.palette;
    }
    return Icons.event;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAI;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isAI = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAI
                ? ThemeProvider.secondaryPurple.withOpacity(0.1)
                : ThemeProvider.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isAI
                ? ThemeProvider.secondaryPurple
                : ThemeProvider.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
