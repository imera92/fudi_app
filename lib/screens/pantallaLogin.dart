import 'package:flutter/material.dart';
import '../widgets/passwordField.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'initialScreen.dart';

class PantallaLogin extends StatefulWidget {
  PantallaLogin({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaLoginState createState() => PantallaLoginState();
}

class PantallaLoginState extends State<PantallaLogin> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  Widget _btnRegresar() {
    return FlatButton(
      color: Colors.white,
      splashColor: Colors.transparent,
      onPressed: () {
        Navigator.pop(context);
      },
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 219, 29, 45))
    );
  }

  OutlineInputBorder commonFieldBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
  );

  OutlineInputBorder commonFieldFocusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color.fromARGB(255, 134, 5, 65), width: 2.0),
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
  );

  Widget _inputUsuario() {
    return Container(
      child: TextField(
        controller: _usuarioController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Usuario o Correo electrónico',
        )
      ),
    );
  }

  Widget _btnLogin() {
    return InkWell(
      onTap: () {
        _login();
      },
      child: Container(
        margin: EdgeInsets.only(top: 15),
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          border: Border.all(color: Color.fromARGB(255, 134, 5, 65), width: 2),
          color: Color.fromARGB(255, 134, 5, 65)
        ),
        child: Text(
          'INICIAR SESIÓN',
          style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      // margin: EdgeInsets.only(top: 40, bottom: 20),
      child: Text(
        'Inicio de sesión',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _login() {
    String usuario = _usuarioController.text;
    String password = _passwordController.text;
    String mensajeError = 'Lo sentimos, no puedes iniciar sesión en este momento. Vuelve a intentarlo más tarde.';

    http.post(
      Constants.API_URL_LOGIN,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': usuario,
        'password': password
      }),
    ).then((response) async {
      if(response.statusCode == 200){
        Map<String, dynamic> tokens = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token_access', tokens['access']);
        await prefs.setString('token_refresh', tokens['refresh']);
        await prefs.setBool('is_authenticated', true);
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      } else {
        if(jsonDecode(response.body)['error'] == 'userExists'){
          mensajeError = 'Lo sentimos, el usuario/contraseña no son válidos.';
        }
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
    }).catchError((error){
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
    });
  }

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
            Row(
                children: <Widget>[
                  _btnRegresar(),
                  _title()
                ]
            ),
            /*SizedBox(
              height: 40,
            ),*/
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _inputUsuario(),
                      PasswordField(_passwordController),
                      _btnLogin()
                    ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}