import 'dart:async';

class ItemsCarritoBloc {
  final carritoStreamController = StreamController.broadcast();

  Stream get getStream => carritoStreamController.stream;

  final Map allItems = {
    'categorias': [],
    'productos': {},
    'items_carrito': {},
    'categoriaEnPantalla': Null
  };

  /*void reset() {
    allItems['categorias'] = [];
    allItems['productos'] = {};
    allItems['items_carrito'] = [];
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
    if (allItems['items_carrito'].containsKey(producto['id'])) {
      allItems['items_carrito'][producto['id']]['cantidad']++;
    } else {
      allItems['items_carrito'][producto['id']] = producto;
      allItems['items_carrito'][producto['id']]['cantidad'] = 1;
    }
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
    carritoStreamController.sink.add(allItems);
  }

  void removeFromCart(item) {
    allItems['cart items'].remove(item);
    allItems['shop items'].add(item);
    carritoStreamController.sink.add(allItems);
  }

  void dispose() {
    carritoStreamController.close(); // close our StreamController
  }
}

final bloc = ItemsCarritoBloc();