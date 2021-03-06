import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as Constants;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
import './bloc/itemCarritoBloc.dart';
// import './bloc/buscadorBloc.dart';
import './bloc/pedidoSeguimientoBloc.dart';

void verificarTokens(String access_token, String refresh_token, SharedPreferences prefs) async {
  bool acces_token_is_valid = true;
  bool refresh_succesful = true;
  http.Response verify_response;
  Map<String, dynamic> verify_data;
  http.Response refresh_response;
  Map<String, dynamic> refresh_data;
  http.Response relogin_response;
  Map<String, dynamic> relogin_data;

  // Primero verificamos si el token de acceso aún es válido
  verify_response = await http.post(
    Constants.API_URL_TOKEN_VERIFY,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'token': access_token,
    }),
  );

  if (verify_response.statusCode != 200) {
    acces_token_is_valid = false;
    verify_data = jsonDecode(verify_response.body);
  }

  // Si el token de acceso no es válido, intentamos hacer un refresco de los tokens
  if (!acces_token_is_valid) {
    if (verify_data.containsKey('code') && verify_data['code'] == 'token_not_valid') {
      refresh_response = await http.post(
        Constants.API_URL_TOKEN_REFRESH,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'refresh': refresh_token,
        }),
      );

      refresh_data = jsonDecode(refresh_response.body);
      if (refresh_response.statusCode == 200) {
        await prefs.setString('token_access', refresh_data['access']);
        await prefs.setString('token_refresh', refresh_data['refresh']);
      } else {
        refresh_succesful = false;
      }
    }
  }

  // Si no se puede hacer el refresco porque el refresh token ya expiró, pedimos nuevos tokens y los guardamos
  if (!refresh_succesful) {
    if (refresh_data.containsKey('code') && refresh_data['code'] == 'token_not_valid') {
      String username = prefs.getString('username');
      String password = prefs.getString('password');

      relogin_response = await http.post(
        Constants.API_URL_LOGIN,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password
        }),
      );

      if (relogin_response.statusCode == 200) {
        relogin_data = jsonDecode(relogin_response.body);
        await prefs.setString('token_access', relogin_data['access']);
        await prefs.setString('token_refresh', relogin_data['refresh']);
      }
    }
  }
}

void consultarMenuRestaurante(int restauranteId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String access_token = prefs.getString('token_access');
  String refresh_token = prefs.getString('token_refresh');

  await verificarTokens(access_token, refresh_token, prefs);
  access_token = prefs.getString('token_access');

  http.Response response = await http.get(
      Constants.API_URL_GET_MENU_RESTAURANTE + restauranteId.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + access_token,
      }
  );

  if (response.statusCode == 200) {
    bloc.resetRestaurante();
    Map data = jsonDecode(response.body);
    for (Map categoria in data['categorias']) {
      bloc.anadirCategoria(categoria);
    }
    for (Map producto in data['productos']) {
      bloc.anadirProductoRestaurante(producto);
    }
  }
}

void crearOrden(Map ordenData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String access_token = prefs.getString('token_access');
  String refresh_token = prefs.getString('token_refresh');

  await verificarTokens(access_token, refresh_token, prefs);
  access_token = prefs.getString('token_access');

  http.Response response = await http.post(
    Constants.API_URL_POST_ORDEN,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + access_token,
    },
    body: jsonEncode(ordenData)
  );

  if (response.statusCode == 200) {
    Map data = jsonDecode(response.body);
    debugPrint(data['orden_id'].toString());
    bloc.setOrdenId(data['orden_id']);
  }
}

void consultarOrdenPendiente() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String access_token = prefs.getString('token_access');
  String refresh_token = prefs.getString('token_refresh');

  await verificarTokens(access_token, refresh_token, prefs);
  access_token = prefs.getString('token_access');

  http.Response response = await http.get(
    Constants.API_URL_GET_ORDEN_PENDIENTE,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + access_token,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    pedidoSeguimientoBloc.setOrdenId(data['orden_id']);
    pedidoSeguimientoBloc.setEstado(data['estado']);
    pedidoSeguimientoBloc.setSubtotal(data['subtotal']);
    pedidoSeguimientoBloc.setCostoEnvio(data['costo_envio']);
    for (Map producto in data['productos']) {
      pedidoSeguimientoBloc.anadirProducto(producto);
    }
  }
}