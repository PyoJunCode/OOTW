

import 'package:flutter/material.dart';
import 'ootw.dart';
import 'login.dart';
import 'splash.dart';


class ootwApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOTW',
      theme: ThemeData(
        primaryColor: const Color(0xFFBBBBBB)
      ),
      home: SplashScreen(),

      initialRoute: '/splash',
      onGenerateRoute: _getRoute,

    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/splash') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => SplashScreen(),
      fullscreenDialog: true,
    );
  }
}
