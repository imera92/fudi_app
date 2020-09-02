import 'package:flutter/material.dart';
// import '../widgets/passwordField.dart';
// import 'package:http/http.dart' as http;
// import '../constants.dart' as Constants;
// import 'dart:convert' show jsonEncode, jsonDecode;
// import 'package:shared_preferences/shared_preferences.dart';

class PantallaPrincipal extends StatefulWidget {
  PantallaPrincipal({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaPrincipalState createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        padding: EdgeInsets.only(top: 30, right: 0, bottom: 40, left: 0),
        // height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text( 'aquí va la búsqueda de tiendas' ),
            ),
          ],
        ),
      ),
    );
  }
}