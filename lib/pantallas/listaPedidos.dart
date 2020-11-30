import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import '../bloc/itemCarritoBloc.dart';
import '../bloc/pedidoSeguimientoBloc.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class PantallaListaPedido extends StatefulWidget {
  PantallaListaPedido({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaListaPedidoState createState() => PantallaListaPedidoState();
}

class PantallaListaPedidoState extends State<PantallaListaPedido> {

  Widget _tituloPedidoPendiente() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
      child: Text(
        'Seguimiento del pedido',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tituloListaPedidos() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
      child: Text(
        'Tus pedidos',
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: pedidoSeguimientoBloc.pedidoData,
      stream: pedidoSeguimientoBloc.getStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data['ordenId'] != null) {
          List<Widget> carritoItems = List<Widget>();
          for (Map producto in snapshot.data['productos']) {
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
                    /*Text(
                      '\$' + producto['precio'],
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),*/
                  ],
                ),
              ),
            );
          }

          return ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _tituloPedidoPendiente(),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.only(right: 20, left: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Detalles del pedido',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        _linea()
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20, left: 20),
                      child: Column(
                        children: carritoItems,
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }

        return ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _tituloListaPedidos()
              ],
            ),
          ],
        );
      }
    );
  }
}