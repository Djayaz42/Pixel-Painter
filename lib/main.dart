import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/level_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PixelPainterApp());
}

class PixelPainterApp extends StatelessWidget {
  const PixelPainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Painter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7357FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LevelSelectScreen(),
    );
  }
}
