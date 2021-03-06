import 'package:flutter/material.dart';

OutlineInputBorder commonFieldBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
);

OutlineInputBorder commonFieldFocusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color.fromARGB(255, 134, 5, 65), width: 2.0),
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
);

class BusquedaField extends StatefulWidget {
  final _busquedaController;
  final Function _callback;
  final Function _callbackBoton;

  const BusquedaField(this._busquedaController, this._callback, this._callbackBoton);

  @override
  BusquedaFieldState createState() => BusquedaFieldState(_busquedaController, _callback, _callbackBoton);
}

class BusquedaFieldState extends State<BusquedaField> {
  final _busquedaController;
  final _callback;
  final _callbackBoton;
  bool _ocultarBoton = true;

  BusquedaFieldState(this._busquedaController, this._callback, this._callbackBoton);

  Widget _field() {
    return Expanded(
      child: TextField(
        textInputAction: TextInputAction.search,
        controller: _busquedaController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldFocusedBorder,
          hintText: '¿Qué deseas comer?',
        ),
        onChanged: (text) {
          if (text == '') {
            setState(() {
              _ocultarBoton = true;
            });
          } else if (text != '' && _ocultarBoton) {
            setState(() {
              _ocultarBoton = false;
            });
          }
        },
        onSubmitted: (value) {
          _callback(value);
        },
      ),
    );
  }

  Widget _boton() {
    return IconButton(
      icon: Icon(
          Icons.clear,
          color: Color.fromARGB(255, 219, 29, 45)
      ),
      onPressed: () {
        _busquedaController.clear();
        _callbackBoton();
        setState(() {
          _ocultarBoton = true;
        });
      },
      padding: EdgeInsets.symmetric(vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = <Widget>[_field()];
    if (!_ocultarBoton) {
      rowChildren.insert(0, _boton());
    }

    return Container(
        padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
        child: Row(
          children: rowChildren,
        )
    );
  }
}