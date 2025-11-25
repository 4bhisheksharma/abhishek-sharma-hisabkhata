import 'package:flutter/material.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/string_constants.dart';

class MyAppView extends StatelessWidget {
  MyAppView({super.key});
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstant.appName,
      // theme: TODO:,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: _appRouter.onGenerateRoute,
      initialRoute: '/',
      // routes: TODO:
    );
  }
}
