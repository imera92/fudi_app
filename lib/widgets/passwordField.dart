import 'package:flutter/material.dart';

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