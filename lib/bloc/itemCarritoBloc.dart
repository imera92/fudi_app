import 'dart:async';

class ItemsCarritoBloc {
  final carritoStreamController = StreamController.broadcast();

  Stream get getStream => carritoStreamController.stream;

  final Map allItems = {
    'categorias': [],
    'productos': {},
    'items_carrito': {},
    'subtotal_carrito': 0,
    'categoriaEnPantalla': Null,
    'restauranteEnPantalla': Null,
    'nombreRestauranteCarrito': '',
  };

  void resetRestaurante() {
    allItems['categorias'] = [];
    allItems['productos'] = {};
    allItems['categoriaEnPantalla'] = Null;
    allItems['restauranteEnPantalla'] = Null;
  }

  void setRestauranteEnPantalla(int restauranteId) {
    allItems['restauranteEnPantalla'] = restauranteId;
    carritoStreamController.sink.add(allItems);
  }

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
    allItems['items_carrito'].forEach((id, producto) {
      if (producto['comercio'] != allItems['restauranteEnPantalla']) {
        allItems['items_carrito'].remove(id);
      }
    });

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

  void setearRestauranteCarrito(String nombreRestauranteCarrito) {
    allItems['nombreRestauranteCarrito'] = nombreRestauranteCarrito;
    carritoStreamController.sink.add(allItems);
  }

  void dispose() {
    carritoStreamController.close(); // close our StreamController
  }
}

final bloc = ItemsCarritoBloc();