import 'package:flutter/material.dart';
import '../navigationService.dart';
import './ubicacion.dart';

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
                        'Nombre de la ubicacion'
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
}