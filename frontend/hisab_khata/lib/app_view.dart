import 'package:flutter/material.dart';
import 'package:hisab_khata/config/app_routes.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hisab Khata",
      // theme: TODO:,
      themeMode: ThemeMode.light,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.initialRoute,
      // routes: TODO:
    );
  }
}