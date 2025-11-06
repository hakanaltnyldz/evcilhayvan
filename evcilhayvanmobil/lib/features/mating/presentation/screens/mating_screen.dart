// lib/features/mating/presentation/screens/mating_screen.dart
import 'package:flutter/material.dart';
class MatingScreen extends StatelessWidget {
  const MatingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('Çiftleştirme')),
      body: Center(child: Text('Çiftleştirme (Eş Bul) Ekranı')),
    );
  }
}