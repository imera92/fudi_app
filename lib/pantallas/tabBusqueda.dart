import 'package:flutter/material.dart';
import './busquedaPorCategorias.dart';
import './menuRestaurante.dart';

class RutasTabBusqueda {
  static const String busqueda = '/';
  static const String menuRestaurante = '/menu';
}

class TabBusqueda extends StatelessWidget {
  TabBusqueda(this.navigatorKey);
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: RutasTabBusqueda.busqueda,
      onGenerateRoute: (routeSettings) {
        final argumentos = routeSettings.arguments;


        switch(routeSettings.name) {
          case RutasTabBusqueda.menuRestaurante: {
            return MaterialPageRoute(builder: (context) => PantallaMenuRestaurante(argumentos));
          }
          break;

          default: {
            return MaterialPageRoute(builder: (context) => PantallaBusquedaPorCategorias());
          }
          break;
        }
      }
    );
  }
}