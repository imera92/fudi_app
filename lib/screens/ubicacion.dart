import 'package:flutter/material.dart';
import '../navigationService.dart';

class PantallaUbicacion extends StatefulWidget {
  PantallaUbicacion({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaUbicacionState createState() => PantallaUbicacionState();
}

class PantallaUbicacionState extends State<PantallaUbicacion> {
  Widget _titulo() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
      child: Text(
        'Detalle de Dirección',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 40, right: 20, bottom: 40, left: 20),
        children: <Widget>[
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Color.fromARGB(255, 219, 29, 45)),
                onPressed: () {
                  navigationService.pop(navigationService.pantallaPrincipalNavigatorKey);
                },
                padding: EdgeInsets.symmetric(vertical: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _titulo()
                ],
              ),
            ],
          ),
        ]
      )
    );
  }
}