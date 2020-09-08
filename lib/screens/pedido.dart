import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import '../bloc/itemCarritoBloc.dart';

class PantallaPedido extends StatefulWidget {
  PantallaPedido({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaPedidoState createState() => PantallaPedidoState();
}

class PantallaPedidoState extends State<PantallaPedido> {
  final _telefonoController = TextEditingController();
  final _pagoController = TextEditingController();

  Widget _titulo() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
      child: Text(
        'Tu pedido',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _linea() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10),
        height: 1.0,
        color: Color.fromARGB(255, 219, 29, 45),
      ),
    );
  }

  OutlineInputBorder commonFieldBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color.fromARGB(255, 134, 5, 65), width: 2.0),
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
  );

  Widget _inputTelefono() {
    return Container(
      child: TextField(
        controller: _telefonoController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldBorder,
          labelText: '¿Número de teléfono?',
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _titulo()
            ],
          ),
          StreamBuilder(
            initialData: bloc.allItems,
            stream: bloc.getStream,
            builder: (context, AsyncSnapshot snapshot) {

              List<Widget> carritoItems = List<Widget>();
              snapshot.data['items_carrito'].forEach((id, producto){
                carritoItems.add(
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          producto['cantidad'].toString() + 'x ' + producto['nombre'],
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$' + producto['precio'],
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });

              return Container(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          snapshot.data['nombreRestauranteCarrito'],
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        _linea()
                      ],
                    ),
                  ] + carritoItems,
                ),
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.only(right: 20, left: 20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Detalles de la entrega',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    _linea()
                  ],
                ),
                _inputTelefono()
              ],
            ),
          )
        ],
      )
    );
  }
}