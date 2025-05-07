import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:social_circle_manager/features/events/domain/models/event.dart';
import 'package:social_circle_manager/features/events/presentation/screens/event_details_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../circles/domain/models/circle_model.dart';
import '../../domain/models/event_recommendation_model.dart';

// Enum for Vote Types
enum VoteType { up, down, none }

class EventMatchingScreen extends StatefulWidget {
  final Circle circle;
  final Map<String, dynamic> eventPreferences;

  const EventMatchingScreen({
    Key? key,
    required this.circle,
    required this.eventPreferences,
  }) : super(key: key);

  @override
  State<EventMatchingScreen> createState() => _EventMatchingScreenState();
}

class _EventMatchingScreenState extends State<EventMatchingScreen> {
  List<EventRecommendation> _recommendations = [];
  bool _isLoading = true;
  Map<String, VoteType> _userVotes = {}; // Tracks current user's vote for each recommendation ID
  String _currentUserId = 'currentUser123'; // Mock current user ID
  // Simulate owner status for the "Close Voting" button
  bool _isOwner = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _recommendations = [
        EventRecommendation.mock(
          'rec1',
          'Evening Stroll & Gelato',
          'A relaxed evening walk through the park followed by delicious artisanal gelato. Perfect for casual conversation.',
          'Central Park & \'Luigi\'s Gelateria''',
          0.92,
          5,
        ),
        EventRecommendation.mock(
          'rec2',
          'Interactive Art Exhibit Visit',
          'Explore a new mind-bending interactive art installation downtown. Sparks creativity and discussion.',
          'The \'Luminarium\' Gallery''',
          0.88,
          3,
        ),
        EventRecommendation.mock(
          'rec3',
          'Outdoor Sunset Yoga Session',
          'Rejuvenating yoga session at a scenic viewpoint as the sun sets. Promotes wellness and mindfulness.',
          'Hilltop Vista Point',
          0.85,
          2,
        ),
        EventRecommendation.mock(
          'rec4',
          'Board Game Cafe Challenge',
          'Spend an afternoon battling it out over classic and new board games at a cozy cafe. Food and drinks available.',
          'The \'Dice & \'Slice Cafe''',
          0.78,
          1,
        ),
      ];
      // Sort by preference score initially and maintain this order for display
      _recommendations.sort((a, b) => b.preferenceScore.compareTo(a.preferenceScore));
      _isLoading = false;
    });
  }

  void _castVote(EventRecommendation recommendation, VoteType newVoteType) {
    HapticFeedback.mediumImpact();
    setState(() {
      VoteType previousVote = _userVotes[recommendation.id] ?? VoteType.none;

      // Adjust votes based on previous vote
      if (previousVote == VoteType.up) {
        recommendation.votes--;
        recommendation.upvoters.remove(_currentUserId);
      } else if (previousVote == VoteType.down) {
        recommendation.votes++;
        recommendation.downvoters.remove(_currentUserId);
      }

      // Apply new vote if it's different from the previous one
      if (newVoteType == previousVote) {
        // User clicked the same vote type again, so remove vote (neutral)
        _userVotes[recommendation.id] = VoteType.none;
      } else {
        _userVotes[recommendation.id] = newVoteType;
        if (newVoteType == VoteType.up) {
          recommendation.votes++;
          recommendation.upvoters.add(_currentUserId);
        } else if (newVoteType == VoteType.down) {
          recommendation.votes--;
          recommendation.downvoters.add(_currentUserId);
        }
      }
    });
  }

  void _handleCloseVoting() {
    HapticFeedback.heavyImpact();
    
    if (_recommendations.isEmpty) {
      print("No recommendations to pick from.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No recommendations available to create an event."), backgroundColor: Colors.orange),
      );
      return;
    }

    // Find the recommendation with the highest net votes.
    // If there's a tie in votes, preferenceScore can be a tie-breaker.
    EventRecommendation? winningRecommendation = _recommendations.reduce((curr, next) {
      if (curr.votes > next.votes) {
        return curr;
      } else if (next.votes > curr.votes) {
        return next;
      } else {
        // Votes are equal, use preferenceScore as a tie-breaker
        return curr.preferenceScore >= next.preferenceScore ? curr : next;
      }
    });

    _confirmEventCreation(winningRecommendation);
  }

  void _confirmEventCreation(EventRecommendation recommendation) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Confirm Event Creation'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Create "${recommendation.title}" as a new event for ${widget.circle.name}?',
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton(
            backgroundColor: ThemeProvider.accentPeach,
            foregroundColor: Colors.white,
            child: const Text('Create Event'),
            onPressed: () {
              Navigator.of(context).pop(true); // Pop dialog
              _createNewEvent(recommendation);
            },
          ),
        ],
      ),
    );
  }

  void _createNewEvent(EventRecommendation recommendation) {
    // This is where you would convert EventRecommendation to an Event
    // and save it to your backend/state management.
    // For now, we just pop and show a success message.
    print('Creating event: ${recommendation.title} for circle ${widget.circle.name}');

    // Pop EventMatchingScreen and return to the previous screen (e.g. CircleDetailScreen or EventsScreen)
    // We can pass a value back if needed to indicate success or the new event ID
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Event "${recommendation.title}" created!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.foreground),
        title: Column(
          children: [
            Text(
              'Event Matching',
              style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold, color: ThemeProvider.secondaryPurple), // AI Purple
            ),
            Text(
              'For ${widget.circle.name}',
              style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
            ),
          ],
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Or .light depending on your app bar color
      ),
      body: _isLoading
          ? _buildLoadingIndicator(theme)
          : _buildRecommendationsList(theme),
      bottomNavigationBar: _isOwner && !_isLoading && _recommendations.isNotEmpty
          ? _buildCloseVotingButton(theme)
          : null,
    );
  }

  Widget _buildLoadingIndicator(ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ThemeProvider.secondaryPurple), // AI Purple
          const SizedBox(height: 20),
          Text('Generating event ideas...', style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(ShadThemeData theme) {
    if (_recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: theme.colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text('No recommendations found.', style: theme.textTheme.p),
            Text('Try adjusting your preferences.', style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80), // Padding for FAB
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations[index];
        return _buildRecommendationCard(recommendation, theme).animate().fadeIn(duration: 300.ms, delay: (100 * index).ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildRecommendationCard(EventRecommendation rec, ShadThemeData theme) {
    final currentUserVote = _userVotes[rec.id] ?? VoteType.none;
    final Color borderColor;
    final double borderWidth = (currentUserVote != VoteType.none) ? 2.0 : 1.5;

    if (currentUserVote == VoteType.up) {
      borderColor = ThemeProvider.accentPeach;
    } else if (currentUserVote == VoteType.down) {
      borderColor = theme.colorScheme.destructive;
    } else {
      borderColor = rec.AIGeneratedColor.withOpacity(0.7);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ShadCard(
        padding: EdgeInsets.zero, 
        border: Border.all(color: borderColor, width: borderWidth),
        backgroundColor: theme.colorScheme.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Flexible(
                          child: Text(
                            rec.title,
                            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600, color: rec.AIGeneratedColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rec.AIGeneratedColor.withOpacity(0.1),
                            borderRadius: theme.radius,
                          ),
                          child: Text(
                            '${(rec.preferenceScore * 100).toStringAsFixed(0)}% Match',
                            style: theme.textTheme.small.copyWith(color: rec.AIGeneratedColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rec.description,
                      style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            rec.location,
                            style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time_outlined, size: 14, color: theme.colorScheme.mutedForeground),
                        const SizedBox(width: 4),
                        Text(
                          '~${rec.estimatedDurationHours.toStringAsFixed(1)} hrs',
                          style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
                        ),
                      ],
                    ),
                  ]),
            ),
            Divider(height: 1, color: theme.colorScheme.border.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.thumbs_up_down_outlined, 
                        size: 16, 
                        color: theme.colorScheme.mutedForeground
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${rec.votes} Vote${rec.votes == 1 ? '' : 's'}',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ShadButton.ghost(
                        icon: Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 16,
                          color: currentUserVote == VoteType.up ? Colors.white : theme.colorScheme.mutedForeground,
                        ),
                        onPressed: () => _castVote(rec, VoteType.up),
                        backgroundColor: currentUserVote == VoteType.up ? ThemeProvider.accentPeach : Colors.transparent,
                        size: ShadButtonSize.sm,
                        padding: const EdgeInsets.all(8), // Ensure touch target is reasonable for an icon button
                      ),
                      const SizedBox(width: 8),
                      ShadButton.ghost(
                        icon: Icon(
                          Icons.thumb_down_alt_rounded,
                          size: 16,
                          color: currentUserVote == VoteType.down ? Colors.white : theme.colorScheme.mutedForeground,
                        ),
                        onPressed: () => _castVote(rec, VoteType.down),
                        backgroundColor: currentUserVote == VoteType.down ? theme.colorScheme.destructive : Colors.transparent,
                        size: ShadButtonSize.sm,
                        padding: const EdgeInsets.all(8), // Ensure touch target is reasonable
                      ),
                    ]
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCloseVotingButton(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(top: BorderSide(color: theme.colorScheme.border.withOpacity(0.7)))
      ),
      child: ShadButton(
        width: double.infinity,
        onPressed: _handleCloseVoting,
        backgroundColor: ThemeProvider.secondaryPurple, // AI Purple for system action
        foregroundColor: Colors.white,
        icon: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.done_all_rounded, size: 18),
        ),
        child: const Text('Close Voting & Pick Best Event', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
} 