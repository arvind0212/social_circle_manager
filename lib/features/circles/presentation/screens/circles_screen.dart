import 'package:flutter/material.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circles'),
      ),
      body: const Center(
        child: Text('Circles Screen'),
      ),
    );
  }
} 