import 'package:flutter/material.dart';
import 'pantallas/initialScreen.dart';
import 'pantallas/pantallaPrincipal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './navigationService.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String rutaInicial = '';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  bool authentication = await prefs.getBool('is_authenticated') ?? false;
  rutaInicial = authentication ? '/' : '/pantallaInicial';

  runApp(MyApp(rutaInicial));
}

class MyApp extends StatefulWidget {
  final String rutaInicial;

  MyApp(this.rutaInicial);

  @override
  MyAppState createState() => MyAppState(this.rutaInicial);
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _rutaInicial;

  MyAppState(String ruta) {
    _rutaInicial = ruta;
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 0) {
      consultarOrdenPendiente();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Made Future X',
        primaryColor: Color.fromARGB(255, 219, 29, 45),
      ),
      // home: InitialScreen(),
      initialRoute: _rutaInicial,
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => PantallaPrincipal(),
        '/pantallaInicial': (BuildContext context) => InitialScreen(),
      },
      navigatorKey: navigationService.pantallaPrincipalNavigatorKey,
    );
  }
}