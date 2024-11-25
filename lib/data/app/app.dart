import 'package:flutter/material.dart';

import '../../utils/constants/routes.dart';
import 'app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Open Street Map',
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: RouteManager.initial,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
