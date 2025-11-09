import 'package:flutter/material.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hisab Khata",
      // theme: TODO:,
      themeMode: ThemeMode.light,
      home: Placeholder(),
      // routes: TODO:
    );
  }
}