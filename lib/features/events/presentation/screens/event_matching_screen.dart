import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:social_circle_manager/features/events/domain/models/event.dart';
import 'package:social_circle_manager/features/events/presentation/screens/event_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:intl/intl.dart'; // Added for date/time formatting
import 'dart:convert'; // Added for jsonEncode
import '../../../../core/theme/app_theme.dart';
import '../../../circles/domain/models/circle_model.dart';
import '../../domain/models/event_recommendation_model.dart';

// Enum for Vote Types
enum VoteType { up, down, none }

class EventMatchingScreen extends StatefulWidget {
  final Circle circle;
  final Map<String, dynamic> eventPreferences;
  final Map<String, dynamic>? matchingResults; // API response data

  const EventMatchingScreen({
    Key? key,
    required this.circle,
    required this.eventPreferences,
    this.matchingResults, // Changed from matchingSessionId
  }) : super(key: key);

  @override
  State<EventMatchingScreen> createState() => _EventMatchingScreenState();
}

class _EventMatchingScreenState extends State<EventMatchingScreen> {
  final supabase = Supabase.instance.client; // Supabase client
  List<EventRecommendation> _recommendations = [];
  bool _isLoading = true;
  Map<String, VoteType> _userVotes = {}; // Tracks current user's vote for each recommendation ID
  
  // For demo purposes, we'll use a mock ID if needed for calls.
  // IMPORTANT: Replace this with the actual session_id from your backend flow.
  String? _currentMatchingSessionId; // Make nullable initially

  // Simulate owner status for the "Close Voting" button
  bool _isOwner = true; 

  @override
  void initState() {
    super.initState();
    _processApiResultsAndLoadVotes();
  }

  Future<void> _processApiResultsAndLoadVotes() async {
    setState(() { _isLoading = true; _recommendations = []; _userVotes = {}; });

    if (widget.matchingResults == null || widget.matchingResults!['recommendations'] == null || widget.matchingResults!['session_id'] == null) {
      print("Error: Missing matching results or session ID from API.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Failed to get matching session data."), backgroundColor: Colors.red),
        );
      }
      setState(() { _isLoading = false; });
      return;
    }

    _currentMatchingSessionId = widget.matchingResults!['session_id'] as String;
    final List<dynamic> rawRecommendations = widget.matchingResults!['recommendations'] as List<dynamic>;

    if (rawRecommendations.isEmpty) {
       print("API returned no recommendations.");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No event suggestions were generated. Try different preferences."), backgroundColor: Colors.orange),
         );
       }
       setState(() { _isLoading = false; });
       return;
    }
    
    // Parse recommendations from API data
    List<EventRecommendation> parsedRecs = [];
    for (var rawRec in rawRecommendations) {
      print("--- DEBUG: Raw Recommendation JSON for EventMatchingScreen from API ---");
      if (rawRec is Map<String, dynamic>) {
        print(jsonEncode(rawRec)); // Encode map to JSON string for clearer logging
      } else {
        print(rawRec.toString()); // Fallback for non-map types
      }
      print("--- END DEBUG ---       ");
      try {
        if (rawRec is Map<String, dynamic>) {
          parsedRecs.add(EventRecommendation.fromJson(rawRec));
        } else {
           print("Warning: Invalid recommendation format received: $rawRec");
        }
      } catch (e) {
        print("Error parsing recommendation: $e. Raw data: $rawRec");
        // Optionally skip this recommendation or handle error
      }
    }

    if (parsedRecs.isEmpty) {
      print("Failed to parse any recommendations from API response.");
      setState(() { _isLoading = false; });
      return;
    }

    // Now fetch votes for the parsed recommendations
    await _fetchVotesForRecommendations(parsedRecs);
  }

  Future<void> _fetchVotesForRecommendations(List<EventRecommendation> initialRecs) async {
    if (supabase.auth.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated."), backgroundColor: Colors.red),
        );
      }
      setState(() { _isLoading = false; });
      return;
    }
    final String currentUserId = supabase.auth.currentUser!.id;
    final String? currentSessionId = _currentMatchingSessionId; // Already checked in _processApiResultsAndLoadVotes

    if (currentSessionId == null || currentSessionId.isEmpty) {
        print("Error: Session ID missing, cannot fetch votes.");
        // We already parsed recommendations, so display them without votes
        setState(() {
            _recommendations = initialRecs;
            _recommendations.sort((a, b) => b.preferenceScore.compareTo(a.preferenceScore));
            _isLoading = false;
            _userVotes = {}; // Ensure user votes are cleared
        });
        return;
    }

    try {
      Map<String, VoteType> userVotesMap = {};
      List<EventRecommendation> recsWithVotes = [];

      for (var rec in initialRecs) {
        final userVoteResponse = await supabase
            .from('event_suggestion_votes')
            .select('vote_value')
            .eq('recommendation_id', rec.id)
            .eq('user_id', currentUserId)
            .eq('session_id', currentSessionId)
            .maybeSingle();

        // Determine user's vote based on existence and value
        if (userVoteResponse != null) {
            final voteVal = userVoteResponse['vote_value'] as int?;
            if (voteVal == 1) {
                userVotesMap[rec.id] = VoteType.up;
            } else if (voteVal == -1) {
                userVotesMap[rec.id] = VoteType.down;
            } else {
                // Handle unexpected value or null, treat as none
                userVotesMap[rec.id] = VoteType.none;
            }
        } else {
            userVotesMap[rec.id] = VoteType.none;
        }

        // Fetch aggregate net votes
        final allVotesResponse = await supabase
            .from('event_suggestion_votes')
            .select('vote_value')
            .eq('recommendation_id', rec.id)
            .eq('session_id', currentSessionId);
        
        int netVotes = 0;
        if (allVotesResponse.isNotEmpty) {
          for (var voteEntry in allVotesResponse) {
            netVotes += (voteEntry['vote_value'] as int?) ?? 0;
          }
        }

        recsWithVotes.add(rec.copyWith(votes: netVotes));
      }

      setState(() {
        _recommendations = recsWithVotes;
        _userVotes = userVotesMap;
        _recommendations.sort((a, b) => b.preferenceScore.compareTo(a.preferenceScore));
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      print('Error loading votes: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vote data: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      // Fallback: show recommendations without votes
      setState(() { 
        _recommendations = initialRecs;
        _recommendations.sort((a, b) => b.preferenceScore.compareTo(a.preferenceScore));
        _isLoading = false; 
        _userVotes = {};
      });
    }
  }

  Future<void> _castVote(EventRecommendation recommendation, VoteType newVoteType) async {
    HapticFeedback.mediumImpact();
    
    if (supabase.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to vote."), backgroundColor: Colors.red));
      return;
    }
    final String currentUserId = supabase.auth.currentUser!.id;
    final String recommendationId = recommendation.id;

    // Ensure session ID is not null before proceeding
    final String sessionId = _currentMatchingSessionId!;

    if (sessionId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Session ID missing. Cannot cast vote."), backgroundColor: Colors.red));
        return;
    }

    // Determine previous vote state more explicitly
    final VoteType previousVoteType = _userVotes[recommendationId] ?? VoteType.none;

    // Determine new DB value and if un-voting
    int? newVoteValueDb; 
    bool isUnvoting = false;

    if (newVoteType == previousVoteType) {
      // Clicked same button again -> un-vote
      isUnvoting = true;
      newVoteValueDb = null; // Will delete the row
    } else if (newVoteType == VoteType.up) {
      newVoteValueDb = 1;
    } else if (newVoteType == VoteType.down) {
      newVoteValueDb = -1;
    }

    // Optimistic UI Update
    setState(() {
      int currentNetVotes = recommendation.votes;
      int deltaVotes = 0;

      if (isUnvoting) { // Removing whatever vote was there
        if (_userVotes[recommendationId] == VoteType.up) deltaVotes = -1;
        if (_userVotes[recommendationId] == VoteType.down) deltaVotes = 1; // Removing a downvote increases net score
        _userVotes[recommendationId] = VoteType.none;
      } else { // Casting a new vote (or changing vote)
        // Calculate change based on previous state
        if (_userVotes[recommendationId] == VoteType.none) { // New vote
          deltaVotes = (newVoteType == VoteType.up) ? 1 : -1;
        } else if (_userVotes[recommendationId] == VoteType.up && newVoteType == VoteType.down) { // Changing Up -> Down
          deltaVotes = -2;
        } else if (_userVotes[recommendationId] == VoteType.down && newVoteType == VoteType.up) { // Changing Down -> Up
          deltaVotes = 2;
        }
        _userVotes[recommendationId] = newVoteType;
      }
      
      int finalNetVotes = currentNetVotes + deltaVotes;

      // Update the recommendation object in the list
      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(votes: finalNetVotes);
      }
    });

    try {
      if (isUnvoting) {
        await supabase.from('event_suggestion_votes').delete().match({
          'recommendation_id': recommendationId,
          'user_id': currentUserId,
          'session_id': sessionId,
        });
        print('Removed vote for $recommendationId by $currentUserId in session $sessionId');
      } else if (newVoteValueDb != null) { // Is upvoting or downvoting
        await supabase.from('event_suggestion_votes').upsert({
          'recommendation_id': recommendationId,
          'user_id': currentUserId,
          'session_id': sessionId,
          'vote_value': newVoteValueDb, // Store 1 or -1
          // 'voted_at' will default to now()
        }, onConflict: 'session_id, recommendation_id, user_id'); // Unique constraint
        print('Upserted vote ($newVoteValueDb) for $recommendationId by $currentUserId in session $sessionId');
      }
      // Optionally, refresh just the vote counts for this specific recommendation for max accuracy
      // For hackathon, optimistic update is likely fine.
    } catch (e) {
      print('Error casting vote in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting vote: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      // TODO: Revert optimistic UI update if Supabase call fails.
      // This might involve re-fetching the original vote state for this item.
      // For simplicity, we might just trigger a full _processApiResultsAndLoadVotes() on error.
      _processApiResultsAndLoadVotes(); // Simplest way to revert/resync on error
    }
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

    // Ensure sorting happens *after* votes might have been updated by Supabase calls finishing
    final sortedRecs = List<EventRecommendation>.from(_recommendations);
    sortedRecs.sort((a, b) {
      final voteComparison = b.votes.compareTo(a.votes); // Higher votes first
      if (voteComparison != 0) return voteComparison;
      return b.preferenceScore.compareTo(a.preferenceScore); // Tie-breaker
    });

    if (sortedRecs.isEmpty || sortedRecs.every((r) => r.votes <= 0)) { 
       // Allow events with 0 votes if it's the only option or highest among negatives
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No event received positive votes."), backgroundColor: Colors.orange),
      );
       return;
    }
    
    EventRecommendation winningRecommendation = sortedRecs.first;

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

  Future<void> _createNewEvent(EventRecommendation recommendation) async {
    if (supabase.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not authenticated."), backgroundColor: Colors.red));
      return;
    }
    
    // ---> Step 1: Close the session status first <--- 
    if (_currentMatchingSessionId == null || _currentMatchingSessionId!.isEmpty) {
      print("Error: Cannot close voting, session ID is missing.");
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error closing voting session."), backgroundColor: Colors.red));
      return;
    }

    print('Attempting to close voting session: [33m[1m[4m$_currentMatchingSessionId[0m');
    try {
      final response = await supabase
          .from('event_matching_sessions')
          .update({'status': 'closed'})
          .eq('id', _currentMatchingSessionId!)
          .select();
      print('Update response: ' + response.toString());
      print('Successfully closed voting session: $_currentMatchingSessionId');
    } catch (e) {
      print('Error closing voting session in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error closing voting session: [31m${e.toString()}[0m'), backgroundColor: Colors.red),
        );
      }
      return; // Stop if we can't close the session
    }
    // ---> End Step 1 <---

    print('Creating event from recommendation: ${recommendation.title} for circle ${widget.circle.id}');

    // For the hackathon, we use details directly from the recommendation object.
    // In a real app, if recommendation.id refers to an 'event_matching_recommendations' record,
    // you'd use its 'circle_event_id' or 'external_event_id' to fetch full original details.
    final newEventData = {
      'circle_id': widget.circle.id,
      'created_by_user_id': supabase.auth.currentUser!.id,
      'title': recommendation.title,
      'description': recommendation.description,
      'start_time': DateTime.now().add(const Duration(days: 7)).toIso8601String(), // Placeholder
      'end_time': DateTime.now().add(const Duration(days: 7, hours: 2)).toIso8601String(), // Placeholder
      'location': recommendation.location, 
      // 'source_recommendation_id': recommendation.id, // Optional: link back to the winning recommendation
    };

    try {
      await supabase.from('events').insert(newEventData).select().single();
      
      if (mounted) {
        Navigator.of(context).pop(true); // Pop EventMatchingScreen and signal success to parent

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
    } catch (e) {
      print('Error creating event in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
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
              'Vote on Suggestions', // Updated title
              style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold, color: ThemeProvider.secondaryPurple), // AI Purple
            ),
            Text(
              'For ${widget.circle.name}',
              style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
            ),
          ],
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark, 
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
          CircularProgressIndicator(color: ThemeProvider.secondaryPurple), 
          const SizedBox(height: 20),
          Text('Loading suggestions & votes...', style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(ShadThemeData theme) {
    if (_recommendations.isEmpty && !_isLoading) { // Added check for !_isLoading
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 48, color: theme.colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text('No suggestions yet.', style: theme.textTheme.p),
            Text('LLM is cooking up ideas, or try again.', style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80), 
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
      // Use AI generated color if available, otherwise a default
      borderColor = (rec.AIGeneratedColor != Colors.transparent ? rec.AIGeneratedColor : ThemeProvider.primaryBlue).withOpacity(0.7);
    }

    // --- Data Parsing & Formatting ---
    String locationDisplay = "No Location provided";
    if (rec.location.isNotEmpty) {
      locationDisplay = rec.location;
    }

    String timeDisplay = "Time TBD";
    try {
      // Use the direct startTime and endTime fields from the EventRecommendation model
      DateTime? startTime = rec.startTime.isNotEmpty ? DateTime.tryParse(rec.startTime)?.toLocal() : null;
      DateTime? endTime = rec.endTime.isNotEmpty ? DateTime.tryParse(rec.endTime)?.toLocal() : null;

      if (startTime != null && endTime != null && endTime.isAfter(startTime)) {
        Duration duration = endTime.difference(startTime);
        String hours = duration.inHours > 0 ? '${duration.inHours}h' : '';
        String minutes = duration.inMinutes.remainder(60) > 0 ? ' ${duration.inMinutes.remainder(60)}m' : '';
        if (hours.isNotEmpty || minutes.isNotEmpty) {
           timeDisplay = 'Duration: ${hours}${minutes}'.trim();
        } else {
           timeDisplay = 'Starts: ${DateFormat.jm().format(startTime)}'; // Fallback if duration is zero
        }
      } else if (startTime != null) {
        timeDisplay = 'Starts: ${DateFormat.yMd().add_jm().format(startTime)}'; // Show start date and time
      }
    } catch (e) {
      print("Error parsing time for recommendation ${rec.id}: $e");
      // Keep default "Time TBD"
    }

    // Format score (assuming rec.preferenceScore is the 1-10 average score)
    String scoreDisplay = '${rec.preferenceScore.toStringAsFixed(1)}/10 Match';
    // --- End Data Parsing & Formatting ---

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
                            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600, color: rec.AIGeneratedColor != Colors.transparent ? rec.AIGeneratedColor : theme.colorScheme.primary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (rec.AIGeneratedColor != Colors.transparent ? rec.AIGeneratedColor : theme.colorScheme.primary).withOpacity(0.1),
                            borderRadius: theme.radius,
                          ),
                          child: Text( // Display LLM match score
                            scoreDisplay,
                            style: theme.textTheme.small.copyWith(color: (rec.AIGeneratedColor != Colors.transparent ? rec.AIGeneratedColor : theme.colorScheme.primary), fontWeight: FontWeight.bold),
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
                    Row( // Assuming EventRecommendation still has these fields from mock
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationDisplay, // Use parsed location
                            style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.mutedForeground), // Changed icon slightly
                        const SizedBox(width: 4),
                        Text(
                          timeDisplay, // Use parsed/calculated time/duration
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
                        rec.votes >= 0 ? Icons.how_to_vote_rounded : Icons.mood_bad_rounded, 
                        size: 16, 
                        color: rec.votes == 0 ? theme.colorScheme.mutedForeground : (rec.votes > 0 ? ThemeProvider.accentPeach : theme.colorScheme.destructive)
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${rec.votes > 0 ? '+' : ''}${rec.votes} Vote${rec.votes.abs() == 1 ? '' : 's'}', // Show +/- sign, use abs() for grammar
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.foreground,
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
                          color: currentUserVote == VoteType.up ? ThemeProvider.accentPeach : theme.colorScheme.mutedForeground,
                        ),
                        onPressed: () => _castVote(rec, VoteType.up),
                        size: ShadButtonSize.sm,
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 4), // Reduced spacing
                      ShadButton.ghost(
                        icon: Icon(
                          Icons.thumb_down_alt_rounded,
                          size: 16,
                          color: currentUserVote == VoteType.down ? theme.colorScheme.destructive : theme.colorScheme.mutedForeground,
                        ),
                        onPressed: () => _castVote(rec, VoteType.down),
                        size: ShadButtonSize.sm,
                        padding: const EdgeInsets.all(8),
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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -4), // changes position of shadow
          ),
        ],
        // border: Border(top: BorderSide(color: theme.colorScheme.border.withOpacity(0.7)))
      ),
      child: ShadButton(
        width: double.infinity,
        onPressed: _handleCloseVoting,
        backgroundColor: ThemeProvider.secondaryPurple, 
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