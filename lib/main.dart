import 'package:flutter/material.dart';
import 'package:voice_assistant/palette.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOVA',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Pallete.blueColor,
          appBarTheme: const AppBarTheme(backgroundColor: Pallete.blueColor)),
      home: const HomePage(),
    );
  }
}
