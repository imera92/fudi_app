import 'dart:ffi';
import 'package:flutter/material.dart';
import '../widgets/busquedaField.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../utils.dart';

class PantallaPrincipal extends StatefulWidget {
  PantallaPrincipal({Key key, this.title}) : super(key: key);

  final String title;
  final categorias = [
    {
      'nombre': 'Comida rápida'
    }
  ];

  @override
  PantallaPrincipalState createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  double _lat;
  double _long;
  List<Widget>_categorias;
  final _busquedaController = TextEditingController();
  int _currentIndex = 0;

  Future<List> consultarCategorias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('token_access');
    String refresh_token = prefs.getString('token_refresh');

    await verificarTokens(access_token, refresh_token, prefs);

    http.Response response = await http.get(
      Constants.API_URL_GET_CATEGORIAS,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + access_token,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['categorias'];
    }
    return [];
  }

  /*void consultarRestaurantesCercanos() async {
    String mensajeError = 'Lo sentimos, no podemos buscar restaurantes para ti en este momento. Vuelve a intentarlo más tarde.';
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _lat = position.latitude;
    _long = position.longitude;

    http.Response response = await http.post(
      Constants.API_URL_GET_RESTAURANTES,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'lat': _lat.toString(),
        'long': _long.toString()
      }),
    );

    if(response.statusCode == 200){
      List<Widget> restaurantes = List<Widget>();
      Map<String, dynamic> data = jsonDecode(response.body);
      List restaurantesData = data['restaurantes'];
      setState(() {
        for (Map categoria in categoriasData) {
          _categorias.add(
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color.fromARGB(255, 248, 244, 244),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(categoria['nombre']),
                  ],
                ),
              ),
            )
          );
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text(mensajeError),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]
            );
          }
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      Container(
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
                      Container(
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
                      )
                  );
                }
              }

              return Column(
                children: <Widget>[
                  BusquedaField(_busquedaController),
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      children: categorias,
                    ),
                  ),
                ],
              );
            }
          ),
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