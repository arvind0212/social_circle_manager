import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthFormContainer extends StatelessWidget {
  final Widget child;
  
  const AuthFormContainer({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    ).animate()
     .fadeIn(
       duration: 800.ms, 
       curve: Curves.easeInOut
     );
  }
} 