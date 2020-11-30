import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../navigationService.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './mapa.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class PantallaUbicacion extends StatefulWidget {
  PantallaUbicacion({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaUbicacionState createState() => PantallaUbicacionState();
}

class PantallaUbicacionState extends State<PantallaUbicacion> {
  Widget _titulo() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Detalle de Dirección',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /*Widget _ubicacionActual() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color.fromARGB(255, 219, 29, 45)))
        ),
        padding: EdgeInsets.only(top: 25, bottom: 25),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.gps_fixed, color: Color.fromARGB(255, 219, 29, 45)),
              padding: EdgeInsets.only(left: 0, right: 10),
              constraints: BoxConstraints.tightFor(height: 23),
            ),
            Text(
              'Usar mi ubicación actual',
              style: TextStyle(
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        navigationService.push(navigationService.pantallaPrincipalNavigatorKey, PantallaMapa());
      },
    );
  }*/

  Widget _ubicacionNueva() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color.fromARGB(255, 219, 29, 45)))
        ),
        padding: EdgeInsets.only(top: 25, bottom: 25),
        child: Row(
          children: [
            Container(
              child: SvgPicture.asset(
                'assets/icons/cursor.svg',
                color: Color.fromARGB(255, 219, 29, 45),
                width: 17.5
              ),
              padding: EdgeInsets.only(right: 16),
            ),
            Text(
              'Ingresar nueva dirección de entrega',
              style: TextStyle(
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
          LatLng posicionActual = LatLng(position.latitude, position.longitude);
          navigationService.push(navigationService.pantallaPrincipalNavigatorKey, PantallaMapa(posicionActual: posicionActual));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 40, right: 30, bottom: 40, left: 30),
        children: <Widget>[
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Color.fromARGB(255, 219, 29, 45)),
                onPressed: () {
                  navigationService.pop(navigationService.pantallaPrincipalNavigatorKey);
                },
                padding: EdgeInsets.only(top: 20),
                constraints: BoxConstraints.tightFor(width: 23),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _titulo()
                ],
              ),
            ],
          ),
          // _ubicacionActual(),
          _ubicacionNueva(),
        ]
      )
    );
  }
}