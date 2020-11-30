import 'package:flutter/material.dart';
import '../clases/restaurante.dart';
import '../utils.dart';
import '../bloc/itemCarritoBloc.dart';
import '../constants.dart' as Constants;
import '../navigationService.dart';

class PantallaMenuRestaurante extends StatefulWidget {
  PantallaMenuRestaurante(this._restaurante, {Key key, this.title}) : super(key: key);

  final String title;
  final Restaurante _restaurante;

  @override
  PantallaMenuRestauranteState createState() => PantallaMenuRestauranteState(_restaurante);
}

class PantallaMenuRestauranteState extends State<PantallaMenuRestaurante> {
  final Restaurante _restaurante;

  PantallaMenuRestauranteState(this._restaurante);

  @override
  void initState() {
    consultarMenuRestaurante(_restaurante.idRestaurante);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: <Widget>[
                    Image.asset('assets/images/default_banner.png', width: double.infinity),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(175, 255, 255, 255),
                      ),
                      child: Text(
                          _restaurante.nombreRestaurante,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white
                  ),
                  onPressed: () {
                    navigationService.tabBusquedaNavigatorKey.currentState.pop();
                  },
                  padding: EdgeInsets.symmetric(vertical: 18),
                ),
              ]
          ),
          StreamBuilder(
              initialData: bloc.allItems,
              stream: bloc.getStream,
              builder: (context, AsyncSnapshot snapshot) {
                List<Widget> categoriasWidgets = List<Widget>();

                for (Map categoria in snapshot.data['categorias']) {
                  categoriasWidgets.add(
                    GestureDetector(
                      child: Container(
                          child: Text(
                              categoria['nombre'],
                              style: TextStyle(
                                color: snapshot.data['categoriaEnPantalla'] == categoria['id'] ? Colors.white : Colors.black54,
                              )
                          ),
                          margin: EdgeInsets.only(right: 15),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              border: Border.all(color: Color.fromARGB(255, 134, 5, 65), width: 2),
                              color: snapshot.data['categoriaEnPantalla'] == categoria['id'] ? Color.fromARGB(255, 134, 5, 65) : Colors.white
                          )
                      ),
                      onTap: () {
                        bloc.setCategoriaEnPantalla(categoria['id']);
                      },
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Menú',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      padding: EdgeInsets.only(top: 20, right: 15, bottom: 20, left: 15),
                    ),
                    Container(
                      height: 62.5,
                      padding: EdgeInsets.only(right: 5, bottom: 20, left: 5),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 134, 5, 65),
                          ),
                        ),
                      ),
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: categoriasWidgets
                      ),
                    ),
                  ],
                );
              }
          ),
          StreamBuilder(
              initialData: bloc.allItems,
              stream: bloc.getStream,
              builder: (context, AsyncSnapshot snapshot) {
                List<Widget> productosWidgets = List<Widget>();

                if (snapshot.data['categoriaEnPantalla'] != Null) {
                  for (Map producto in snapshot.data['productos'][snapshot.data['categoriaEnPantalla']]) {

                    List<Widget> botones = [
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Color.fromARGB(255, 134, 5, 65),
                          ),
                          child: Icon(
                              Icons.add,
                              color: Colors.white
                          ),
                        ),
                        onTap: (){
                          bloc.anadirAlCarrito(producto);
                          bloc.setCostoEnvio(_restaurante.costoEnvio);
                          bloc.setRestauranteCarrito(_restaurante.nombreRestaurante);
                        },
                      ),
                    ];
                    bool productoEnCarrito = snapshot.data['items_carrito'].containsKey(producto['id']);
                    if (productoEnCarrito) {
                      botones.add(
                          GestureDetector(
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Color.fromARGB(255, 134, 5, 65),
                              ),
                              child: Icon(
                                  Icons.remove,
                                  color: Colors.white
                              ),
                            ),
                            onTap: (){
                              bloc.quitarDelCarrito(producto);
                            },
                          )
                      );
                    }

                    productosWidgets.add(
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 134, 5, 65),
                              ),
                            )
                        ),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        padding: EdgeInsets.only(top:15, right: 5, left: 5, bottom: 15),
                        child: Row(
                            children: <Widget>[
                              Container(
                                child: Image.network(
                                  Constants.MEDIA_ROOT + producto['imagen'],
                                  width: 100,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        producto['nombre'],
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '\$' + producto['precio'],
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: botones,
                                              ),
                                            ),
                                            // productoEnCarrito ? Text ('coso') : null
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                    );
                  }
                }

                return Column(
                  children: productosWidgets,
                );
              }
          ),
        ],
      ),
    );
  }
}