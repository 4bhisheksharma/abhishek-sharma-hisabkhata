import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/providers/locale_provider.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  final AppRouter _appRouter = AppRouter();
  Locale _locale = const Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      locale: _locale,
      changeLanguage: _changeLanguage,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hisab Khata',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        onGenerateRoute: _appRouter.onGenerateRoute,
        initialRoute: AppRoutes.welcome,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ne'), // Nepali
        ],
      ),
    );
  }
}
