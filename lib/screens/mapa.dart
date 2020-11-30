import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../navigationService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/geoLocBloc.dart';

class PantallaMapa extends StatefulWidget {
  PantallaMapa({Key key, this.title, this.posicionActual}) : super(key: key);

  final String title;
  final LatLng posicionActual;

  @override
  PantallaMapaState createState() => PantallaMapaState(posicionActual);
}

class PantallaMapaState extends State<PantallaMapa> {
  GoogleMapController _mapController;
  LatLng _center;
  LatLng _lastMapPosition;
  final double _zoom = 15.5;
  final _referenciaController = TextEditingController();
  final _nombreController = TextEditingController();

  PantallaMapaState (LatLng posicionActual) {
    _center = LatLng(posicionActual.latitude, posicionActual.longitude);
    _lastMapPosition = LatLng(posicionActual.latitude, posicionActual.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastMapPosition = position.target;
    });
  }

  Widget _titulo() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Ingresar nueva dirección',
        style: TextStyle(color: Color.fromARGB(255, 134, 5, 65), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _nombreInput() {
    return Container(
      child: TextField(
        controller: _nombreController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 10),
          enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Color.fromARGB(255, 219, 29, 45), width: 2.0)
          ),
          hintText: 'Nombre',
        )
      ),
    );
  }

  Widget _referenciaInput() {
    return Container(
      child: TextField(
        controller: _referenciaController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 10),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 219, 29, 45), width: 2.0)
          ),
          hintText: 'Piso, departamento o alguna caraterística',
        )
      ),
    );
  }

  Widget _guardarBtn() {
    return InkWell(
      onTap: () {
        geolocBloc.guardarUbicacion(_nombreController.text, _referenciaController.text, _lastMapPosition.latitude, _lastMapPosition.longitude);
        Navigator.of(context).popUntil((route) => route.isFirst);
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
          'GUARDAR DIRECCIÓN',
          style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren = <Widget>[
      Container(
        padding: EdgeInsets.only(left: 30, right: 40),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: Color.fromARGB(255, 219, 29, 45)),
              onPressed: () {
                navigationService.pop(navigationService.pantallaPrincipalNavigatorKey);
              },
              padding: EdgeInsets.only(top: 20),
              constraints: BoxConstraints.tightFor(width: 23),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _titulo()
              ],
            ),
          ],
        ),
      ),
    ];


    listViewChildren.addAll([
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _zoom,
              ),
              // el ListView solo permite hacer ciertos gestos sobre el mapa, lo que impide que se pueda mover o hacer zoom sobre el mismo.
              //  por ello, necesitamos anadir estos gestureRecognizers, que van a permitir que los eventos disparados por los gestos sean
              //  despachados al widget del mapa.
              gestureRecognizers: < Factory < OneSequenceGestureRecognizer >> [
                new Factory < OneSequenceGestureRecognizer > (
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet()
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: () {
                    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
                      _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.gps_fixed, size: 36.0, color: Color.fromARGB(255, 134, 5, 65)),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: SvgPicture.asset(
                  'assets/icons/home.svg',
                  width: 55
                ),
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 30,
      ),
      Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: _nombreInput(),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: _referenciaInput(),
      ),
      SizedBox(
        height: 60,
      ),
      Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: _guardarBtn(),
      ),
    ]);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 40, bottom: 40),
        children: listViewChildren,
      )
    );
  }
}