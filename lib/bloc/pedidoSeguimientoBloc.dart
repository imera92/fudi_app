import 'dart:async';

class PedidoSeguimientoBloc {
  final pedidoSeguimientoStreamController = StreamController.broadcast();

  Stream get getStream => pedidoSeguimientoStreamController.stream;

  final Map pedidoData = {
    'ordenId': null,
    'generada': false,
    'preparando': false,
    'despachado': false,
    'entregado': false,
    'productos': [],
    'subtotal': 0,
    'costoEnvio': 0
  };

  void anadirProducto(producto) {
    pedidoData['productos'].add(producto);
    pedidoSeguimientoStreamController.sink.add(pedidoData);
  }

  void setOrdenId(ordenId) {
    pedidoData['ordenId'] = ordenId;
    pedidoSeguimientoStreamController.sink.add(pedidoData);
  }

  void setEstado(estado) {
    if (estado == 'EN') {
      pedidoData['generada'] = true;
    }
    if (estado == 'P') {
      pedidoData['preparando'] = true;
    }
    if (estado == 'E') {
      pedidoData['despachado'] = true;
    }
    if (estado == 'F') {
      pedidoData['entregado'] = true;
    }
    pedidoSeguimientoStreamController.sink.add(pedidoData);
  }

  void setSubtotal(subtotal) {
    pedidoData['subtotal'] = subtotal;
    pedidoSeguimientoStreamController.sink.add(pedidoData);
  }

  void setCostoEnvio(costoEnvio) {
    pedidoData['costoEnvio'] = costoEnvio;
    pedidoSeguimientoStreamController.sink.add(pedidoData);
  }

  void dispose() {
    pedidoSeguimientoStreamController.close(); // close our StreamController
  }
}

final pedidoSeguimientoBloc = PedidoSeguimientoBloc();