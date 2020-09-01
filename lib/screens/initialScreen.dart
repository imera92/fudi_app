import 'package:flutter/material.dart';
import 'pantallaRegistro.dart';
import 'pantallaLogin.dart';

class InitialScreen extends StatefulWidget {
  InitialScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  // int _counter = 0;

  /*void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }*/

  Widget _btnLogin() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PantallaLogin())
        );
        return null;
      },
      child: Container(
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

  Widget _btnRegistro() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PantallaRegistro())
        );
        return null;
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          border: Border.all(color: Color.fromARGB(255, 134, 5, 65), width: 2),
        ),
        child: Text(
          'REGISTRARSE',
          style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 134, 5, 65), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _btnContinuar() {
    return InkWell(
      onTap: () {
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage())
        );*/
        return null;
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
            border: Border.all(color: Color.fromARGB(255, 219, 29, 45), width: 2),
            color: Color.fromARGB(255, 219, 29, 45)
        ),
        child: Text(
          'BUSCAR RESTAURANTES',
          style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _label() {
    return Container(
        margin: EdgeInsets.only(top: 40, bottom: 20),
        child: Column(
          children: <Widget>[
            Text(
              '¿Qué se te antoja comer hoy?',
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/fudi_logo.png', width: 225),
              SizedBox(
                height: 60,
              ),
              _label(),
              SizedBox(
                height: 40,
              ),
              _btnRegistro(),
              SizedBox(
                height: 15,
              ),
              _btnLogin(),
              SizedBox(
                height: 15,
              ),
              _btnContinuar(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}