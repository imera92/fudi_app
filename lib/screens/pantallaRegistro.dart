import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:oktoast/oktoast.dart';

class PantallaRegistro extends StatefulWidget {
  PantallaRegistro({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaRegistroState createState() => PantallaRegistroState();
}

class PantallaRegistroState extends State<PantallaRegistro> {

  final _nombreController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _correoController = TextEditingController();
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

  Widget _inputNombre() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _nombreController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Nombre completo',
        )
      )
    );
  }

  Widget _inputUsuario() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _usuarioController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Usuario',
        )
      ),
    );
  }

  Widget _inputCorreo() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _correoController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Correo electrónico',
        )
      ),
    );
  }

  Widget _btnCrear() {
    return InkWell(
      onTap: () {
        _registrarUsuario();
      },
      child: Container(
        margin: EdgeInsets.only(top: 30),
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
          'CREAR CUENTA',
          style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
        // margin: EdgeInsets.only(top: 40, bottom: 20),
        child: Text(
          'Registro',
          style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 17, fontWeight: FontWeight.bold),
        ),
    );
  }

  void _registrarUsuario() {
    String nombre  = _nombreController.text;
    String usuario = _usuarioController.text;
    String correo = _correoController.text;
    String password = _passwordController.text;
    String mensajeError = 'Lo sentimos, no podemos registrar tu cuenta en este momento. Vuelve a intentarlo más tarde.';

    http.post(
      'http://192.168.100.118:8000/api/movil/registrar_usuario/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nombre': nombre,
        'usuario': usuario,
        'correo': correo,
        'password': password
      }),
    ).then((response) {
      if(response.statusCode == 200){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text('¡Felicidades! Tu cuenta fue creada con éxito.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Continuar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                  ),
                ]
            );
          }
        );
      } else {
        if(jsonDecode(response.body)['error'] == 'userExists'){
          mensajeError = 'Lo sentimos, el usuario que intenta registrar ya existe.';
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _inputNombre(),
                    _inputUsuario(),
                    _inputCorreo(),
                    PasswordField(_passwordController),
                    // _inputPassword(),
                    // _inputConfirmarPassword(),
                    _btnCrear()
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

class PasswordField extends StatefulWidget {
  final _passwordController;

  const PasswordField(this._passwordController);

  @override
  PasswordFieldState createState() => PasswordFieldState(_passwordController);
}

class PasswordFieldState extends State<PasswordField> {
  final _passwordController;
  bool _ocultarPassword = true;
  Color _iconButtonColor = Colors.black38;

  PasswordFieldState(this._passwordController);

  void _toggle() {
    setState(() {
      _ocultarPassword = !_ocultarPassword;
      if(_ocultarPassword) {
        _iconButtonColor = Colors.black38;
      } else {
        _iconButtonColor = Color.fromARGB(255, 134, 5, 65);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        children: <Widget>[
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(const Radius.circular(10.0))
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 134, 5, 65), width: 2.0),
                  borderRadius: const BorderRadius.all(const Radius.circular(10.0))
              ),
              labelText: 'Contraseña',
            ),
            obscureText: _ocultarPassword,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: _iconButtonColor),
                onPressed: () {
                  _toggle();
                },
                padding: EdgeInsets.symmetric(vertical: 18),
              )
            ],
          ),
        ],
      ),
    );
  }
}