import 'package:flutter/material.dart';
import 'screens/initialScreen.dart';
import 'screens/pantallaPrincipal.dart';
// import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class MyAppState extends State<MyApp> {
  String _rutaInicial;

  MyAppState(String ruta) {
    _rutaInicial = ruta;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Made Future X',
        ),
        // home: InitialScreen(),
        initialRoute: _rutaInicial,
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => PantallaPrincipal(),
          '/pantallaInicial': (BuildContext context) => InitialScreen(),
        }
    );
  }
}