import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> pantallaPrincipalNavigatorKey = new GlobalKey<NavigatorState>();

  /*Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }*/

  Future<dynamic> push(GlobalKey<NavigatorState> navigatorKey, Widget screen) {
    return navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => screen));
  }

  pop(GlobalKey<NavigatorState> navigatorKey) {
    return navigatorKey.currentState.pop();
  }
}

final navigationService = NavigationService();