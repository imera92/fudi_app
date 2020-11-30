import 'package:flutter/material.dart';
import '../navigationService.dart';
import './ubicacion.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/geoLocBloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PantallaHome extends StatefulWidget {
  PantallaHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaHomeState createState() => PantallaHomeState();
}

class PantallaHomeState extends State<PantallaHome> {

  Widget _linea() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10),
        height: 1.0,
        color: Color.fromARGB(255, 219, 29, 45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: geolocBloc.data,
      stream: geolocBloc.getStream,
      builder: (context, AsyncSnapshot snapshot) {
        bool mostrarAnimacion = true;
        String textoBotonCambiarPosicion;

        if (snapshot.data['lat'] != null && snapshot.data['long'] != null) {
          mostrarAnimacion = false;
        }
        textoBotonCambiarPosicion = snapshot.data['nombre'] != '' ? snapshot.data['nombre'] : 'Ubicación actual';

        if (mostrarAnimacion) {
          return Center(
            child: SpinKitDoubleBounce(
              color: Colors.red,
              size: 50.0,
            ),
          );
        } else {
          return ListView(
            padding: EdgeInsets.only(top: 40, right: 20, bottom: 40, left: 20),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      // Borrar decoracion al final
                      /*decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 219, 29, 45),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                      ),*/
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Image.asset('assets/images/ubicacion-icon.png', width: 15, height: 15),
                          Container(
                            child: Text(
                              textoBotonCambiarPosicion
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      navigationService.push(navigationService.pantallaPrincipalNavigatorKey, PantallaUbicacion());
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Destacados',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  _linea()
                ],
              ),
            ],
          );
        }
      },
    );
  }
}