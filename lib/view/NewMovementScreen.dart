import 'package:flutter/material.dart';

class NewMovementScreen extends StatelessWidget {
  const NewMovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Movement Page",
      theme: ThemeData(colorScheme: ColorScheme.light()),
      home: Scaffold(body: Stack()),
    );
  }
}
