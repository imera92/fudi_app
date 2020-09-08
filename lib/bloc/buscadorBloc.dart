import 'dart:async';

class BuscadorBloc {
  final buscadorStreamController = StreamController.broadcast();

  Stream get getStream => buscadorStreamController.stream;

  final Map buscadorData = {
    'categorias': [],
    'restaurantes': [],
  };

  void anadirCategoria(categoria) {
    buscadorData['categorias'].add(categoria);
    buscadorStreamController.sink.add(buscadorData);
  }

  void anadirRestaurante(restaurante) {
    buscadorData['restaurantes'].add(restaurante);
    buscadorStreamController.sink.add(buscadorData);
  }

  void resetRestaurantes() {
    buscadorData['restaurantes'] = [];
    buscadorStreamController.sink.add(buscadorData);
  }

  void dispose() {
    buscadorStreamController.close(); // close our StreamController
  }
}

final buscadorBloc = BuscadorBloc();