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
import '../bloc/buscadorBloc.dart';
import './pedido.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PantallaPrincipalNavigatorRoutes {
  static const String root = '/';
  static const String restaurantesPorCategoria = '/restaurantes';
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

  @override
  void initState() {
    consultarCategorias();
    super.initState();
  }

  void _submitCallback(String value) {
    _buscandoRestaurantes = true;
    buscadorBloc.resetRestaurantes();
    consultarRestaurantes(termino_busqueda: value);
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
          child: Column(
            children: <Widget>[
              BusquedaField(_busquedaController, _submitCallback, _callbackLimpiarBusqueda),
              Expanded(
                child: StreamBuilder(
                  initialData: buscadorBloc.buscadorData,
                  stream: buscadorBloc.getStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    List<Widget> itemsBuscador = List<Widget>();
                    bool mostrarAnimacion = false;

                    if (_buscandoRestaurantes) {
                      if (snapshot.data['restaurantes'].length == 0) {
                        mostrarAnimacion = true;
                      } else {
                        for (Map restaurante in snapshot.data['restaurantes']) {
                          itemsBuscador.add(
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
                      }
                    } else {
                      if (snapshot.data['categorias'].length == 0) {
                        mostrarAnimacion = true;
                      } else {
                        for (Map categoria in snapshot.data['categorias']) {
                          itemsBuscador.add(
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
                              onTap: () {
                                buscadorBloc.resetRestaurantes();
                                consultarRestaurantes(categoria_busqueda: categoria['id'].toString());
                                Navigator.pushNamed(
                                  context,
                                  PantallaPrincipalNavigatorRoutes.restaurantesPorCategoria,
                                );
                              },
                            ),
                          );
                        }
                      }
                    }

                    if (mostrarAnimacion) {
                      return Center(
                        child: SpinKitDoubleBounce(
                          color: Colors.red,
                          size: 50.0,
                        ),
                      );
                    } else {
                      return GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: _buscandoRestaurantes ? 1 : 2,
                        children: itemsBuscador,
                      );
                    }
                  }
                ),
              )
            ]
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
          if (routeSettings.name == PantallaPrincipalNavigatorRoutes.restaurantesPorCategoria) {
            return MaterialPageRoute(
              builder: (context) => PantallaRestaurantesPorCategoria()
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
      PantallaPedido()
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      floatingActionButton: StreamBuilder(
        initialData: bloc.allItems,
        stream: bloc.getStream,
        builder: (context, AsyncSnapshot snapshot) {
          bool visible = !snapshot.data['items_carrito'].isEmpty;
          String textoBoton = '';

          if (visible) {
            textoBoton = 'PEDIR ' + bloc.contarProductosCarrito().toString() + ' POR \$' + snapshot.data['subtotal_carrito'].toString();
          }

          return Visibility(
            visible: visible && _currentIndex != 2,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 15, right: 50, bottom: 15, left: 50),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              color: Color.fromARGB(255, 134, 5, 65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                textoBoton,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                )
              ),
            ),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

class PantallaRestaurantesPorCategoria extends StatefulWidget {
  PantallaRestaurantesPorCategoria({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaRestaurantesPorCategoriaState createState() => PantallaRestaurantesPorCategoriaState();
}

class PantallaRestaurantesPorCategoriaState extends State<PantallaRestaurantesPorCategoria> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(top: 30, right: 0, bottom: 40, left: 0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
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
            child: StreamBuilder(
              initialData: buscadorBloc.buscadorData,
              stream: buscadorBloc.getStream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data['restaurantes'].length == 0) {
                  return Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.red,
                      size: 50.0,
                    ),
                  );
                } else {
                  List<Widget> restaurantes = List<Widget>();
                  for (Map restaurante in snapshot.data['restaurantes']) {
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
                  return GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 1,
                    children: restaurantes,
                  );
                }
              }
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
                        bloc.setearRestauranteCarrito(_nombreRestaurante);
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