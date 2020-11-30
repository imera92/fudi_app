import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonEncode, jsonDecode;
import '../utils.dart';
import '../constants.dart' as Constants;
import 'geoLocBloc.dart';

class BuscadorBloc {
  final buscadorStreamController = StreamController.broadcast();

  Stream get getStream => buscadorStreamController.stream;

  final Map buscadorData = {
    'categorias': [],
    'restaurantes': [],
  };

  void resetRestaurantes() {
    buscadorData['restaurantes'] = [];
    buscadorStreamController.sink.add(buscadorData);
  }

  void consultarCategorias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('token_access');
    String refresh_token = prefs.getString('token_refresh');

    await verificarTokens(access_token, refresh_token, prefs);
    access_token = prefs.getString('token_access');

    http.Response response = await http.get(
      Constants.API_URL_GET_CATEGORIAS,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + access_token,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      for (Map categoria in data['categorias']) {
        buscadorData['categorias'].add(categoria);
      }
      buscadorStreamController.sink.add(buscadorData);
    }
  }

  void consultarRestaurantes({String categoria_busqueda = '', String termino_busqueda = ''}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('token_access');
    String refresh_token = prefs.getString('token_refresh');

    await verificarTokens(access_token, refresh_token, prefs);
    access_token = prefs.getString('token_access');

    Map<String, String> query_parameters = {
      'lat': geolocBloc.data['lat'].toString(),
      'long': geolocBloc.data['long'].toString(),
      'cat': categoria_busqueda,
      't': termino_busqueda
    };

    var uri = Uri.parse(Constants.API_URL_GET_RESTAURANTES);
    uri = uri.replace(queryParameters: query_parameters);
    http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + access_token,
        }
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      for (Map restaurante in data['restaurantes']) {
        buscadorData['restaurantes'].add(restaurante);
      }
      buscadorStreamController.sink.add(buscadorData);
    }
  }

  void dispose() {
    buscadorStreamController.close(); // close our StreamController
  }
}

final buscadorBloc = BuscadorBloc();