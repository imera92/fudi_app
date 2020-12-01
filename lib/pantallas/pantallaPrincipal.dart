import 'package:flutter/material.dart';
import '../bloc/itemCarritoBloc.dart';
import '../bloc/buscadorBloc.dart';
import './pedido.dart';
import './home.dart';
import './listaPedidos.dart';
import './tabBusqueda.dart';
import '../navigationService.dart';

class PantallaPrincipal extends StatefulWidget {
  PantallaPrincipal({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PantallaPrincipalState createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  int _currentIndex = 0;

  final _tabs = <Widget>[
    PantallaHome(),
    TabBusqueda(navigationService.tabBusquedaNavigatorKey),
    PantallaListaPedido(),
    PantallaPedido()
  ];

  @override
  void initState() {
    buscadorBloc.consultarCategorias();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: StreamBuilder(
        initialData: bloc.allItems,
        stream: bloc.getStream,
        builder: (context, AsyncSnapshot snapshot) {
          bool visible = !snapshot.data['items_carrito'].isEmpty;
          String textoBoton = '';

          if (visible) {
            textoBoton = 'PEDIR ' + bloc.contarProductosCarrito().toString() + ' POR \$' + snapshot.data['subtotal_carrito'].toString();
          }

          return Visibility(
            visible: visible && _currentIndex == 1,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 15, right: 50, bottom: 15, left: 50),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
              color: Color.fromARGB(255, 134, 5, 65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                textoBoton,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                )
              ),
            ),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: StreamBuilder(
        initialData: bloc.allItems,
        stream: bloc.getStream,
        builder: (context, AsyncSnapshot snapshot) {
          List<BottomNavigationBarItem> navigationItems = [
            BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.home),
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                title: Container(
                  child: Text('Inicio'),
                  padding: EdgeInsets.only(bottom: 5),
                )
            ),
            BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.search),
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                title: Container(
                  child: Text('Buscar'),
                  padding: EdgeInsets.only(bottom: 5),
                )
            ),
            BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.description),
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                title: Container(
                  child: Text('Pedidos'),
                  padding: EdgeInsets.only(bottom: 5),
                )
            ),
          ];

          if (!snapshot.data['items_carrito'].isEmpty) {
            navigationItems.add(
              BottomNavigationBarItem(
                  icon: Container(
                    child: Icon(Icons.shopping_cart),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  title: Container(
                    child: Text('Carrito'),
                    padding: EdgeInsets.only(bottom: 5),
                  )
              ),
            );
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color.fromARGB(255, 219, 29, 45),
            selectedFontSize: 12,
            items: navigationItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        }
      )
    );
  }
}