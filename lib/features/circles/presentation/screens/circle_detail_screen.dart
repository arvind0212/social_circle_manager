import 'package:flutter/material.dart';

class CircleDetailScreen extends StatefulWidget {
  // ... (existing code)
}

class _CircleDetailScreenState extends State<CircleDetailScreen> {
  // ... (existing code)

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ShadCard(
        child: Padding(
          // ... (existing code)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the existing code)
  }
} 