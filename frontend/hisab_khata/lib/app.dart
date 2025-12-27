import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hisab_khata/app_view.dart";
import "package:hisab_khata/core/di/dependency_injection.dart";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _di = DependencyInjection();

  @override
  void initState() {
    super.initState();
    _di.init();
  }

  @override
  void dispose() {
    _di.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _di.authBloc),
        BlocProvider(create: (context) => _di.customerBloc),
        BlocProvider(create: (context) => _di.businessBloc),
        BlocProvider(create: (context) => _di.connectionRequestBloc),
        BlocProvider(create: (context) => _di.notificationBloc),
      ],
      child: MyAppView(),
    );
  }
}
