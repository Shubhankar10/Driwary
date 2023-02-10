import 'package:exception/screens/auth_screens/login_screen.dart';
import 'package:exception/screens/auth_screens/signup_screen.dart';
import 'package:exception/screens/auth_screens/verify.dart';
import 'package:exception/screens/camera_page.dart';
import 'package:flutter/material.dart';

import 'main.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case 'login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case 'home':
        return MaterialPageRoute(builder: (_) => HomePage());

      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case 'camera':
        return MaterialPageRoute(builder: (_) => CameraPage());
      case '/verifyOtp':
        return MaterialPageRoute(builder: (_) => verifyOtp());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
