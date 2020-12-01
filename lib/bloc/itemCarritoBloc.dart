import 'dart:async';
import 'geoLocBloc.dart';

class ItemsCarritoBloc {
  final carritoStreamController = StreamController.broadcast();

  Stream get getStream => carritoStreamController.stream;

  final Map allItems = {
    'categorias': [],
    'productos': {},
    'items_carrito': {},
    'subtotal_carrito': 0,
    'costoEnvio': 0,
    'categoriaEnPantalla': Null,
    'restauranteOrden': Null,
    'nombreRestauranteCarrito': '',
    'tipoEntrega': 'IN',
    'fechaPedidoProgramado': null,
    'ordenId': null,
    'telefono': '',
    'denominacion': ''
  };

  void resetRestaurante() {
    allItems['categorias'] = [];
    allItems['productos'] = {};
    allItems['categoriaEnPantalla'] = Null;
  }

  /*void setRestauranteOrden(int restauranteId) {
    allItems['restauranteOrden'] = restauranteId;
    carritoStreamController.sink.add(allItems);
  }*/

  void anadirCategoria(categoria) {
    allItems['categorias'].add(categoria);
    allItems['productos'][categoria['id']] = [];
    if (allItems['categorias'].length == 1) {
      allItems['categoriaEnPantalla'] = categoria['id'];
    }
    carritoStreamController.sink.add(allItems);
  }

  void anadirProductoRestaurante(producto) {
    allItems['productos'][producto['categoria']].add(producto);
    carritoStreamController.sink.add(allItems);
  }

  void setCategoriaEnPantalla(int categoria_id) {
    allItems['categoriaEnPantalla'] = categoria_id;
    carritoStreamController.sink.add(allItems);
  }

  void anadirAlCarrito(producto) {
    if (producto['comercio'] != allItems['restauranteOrden']) {
      allItems['items_carrito'].clear();
    }

    allItems['restauranteOrden'] = producto['comercio'];
    if (allItems['items_carrito'].containsKey(producto['id'])) {
      allItems['items_carrito'][producto['id']]['cantidad']++;
    } else {
      allItems['items_carrito'][producto['id']] = producto;
      allItems['items_carrito'][producto['id']]['cantidad'] = 1;
    }
    actualizarSubtotalCarrito();
    carritoStreamController.sink.add(allItems);
  }

  void quitarDelCarrito(producto) {
    if (allItems['items_carrito'].containsKey(producto['id'])) {
      if (allItems['items_carrito'][producto['id']]['cantidad'] > 1) {
        allItems['items_carrito'][producto['id']]['cantidad']--;
      } else {
        allItems['items_carrito'].remove(producto['id']);
      }
    }
    actualizarSubtotalCarrito();
    carritoStreamController.sink.add(allItems);
  }

  int contarProductosCarrito() {
    if (allItems['items_carrito'].isEmpty) {
      return 0;
    } else {
      int cantidad = 0;
      allItems['items_carrito'].forEach((id, producto) => cantidad += producto['cantidad']);
      return cantidad;
    }
  }

  void actualizarSubtotalCarrito() {
    double subtotal = 0;
    allItems['items_carrito'].forEach((id, producto) => subtotal += (double.parse(producto['precio']) * producto['cantidad']));
    allItems['subtotal_carrito'] = subtotal;
  }

  void setRestauranteCarrito(String nombreRestauranteCarrito) {
    allItems['nombreRestauranteCarrito'] = nombreRestauranteCarrito;
    carritoStreamController.sink.add(allItems);
  }

  void setFechaPedidoProgramado(fecha) {
    allItems['fechaPedidoProgramado'] = fecha;
    carritoStreamController.sink.add(allItems);
  }

  void setCostoEnvio(costoEnvio) {
    allItems['costoEnvio'] = costoEnvio;
    carritoStreamController.sink.add(allItems);
  }

  void setOrdenId(ordenId) {
    allItems['ordenId'] = ordenId;
    carritoStreamController.sink.add(allItems);
  }

  void setTipoEntrega(String tipoEntrega) {
    allItems['tipoEntrega'] = tipoEntrega;
    carritoStreamController.sink.add(allItems);
  }

  void setTelefono(String telefono) {
    allItems['telefono'] = telefono;
    carritoStreamController.sink.add(allItems);
  }

  void setDenominacionBillete(String denominacion) {
    allItems['denominacion'] = denominacion;
    carritoStreamController.sink.add(allItems);
  }

  Map generarDataPedido() {
    Map data = {};
    // Guardamos los productos
    data['productos'] = [];
    allItems['items_carrito'].forEach((id, producto){
      Map dataProducto = {};
      dataProducto['producto'] = id;
      dataProducto['cantidad'] = producto['cantidad'];
      dataProducto['descuento'] = 0.00;
      data['productos'].add(dataProducto);
    });

    // Guardamos el tipo de entrega
    data['tipo_entrega'] = allItems['tipoEntrega'];

    // Guardamos el numero de contacto
    data['telefono'] = allItems['telefono'];

    // Guardamos la denominacion del billete
    data['denominacion'] = allItems['denominacion'];

    // Guardamos la fecha de emisión de la orden
    data['fecha_emision'] = DateTime.now().toString();

    // Guardamos el subtotal, costo de envío y total de la orden
    data['subtotal'] = allItems['subtotal_carrito'];
    data['costo_envio'] = allItems['costoEnvio'];
    data['total'] = allItems['subtotal_carrito'] + allItems['costoEnvio'];

    // Guardamos las coordenadas
    data['latitud'] = geolocBloc.data['lat'].toString();
    data['longitud'] = geolocBloc.data['long'].toString();

    // Guardamos el ID del restaurante
    data['comercio'] = allItems['restauranteOrden'];

    return data;
  }

  void dispose() {
    carritoStreamController.close(); // close our StreamController
  }
}

final bloc = ItemsCarritoBloc();