import 'dart:ffi';
import 'package:flutter/material.dart';
import '../widgets/busquedaField.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../utils.dart';

class PantallaPrincipalNavigatorRoutes {
  static const String root = '/';
  static const String tiendas = '/tiendas';
}

class ScreenArguments {
  final List listaRestaurantes;

  ScreenArguments(this.listaRestaurantes);
}

class PantallaPrincipal extends StatefulWidget {
  PantallaPrincipal({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaPrincipalState createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  final _busquedaController = TextEditingController();
  int _currentIndex = 0;
  bool _buscandoRestaurantes = false;
  List<Widget> _listaRestaurantes = List<Widget>();

  void _submitCallback(String value) {
    consultarRestaurantes(termino_busqueda:value).then((restaurantesData) {
      _listaRestaurantes.clear();
      for (Map restaurante in restaurantesData) {
        _listaRestaurantes.add(
          GestureDetector(
            child: Container(
              child: Column(
                children: <Widget>[
                  Image.asset('assets/images/default_banner.png', width: double.infinity),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color.fromARGB(255, 204, 204, 204))
                    ),
                    child: Text(restaurante['nombre']),
                  )
                ],
              ),
            ),
            onTap: () {},
          ),
        );
      }
      setState(() {
        _buscandoRestaurantes = true;
      });
    });
  }

  void _callbackLimpiarBusqueda() {
    setState(() {
      _buscandoRestaurantes = false;
    });
  }

  Map<String, WidgetBuilder> _routeWidgets(BuildContext context) {
    return {
      PantallaPrincipalNavigatorRoutes.root: (context) {
        return Container(
          padding: EdgeInsets.only(top: 30, right: 0, bottom: 40, left: 0),
          color: Colors.white,
          child: FutureBuilder<List>(
              future: consultarCategorias(),
              builder: (context, AsyncSnapshot snapshot) {
                List<Widget> categorias = List<Widget>();

                if (snapshot.hasData) {
                  List categoriasData = snapshot.data;

                  for (Map categoria in categoriasData) {
                    categorias.add(
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color.fromARGB(255, 248, 244, 244),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('assets/images/' + categoria['imagen'], width: 100),
                                Text(categoria['nombre']),
                              ],
                            ),
                          ),
                        ),
                        onTap: () async {
                          List listaRestaurantes = await consultarRestaurantes(categoria_busqueda: categoria['id'].toString());
                          Navigator.pushNamed(
                              context,
                              PantallaPrincipalNavigatorRoutes.tiendas,
                              arguments: listaRestaurantes
                          );
                        },
                      ),
                    );
                  }
                }

                return Column(
                  children: <Widget>[
                    BusquedaField(_busquedaController, _submitCallback, _callbackLimpiarBusqueda),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: _buscandoRestaurantes ? 1 : 2,
                        children: _buscandoRestaurantes ? _listaRestaurantes : categorias,
                      ),
                    ),
                  ],
                );
              }
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeWidget = _routeWidgets(context);

    final tabs = <Widget>[
      Navigator(
        initialRoute: '/',
        onGenerateRoute: (routeSettings) {
          if (routeSettings.name == PantallaPrincipalNavigatorRoutes.tiendas) {
            debugPrint(routeSettings.arguments.toString());
            return MaterialPageRoute(
                builder: (context) => PantallaTiendas(routeSettings.arguments)
            );
          }

          return MaterialPageRoute(
            builder: (context) => routeWidget[routeSettings.name](context)
          );
        }
      ),
      Center(
        child: Text('Aquí van las órdenes')
      )
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 219, 29, 45),
        selectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              child: Icon(Icons.search),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            title: Container(
              child: Text('Buscar'),
              padding: EdgeInsets.only(bottom: 5),
            )
          ),
          BottomNavigationBarItem(
              icon: Container(
                child: Icon(Icons.description),
                padding: EdgeInsets.symmetric(vertical: 5),
              ),
              title: Container(
                child: Text('Pedidos'),
                padding: EdgeInsets.only(bottom: 5),
              )
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class PantallaTiendas extends StatefulWidget {
  PantallaTiendas(this.listaRestaurantes, {Key key, this.title}) : super(key: key);

  final String title;
  final List listaRestaurantes;

  @override
  PantallaTiendasState createState() => PantallaTiendasState(listaRestaurantes);
}

class PantallaTiendasState extends State<PantallaTiendas> {
  final List _listaRestaurantes;

  PantallaTiendasState(this._listaRestaurantes);

  @override
  Widget build(BuildContext context) {
    List<Widget> restaurantes = List<Widget>();
    for (Map restaurante in _listaRestaurantes) {
      restaurantes.add(
        GestureDetector(
          child: Container(
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/default_banner.png', width: double.infinity),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color.fromARGB(255, 204, 204, 204))
                  ),
                  child: Text(restaurante['nombre']),
                )
              ],
            ),
          ),
          onTap: () {},
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 30, right: 0, bottom: 40, left: 0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          // BusquedaField(_busquedaController),
          Container(
            padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 219, 29, 45)
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ],
              )
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 1,
              children: restaurantes,
            ),
          ),
        ],
      ),
    );
  }
}