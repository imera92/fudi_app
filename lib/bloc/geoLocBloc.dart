import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class GeolocBloc {
  final geolocStreamController = StreamController.broadcast();

  Stream get getStream => geolocStreamController.stream;

  SharedPreferences prefs;

  final Map data = {
    'nombre': '',
    'ref': '',
    'lat': null,
    'long': null,
  };

  GeolocBloc() {
    SharedPreferences.getInstance().then((instance) {
      prefs = instance;
      if (instance.getString('lat') == null || instance.getString('long') == null) {
        this.setPosicionActual();
      } else {
        data['lat'] = instance.getDouble('lat');
        data['long'] = instance.getDouble('long');
        geolocStreamController.sink.add(data);
      }
    });
  }

  void setPosicionActual() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    data['lat'] = position.latitude;
    data['long'] = position.longitude;
    geolocStreamController.sink.add(data);
  }

  void guardarUbicacion(String nombre, String referencia, double lat, double long) {
    prefs.setString('nombre', nombre);
    prefs.setString('ref', referencia);
    prefs.setDouble('lat', lat);
    prefs.setDouble('long', long);

    data['nombre'] = nombre;
    data['ref'] = referencia;
    data['lat'] = lat;
    data['long'] = long;
    geolocStreamController.sink.add(data);
  }
}

final geolocBloc = GeolocBloc();