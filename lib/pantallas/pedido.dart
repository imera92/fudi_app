import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import '../bloc/itemCarritoBloc.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

class PantallaPedido extends StatefulWidget {
  PantallaPedido({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaPedidoState createState() => PantallaPedidoState();
}

class PantallaPedidoState extends State<PantallaPedido> {
  final _telefonoController = TextEditingController();
  final _pagoEfectivoController = TextEditingController();
  // String _tipoEntregaDropdownDefault = 'IN';

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
    borderSide: const BorderSide(color: Color.fromARGB(255, 219, 29, 45)),
    borderRadius: const BorderRadius.all(const Radius.circular(10.0))
  );

  Widget _dropdownTipoEntrega() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Color.fromARGB(255, 219, 29, 45),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                // value: _tipoEntregaDropdownDefault,
                value: bloc.allItems['tipoEntrega'],
                items: [
                  DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.directions_bike),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text('Entrega inmediata'),
                        ),
                      ],
                    ),
                    value: 'IN',
                  ),
                  DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text('Agendar pedido'),
                        ),
                      ],
                    ),
                    value: 'AG',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    bloc.setTipoEntrega(value);
                  });
                }
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _botonProgramarPedido() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.only(top: 17.5, right: 10, bottom: 17.5, left: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 219, 29, 45),
          ),
          borderRadius: BorderRadius.all(Radius.circular(10.0))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder(
              initialData: bloc.allItems,
              stream: bloc.getStream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data['fechaPedidoProgramado'] != null) {
                  DateFormat formatoFecha = DateFormat('yyyy-MM-dd');
                  DateFormat formatoHora = DateFormat('H:mm');
                  String texto = 'Programada para '
                                 + formatoFecha.format(snapshot.data['fechaPedidoProgramado'])
                                 + ' a las ' + formatoHora.format(snapshot.data['fechaPedidoProgramado']);
                  return Text(texto);
                } else {
                  return Text('Programar pedido');
                }
              }
            ),
            Icon(Icons.arrow_forward)
          ],
        ),
      ),
      onTap: () {
        DateTime fechaInicio = DateTime.now();
        DateTime fechaFin = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day + 5);

        /*DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          minTime: fechaInicio,
          maxTime: fechaFin,
          onChanged: (date) {
            print('change $date');
          },
          onConfirm: (date) {
            bloc.setFechaPedidoProgramado(date);
          },
          // onCancel: ,
          currentTime: bloc.allItems['fechaPedidoProgramado'],
          locale: LocaleType.es
        );*/
      },
    );
  }

  Widget _inputTelefono() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _telefonoController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldBorder,
          hintText: '¿Número de teléfono?',
          prefixIcon: Icon(Icons.local_phone),
        ),
        onChanged: (text) {
          bloc.setTelefono(text);
        }
      ),
    );
  }

  Widget _inputPagoEfectivo() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: _pagoEfectivoController,
        decoration: InputDecoration(
          border: commonFieldBorder,
          focusedBorder: commonFieldBorder,
          hintText: 'Especifique el billete que usará para pagar',
          prefixIcon: Icon(Icons.attach_money),
        ),
        onChanged: (text) {
          bloc.setDenominacionBillete(text);
        }
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
                SizedBox(
                  height: 10,
                ),
                // _botonProgramarPedido(),
                _dropdownTipoEntrega(),
                _inputTelefono(),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Método de pago: Efectivo',
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
                _inputPagoEfectivo(),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          StreamBuilder(
            initialData: bloc.allItems,
            stream: bloc.getStream,
            builder: (context, AsyncSnapshot snapshot) {

              List<Widget> detalles = List<Widget>();
              detalles.add(
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Pedido',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$' + snapshot.data['subtotal_carrito'].toString(),
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              detalles.add(
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Envío',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$' + snapshot.data['costoEnvio'].toString(),
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              detalles.add(
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$' + (snapshot.data['subtotal_carrito'] + snapshot.data['costoEnvio']).toString(),
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              return Container(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Resumen de Compra',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        _linea()
                      ],
                    ),
                  ] + detalles,
                ),
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.only(top: 15, right: 50, bottom: 15, left: 50),
                  onPressed: () {
                    crearOrden(bloc.generarDataPedido());
                  },
                  color: Color.fromARGB(255, 134, 5, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'CONFIRMAR PEDIDO',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}