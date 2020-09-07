import 'dart:ffi';
import 'package:flutter/material.dart';
import '../widgets/busquedaField.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../utils.dart';
import '../bloc/itemCarritoBloc.dart';

class PantallaPrincipalNavigatorRoutes {
  static const String root = '/';
  static const String tiendas = '/tiendas';
  static const String menu = '/menu';
}

class ScreenArguments {
  final List listaRestaurantes;

  ScreenArguments(this.listaRestaurantes);
}

class MenuArguments {
  final String nombreRestaurante;
  final int idRestaurante;

  MenuArguments(this.nombreRestaurante, this.idRestaurante);
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
            return MaterialPageRoute(
                builder: (context) => PantallaTiendas(routeSettings.arguments)
            );
          }

          if (routeSettings.name == PantallaPrincipalNavigatorRoutes.menu) {
            MenuArguments datosRestaurante = routeSettings.arguments;
            return MaterialPageRoute(
              builder: (context) => PantallaMenu(datosRestaurante.nombreRestaurante, datosRestaurante.idRestaurante)
            );
          }

          return MaterialPageRoute(
            builder: (context) => routeWidget[routeSettings.name](context)
          );
        }
      ),
      Center(
        child: Text('Aquí van las órdenes')
      ),
      Center(
        child: Text('Aquí va el carrito')
      )
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: StreamBuilder(
        initialData: bloc.allItems,
        stream: bloc.getStream,
        builder: (context, AsyncSnapshot snapshot) {
          List<BottomNavigationBarItem> navigationItems = [
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
            ),
          ];

          if (!snapshot.data['items_carrito'].isEmpty) {
            navigationItems.add(
              BottomNavigationBarItem(
                  icon: Container(
                    child: Icon(Icons.shopping_cart),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  title: Container(
                    child: Text('Carrito'),
                    padding: EdgeInsets.only(bottom: 5),
                  )
              ),
            );
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color.fromARGB(255, 219, 29, 45),
            selectedFontSize: 12,
            items: navigationItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        }
      )
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
          onTap: () {
            MenuArguments dataRestaurante = MenuArguments(restaurante['nombre'], restaurante['id']);
            Navigator.pushNamed(
                context,
                PantallaPrincipalNavigatorRoutes.menu,
                arguments: dataRestaurante
            );
          },
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

class PantallaMenu extends StatefulWidget {
  PantallaMenu(this.nombreRestaurante, this.restauranteId, {Key key, this.title}) : super(key: key);

  final String title;
  final String nombreRestaurante;
  final int restauranteId;

  @override
  PantallaMenuState createState() => PantallaMenuState(nombreRestaurante, restauranteId);
}

class PantallaMenuState extends State<PantallaMenu> {
  final String _nombreRestaurante;
  final int _restauranteId;
  // Future<List> _categorias;
  // Future<Map> _restaurantes;
  Future<Map> _restauranteData;

  PantallaMenuState(this._nombreRestaurante, this._restauranteId);

  @override
  void initState() {
    _restauranteData = consultarMenuRestaurante(_restauranteId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              Image.asset('assets/images/default_banner.png', width: double.infinity),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(175, 255, 255, 255),
                ),
                child: Text(
                  _nombreRestaurante,
                 style: TextStyle(
                   color: Colors.black87,
                   fontSize: 18,
                   fontWeight: FontWeight.bold
                 )
                ),
              ),
            ],
          ),
          StreamBuilder(
            initialData: bloc.allItems,
            stream: bloc.getStream,
            builder: (context, AsyncSnapshot snapshot) {
              List<Widget> categoriasWidgets = List<Widget>();

              for (Map categoria in snapshot.data['categorias']) {
                categoriasWidgets.add(
                  GestureDetector(
                    child: Container(
                      child: Text(
                        categoria['nombre'],
                        style: TextStyle(
                          color: snapshot.data['categoriaEnPantalla'] == categoria['id'] ? Colors.white : Colors.black54,
                        )
                      ),
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Color.fromARGB(255, 134, 5, 65), width: 2),
                        color: snapshot.data['categoriaEnPantalla'] == categoria['id'] ? Color.fromARGB(255, 134, 5, 65) : Colors.white
                      )
                    ),
                    onTap: () {
                      bloc.setCategoriaEnPantalla(categoria['id']);
                    },
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      'Menú',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    padding: EdgeInsets.only(top: 20, right: 15, bottom: 20, left: 15),
                  ),
                  Container(
                    height: 62.5,
                    padding: EdgeInsets.only(right: 5, bottom: 20, left: 5),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 134, 5, 65),
                        ),
                      ),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: categoriasWidgets
                    ),
                  ),
                ],
              );
            }
          ),
          StreamBuilder(
            initialData: bloc.allItems,
            stream: bloc.getStream,
            builder: (context, AsyncSnapshot snapshot) {
              List<Widget> productosWidgets = List<Widget>();

              if (snapshot.data['categoriaEnPantalla'] != Null) {
                for (Map producto in snapshot.data['productos'][snapshot.data['categoriaEnPantalla']]) {

                  List<Widget> botones = [
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Color.fromARGB(255, 134, 5, 65),
                        ),
                        child: Icon(
                            Icons.add,
                            color: Colors.white
                        ),
                      ),
                      onTap: (){
                        bloc.anadirAlCarrito(producto);
                      },
                    ),
                  ];
                  bool productoEnCarrito = snapshot.data['items_carrito'].containsKey(producto['id']);
                  if (productoEnCarrito) {
                    botones.add(
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Color.fromARGB(255, 134, 5, 65),
                          ),
                          child: Icon(
                              Icons.remove,
                              color: Colors.white
                          ),
                        ),
                        onTap: (){
                          bloc.quitarDelCarrito(producto);
                        },
                      )
                    );
                  }

                  productosWidgets.add(
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 134, 5, 65),
                          ),
                        )
                      ),
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(top:15, right: 5, left: 5, bottom: 15),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Image.network(
                              Constants.MEDIA_ROOT + producto['imagen'],
                              width: 100,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    producto['nombre'],
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          '\$' + producto['precio'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: botones,
                                          ),
                                        ),
                                        // productoEnCarrito ? Text ('coso') : null
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  );
                }
              }

              return Column(
                children: productosWidgets,
              );
            }
          ),
        ],
      ),
    );
  }
}