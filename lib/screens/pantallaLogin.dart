import 'package:flutter/material.dart';

class PantallaLogin extends StatefulWidget {
  PantallaLogin({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaLoginState createState() => PantallaLoginState();
}

class PantallaLoginState extends State<PantallaLogin> {
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
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Correo electrónico',
        )
      ),
    );
  }

  Widget _inputPassword() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: TextField(
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          labelText: 'Contraseña',
        ),
        obscureText: true,
      ),
    );
  }

  Widget _btnLogin() {
    return InkWell(
      onTap: () {
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => PantallaLogin())
        );*/
        return null;
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
                      _inputPassword(),
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