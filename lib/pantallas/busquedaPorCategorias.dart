import 'package:flutter/material.dart';
import '../widgets/busquedaField.dart';
import '../bloc/buscadorBloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../clases/restaurante.dart';
import '../navigationService.dart';
import './tabBusqueda.dart' show RutasTabBusqueda;

class PantallaBusquedaPorCategorias extends StatefulWidget {
  PantallaBusquedaPorCategorias({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaBusquedaPorCategoriasState createState() => PantallaBusquedaPorCategoriasState();
}

class PantallaBusquedaPorCategoriasState extends State<PantallaBusquedaPorCategorias> {
  final _busquedaController = TextEditingController();
  bool _buscandoRestaurantes = false;
  bool _consultandoCategoria = false;
  Widget get _barraSuperior {
    if (_consultandoCategoria) {
      return Container(
          padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 219, 29, 45)
                ),
                onPressed: () {
                  setState(() {
                    _consultandoCategoria = false;
                    _buscandoRestaurantes = false;
                  });
                },
                padding: EdgeInsets.symmetric(vertical: 18),
              ),
            ],
          )
      );
    } else {
      return BusquedaField(_busquedaController, _submitCallback, _callbackLimpiarBusqueda);
    }
  }

  void _submitCallback(String value) {
    _buscandoRestaurantes = true;
    buscadorBloc.resetRestaurantes();
    buscadorBloc.consultarRestaurantes(termino_busqueda: value);
  }

  void _callbackLimpiarBusqueda() {
    setState(() {
      _buscandoRestaurantes = false;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30, right: 0, bottom: 40, left: 0),
      color: Colors.white,
      child: Column(
          children: <Widget>[
            _barraSuperior,
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
                        String restaurante_nombre = restaurante['nombre'];
                        int restaurante_id = restaurante['id'];
                        String restaurante_costo_envio = restaurante['costo_envio'];

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
                              Restaurante restaurante = Restaurante(restaurante_nombre, restaurante_id, double.parse(restaurante_costo_envio));
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaMenuRestaurante(restaurante)));
                              navigationService.tabBusquedaNavigatorKey.currentState.pushNamed(RutasTabBusqueda.menuRestaurante, arguments: restaurante);
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
                              setState(() {
                                _consultandoCategoria = true;
                                _buscandoRestaurantes = true;
                              });
                              buscadorBloc.resetRestaurantes();
                              buscadorBloc.consultarRestaurantes(categoria_busqueda: categoria['id'].toString());
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
}