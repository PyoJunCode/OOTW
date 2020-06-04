

import 'package:flutter/material.dart';
import 'package:ootw/ootw.dart';

import 'login.dart';



class ootwApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOTW',

      home: LoginPage(),

      initialRoute: '/login',
      onGenerateRoute: _getRoute,

    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}
